import { HttpClient, httpResource } from '@angular/common/http';
import { Injectable, computed, inject } from '@angular/core';
import { firstValueFrom } from 'rxjs';
import { environment } from '../../../environments/environment';
import { AuthService } from '../auth/auth.service';
import { RarityCode, Settings, SpeciesProgress, SpeciesUpdate } from './models';

/** Collection du joueur connecté et ses réglages. */
@Injectable({ providedIn: 'root' })
export class CollectionService {
  private readonly http = inject(HttpClient);
  private readonly auth = inject(AuthService);

  readonly collection = httpResource<SpeciesProgress[]>(
    () => (this.auth.isLoggedIn() ? `${environment.apiUrl}/collection` : undefined),
    { defaultValue: [] },
  );

  readonly settings = httpResource<Settings>(() =>
    this.auth.isLoggedIn() ? `${environment.apiUrl}/settings` : undefined,
  );

  readonly byId = computed(() => new Map(this.collection.value().map((s) => [s.speciesId, s])));

  /** Espèces épinglées en favori, triées par nom. */
  readonly favorites = computed(() =>
    this.collection
      .value()
      .filter((s) => s.favorite)
      .sort((a, b) => a.name.localeCompare(b.name, 'fr')),
  );

  async setFavorite(speciesId: number, favorite: boolean): Promise<void> {
    const updated = await firstValueFrom(
      this.http.put<SpeciesProgress>(`${environment.apiUrl}/collection/${speciesId}/favorite`, {
        favorite,
      }),
    );
    this.collection.value.update((list) =>
      list.map((s) => (s.speciesId === speciesId ? updated : s)),
    );
  }

  async update(speciesId: number, patch: Partial<SpeciesUpdate>): Promise<void> {
    const current = this.byId().get(speciesId);
    if (!current) {
      return;
    }
    const body: SpeciesUpdate = {
      unlocked: current.unlocked,
      lvl10: current.lvl10,
      lvl20: current.lvl20,
      lvl30: current.lvl30,
      lvl40: current.lvl40,
      targetLvl40: current.targetLvl40,
      ...patch,
    };
    const updated = await firstValueFrom(
      this.http.put<SpeciesProgress>(`${environment.apiUrl}/collection/${speciesId}`, body),
    );
    this.collection.value.update((list) =>
      list.map((s) => (s.speciesId === speciesId ? updated : s)),
    );
  }

  async setTargets(rarityCode: RarityCode | null, targetLvl40: number): Promise<number> {
    const result = await firstValueFrom(
      this.http.put<{ updatedSpecies: number }>(`${environment.apiUrl}/collection/targets`, {
        rarityCode,
        targetLvl40,
      }),
    );
    this.collection.reload();
    return result.updatedSpecies;
  }

  async saveSettings(settings: Settings): Promise<void> {
    const saved = await firstValueFrom(
      this.http.put<Settings>(`${environment.apiUrl}/settings`, settings),
    );
    this.settings.value.set(saved);
  }
}
