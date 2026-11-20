import { Component, computed, input, output } from '@angular/core';
import { SpeciesProgress } from '../../../../core/data/models';
import { CurrencyTag } from '../../../../shared/ui/currency-tag/currency-tag';
import { RarityChip } from '../../../../shared/ui/rarity-chip/rarity-chip';
import { PercentPipe } from '../../../../shared/format/format.pipes';

export type FusableLevel = 10 | 20 | 30;

export interface FusionOption {
  from: FusableLevel;
  to: 20 | 30 | 40;
  available: number;
  /** Nombre de fusions possibles à ce palier (2 spécimens par fusion). */
  possible: number;
}

const FIELD: Record<FusableLevel, 'lvl10' | 'lvl20' | 'lvl30'> = {
  10: 'lvl10',
  20: 'lvl20',
  30: 'lvl30',
};
const NEXT: Record<FusableLevel, 20 | 30 | 40> = { 10: 20, 20: 30, 30: 40 };

/** Une espèce et ses fusions possibles. */
@Component({
  selector: 'app-fusion-card',
  imports: [CurrencyTag, RarityChip, PercentPipe],
  templateUrl: './fusion-card.html',
  styleUrl: './fusion-card.scss',
})
export class FusionCard {
  readonly species = input.required<SpeciesProgress>();
  readonly busy = input(false);
  readonly fused = output<FusableLevel>();

  protected readonly options = computed<FusionOption[]>(() => {
    const s = this.species();
    return ([10, 20, 30] as const)
      .map((from) => ({
        from,
        to: NEXT[from],
        available: s[FIELD[from]],
        possible: Math.floor(s[FIELD[from]] / 2),
      }))
      .filter((o) => o.possible > 0);
  });
}
