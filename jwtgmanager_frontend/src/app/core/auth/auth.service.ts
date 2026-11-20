import { HttpClient } from '@angular/common/http';
import { Injectable, PLATFORM_ID, computed, inject, signal } from '@angular/core';
import { isPlatformBrowser } from '@angular/common';
import { Router } from '@angular/router';
import { firstValueFrom } from 'rxjs';
import { environment } from '../../../environments/environment';
import { AuthResponse, User } from '../data/models';

const STORAGE_KEY = 'jwtg.session';

interface Session {
  token: string;
  user: User;
}

@Injectable({ providedIn: 'root' })
export class AuthService {
  private readonly http = inject(HttpClient);
  private readonly router = inject(Router);
  private readonly browser = isPlatformBrowser(inject(PLATFORM_ID));
  private readonly session = signal<Session | null>(this.restore());

  readonly user = computed(() => this.session()?.user ?? null);
  readonly token = computed(() => this.session()?.token ?? null);
  readonly isLoggedIn = computed(() => this.session() !== null);

  async login(email: string, password: string): Promise<void> {
    this.store(
      await firstValueFrom(
        this.http.post<AuthResponse>(`${environment.apiUrl}/auth/login`, { email, password }),
      ),
    );
  }

  async register(email: string, pseudo: string, password: string): Promise<void> {
    this.store(
      await firstValueFrom(
        this.http.post<AuthResponse>(`${environment.apiUrl}/auth/register`, {
          email,
          pseudo,
          password,
        }),
      ),
    );
  }

  logout(): void {
    this.session.set(null);
    this.write(null);
    void this.router.navigate(['/connexion']);
  }

  private store(response: AuthResponse): void {
    const session = { token: response.token, user: response.user };
    this.session.set(session);
    this.write(session);
  }

  private restore(): Session | null {
    if (!this.browser) {
      return null;
    }
    try {
      const raw = localStorage.getItem(STORAGE_KEY);
      return raw ? (JSON.parse(raw) as Session) : null;
    } catch {
      return null;
    }
  }

  private write(session: Session | null): void {
    if (!this.browser) {
      return;
    }
    try {
      if (session) {
        localStorage.setItem(STORAGE_KEY, JSON.stringify(session));
      } else {
        localStorage.removeItem(STORAGE_KEY);
      }
    } catch {
      /* stockage indisponible : la session reste en mémoire */
    }
  }
}
