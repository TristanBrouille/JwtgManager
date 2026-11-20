import { Component, computed, input } from '@angular/core';

@Component({
  selector: 'app-progress-bar',
  templateUrl: './progress-bar.html',
  styleUrl: './progress-bar.scss',
})
export class ProgressBar {
  /** Valeur entre 0 et 1. */
  readonly value = input.required<number>();
  /** Couleur CSS de la jauge (par défaut : vert). */
  readonly color = input<string | null>(null);
  readonly label = input('Progression');
  protected readonly Math = Math;
  protected readonly width = computed(() => `${Math.max(0, Math.min(1, this.value())) * 100}%`);
}
