import { Component, input } from '@angular/core';
import { RouterLink } from '@angular/router';
import { TournamentTeam } from '../../../../core/data/models';

/** Un trio proposé : la paire de même classe, puis le dino seul. */
@Component({
  selector: 'app-team-card',
  imports: [RouterLink],
  templateUrl: './team-card.html',
  styleUrl: './team-card.scss',
})
export class TeamCard {
  readonly team = input.required<TournamentTeam>();
}
