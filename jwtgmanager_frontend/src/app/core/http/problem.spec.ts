import { HttpErrorResponse } from '@angular/common/http';
import { describe, expect, it } from 'vitest';
import { problemMessage } from './problem';

describe('problemMessage', () => {
  it('lit le détail du ProblemDetail renvoyé par le back', () => {
    const error = new HttpErrorResponse({
      status: 422,
      error: { title: 'Règle', detail: 'Pas assez de spécimens' },
    });
    expect(problemMessage(error)).toBe('Pas assez de spécimens');
  });

  it('signale une API injoignable', () => {
    expect(problemMessage(new HttpErrorResponse({ status: 0 }))).toContain(
      "Impossible de joindre l'API",
    );
  });
});
