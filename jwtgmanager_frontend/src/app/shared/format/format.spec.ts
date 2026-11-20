import { describe, expect, it } from 'vitest';
import { percent, shortNumber } from './format';

describe('format', () => {
  it('abrège les grands nombres comme dans le jeu', () => {
    expect(shortNumber(5_309_860)).toBe('5,3 M');
    expect(shortNumber(26_800_000)).toBe('27 M');
    expect(shortNumber(458_000)).toBe('458 k');
    expect(shortNumber(4620)).toBe('4 620');
    expect(shortNumber(null)).toBe('—');
  });

  it('formate les pourcentages en français', () => {
    expect(percent(0.2611)).toBe('26 %');
    expect(percent(0.2611, 1)).toBe('26,1 %');
  });
});
