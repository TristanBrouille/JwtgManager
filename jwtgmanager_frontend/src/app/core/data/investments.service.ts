import { HttpClient, httpResource } from '@angular/common/http';
import { Injectable, inject } from '@angular/core';
import { firstValueFrom } from 'rxjs';
import { environment } from '../../../environments/environment';
import { AuthService } from '../auth/auth.service';
import { CollectionService } from './collection.service';
import { Investment, NewInvestment } from './models';

@Injectable({ providedIn: 'root' })
export class InvestmentsService {
  private readonly http = inject(HttpClient);
  private readonly auth = inject(AuthService);
  private readonly collection = inject(CollectionService);

  readonly investments = httpResource<Investment[]>(
    () => (this.auth.isLoggedIn() ? `${environment.apiUrl}/investments` : undefined),
    { defaultValue: [] },
  );

  async record(investment: NewInvestment): Promise<Investment> {
    const saved = await firstValueFrom(
      this.http.post<Investment>(`${environment.apiUrl}/investments`, investment),
    );
    this.investments.reload();
    this.collection.collection.reload();
    return saved;
  }

  async cancel(id: number): Promise<void> {
    await firstValueFrom(this.http.delete<void>(`${environment.apiUrl}/investments/${id}`));
    this.investments.reload();
    this.collection.collection.reload();
  }
}
