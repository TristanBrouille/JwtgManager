import { Component, computed, inject, input, signal } from '@angular/core';
import { CollectionService } from '../../../core/data/collection.service';
import { InvestmentsService } from '../../../core/data/investments.service';
import { Settings } from '../../../core/data/models';
import { problemMessage } from '../../../core/http/problem';
import { BudgetForm } from '../ui/budget-form/budget-form';
import { CountAdjustment, FavoritesPanel } from '../ui/favorites-panel/favorites-panel';
import { InvestmentLog } from '../ui/investment-log/investment-log';

@Component({
  selector: 'app-investments-page',
  imports: [FavoritesPanel, BudgetForm, InvestmentLog],
  templateUrl: './investments-page.html',
  styleUrl: './investments-page.scss',
})
export class InvestmentsPage {
  private readonly collectionService = inject(CollectionService);
  private readonly investmentsService = inject(InvestmentsService);

  /** Paramètre d'URL `?espece=<id>` : favori ouvert depuis le tableau de bord. */
  readonly espece = input<string | undefined>();
  protected readonly focusedId = computed(() => {
    const id = Number(this.espece());
    return Number.isInteger(id) && id > 0 ? id : null;
  });

  protected readonly species = this.collectionService.collection.value;
  protected readonly settings = computed(() =>
    this.collectionService.settings.hasValue()
      ? this.collectionService.settings.value()
      : undefined,
  );
  protected readonly investments = this.investmentsService.investments.value;

  protected readonly busyId = signal<number | null>(null);
  protected readonly savingBudget = signal(false);
  protected readonly cancelling = signal<number | null>(null);
  protected readonly message = signal<string | null>(null);
  protected readonly error = signal<string | null>(null);

  protected async addFavorite(speciesId: number): Promise<void> {
    await this.run(speciesId, () => this.collectionService.setFavorite(speciesId, true));
  }

  protected async removeFavorite(speciesId: number): Promise<void> {
    await this.run(speciesId, () => this.collectionService.setFavorite(speciesId, false));
  }

  protected async adjust(change: CountAdjustment): Promise<void> {
    await this.run(change.speciesId, () =>
      this.collectionService.update(change.speciesId, { [change.field]: change.value }),
    );
  }

  protected async cancel(id: number): Promise<void> {
    this.cancelling.set(id);
    this.error.set(null);
    try {
      await this.investmentsService.cancel(id);
      this.message.set(
        'Investissement annulé : les spécimens sont revenus à leur palier de départ.',
      );
    } catch (e) {
      this.error.set(problemMessage(e, 'Annulation impossible'));
    } finally {
      this.cancelling.set(null);
    }
  }

  protected async saveBudget(settings: Settings): Promise<void> {
    this.savingBudget.set(true);
    this.error.set(null);
    try {
      await this.collectionService.saveSettings(settings);
      this.message.set('Budget hebdomadaire enregistré.');
    } catch (e) {
      this.error.set(problemMessage(e, 'Budget non enregistré'));
    } finally {
      this.savingBudget.set(false);
    }
  }

  private async run(speciesId: number, action: () => Promise<void>): Promise<void> {
    this.busyId.set(speciesId);
    this.error.set(null);
    try {
      await action();
    } catch (e) {
      this.error.set(problemMessage(e, 'Modification refusée'));
      this.collectionService.collection.reload();
    } finally {
      this.busyId.set(null);
    }
  }
}
