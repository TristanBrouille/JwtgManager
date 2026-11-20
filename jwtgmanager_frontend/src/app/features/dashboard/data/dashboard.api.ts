import { Injectable, inject, signal } from '@angular/core';
import { httpResource } from '@angular/common/http';
import { environment } from '../../../../environments/environment';
import { AuthService } from '../../../core/auth/auth.service';
import { CurrencyFilter, Dashboard, HistoryPoint } from '../../../core/data/models';

@Injectable({ providedIn: 'root' })
export class DashboardApi {
  private readonly auth = inject(AuthService);

  readonly currency = signal<CurrencyFilter>('ALL');

  readonly dashboard = httpResource<Dashboard>(() =>
    this.auth.isLoggedIn()
      ? { url: `${environment.apiUrl}/dashboard`, params: { currency: this.currency() } }
      : undefined,
  );

  readonly history = httpResource<HistoryPoint[]>(
    () => (this.auth.isLoggedIn() ? `${environment.apiUrl}/progress/history` : undefined),
    { defaultValue: [] },
  );

  refresh(): void {
    this.dashboard.reload();
    this.history.reload();
  }
}
