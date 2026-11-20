import { Component, input } from '@angular/core';
import { Dashboard } from '../../../../core/data/models';
import { ProgressBar } from '../../../../shared/ui/progress-bar/progress-bar';
import { RarityChip } from '../../../../shared/ui/rarity-chip/rarity-chip';
import { PercentPipe, ShortNumberPipe } from '../../../../shared/format/format.pipes';

@Component({
  selector: 'app-rarity-bars',
  imports: [ProgressBar, RarityChip, PercentPipe, ShortNumberPipe],
  templateUrl: './rarity-bars.html',
  styleUrl: './rarity-bars.scss',
})
export class RarityBars {
  readonly rarities = input.required<Dashboard['byRarity']>();
}
