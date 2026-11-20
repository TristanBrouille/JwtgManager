import {
  Component,
  ElementRef,
  afterNextRender,
  computed,
  inject,
  input,
  signal,
  DestroyRef,
} from '@angular/core';
import { HistoryPoint } from '../../../../core/data/models';

interface Point {
  x: number;
  y: number;
  label: string;
  value: number;
  last: boolean;
}

/** Courbe de complétion jour par jour (un point par jour où la collection a changé). */
@Component({
  selector: 'app-evolution-chart',
  templateUrl: './evolution-chart.html',
  styleUrl: './evolution-chart.scss',
})
export class EvolutionChart {
  readonly points = input.required<HistoryPoint[]>();

  private readonly host = inject<ElementRef<HTMLElement>>(ElementRef);
  protected readonly width = signal(0);
  protected readonly height = 280;
  private readonly margin = { l: 44, r: 18, t: 22, b: 30 };

  constructor() {
    const destroyRef = inject(DestroyRef);
    afterNextRender(() => {
      const observer = new ResizeObserver(([entry]) =>
        this.width.set(Math.round(entry.contentRect.width)),
      );
      observer.observe(this.host.nativeElement);
      destroyRef.onDestroy(() => observer.disconnect());
    });
  }

  protected readonly max = computed(() => {
    const top = Math.max(0.2, ...this.points().map((p) => p.completion));
    return Math.min(1, Math.ceil((top + 0.05) * 10) / 10);
  });

  protected readonly ticks = computed(() =>
    [0, 1, 2, 3, 4].map((k) => {
      const value = (this.max() * k) / 4;
      return { y: this.y(value), label: `${Math.round(value * 100)} %` };
    }),
  );

  protected readonly plotted = computed<Point[]>(() => {
    const pts = this.points();
    const w = this.width();
    if (!w || pts.length === 0) {
      return [];
    }
    const inner = w - this.margin.l - this.margin.r;
    const step = pts.length > 1 ? inner / (pts.length - 1) : 0;
    return pts.map((p, i) => ({
      x: pts.length > 1 ? this.margin.l + i * step : this.margin.l + inner / 2,
      y: this.y(p.completion),
      label: `${p.day.slice(8, 10)}/${p.day.slice(5, 7)}`,
      value: p.completion,
      last: i === pts.length - 1,
    }));
  });

  protected readonly line = computed(() =>
    this.plotted()
      .map((p, i) => `${i ? 'L' : 'M'}${p.x},${p.y}`)
      .join(''),
  );

  protected readonly area = computed(() => {
    const pts = this.plotted();
    if (pts.length < 2) {
      return '';
    }
    const base = this.y(0);
    return `${this.line()}L${pts[pts.length - 1].x},${base}L${pts[0].x},${base}Z`;
  });

  protected readonly labelEvery = computed(() =>
    Math.max(1, Math.ceil(this.plotted().length / (this.width() < 520 ? 4 : 10))),
  );
  protected readonly lastPoint = computed(() => this.plotted().at(-1) ?? null);
  protected readonly gridRight = computed(() => this.width() - this.margin.r);
  protected readonly gridLeft = this.margin.l;

  private y(value: number): number {
    const inner = this.height - this.margin.t - this.margin.b;
    return this.margin.t + inner - (value / this.max()) * inner;
  }
}
