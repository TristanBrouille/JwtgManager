const integer = new Intl.NumberFormat('fr-FR', { maximumFractionDigits: 0 });

/** 5 309 860 → « 5,3 M », 458 000 → « 458 k », 4 620 → « 4 620 ». */
export function shortNumber(value: number | null | undefined): string {
  if (value === null || value === undefined) {
    return '—';
  }
  const abs = Math.abs(value);
  if (abs >= 1e6) {
    return `${(value / 1e6).toFixed(abs >= 1e7 ? 0 : 1).replace('.', ',')} M`;
  }
  if (abs >= 1e4) {
    return `${Math.round(value / 1e3)} k`;
  }
  return integer.format(Math.round(value));
}

export function fullNumber(value: number): string {
  return integer.format(value);
}

/** 0,2611 → « 26 % » (digits = 0) ou « 26,1 % » (digits = 1). */
export function percent(ratio: number, digits = 0): string {
  return `${(ratio * 100).toFixed(digits).replace('.', ',')} %`;
}

/** Durée en minutes : 52 → « 52 min », 360 → « 6 h », 10080 → « 7 j », 1530 → « 1 j 1 h ». */
export function duration(minutes: number | null | undefined): string {
  if (minutes === null || minutes === undefined) {
    return '—';
  }
  const days = Math.floor(minutes / 1440);
  const hours = Math.floor((minutes % 1440) / 60);
  const mins = minutes % 60;
  const parts = [days && `${days} j`, hours && `${hours} h`, mins && `${mins} min`].filter(Boolean);
  return parts.length ? parts.slice(0, 2).join(' ') : '0 min';
}
