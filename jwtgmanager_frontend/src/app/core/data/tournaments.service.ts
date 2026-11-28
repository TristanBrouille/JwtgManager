import { HttpClient, httpResource } from '@angular/common/http';
import { Injectable, inject } from '@angular/core';
import { firstValueFrom } from 'rxjs';
import { environment } from '../../../environments/environment';
import { AuthService } from '../auth/auth.service';
import { TournamentPlan } from './models';

/** Trios de tournoi : lecture du dernier calcul, recalcul uniquement à la demande. */
@Injectable({ providedIn: 'root' })
export class TournamentsService {
  private readonly http = inject(HttpClient);
  private readonly auth = inject(AuthService);

  readonly plan = httpResource<TournamentPlan>(() =>
    this.auth.isLoggedIn() ? `${environment.apiUrl}/tournaments` : undefined,
  );

  async compute(): Promise<void> {
    const plan = await firstValueFrom(
      this.http.post<TournamentPlan>(`${environment.apiUrl}/tournaments/compute`, {}),
    );
    this.plan.value.set(plan);
  }
}
