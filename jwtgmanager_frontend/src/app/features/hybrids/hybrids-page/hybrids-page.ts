import { Component, computed, inject, signal } from '@angular/core';
import { Toolbar, ToolbarWidget } from '@angular/aria/toolbar';
import { CatalogService } from '../../../core/data/catalog.service';
import { CollectionService } from '../../../core/data/collection.service';
import { problemMessage } from '../../../core/http/problem';
import { HybridCard, HybridEntry } from '../ui/hybrid-card/hybrid-card';

type Filter = 'all' | 'open' | 'locked';
type KindFilter = 'ALL' | 'HYBRID' | 'SUPER_HYBRID';

@Component({
  selector: 'app-hybrids-page',
  imports: [Toolbar, ToolbarWidget, HybridCard],
  templateUrl: './hybrids-page.html',
  styleUrl: './hybrids-page.scss',
})
export class HybridsPage {
  private readonly catalog = inject(CatalogService);
  private readonly collection = inject(CollectionService);

  protected readonly filter = signal<Filter>('all');
  protected readonly kind = signal<KindFilter>('ALL');
  protected readonly error = signal<string | null>(null);
  protected readonly filters: { value: Filter; label: string }[] = [
    { value: 'all', label: 'Tous' },
    { value: 'open', label: 'Débloqués' },
    { value: 'locked', label: 'À débloquer' },
  ];
  protected readonly kinds: { value: KindFilter; label: string }[] = [
    { value: 'ALL', label: 'Tous types' },
    { value: 'HYBRID', label: 'Hybrides' },
    { value: 'SUPER_HYBRID', label: 'Super hybrides' },
  ];

  private readonly entries = computed<HybridEntry[]>(() => {
    const byId = this.collection.byId();
    const entries: HybridEntry[] = [];
    for (const h of this.catalog.hybrids.value()) {
      const hybrid = byId.get(h.hybridId);
      if (hybrid) {
        entries.push({
          kind: h.kind,
          hybrid,
          components: h.componentIds.map((id) => byId.get(id)).filter((c) => c !== undefined),
        });
      }
    }
    return entries.sort(
      (a, b) =>
        Number(a.hybrid.unlocked) - Number(b.hybrid.unlocked) ||
        a.hybrid.name.localeCompare(b.hybrid.name, 'fr'),
    );
  });

  protected readonly visible = computed(() => {
    const f = this.filter();
    const k = this.kind();
    return this.entries().filter(
      (e) => (k === 'ALL' || e.kind === k) && (f === 'all' || (f === 'open') === e.hybrid.unlocked),
    );
  });

  protected readonly unlockedCount = computed(
    () => this.entries().filter((e) => e.hybrid.unlocked).length,
  );
  protected readonly total = computed(() => this.entries().length);
  protected readonly superCount = computed(
    () => this.entries().filter((e) => e.kind === 'SUPER_HYBRID').length,
  );

  protected async toggle(change: { speciesId: number; unlocked: boolean }): Promise<void> {
    this.error.set(null);
    try {
      await this.collection.update(change.speciesId, { unlocked: change.unlocked });
    } catch (e) {
      this.error.set(problemMessage(e, 'Modification refusée'));
      this.collection.collection.reload();
    }
  }
}
