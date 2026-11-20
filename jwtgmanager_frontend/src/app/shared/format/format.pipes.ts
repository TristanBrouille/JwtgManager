import { Pipe, PipeTransform } from '@angular/core';
import { percent, shortNumber } from './format';

@Pipe({ name: 'short' })
export class ShortNumberPipe implements PipeTransform {
  transform(value: number | null | undefined): string {
    return shortNumber(value);
  }
}

@Pipe({ name: 'pct' })
export class PercentPipe implements PipeTransform {
  transform(ratio: number | null | undefined, digits = 0): string {
    return ratio === null || ratio === undefined ? '—' : percent(ratio, digits);
  }
}
