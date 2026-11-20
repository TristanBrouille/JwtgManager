import { Component, input } from '@angular/core';
import { Dashboard } from '../../../../core/data/models';
import { CurrencyTag } from '../../../../shared/ui/currency-tag/currency-tag';
import { RarityChip } from '../../../../shared/ui/rarity-chip/rarity-chip';
import { PercentPipe, ShortNumberPipe } from '../../../../shared/format/format.pipes';

@Component({
  selector: 'app-closest-list',
  imports: [CurrencyTag, RarityChip, PercentPipe, ShortNumberPipe],
  templateUrl: './closest-list.html',
})
export class ClosestList {
  readonly species = input.required<Dashboard['closest']>();
}
