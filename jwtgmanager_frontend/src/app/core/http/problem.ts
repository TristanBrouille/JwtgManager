import { HttpErrorResponse } from '@angular/common/http';

/** Extrait le message lisible d'une erreur d'API (ProblemDetail RFC 9457). */
export function problemMessage(error: unknown, fallback = 'Une erreur est survenue'): string {
  if (error instanceof HttpErrorResponse) {
    const body = error.error as { detail?: string; title?: string } | null;
    if (body?.detail) {
      return body.detail;
    }
    if (error.status === 0) {
      return "Impossible de joindre l'API. Le back-end est-il démarré ?";
    }
    return body?.title ?? fallback;
  }
  return fallback;
}
