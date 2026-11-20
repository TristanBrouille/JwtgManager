import { Component, effect, input, output, signal, untracked } from '@angular/core';
import { FormField, form, min, required, submit } from '@angular/forms/signals';
import { Settings } from '../../../../core/data/models';

/** Revenus hebdomadaires du joueur, utilisés pour la projection de fin. */
@Component({
  selector: 'app-budget-form',
  imports: [FormField],
  templateUrl: './budget-form.html',
})
export class BudgetForm {
  readonly settings = input<Settings | undefined>();
  readonly saving = input(false);
  readonly saved = output<Settings>();

  protected readonly model = signal<Settings>({
    weeklyDna: 0,
    weeklySuperDna: 0,
    weeklyAmber: 0,
    defaultTarget: 3,
  });
  protected readonly budgetForm = form(this.model, (p) => {
    required(p.weeklyDna, { message: 'Obligatoire' });
    min(p.weeklyDna, 0, { message: 'Doit être positif' });
    required(p.weeklySuperDna, { message: 'Obligatoire' });
    min(p.weeklySuperDna, 0, { message: 'Doit être positif' });
    required(p.weeklyAmber, { message: 'Obligatoire' });
    min(p.weeklyAmber, 0, { message: 'Doit être positif' });
  });

  constructor() {
    effect(() => {
      const s = this.settings();
      if (s) {
        untracked(() => this.model.set({ ...s }));
      }
    });
  }

  protected onSubmit(event: Event): void {
    event.preventDefault();
    void submit(this.budgetForm, async () => {
      this.saved.emit(this.model());
      return undefined;
    });
  }
}
