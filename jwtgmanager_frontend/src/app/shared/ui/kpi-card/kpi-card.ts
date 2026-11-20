import { Component, input } from '@angular/core';

@Component({
  selector: 'app-kpi-card',
  templateUrl: './kpi-card.html',
  styleUrl: './kpi-card.scss',
})
export class KpiCard {
  readonly label = input.required<string>();
  readonly value = input.required<string>();
  readonly tone = input<'default' | 'amber' | 'super'>('default');
}
