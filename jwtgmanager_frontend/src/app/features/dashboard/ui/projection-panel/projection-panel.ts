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

  protected readonly rows = computed<{ currency: Currency; projection: Projection }[]>(() => [
    { currency: 'DNA', projection: this.dna() },
    { currency: 'SUPER_DNA', projection: this.superDna() },
    { currency: 'AMBER', projection: this.amber() },
  ]);
}
