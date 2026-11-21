# 🦖 JWTG Manager

> Suivi de complétion des espèces de **Jurassic World : le jeu**, pour savoir où en est ta collection, combien d'ADN il reste à dépenser et quelles espèces finir en priorité.

JWTG Manager remplace le gros tableur Excel de suivi par une application web. Chaque joueur crée son compte, fixe son objectif de niveaux 40 par espèce, saisit ses spécimens et ses dépenses, puis suit sa progression sur un tableau de bord.

---

## ✨ Fonctionnalités

| Écran | Ce qu'il fait |
|---|---|
| **Tableau de bord** | KPI de complétion globale, ADN / super ADN / ambre restants, espèces terminées, courbe d'évolution, complétion par rareté, espèces les plus proches de l'objectif (dépenses en ADN), projection selon le budget hebdo, accès rapide aux favoris |
| **Espèces** | Tableau des 351 espèces avec filtres (rareté, type normal / hybride / super hybride, déblocage, statut), tri par défaut sur le coût unitaire et couleurs : 🟧 bloquée débloquable à l'ambre, 🟥 bloquée sans ambre |
| **Objectifs** | Nombre de niveaux 40 visé par espèce, réglable en masse ou espèce par espèce |
| **Investissements** | Espèces favorites avec +/- rapide par niveau, budget hebdo par monnaie, journal des dépenses |
| **Fusion** | Liste des espèces fusionnables : 2 spécimens d'un niveau donnent 1 spécimen du niveau suivant (impossible au niveau 40) |
| **Hybrides** | Recettes des hybrides et super hybrides, avec l'état de leurs ingrédients |
| **Comptes** | Inscription et connexion par JWT, chaque joueur a sa propre collection |

## 📐 Règles métier

- **Paliers** : un spécimen au niveau 10 / 20 / 30 / 40 vaut 1 / 2 / 4 / 8 unités.
- **Avancement** d'une espèce, repris de la formule du tableur et ramené à l'objectif *N* niveaux 40 (3 par défaut) :
  `((n10/48 + n20/8 + n30/4 + n40/2) + n20/24 + n30/6 + n40/2) / 3`
  Il plafonne à 99 % tant que les *N* niveaux 40 ne sont pas atteints.
- **Reste** : `max(0, 8·N − unités)`. Le reste décompte dès que des spécimens sont ajoutés, même aux niveaux inférieurs.
- **Terminé** : avancement à 100 % **et** reste à 0.
- **Monnaies** :
  - Espèce débloquée : **ADN**.
  - Super hybride (hybride d'hybrides) : **super ADN**.
  - Espèce bloquée : **ambre**. Si elle n'a pas de coût en ambre, l'appli affiche le coût en ADN.

## 🧱 Stack technique

| Couche | Technologies |
|---|---|
| Back | Java 27 · Spring Boot 4.2 · Spring Security (OAuth2 Resource Server, JWT HS256) · Spring Data JPA / Hibernate 7 · Maven |
| Front | Angular 22 · TypeScript 6 · Signals · `httpResource` · Signal Forms · zoneless · SSR · Angular Aria · Vitest |
| Base | PostgreSQL 18 |

### Architecture du back (DDD)

Le code est découpé par contexte métier : `catalog`, `account`, `collection`, `investment`, `progress` et `shared`. Chaque contexte a quatre couches :

```
domain/          entités, value objects, services de domaine, interfaces de repository
application/     services applicatifs, exceptions, DTO internes
exposition/      contrôleurs REST, DTO externes
infrastructure/  implémentations JPA, configuration, intégrations
```

Les contextes communiquent par événements Spring (`UserRegistered`, `CollectionChanged`). Les erreurs sont renvoyées au format `ProblemDetail` (RFC 9457).

### Architecture du front

```
src/app/
├── core/       auth (service, intercepteur, guards), accès aux données, layout
├── shared/     composants d'UI réutilisables, pipes de formatage
└── features/   dashboard, species, targets, investments, fusion, hybrids, auth
```

Les composants sont standalone, en OnPush, avec des fichiers `.ts` / `.html` / `.scss` séparés.

## 🚀 Démarrage

### Prérequis

- JDK 27
- Node.js 22+ et npm
- PostgreSQL 18

### 1. Base de données

```bash
createdb pwtgmanagerdb
psql -d pwtgmanagerdb -f jwtgmanager/src/main/resources/db/jwtg_schema.sql
psql -d pwtgmanagerdb -f jwtgmanager/src/main/resources/db/jwtg_seed.sql
```

Le seed charge les raretés, les 351 espèces, les recettes d'hybrides et un compte de démo.

### 2. Back

Crée `jwtgmanager/secrets.properties` (ignoré par git) :

```properties
DB_PASSWORD=ton_mot_de_passe_postgres
JWTG_JWT_SECRET=une_cle_aleatoire_d_au_moins_32_caracteres
```

Tu peux aussi passer ces valeurs en variables d'environnement. `DB_HOST`, `DB_PORT`, `DB_NAME` et `DB_USER` sont optionnelles et valent par défaut `localhost`, `5432`, `pwtgmanagerdb` et `postgres`.

```bash
cd jwtgmanager
./mvnw spring-boot:run        # API sur http://localhost:8080
```

### 3. Front

```bash
cd jwtgmanager_frontend
npm ci
npx ng serve                  # http://localhost:4200
```

Le serveur de dev redirige `/api` vers `http://localhost:8080` (`proxy.conf.json`).

### Compte de démo

| E-mail | Mot de passe |
|---|---|
| `demo@jwtg.local` | `Demo1234!` |

## 🔌 API

| Méthode | Route | Rôle |
|---|---|---|
| `POST` | `/api/auth/register` · `/api/auth/login` | Inscription / connexion, renvoie un JWT |
| `GET` | `/api/auth/me` | Utilisateur courant |
| `GET` | `/api/catalog/rarities` · `/api/catalog/hybrids` | Référentiel |
| `GET` | `/api/collection` | Collection du joueur avec avancement, reste et coûts |
| `PUT` | `/api/collection/{id}` | Mise à jour des spécimens ou de l'objectif d'une espèce |
| `PUT` | `/api/collection/{id}/favorite` | Ajout ou retrait des favoris |
| `POST` | `/api/collection/{id}/fusions` | Fusion de 2 spécimens d'un niveau |
| `PUT` | `/api/collection/targets` | Objectifs en masse |
| `GET` `PUT` | `/api/settings` | Budget hebdo et objectif par défaut |
| `GET` `POST` `DELETE` | `/api/investments` | Journal des investissements |
| `GET` | `/api/dashboard?currency=ALL\|DNA\|SUPER_DNA\|AMBER` | KPI du tableau de bord |
| `GET` | `/api/progress/history` | Historique de progression |

## 🧪 Tests

```bash
cd jwtgmanager && ./mvnw test           # tests du domaine (calculs d'avancement, reste, fusion…)
cd jwtgmanager_frontend && npx ng test  # tests Vitest
```

## 📁 Structure du dépôt

```
JwtgManager/
├── jwtgmanager/              API Spring Boot
│   ├── src/main/resources/db/   schéma, seed et migrations SQL
│   └── CLAUDE.md, .claude/      conventions du back
└── jwtgmanager_frontend/     application Angular
    └── CLAUDE.md, .claude/      conventions du front
```

Les fichiers `CLAUDE.md` et les skills `.claude/skills/` décrivent les conventions d'architecture et de code de chaque partie.

---

*Projet de fan non officiel, sans lien avec Ludia ni Universal. Jurassic World est une marque d'Universal Studios et d'Amblin Entertainment.*
