import { Component, computed, input } from '@angular/core';
import { CURRENCY_LABEL, Currency } from '../../../core/data/models';

@Component({
  selector: 'app-currency-tag',
  templateUrl: './currency-tag.html',
  styleUrl: './currency-tag.scss',
})
export class CurrencyTag {
  readonly currency = input.required<Currency>();
  protected readonly label = computed(() => CURRENCY_LABEL[this.currency()]);
}
