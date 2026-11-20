import { Component, computed, inject, signal } from '@angular/core';
import { CatalogService } from '../../../core/data/catalog.service';
import { CollectionService } from '../../../core/data/collection.service';
import { RarityCode } from '../../../core/data/models';
import { problemMessage } from '../../../core/http/problem';
import { FusableLevel, FusionCard } from '../ui/fusion-card/fusion-card';

@Component({
  selector: 'app-fusion-page',
  imports: [FusionCard],
  templateUrl: './fusion-page.html',
  styleUrl: './fusion-page.scss',
})
export class FusionPage {
  private readonly collection = inject(CollectionService);
  protected readonly catalog = inject(CatalogService);

  protected readonly rarity = signal<RarityCode | ''>('');
  protected readonly busyId = signal<number | null>(null);
  protected readonly message = signal<string | null>(null);
  protected readonly error = signal<string | null>(null);

  /** Espèces avec au moins 2 spécimens au niveau 10, 20 ou 30. */
  protected readonly candidates = computed(() => {
    const rarity = this.rarity();
    return this.collection.collection
      .value()
      .filter((s) => s.lvl10 >= 2 || s.lvl20 >= 2 || s.lvl30 >= 2)
      .filter((s) => !rarity || s.rarityCode === rarity)
      .sort((a, b) => a.name.localeCompare(b.name, 'fr'));
  });

  protected readonly loading = this.collection.collection.isLoading;

  protected onRarity(event: Event): void {
    this.rarity.set((event.target as HTMLSelectElement).value as RarityCode | '');
  }

  protected async fuse(speciesId: number, level: FusableLevel): Promise<void> {
    this.busyId.set(speciesId);
    this.error.set(null);
    try {
      const s = await this.collection.fuse(speciesId, level);
      this.message.set(`${s.name} : 2 niveaux ${level} fusionnés en 1 niveau ${level + 10}.`);
    } catch (e) {
      this.error.set(problemMessage(e, 'Fusion impossible'));
      this.collection.collection.reload();
    } finally {
      this.busyId.set(null);
    }
  }
}
