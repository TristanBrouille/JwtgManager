import { Component, computed, inject, input } from '@angular/core';
import { CatalogService } from '../../../core/data/catalog.service';
import { RarityCode } from '../../../core/data/models';

@Component({
  selector: 'app-rarity-chip',
  templateUrl: './rarity-chip.html',
  styleUrl: './rarity-chip.scss',
})
export class RarityChip {
  private readonly catalog = inject(CatalogService);
  readonly code = input.required<RarityCode>();
  protected readonly label = computed(
    () => this.catalog.rarityLabel().get(this.code()) ?? this.code(),
  );
}
