import { Component, input } from '@angular/core';
import { CreatureLevel } from '../../../../core/data/models';

/** Santé et attaque de l'espèce à chaque palier, avec le portrait correspondant. */
@Component({
  selector: 'app-level-stats',
  templateUrl: './level-stats.html',
  styleUrl: './level-stats.scss',
})
export class LevelStats {
  readonly name = input.required<string>();
  readonly levels = input.required<CreatureLevel[]>();
  readonly ferocity = input<number | null>(null);
}
