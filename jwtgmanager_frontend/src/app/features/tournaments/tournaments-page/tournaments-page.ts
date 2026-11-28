import { Component, computed, inject, signal } from '@angular/core';
import { DatePipe, PercentPipe } from '@angular/common';
import { RouterLink } from '@angular/router';
import { Toolbar, ToolbarWidget } from '@angular/aria/toolbar';
import { TournamentCode } from '../../../core/data/models';
import { TournamentsService } from '../../../core/data/tournaments.service';
import { problemMessage } from '../../../core/http/problem';
import { TeamCard } from '../ui/team-card/team-card';

/** Trios optimisés par tournoi et par ligue, recalculés uniquement sur demande. */
@Component({
  selector: 'app-tournaments-page',
  imports: [Toolbar, ToolbarWidget, DatePipe, PercentPipe, RouterLink, TeamCard],
  templateUrl: './tournaments-page.html',
  styleUrl: './tournaments-page.scss',
})
export class TournamentsPage {
  private readonly tournaments = inject(TournamentsService);

  protected readonly plan = this.tournaments.plan;
  protected readonly selected = signal<TournamentCode>('JURASSIC');
  protected readonly computing = signal(false);
  protected readonly error = signal<string | null>(null);

  protected readonly tabs = computed(() => this.plan.value()?.tournaments ?? []);
  protected readonly current = computed(() => this.tabs().find((t) => t.code === this.selected()));
  protected readonly loadError = computed(() =>
    this.plan.error() ? problemMessage(this.plan.error(), 'Trios indisponibles') : null,
  );

  protected async compute(): Promise<void> {
    this.computing.set(true);
    this.error.set(null);
    try {
      await this.tournaments.compute();
    } catch (e) {
      this.error.set(problemMessage(e, 'Le calcul des trios a échoué'));
    } finally {
      this.computing.set(false);
    }
  }
}
