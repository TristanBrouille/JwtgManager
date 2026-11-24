import { Component, input, output } from '@angular/core';
import { SpeciesProgress } from '../../../../core/data/models';
import { CurrencyTag } from '../../../../shared/ui/currency-tag/currency-tag';
import { ProgressBar } from '../../../../shared/ui/progress-bar/progress-bar';
import { PercentPipe, ShortNumberPipe } from '../../../../shared/format/format.pipes';

export type CountField = 'lvl10' | 'lvl20' | 'lvl30' | 'lvl40';

export interface CountChange {
  field: CountField;
  value: number;
}

/** Progression du joueur sur une espèce, avec +/- par palier. */
@Component({
  selector: 'app-specimen-counter',
  imports: [CurrencyTag, ProgressBar, PercentPipe, ShortNumberPipe],
  templateUrl: './specimen-counter.html',
  styleUrl: './specimen-counter.scss',
})
export class SpecimenCounter {
  readonly species = input.required<SpeciesProgress>();
  readonly busy = input(false);
  readonly changed = output<CountChange>();

  protected readonly levels: { field: CountField; label: string }[] = [
    { field: 'lvl10', label: 'Niv. 10' },
    { field: 'lvl20', label: 'Niv. 20' },
    { field: 'lvl30', label: 'Niv. 30' },
    { field: 'lvl40', label: 'Niv. 40' },
  ];

  protected change(field: CountField, delta: number): void {
    const s = this.species();
    const value = Math.max(0, Math.min(99, s[field] + delta));
    if (value !== s[field]) {
      this.changed.emit({ field, value });
    }
  }
}
