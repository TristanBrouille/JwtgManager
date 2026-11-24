import { Component, input, output } from '@angular/core';
import { RouterLink } from '@angular/router';
import {
  HYBRID_KIND_LABEL,
  LockState,
  SpeciesProgress,
  SpeciesUpdate,
} from '../../../../core/data/models';
import { CurrencyTag } from '../../../../shared/ui/currency-tag/currency-tag';
import { ProgressBar } from '../../../../shared/ui/progress-bar/progress-bar';
import { RarityChip } from '../../../../shared/ui/rarity-chip/rarity-chip';
import { PercentPipe, ShortNumberPipe } from '../../../../shared/format/format.pipes';

/** Ligne du tableau : l'espèce et son état de déblocage (calculé une fois par la page). */
export type SpeciesRow = SpeciesProgress & { lock: LockState };

export interface SpeciesChange {
  speciesId: number;
  patch: Partial<SpeciesUpdate>;
}

type CountField = 'lvl10' | 'lvl20' | 'lvl30' | 'lvl40';

/** Tableau éditable des espèces : paliers, objectif et déblocage. */
@Component({
  selector: 'app-species-table',
  imports: [RouterLink, CurrencyTag, ProgressBar, RarityChip, PercentPipe, ShortNumberPipe],
  templateUrl: './species-table.html',
  styleUrl: './species-table.scss',
})
export class SpeciesTable {
  readonly rows = input.required<SpeciesRow[]>();
  readonly changed = output<SpeciesChange>();
  protected readonly kindLabel = HYBRID_KIND_LABEL;

  protected readonly levels: { field: CountField; label: string }[] = [
    { field: 'lvl10', label: 'Niveau 10' },
    { field: 'lvl20', label: 'Niveau 20' },
    { field: 'lvl30', label: 'Niveau 30' },
    { field: 'lvl40', label: 'Niveau 40' },
  ];

  protected onCount(row: SpeciesProgress, field: CountField, event: Event): void {
    const input = event.target as HTMLInputElement;
    const value = Math.max(0, Math.min(99, Math.trunc(Number(input.value) || 0)));
    input.value = String(value);
    if (value !== row[field]) {
      this.changed.emit({ speciesId: row.speciesId, patch: { [field]: value } });
    }
  }

  protected onUnlocked(row: SpeciesProgress, event: Event): void {
    this.changed.emit({
      speciesId: row.speciesId,
      patch: { unlocked: (event.target as HTMLInputElement).checked },
    });
  }
}
