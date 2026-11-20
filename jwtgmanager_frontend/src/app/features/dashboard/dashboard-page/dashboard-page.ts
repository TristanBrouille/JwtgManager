import { Component, computed, inject } from '@angular/core';
import { Toolbar, ToolbarWidget } from '@angular/aria/toolbar';
import { CollectionService } from '../../../core/data/collection.service';
import { CurrencyFilter } from '../../../core/data/models';
import { problemMessage } from '../../../core/http/problem';
import { percent, shortNumber } from '../../../shared/format/format';
import { KpiCard } from '../../../shared/ui/kpi-card/kpi-card';
import { DashboardApi } from '../data/dashboard.api';
import { ClosestList } from '../ui/closest-list/closest-list';
import { EvolutionChart } from '../ui/evolution-chart/evolution-chart';
import { FavoritesList } from '../ui/favorites-list/favorites-list';
import { ProjectionPanel } from '../ui/projection-panel/projection-panel';
import { RarityBars } from '../ui/rarity-bars/rarity-bars';

@Component({
  selector: 'app-dashboard-page',
  imports: [
    Toolbar,
    ToolbarWidget,
    KpiCard,
    EvolutionChart,
    RarityBars,
    ClosestList,
    FavoritesList,
    ProjectionPanel,
  ],
  templateUrl: './dashboard-page.html',
  styleUrl: './dashboard-page.scss',
})
export class DashboardPage {
  protected readonly api = inject(DashboardApi);
  protected readonly favorites = inject(CollectionService).favorites;

  protected readonly filters: { value: CurrencyFilter; label: string }[] = [
    { value: 'ALL', label: 'Tout' },
    { value: 'DNA', label: 'ADN' },
    { value: 'SUPER_DNA', label: 'Super ADN' },
    { value: 'AMBER', label: 'Ambre' },
  ];

  protected readonly data = computed(() =>
    this.api.dashboard.hasValue() ? this.api.dashboard.value() : null,
  );
  protected readonly error = computed(() =>
    this.api.dashboard.error()
      ? problemMessage(this.api.dashboard.error(), 'Tableau de bord indisponible')
      : null,
  );

  protected readonly title = computed(() => {
    const d = this.data();
    return d ? `Collection complétée à ${percent(d.summary.completion, 1)}` : 'Tableau de bord';
  });

  protected readonly completionLabel = computed(() => {
    const d = this.data();
    return d ? percent(d.summary.completion) : '—';
  });

  protected readonly delta = computed(() => {
    const d = this.data();
    if (!d || d.previousCompletion === null) {
      return null;
    }
    const points = (d.summary.completion - d.previousCompletion) * 100;
    return `${points >= 0 ? '+' : ''}${points.toFixed(1).replace('.', ',')} pts`;
  });

  protected readonly kpis = computed(() => {
    const d = this.data();
    if (!d) {
      return [];
    }
    const s = d.summary;
    return [
      {
        label: 'Niveaux 40',
        value: `${s.lvl40} / ${s.lvl40Target}`,
        sub: `${percent(s.lvl40Target ? s.lvl40 / s.lvl40Target : 0)} de l'objectif`,
        tone: 'default' as const,
      },
      {
        label: 'ADN restant',
        value: shortNumber(s.dnaRemaining),
        sub: `${shortNumber(s.dnaInvested)} déjà investi`,
        tone: 'default' as const,
      },
      {
        label: 'Super ADN restant',
        value: shortNumber(s.superDnaRemaining),
        sub: `${shortNumber(s.superDnaInvested)} déjà investi`,
        tone: 'super' as const,
      },
      {
        label: 'Ambre restant',
        value: shortNumber(s.amberRemaining),
        sub: `${shortNumber(s.amberInvested)} déjà investi`,
        tone: 'amber' as const,
      },
      {
        label: 'Hybrides débloqués',
        value: `${d.hybridsUnlocked} / ${d.hybridsTotal}`,
        sub: `Super hybrides : ${d.superHybridsUnlocked} / ${d.superHybridsTotal}`,
        tone: 'default' as const,
      },
    ];
  });

  constructor() {
    this.api.refresh();
  }

  protected select(value: CurrencyFilter): void {
    this.api.currency.set(value);
  }
}
