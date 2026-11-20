import { Component, computed, inject, signal } from '@angular/core';
import { CatalogService } from '../../../core/data/catalog.service';
import { CollectionService } from '../../../core/data/collection.service';
import {
  HybridKind,
  LockState,
  RarityCode,
  SpeciesProgress,
  lockState,
} from '../../../core/data/models';
import { problemMessage } from '../../../core/http/problem';
import { SpeciesChange, SpeciesRow, SpeciesTable } from '../ui/species-table/species-table';

type Status = '' | 'done' | 'progress' | 'todo' | 'nocost';
type Sort = 'rest' | 'progress' | 'name' | 'cost';
type LockFilter = LockState | '';
type KindFilter = HybridKind | '';

@Component({
  selector: 'app-species-page',
  imports: [SpeciesTable],
  templateUrl: './species-page.html',
  styleUrl: './species-page.scss',
})
export class SpeciesPage {
  private readonly collection = inject(CollectionService);
  protected readonly catalog = inject(CatalogService);

  protected readonly query = signal('');
  protected readonly rarity = signal<RarityCode | ''>('');
  protected readonly status = signal<Status>('');
  protected readonly lock = signal<LockFilter>('');
  protected readonly lockFilters: { value: LockFilter; label: string }[] = [
    { value: '', label: 'Tout déblocage' },
    { value: 'UNLOCKED', label: 'Débloquées' },
    { value: 'LOCKED_AMBER', label: 'Bloquées (ambre)' },
    { value: 'LOCKED', label: 'Bloquées (sans ambre)' },
  ];
  protected readonly kind = signal<KindFilter>('');
  protected readonly kindFilters: { value: KindFilter; label: string }[] = [
    { value: '', label: 'Tous types' },
    { value: 'NONE', label: 'Espèces normales' },
    { value: 'HYBRID', label: 'Hybrides' },
    { value: 'SUPER_HYBRID', label: 'Super hybrides' },
  ];
  protected readonly sort = signal<Sort>('cost');
  protected readonly error = signal<string | null>(null);
  protected readonly loading = this.collection.collection.isLoading;

  protected readonly rows = computed<SpeciesRow[]>(() => {
    const q = this.query().trim().toLowerCase();
    const rarity = this.rarity();
    const status = this.status();
    const lock = this.lock();
    const kind = this.kind();
    return this.collection.collection
      .value()
      .map((s) => ({ ...s, lock: lockState(s) }))
      .filter(
        (s) =>
          (!rarity || s.rarityCode === rarity) &&
          (!lock || s.lock === lock) &&
          (!kind || s.hybridKind === kind) &&
          (!q || s.name.toLowerCase().includes(q)) &&
          matches(s, status),
      )
      .sort(comparator(this.sort()));
  });

  protected readonly lockCounts = computed(() => {
    const counts: Record<LockState, number> = { UNLOCKED: 0, LOCKED_AMBER: 0, LOCKED: 0 };
    for (const s of this.collection.collection.value()) {
      counts[lockState(s)]++;
    }
    return counts;
  });

  protected readonly total = computed(() => this.collection.collection.value().length);

  protected async onChange(change: SpeciesChange): Promise<void> {
    this.error.set(null);
    try {
      await this.collection.update(change.speciesId, change.patch);
    } catch (e) {
      this.error.set(problemMessage(e, 'Modification refusée'));
      this.collection.collection.reload();
    }
  }

  protected onQuery(event: Event): void {
    this.query.set((event.target as HTMLInputElement).value);
  }

  protected onRarity(event: Event): void {
    this.rarity.set((event.target as HTMLSelectElement).value as RarityCode | '');
  }

  protected onKind(event: Event): void {
    this.kind.set((event.target as HTMLSelectElement).value as KindFilter);
  }

  protected onLock(event: Event): void {
    this.lock.set((event.target as HTMLSelectElement).value as LockFilter);
  }

  protected onStatus(event: Event): void {
    this.status.set((event.target as HTMLSelectElement).value as Status);
  }

  protected onSort(event: Event): void {
    this.sort.set((event.target as HTMLSelectElement).value as Sort);
  }
}

function matches(s: SpeciesProgress, status: Status): boolean {
  switch (status) {
    case 'done':
      return s.targetLvl40 > 0 && s.done;
    case 'progress':
      return s.progress > 0 && !s.done;
    case 'todo':
      return s.units === 0 && s.unitCost !== null;
    case 'nocost':
      return s.unitCost === null;
    default:
      return true;
  }
}

function comparator(sort: Sort): (a: SpeciesProgress, b: SpeciesProgress) => number {
  switch (sort) {
    case 'name':
      return (a, b) => a.name.localeCompare(b.name, 'fr');
    case 'progress':
      return (a, b) => b.progress - a.progress;
    case 'cost':
      return (a, b) => (a.unitCost ?? Infinity) - (b.unitCost ?? Infinity);
    default:
      return (a, b) =>
        Number(a.done) - Number(b.done) ||
        Number(a.unitCost === null) - Number(b.unitCost === null) ||
        a.remaining - b.remaining;
  }
}
