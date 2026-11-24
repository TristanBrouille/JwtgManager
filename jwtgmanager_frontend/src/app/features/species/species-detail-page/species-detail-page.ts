import { Component, computed, inject, input, signal } from '@angular/core';
import { httpResource } from '@angular/common/http';
import { RouterLink } from '@angular/router';
import { environment } from '../../../../environments/environment';
import { CatalogService } from '../../../core/data/catalog.service';
import { CollectionService } from '../../../core/data/collection.service';
import { HYBRID_KIND_LABEL, SpeciesDetail, SpeciesProgress } from '../../../core/data/models';
import { problemMessage } from '../../../core/http/problem';
import { DurationPipe, ShortNumberPipe } from '../../../shared/format/format.pipes';
import { ProgressBar } from '../../../shared/ui/progress-bar/progress-bar';
import { RarityChip } from '../../../shared/ui/rarity-chip/rarity-chip';
import { LevelStats } from '../ui/level-stats/level-stats';
import { CountChange, SpecimenCounter } from '../ui/specimen-counter/specimen-counter';

/** Espèce liée (composant ou hybride) avec la progression du joueur si elle est connue. */
interface LinkedSpecies {
  id: number;
  name: string;
  progress: SpeciesProgress | undefined;
}

/** Fiche d'une espèce : image, statistiques de jeu, recette et progression du joueur. */
@Component({
  selector: 'app-species-detail-page',
  imports: [
    RouterLink,
    RarityChip,
    ProgressBar,
    LevelStats,
    SpecimenCounter,
    ShortNumberPipe,
    DurationPipe,
  ],
  templateUrl: './species-detail-page.html',
  styleUrl: './species-detail-page.scss',
})
export class SpeciesDetailPage {
  private readonly collection = inject(CollectionService);
  protected readonly catalog = inject(CatalogService);
  protected readonly kindLabel = HYBRID_KIND_LABEL;

  /** Paramètre de route {@code :id}. */
  readonly id = input.required<string>();
  private readonly speciesId = computed(() => Number(this.id()));

  protected readonly detail = httpResource<SpeciesDetail>(() =>
    Number.isInteger(this.speciesId())
      ? `${environment.apiUrl}/catalog/species/${this.speciesId()}`
      : undefined,
  );

  protected readonly mine = computed(() => this.collection.byId().get(this.speciesId()));
  protected readonly busy = signal(false);
  protected readonly error = signal<string | null>(null);
  protected readonly imageFailed = signal(false);

  protected readonly loadError = computed(() =>
    this.detail.error() ? problemMessage(this.detail.error(), 'Espèce introuvable') : null,
  );

  protected readonly components = computed(() => this.linked(this.detail.value()?.componentIds));
  protected readonly usedIn = computed(() => this.linked(this.detail.value()?.usedInIds));

  protected async toggleFavorite(s: SpeciesProgress): Promise<void> {
    await this.run(() => this.collection.setFavorite(s.speciesId, !s.favorite));
  }

  protected async onCount(change: CountChange): Promise<void> {
    await this.run(() =>
      this.collection.update(this.speciesId(), { [change.field]: change.value }),
    );
  }

  protected async onUnlocked(event: Event): Promise<void> {
    const unlocked = (event.target as HTMLInputElement).checked;
    await this.run(() => this.collection.update(this.speciesId(), { unlocked }));
  }

  private async run(action: () => Promise<unknown>): Promise<void> {
    this.busy.set(true);
    this.error.set(null);
    try {
      await action();
    } catch (e) {
      this.error.set(problemMessage(e, 'Modification impossible'));
      this.collection.collection.reload();
    } finally {
      this.busy.set(false);
    }
  }

  private linked(ids: number[] | undefined): LinkedSpecies[] {
    const byId = this.collection.byId();
    return (ids ?? [])
      .map((id) => ({ id, name: byId.get(id)?.name ?? `Espèce n°${id}`, progress: byId.get(id) }))
      .sort((a, b) => a.name.localeCompare(b.name, 'fr'));
  }
}
