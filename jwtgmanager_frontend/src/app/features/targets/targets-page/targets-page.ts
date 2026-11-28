import { Component, computed, effect, inject, signal, untracked } from '@angular/core';
import { FormField, form, max, min, required } from '@angular/forms/signals';
import { CatalogService } from '../../../core/data/catalog.service';
import { CollectionService } from '../../../core/data/collection.service';
import { RARITY_CODES, RarityCode, SpeciesProgress } from '../../../core/data/models';
import { problemMessage } from '../../../core/http/problem';
import { ProgressBar } from '../../../shared/ui/progress-bar/progress-bar';
import { PercentPipe, ShortNumberPipe } from '../../../shared/format/format.pipes';

type Targets = Record<RarityCode, number>;

interface RarityStats {
  code: RarityCode;
  label: string;
  count: number;
  tracked: number;
  completion: number;
  lvl40: number;
  lvl40Target: number;
  dnaRemaining: number;
  superDnaRemaining: number;
  amberRemaining: number;
  unknownCost: number;
}

@Component({
  selector: 'app-targets-page',
  imports: [FormField, ProgressBar, PercentPipe, ShortNumberPipe],
  templateUrl: './targets-page.html',
  styleUrl: './targets-page.scss',
})
export class TargetsPage {
  private readonly collection = inject(CollectionService);
  private readonly catalog = inject(CatalogService);

  protected readonly presets = [1, 2, 3, 5];
  protected readonly message = signal<string | null>(null);
  protected readonly error = signal<string | null>(null);
  protected readonly busy = signal(false);

  protected readonly model = signal<Targets>(
    Object.fromEntries(RARITY_CODES.map((code) => [code, 3])) as Targets,
  );
  protected readonly targetsForm = form(this.model, (p) => {
    for (const code of RARITY_CODES) {
      required(p[code], { message: 'Obligatoire' });
      min(p[code], 0, { message: '0 minimum' });
      max(p[code], 99, { message: '99 maximum' });
    }
  });

  protected readonly stats = computed<RarityStats[]>(() => {
    const list = this.collection.collection.value();
    return this.catalog.rarities.value().map((r) =>
      summarize(
        r.code,
        r.label,
        list.filter((s) => s.rarityCode === r.code),
      ),
    );
  });

  constructor() {
    // Pré-remplit chaque champ avec l'objectif le plus fréquent de la rareté.
    effect(() => {
      const list = this.collection.collection.value();
      if (list.length === 0) {
        return;
      }
      untracked(() =>
        this.model.update((current) => {
          const next = { ...current };
          for (const code of Object.keys(next) as RarityCode[]) {
            next[code] =
              mostFrequentTarget(list.filter((s) => s.rarityCode === code)) ?? next[code];
          }
          return next;
        }),
      );
    });
  }

  protected async apply(code: RarityCode | null, target: number, label: string): Promise<void> {
    if (code && this.targetsForm[code]().invalid()) {
      return;
    }
    this.busy.set(true);
    this.error.set(null);
    try {
      const updated = await this.collection.setTargets(code, target);
      if (!code) {
        this.model.set(Object.fromEntries(RARITY_CODES.map((code) => [code, target])) as Targets);
      }
      this.message.set(
        `${label} : objectif fixé à ${target} niveau${target > 1 ? 'x' : ''} 40 (${updated} espèces)`,
      );
    } catch (e) {
      this.error.set(problemMessage(e, 'Objectif non enregistré'));
    } finally {
      this.busy.set(false);
    }
  }
}

function summarize(code: RarityCode, label: string, list: SpeciesProgress[]): RarityStats {
  const tracked = list.filter((s) => s.targetLvl40 > 0);
  const progressSum = tracked.reduce((n, s) => n + s.progress, 0);
  return {
    code,
    label,
    count: list.length,
    tracked: tracked.length,
    completion: tracked.length ? progressSum / tracked.length : 0,
    lvl40: tracked.reduce((n, s) => n + Math.min(s.lvl40, s.targetLvl40), 0),
    lvl40Target: tracked.reduce((n, s) => n + s.targetLvl40, 0),
    dnaRemaining: tracked.filter((s) => s.currency === 'DNA').reduce((n, s) => n + s.remaining, 0),
    superDnaRemaining: tracked
      .filter((s) => s.currency === 'SUPER_DNA')
      .reduce((n, s) => n + s.remaining, 0),
    amberRemaining: tracked
      .filter((s) => s.currency === 'AMBER')
      .reduce((n, s) => n + s.remaining, 0),
    unknownCost: list.filter((s) => s.unitCost === null).length,
  };
}

function mostFrequentTarget(list: SpeciesProgress[]): number | null {
  const counts = new Map<number, number>();
  for (const s of list) {
    counts.set(s.targetLvl40, (counts.get(s.targetLvl40) ?? 0) + 1);
  }
  let best: number | null = null;
  let bestCount = 0;
  for (const [target, count] of counts) {
    if (count > bestCount) {
      best = target;
      bestCount = count;
    }
  }
  return best;
}
