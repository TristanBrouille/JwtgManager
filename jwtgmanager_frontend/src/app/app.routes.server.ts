import { RenderMode, ServerRoute } from '@angular/ssr';

/** Pages publiques prérendues ; pages du joueur rendues côté navigateur (jeton stocké localement). */
export const serverRoutes: ServerRoute[] = [
  { path: 'connexion', renderMode: RenderMode.Prerender },
  { path: 'inscription', renderMode: RenderMode.Prerender },
  { path: '**', renderMode: RenderMode.Client },
];
