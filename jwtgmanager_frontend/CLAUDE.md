# JWTG Manager — front-end

Front Angular 22 du SaaS JWTG Manager (suivi de complétion des espèces de Jurassic World le jeu).

Avant d'écrire du code ici, suivre le skill `.claude/skills/jwtg-frontend-angular/SKILL.md` :
Signals-First, standalone, zoneless, OnPush, un `.ts` / `.html` / `.scss` séparé par composant, organisation par fonctionnalité, checklist.

## Lancer
- `npm ci` puis `npx ng serve` → http://localhost:4200 (le back doit tourner sur le port 8080).
- L'API est appelée en relatif sur `/api` ; en dev, `proxy.conf.json` relaie vers http://localhost:8080.
  En production, servir le front et l'API derrière le même domaine (reverse proxy).
- Autres commandes : `npx ng build`, `npx ng test --watch=false`, `npx prettier --check "src/**/*.{ts,html,scss}"`.
- Compte démo : `demo@jwtg.local` / `Demo1234!`.

## Structure
- `core/` : authentification JWT (service, intercepteur, guards), services de données partagés (`httpResource`), layout.
- `shared/` : format des nombres, composants d'affichage (rareté, monnaie, jauge, KPI).
- `features/` : `auth`, `dashboard`, `species`, `targets`, `investments`, `hybrids` (chargées en lazy loading).

- Back : dépôt voisin `../jwtgmanager` (API REST sous `/api/...`).
