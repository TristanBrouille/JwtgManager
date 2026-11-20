import { Component, computed, input, output } from '@angular/core';
import { DatePipe } from '@angular/common';
import { Currency, Investment } from '../../../../core/data/models';
import { CurrencyTag } from '../../../../shared/ui/currency-tag/currency-tag';
import { ShortNumberPipe } from '../../../../shared/format/format.pipes';

@Component({
  selector: 'app-investment-log',
  imports: [CurrencyTag, ShortNumberPipe, DatePipe],
  templateUrl: './investment-log.html',
  styleUrl: './investment-log.scss',
})
export class InvestmentLog {
  readonly investments = input.required<Investment[]>();
  readonly busyId = input<number | null>(null);
  readonly cancelled = output<number>();

  protected readonly totals = computed(() =>
    this.investments().reduce((t, i) => ({ ...t, [i.currency]: t[i.currency] + i.cost }), {
      DNA: 0,
      SUPER_DNA: 0,
      AMBER: 0,
    } as Record<Currency, number>),
  );
}
