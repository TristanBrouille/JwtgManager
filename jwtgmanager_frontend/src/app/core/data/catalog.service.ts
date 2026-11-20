import { Injectable, computed } from '@angular/core';
import { httpResource } from '@angular/common/http';
import { environment } from '../../../environments/environment';
import { Hybrid, Rarity, RarityCode } from './models';

/** Catalogue du jeu (raretés, recettes d'hybrides), partagé par tous les joueurs. */
@Injectable({ providedIn: 'root' })
export class CatalogService {
  readonly rarities = httpResource<Rarity[]>(() => `${environment.apiUrl}/catalog/rarities`, {
    defaultValue: [],
  });
  readonly hybrids = httpResource<Hybrid[]>(() => `${environment.apiUrl}/catalog/hybrids`, {
    defaultValue: [],
  });

  readonly rarityLabel = computed(() => {
    const labels = new Map<RarityCode, string>();
    for (const r of this.rarities.value()) {
      labels.set(r.code, r.label);
    }
    return labels;
  });
}
