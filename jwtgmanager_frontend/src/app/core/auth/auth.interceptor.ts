import { HttpErrorResponse, HttpInterceptorFn } from '@angular/common/http';
import { inject } from '@angular/core';
import { catchError, throwError } from 'rxjs';
import { environment } from '../../../environments/environment';
import { AuthService } from './auth.service';

/** Ajoute le jeton JWT aux appels de l'API et déconnecte le joueur si le jeton est refusé. */
export const authInterceptor: HttpInterceptorFn = (req, next) => {
  const auth = inject(AuthService);
  const token = auth.token();
  const isApi = req.url.startsWith(environment.apiUrl);
  const isAuthCall = req.url.includes('/auth/login') || req.url.includes('/auth/register');
  const request =
    token && isApi ? req.clone({ setHeaders: { Authorization: `Bearer ${token}` } }) : req;
  return next(request).pipe(
    catchError((error: unknown) => {
      if (error instanceof HttpErrorResponse && error.status === 401 && isApi && !isAuthCall) {
        auth.logout();
      }
      return throwError(() => error);
    }),
  );
};
