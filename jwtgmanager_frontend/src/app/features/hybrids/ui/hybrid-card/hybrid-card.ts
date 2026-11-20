import { Component, computed, input, output } from '@angular/core';
import { HybridKind, SpeciesProgress } from '../../../../core/data/models';
import { ProgressBar } from '../../../../shared/ui/progress-bar/progress-bar';
import { RarityChip } from '../../../../shared/ui/rarity-chip/rarity-chip';
import { PercentPipe } from '../../../../shared/format/format.pipes';

export interface HybridEntry {
  kind: Exclude<HybridKind, 'NONE'>;
  hybrid: SpeciesProgress;
  components: SpeciesProgress[];
}

@Component({
  selector: 'app-hybrid-card',
  imports: [ProgressBar, RarityChip, PercentPipe],
  templateUrl: './hybrid-card.html',
  styleUrl: './hybrid-card.scss',
})
export class HybridCard {
  readonly entry = input.required<HybridEntry>();
  readonly toggled = output<{ speciesId: number; unlocked: boolean }>();

  protected readonly isSuper = computed(() => this.entry().kind === 'SUPER_HYBRID');
  protected readonly ready = computed(
    () =>
      !this.entry().hybrid.unlocked &&
      this.entry().components.length > 0 &&
      this.entry().components.every((c) => c.done),
  );

  protected onToggle(event: Event): void {
    this.toggled.emit({
      speciesId: this.entry().hybrid.speciesId,
      unlocked: (event.target as HTMLInputElement).checked,
    });
  }
}
