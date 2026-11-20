# JWTG Manager — back-end

Back Spring Boot 4.2 / Java 27 du SaaS JWTG Manager (suivi de complétion des espèces de Jurassic World le jeu).

Avant d'écrire du code Java ou SQL ici, suivre le skill `.claude/skills/jwtg-backend-ddd/SKILL.md` :
architecture DDD (domain, application, exposition, infrastructure), règles métier, conventions et checklist.

## Lancer
- Secrets locaux dans `secrets.properties` (non versionné) : `DB_PASSWORD=...` et `JWTG_JWT_SECRET=...` (32 caractères min.).
- Build + tests : `./mvnw package` avec `JAVA_HOME` sur le JDK 27.
- API : `java -jar target/jwtgmanager-0.0.1-SNAPSHOT.jar` → http://localhost:8080/api

## Base
- PostgreSQL `pwtgmanagerdb`. Schéma : `src/main/resources/db/jwtg_schema.sql` (`ddl-auto=validate`).
- Données : `src/main/resources/db/jwtg_seed.sql` (catalogue de 360 espèces + 157 recettes d'hybrides depuis JWTG.xlsx, et compte démo `demo@jwtg.local` / `Demo1234!` avec la collection de l'Excel).

## API
`/api/auth/{register,login,me}`, `/api/catalog/{rarities,hybrids}`, `/api/collection`, `/api/collection/{speciesId}`,
`/api/collection/targets`, `/api/settings`, `/api/investments`, `/api/dashboard?currency=ALL|DNA|AMBER`, `/api/progress/history`.
Authentification par JWT (en-tête `Authorization: Bearer ...`), erreurs en `ProblemDetail`.

- Front : dépôt voisin `../jwtgmanager_frontend`.
