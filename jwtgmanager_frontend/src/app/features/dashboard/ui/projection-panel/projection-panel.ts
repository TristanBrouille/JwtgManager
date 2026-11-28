import { Component, computed, input } from '@angular/core';
import { DatePipe } from '@angular/common';
import { RouterLink } from '@angular/router';
import { Currency, Projection } from '../../../../core/data/models';
import { CurrencyTag } from '../../../../shared/ui/currency-tag/currency-tag';
import { ShortNumberPipe } from '../../../../shared/format/format.pipes';

@Component({
  selector: 'app-projection-panel',
  imports: [CurrencyTag, ShortNumberPipe, DatePipe, RouterLink],
  templateUrl: './projection-panel.html',
  styleUrl: './projection-panel.scss',
})
export class ProjectionPanel {
  readonly dna = input.required<Projection>();
  readonly superDna = input.required<Projection>();
  readonly amber = input.required<Projection>();
  /** Masque les monnaies sans reste à payer. */
  readonly hideDone = input(false);

  protected readonly rows = computed<{ currency: Currency; projection: Projection }[]>(() =>
    [
      { currency: 'DNA' as const, projection: this.dna() },
      { currency: 'SUPER_DNA' as const, projection: this.superDna() },
      { currency: 'AMBER' as const, projection: this.amber() },
    ].filter((row) => !this.hideDone() || row.projection.remaining > 0),
  );
}
