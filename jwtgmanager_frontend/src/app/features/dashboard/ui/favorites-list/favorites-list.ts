import { Component, input } from '@angular/core';
import { RouterLink } from '@angular/router';
import { SpeciesProgress } from '../../../../core/data/models';
import { CurrencyTag } from '../../../../shared/ui/currency-tag/currency-tag';
import { ProgressBar } from '../../../../shared/ui/progress-bar/progress-bar';
import { RarityChip } from '../../../../shared/ui/rarity-chip/rarity-chip';
import { PercentPipe, ShortNumberPipe } from '../../../../shared/format/format.pipes';

/** Favoris du joueur : un clic ouvre l'accès rapide dans Investissements. */
@Component({
  selector: 'app-favorites-list',
  imports: [RouterLink, CurrencyTag, ProgressBar, RarityChip, PercentPipe, ShortNumberPipe],
  templateUrl: './favorites-list.html',
  styleUrl: './favorites-list.scss',
})
export class FavoritesList {
  readonly favorites = input.required<SpeciesProgress[]>();
}
