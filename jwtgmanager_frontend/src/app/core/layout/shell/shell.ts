import { Component, computed, inject } from '@angular/core';
import { RouterLink, RouterLinkActive, RouterOutlet } from '@angular/router';
import { AuthService } from '../../auth/auth.service';
import { CatalogService } from '../../data/catalog.service';
import { CollectionService } from '../../data/collection.service';

@Component({
  selector: 'app-shell',
  imports: [RouterOutlet, RouterLink, RouterLinkActive],
  templateUrl: './shell.html',
  styleUrl: './shell.scss',
})
export class Shell {
  private readonly collection = inject(CollectionService);
  private readonly catalog = inject(CatalogService);
  protected readonly auth = inject(AuthService);

  protected readonly speciesCount = computed(() => this.collection.collection.value().length);
  /** Espèces ayant au moins une fusion possible (2 spécimens ou plus au niveau 10, 20 ou 30). */
  protected readonly fusionCount = computed(
    () =>
      this.collection.collection.value().filter((s) => s.lvl10 >= 2 || s.lvl20 >= 2 || s.lvl30 >= 2)
        .length,
  );
  protected readonly hybridsLabel = computed(() => {
    const unlocked = new Set(
      this.collection.collection
        .value()
        .filter((s) => s.unlocked)
        .map((s) => s.speciesId),
    );
    const hybrids = this.catalog.hybrids.value();
    return `${hybrids.filter((h) => unlocked.has(h.hybridId)).length}/${hybrids.length}`;
  });

  protected readonly links = [
    { path: '/tableau-de-bord', label: 'Tableau de bord' },
    { path: '/especes', label: 'Espèces' },
    { path: '/objectifs', label: 'Objectifs' },
    { path: '/investissements', label: 'Investissements' },
    { path: '/fusion', label: 'Fusion' },
    { path: '/hybrides', label: 'Hybrides' },
  ];
}
