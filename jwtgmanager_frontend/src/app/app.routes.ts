import { Routes } from '@angular/router';
import { authGuard, guestGuard } from './core/auth/auth.guards';

export const routes: Routes = [
  { path: '', pathMatch: 'full', redirectTo: 'tableau-de-bord' },
  {
    path: 'connexion',
    canActivate: [guestGuard],
    title: 'Connexion · JWTG Manager',
    loadComponent: () => import('./features/auth/login-page/login-page').then((m) => m.LoginPage),
  },
  {
    path: 'inscription',
    canActivate: [guestGuard],
    title: 'Inscription · JWTG Manager',
    loadComponent: () =>
      import('./features/auth/register-page/register-page').then((m) => m.RegisterPage),
  },
  {
    path: '',
    canActivate: [authGuard],
    loadComponent: () => import('./core/layout/shell/shell').then((m) => m.Shell),
    children: [
      {
        path: 'tableau-de-bord',
        title: 'Tableau de bord · JWTG Manager',
        loadComponent: () =>
          import('./features/dashboard/dashboard-page/dashboard-page').then((m) => m.DashboardPage),
      },
      {
        path: 'especes',
        title: 'Espèces · JWTG Manager',
        loadComponent: () =>
          import('./features/species/species-page/species-page').then((m) => m.SpeciesPage),
      },
      {
        path: 'objectifs',
        title: 'Objectifs · JWTG Manager',
        loadComponent: () =>
          import('./features/targets/targets-page/targets-page').then((m) => m.TargetsPage),
      },
      {
        path: 'investissements',
        title: 'Investissements · JWTG Manager',
        loadComponent: () =>
          import('./features/investments/investments-page/investments-page').then(
            (m) => m.InvestmentsPage,
          ),
      },
      {
        path: 'fusion',
        title: 'Fusion · JWTG Manager',
        loadComponent: () =>
          import('./features/fusion/fusion-page/fusion-page').then((m) => m.FusionPage),
      },
      {
        path: 'hybrides',
        title: 'Hybrides · JWTG Manager',
        loadComponent: () =>
          import('./features/hybrids/hybrids-page/hybrids-page').then((m) => m.HybridsPage),
      },
    ],
  },
  { path: '**', redirectTo: 'tableau-de-bord' },
];
