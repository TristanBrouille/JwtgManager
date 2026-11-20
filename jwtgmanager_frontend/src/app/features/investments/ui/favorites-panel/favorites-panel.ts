import { Component, computed, input, output, signal } from '@angular/core';
import { FormField, form, submit, validate } from '@angular/forms/signals';
import { SpeciesProgress } from '../../../../core/data/models';
import { CurrencyTag } from '../../../../shared/ui/currency-tag/currency-tag';
import { ProgressBar } from '../../../../shared/ui/progress-bar/progress-bar';
import { RarityChip } from '../../../../shared/ui/rarity-chip/rarity-chip';
import { PercentPipe, ShortNumberPipe } from '../../../../shared/format/format.pipes';

export type LevelField = 'lvl10' | 'lvl20' | 'lvl30' | 'lvl40';

export interface CountAdjustment {
  speciesId: number;
  field: LevelField;
  value: number;
}

/** Espèces favorites : ajout, retrait et accès rapide pour ajouter ou retirer des spécimens par palier. */
@Component({
  selector: 'app-favorites-panel',
  imports: [FormField, CurrencyTag, ProgressBar, RarityChip, PercentPipe, ShortNumberPipe],
  templateUrl: './favorites-panel.html',
  styleUrl: './favorites-panel.scss',
})
export class FavoritesPanel {
  /** Toute la collection du joueur (pour la recherche). */
  readonly species = input.required<SpeciesProgress[]>();
  /** Espèce mise en avant (arrivée depuis le tableau de bord). */
  readonly focusedId = input<number | null>(null);
  readonly busyId = input<number | null>(null);

  readonly added = output<number>();
  readonly removed = output<number>();
  readonly adjusted = output<CountAdjustment>();

  protected readonly levels: { field: LevelField; label: string }[] = [
    { field: 'lvl10', label: 'Niv. 10' },
    { field: 'lvl20', label: 'Niv. 20' },
    { field: 'lvl30', label: 'Niv. 30' },
    { field: 'lvl40', label: 'Niv. 40' },
  ];

  private readonly byName = computed(
    () => new Map(this.species().map((s) => [s.name.toLowerCase(), s])),
  );

  /** Favoris, l'espèce mise en avant en premier. */
  protected readonly favorites = computed(() => {
    const focused = this.focusedId();
    return this.species()
      .filter((s) => s.favorite)
      .sort(
        (a, b) =>
          Number(b.speciesId === focused) - Number(a.speciesId === focused) ||
          a.name.localeCompare(b.name, 'fr'),
      );
  });

  protected readonly candidates = computed(() => this.species().filter((s) => !s.favorite));

  protected readonly model = signal({ species: '' });
  protected readonly addForm = form(this.model, (p) => {
    validate(p.species, (ctx) => {
      const found = this.byName().get(ctx.value().trim().toLowerCase());
      if (ctx.value() && !found) {
        return { kind: 'unknownSpecies', message: 'Espèce inconnue : choisissez-la dans la liste' };
      }
      if (found?.favorite) {
        return { kind: 'alreadyFavorite', message: 'Cette espèce est déjà dans vos favoris' };
      }
      return undefined;
    });
  });

  /** L'espèce saisie existe et n'est pas encore en favori. */
  protected readonly canAdd = computed(
    () => this.model().species.trim() !== '' && this.addForm().valid(),
  );

  protected onAdd(event: Event): void {
    event.preventDefault();
    void submit(this.addForm, async () => {
      const found = this.byName().get(this.model().species.trim().toLowerCase());
      if (found && !found.favorite) {
        this.added.emit(found.speciesId);
        this.model.set({ species: '' });
        this.addForm().reset();
      }
      return undefined;
    });
  }

  protected change(s: SpeciesProgress, field: LevelField, delta: number): void {
    const value = Math.max(0, Math.min(99, s[field] + delta));
    if (value !== s[field]) {
      this.adjusted.emit({ speciesId: s.speciesId, field, value });
    }
  }
}
