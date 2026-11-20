---
name: jwtg-frontend-angular
description: Conventions du front Angular 22 de JWTG Manager (Signals-First, standalone, zoneless, OnPush, Signal Forms, httpResource). À utiliser pour tout code du dossier jwtgmanager_frontend.
---

# JWTG Manager — front-end Angular 22

## Le projet
Vocabulaire du jeu : trois monnaies, l'ADN (`DNA`), le super ADN (`SUPER_DNA`, super hybrides, affiché en rouge) et l'ambre (`AMBER`). Libellés dans `CURRENCY_LABEL` ; ne jamais parler de « pièces ». Ne pas confondre hybride et super hybride (hybride d'hybrides).
Interface du SaaS JWTG Manager : suivi de complétion des espèces de Jurassic World le jeu.
Écrans : Tableau de bord (KPI, courbe d'évolution, complétion par rareté, espèces les plus proches de l'objectif, projection budget), Espèces (tableau éditable des paliers et objectifs), Objectifs (objectif en masse par rareté), Investissements (enregistrer une montée, journal, budget hebdo), Hybrides.

- Racine : `JwtgManager/jwtgmanager_frontend`, SSR activé (`@angular/ssr`), tests Vitest, Prettier.
- Cible : Angular 22 (TypeScript 6.0 minimum, Node 22+). Si le projet est encore en 21 : avant toute nouvelle fonctionnalité, migrer avec `ng update @angular/core@22 @angular/cli@22` et appliquer les migrations proposées.
- Back : API REST Spring Boot sous `/api/...` (voir skill `jwtg-backend-ddd` dans le dépôt `jwtgmanager`).

## Organisation des dossiers (par fonctionnalité)

```
src/app
├── core/          services singletons, intercepteurs, guards, config
├── shared/        composants, pipes et directives réutilisables, sans logique métier
└── features/
    ├── dashboard/
    ├── species/
    ├── targets/
    ├── investments/
    └── hybrids/
        ├── data/          services d'accès API + modèles (types) de la fonctionnalité
        ├── ui/            composants de présentation (inputs/outputs seulement)
        └── <page>/        composant page (routé), qui orchestre
```

Chaque fonctionnalité regroupe ses routes, composants, services et état local, et est chargée en lazy loading via `loadComponent` / `loadChildren` dans `app.routes.ts`.

## Bonnes pratiques Angular 22 à appliquer

Orientation officielle d'Angular 22 (angular.dev), à suivre partout : Signals-First, composants standalone, zoneless, OnPush par défaut, découpage par fonctionnalité, chargement différé et SSR, primitives UI accessibles.

### Composants
- Composants standalone uniquement (pas de NgModule). Ne pas écrire `standalone: true` (c'est le défaut).
- Chaque composant a toujours trois fichiers séparés : `.ts`, `.html` (`templateUrl`) et `.scss` (`styleUrl`). Jamais de `template:` ni de `styles:` inline, même pour un petit composant.
- Nommage du CLI v20+ : `species-table.ts` / `.html` / `.scss`, classe `SpeciesTable`, sans suffixe `Component`.
- `OnPush` est la stratégie par défaut en v22 (l'ancienne stratégie Default s'appelle désormais `Eager`) : ne pas la redéclarer, ne jamais utiliser `Eager`. Les composants réagissent aux inputs, aux signals et aux événements explicites, pas à un balayage global de l'arbre.
- Application zoneless : pas de `zone.js`, pas de dépendance à la détection de changements implicite.
- Entrées / sorties avec `input()`, `input.required()`, `output()`, `model()` ; requêtes avec `viewChild()`, `contentChildren()`. Jamais `@Input`, `@Output`, `@ViewChild`.
- Injection avec `inject()`, jamais par constructeur.
- Séparer composants page (état, appels de services) et composants de présentation (purement inputs/outputs).
- Templates : contrôle de flux `@if`, `@for` (avec `track` obligatoire), `@switch`. Jamais `*ngIf`, `*ngFor`.
- `@defer` pour tout bloc lourd non critique (graphiques, tableaux longs) ; utiliser l'option de timeout de `on idle` et personnaliser via `IdleService` si besoin ; prévoir `@placeholder` et `@loading`.
- Liaisons `[class.x]` et `[style.x]` plutôt que `ngClass` / `ngStyle`. Pas d'appel de méthode dans les templates : utiliser des `computed()`.

### État et réactivité (Signals-First)
- Signals partout : `signal()`, `computed()`, `linkedSignal()` pour un état dérivé modifiable, `effect()` seulement pour les effets de bord (logs, stockage local), jamais pour propager de l'état.
- État local et petits stores en signals plutôt qu'en `BehaviorSubject` / RxJS dès qu'un signal suffit.
- Données asynchrones avec les Asynchronous Signals stables en v22 : `httpResource()` ou `resource()` pour les lectures HTTP, en gérant `value()`, `isLoading()` et `error()` dans le template ; profiter du cache SSR des ressources.
- Écritures (POST/PUT/DELETE) via `HttpClient` dans les services `data/`, puis `reload()` de la ressource concernée.
- RxJS seulement quand il apporte quelque chose (flux d'événements complexes) ; convertir avec `toSignal()` / `toObservable()`.
- Services fournis à la racine (`providedIn: 'root'` ou le nouveau `@Service`) ; pas d'état global caché ailleurs.

### Formulaires
- Signal Forms (stables en v22) pour tous les nouveaux formulaires (saisie d'investissement, objectifs, budget) avec validateurs déclaratifs et messages d'erreur en français.
- Pas de Template-driven forms ; Reactive Forms seulement pour du code existant.

### HTTP, routage et sécurité
- `provideHttpClient(withInterceptors([...]))` : `FetchBackend` est le backend HTTP par défaut en v22, ne plus ajouter `withFetch()`. Intercepteurs fonctionnels (auth, gestion d'erreurs `ProblemDetail`).
- Guards fonctionnels (`CanActivateFn`) ; paramètres de route lus via `withComponentInputBinding()`.
- Modèles TypeScript alignés sur les DTO `Response` du back ; jamais de `any`.
- URL de l'API dans la configuration d'environnement, jamais en dur.

### SSR et hydratation
- Pas d'accès direct à `window`, `document` ou `localStorage` : passer par `isPlatformBrowser`, `afterNextRender()` ou des services dédiés.
- Hydratation incrémentale avec `@defer (hydrate on viewport)` pour les blocs lourds.

### Accessibilité et UI
- Primitives UI accessibles et headless avec Angular Aria (`@angular/aria`, stable en v22) pour tous les widgets interactifs (onglets, menus, listes, combobox), stylées par nos propres SCSS et compatibles Signal Forms.
- Contrôles de 44 px minimum, focus visible, libellés sur tous les champs, contraste AA.
- Interface en français ; nombres formatés `fr-FR` (`DecimalPipe` / `Intl.NumberFormat`).
- Responsive : barre latérale qui devient une barre de navigation horizontale sous 860 px ; tableaux défilables sur mobile.
- Style : SCSS avec variables CSS (thème clair / sombre), pas de styles inline.

### TypeScript
- TypeScript 6.0 minimum.
- `strict` activé, `noImplicitAny`, `strictTemplates`.
- `readonly` sur les propriétés injectées et les signals exposés ; préférer `type`/`interface` aux classes pour les modèles.

### Outillage
- Pour déboguer la réactivité et l'injection, utiliser les outils d'inspection du graphe de signals et d'injection (`signal_graph`, `di_graph`) plutôt que des `console.log`.
- WebMCP (exposer des formulaires ou actions comme outils pour des agents IA dans le navigateur) est expérimental : ne l'utiliser que sur demande explicite.

## Tests
- Vitest + Angular Testing Library ou `TestBed` ; tester les `computed()` et services `data/` en priorité, puis les composants page.
- Simuler l'API avec `provideHttpClientTesting()`.

## Avant de livrer
1. `ng build` (SSR compris) passe sans avertissement.
2. `ng test` passe.
3. `npx prettier --check .` passe.
4. Aucun `NgModule`, `template:` / `styles:` inline, `@Input`, `*ngIf`, `*ngFor`, `ngClass`, `Eager`, `withFetch()`, `constructor(private ...)` ni `any` dans le code ajouté.
