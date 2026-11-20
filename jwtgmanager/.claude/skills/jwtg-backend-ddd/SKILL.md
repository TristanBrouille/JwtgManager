---
name: jwtg-backend-ddd
description: Conventions du back Spring Boot de JWTG Manager (archi DDD : domain, application, exposition, infrastructure). À utiliser pour tout code Java/SQL du dossier jwtgmanager.
---

# JWTG Manager — back-end (DDD)

## Le projet
JWTG Manager est un SaaS qui aide un joueur de Jurassic World le jeu à suivre la complétion de ses espèces : nombre de spécimens par palier (niv. 10/20/30/40), objectif de niveaux 40 par espèce, investissements (ADN / ambre), KPI et évolution dans le temps, hybrides.

- Racine : `JwtgManager/jwtgmanager` (front à côté dans `JwtgManager/jwtgmanager_frontend`)
- Spring Boot 4.2 (4.2.0), Java 27 (Eclipse Temurin 27, `C:\Program Files\Eclipse Adoptium\jdk-27.0.1.0-hotspot`), Maven via `mvnw`, package racine `com.seckmet.jwtgmanager`
- Politique de versions : toujours la dernière version stable de Java, de Spring Boot et des dépendances. Les versions des dépendances sont gérées par le BOM Spring Boot : ne jamais fixer `RELEASE`, `LATEST` ni une version en dur quand Boot la gère.
- Base PostgreSQL 18 `pwtgmanagerdb` (localhost:5432)
- Source de vérité du schéma : `src/main/resources/db/jwtg_schema.sql`. Hibernate ne crée jamais les tables : `spring.jpa.hibernate.ddl-auto=validate`. Toute évolution du schéma passe par un script SQL versionné, jamais par `update`.
- Ne jamais écrire d'identifiants en clair dans `application.properties` : utiliser des variables d'environnement (`${DB_PASSWORD}`).

### Règles métier de référence
- Un palier coûte 1× (niv. 10), 2× (niv. 20), 4× (niv. 30), 8× (niv. 40) le coût unitaire de l'espèce.
- Trois monnaies (`Currency`) : espèce débloquée (`unlocked = true`) → ADN (`DNA`, coût `dna_cost`) ; super hybride débloqué → super ADN (`SUPER_DNA`, même colonne `dna_cost`) ; espèce non débloquée → ambre (`AMBER`, `amber_cost`), sauf si le coût ambre est inconnu (null ou 0) : on reste alors en ADN / super ADN avec `dna_cost`. Toujours passer par `UnitCosts.currencyFor(unlocked)`. Toujours passer par `Currency.of(unlocked, superHybrid)`.
- Unités payées = n10 + 2·n20 + 4·n30 + 8·n40 ; investi = unités payées × coût.
- Avancement (formule « Avancement » de JWTG.xlsx) = (n10/48 + n20/6 + 5·n30/12 + n40) / objectif niv. 40, plafonné à 99 % tant que l'objectif de niveaux 40 n'est pas réellement atteint. Ne jamais calculer l'avancement en unités de coût : 4 niv. 20 + 4 niv. 30 ne valent pas 3 niv. 40.
- Reste (colonne « Rest » de l'Excel) = max(0, 8 × objectif − unités payées) × coût : tout l'ADN investi compte, quel que soit le palier (6 niveaux 30 = reste 0). Le reste peut donc valoir 0 avant la fin : terminé = avancement à 100 % ET reste à 0.
- Complétion d'un groupe (global, rareté) = moyenne des avancements des espèces suivies (ligne « Moyenne » de l'Excel).
- Chaque espèce a un `hybrid_kind` (enum `HybridKind`) : `NONE`, `HYBRID` ou `SUPER_HYBRID`. Un super hybride est un hybride d'hybrides (au moins un composant est lui-même un hybride) : ne jamais confondre les deux. Les composants sont dans `hybrid_recipe`. Dans JWTG.xlsx, bleu = hybride, rouge = super hybride.
- Ces règles vivent dans le domaine (objets valeur / services de domaine), jamais dans un contrôleur ni en SQL seul.

### Tables
`rarity`, `species`, `hybrid_recipe` (catalogue partagé) ; `app_user`, `player_settings`, `player_species`, `investment`, `progress_snapshot` (données joueur) ; vue `player_species_progress`.

## Architecture : un package par contexte métier, quatre couches dans chacun

```
com.seckmet.jwtgmanager
├── <contexte>            (ex. species, collection, investment, progress, security)
│   ├── domain
│   ├── application
│   ├── exposition
│   └── infrastructure
└── shared                (types transverses : exceptions de base, Money, etc.)
```

Sens des dépendances, à respecter strictement :
`exposition → application → domain ← infrastructure`
Le domaine ne dépend de rien. L'infrastructure implémente les interfaces du domaine. Un contexte n'accède à un autre que par sa couche application (jamais par ses repositories ou entités JPA).

### domain — le cœur métier, en Java pur
Contient :
- Entités et agrégats métier (ex. `Species`, `PlayerSpecies`, `Investment`), objets valeur immuables en `record` (ex. `Level`, `Currency`, `Cost`, `SpeciesId`).
- Services de domaine pour la logique qui ne tient pas dans une seule entité (ex. `CompletionCalculator`, `InvestmentCostCalculator`).
- Interfaces de repository (ports), exprimées en termes métier : `SpeciesRepository`, `PlayerSpeciesRepository`…
- Exceptions métier (ex. `NotEnoughSpecimensException`).

Interdits dans `domain` : annotations Spring (`@Service`, `@Component`, `@Transactional`…), JPA (`@Entity`, `@Id`…), Jackson, Lombok, DTO. Les invariants sont vérifiés dans les constructeurs / méthodes métier (pas de setters publics).

### application — les cas d'usage
Contient :
- Services applicatifs, un par cas d'usage ou groupe cohérent (ex. `RecordInvestmentService`, `UpdateTargetsService`). Ils orchestrent le domaine et les repositories, portent `@Service` et `@Transactional`.
- DTO internes (commandes et résultats) en `record` : `RecordInvestmentCommand`, `SpeciesProgressView`…
- Exceptions applicatives (ex. `SpeciesNotFoundException`, `AccessDeniedToPlayerDataException`).
- Mappers domaine ↔ DTO internes.

Pas de logique métier ici : si une règle apparaît, elle descend dans le domaine.

### exposition — l'API REST
Contient :
- Contrôleurs `@RestController` sous `/api/...`, minces : valider l'entrée, appeler un service applicatif, mapper la réponse.
- DTO externes (requêtes / réponses JSON) en `record`, suffixés `Request` / `Response`, annotés Bean Validation (`@NotNull`, `@Min`…).
- Mappers DTO externes ↔ DTO internes.
- `@RestControllerAdvice` qui traduit les exceptions en `ProblemDetail` (RFC 9457) avec le bon statut HTTP.

Un contrôleur n'appelle jamais un repository ni une entité du domaine directement, et n'expose jamais une entité JPA.

### infrastructure — le monde extérieur
Contient :
- Implémentations des repositories du domaine (`JpaSpeciesRepository implements SpeciesRepository`) qui s'appuient sur des interfaces Spring Data internes.
- Entités JPA (`SpeciesJpaEntity`…), séparées des entités du domaine, avec mappers JPA ↔ domaine.
- Clients vers d'autres API avec `RestClient` (ou interfaces HTTP `@HttpExchange`). `RestTemplate` est déprécié depuis Spring Boot 4.2 : ne jamais l'utiliser.
- Configuration (`@Configuration`, sécurité, CORS, beans techniques).

Les noms de tables et colonnes des entités JPA correspondent exactement à `jwtg_schema.sql` (snake_case).

## Conventions de code
- Injection par constructeur uniquement (champs `private final`), jamais `@Autowired` sur un champ.
- Pas de Lombok dans le nouveau code : `record` et constructeurs explicites (Lombok passe par `sun.misc.Unsafe`, en voie de suppression sur Java 27+). Le retirer du `pom.xml` quand plus aucune classe ne l'utilise.
- Utiliser les fonctionnalités finales de Java 27 (records, pattern matching, `switch` exhaustif sur `sealed`) ; pas de fonctionnalité en preview.
- `record` pour tous les DTO et objets valeur ; `Optional` en retour de recherche, jamais en paramètre.
- Noms en anglais dans le code, messages d'erreur exposés en français.
- Montants en `long` (ADN et ambre peuvent dépasser 2^31 en cumul).
- Les montées de niveau enregistrent leur coût au moment de l'opération (`investment.cost`) : ne jamais le recalculer a posteriori.
- Les requêtes doivent toujours être filtrées par l'utilisateur connecté pour les données joueur.

## Tests
- Domaine : tests unitaires JUnit 5 purs, sans Spring, qui couvrent chaque règle métier ci-dessus.
- Application : tests avec repositories simulés (Mockito ou implémentations en mémoire).
- Exposition : `@WebMvcTest` sur les contrôleurs.
- Infrastructure : tests d'intégration sur PostgreSQL (Testcontainers) avec le schéma `jwtg_schema.sql`.

## Avant de livrer
1. Le domaine ne contient aucun import `org.springframework`, `jakarta.persistence`, `com.fasterxml` ni `lombok`.
2. Le sens des dépendances entre couches est respecté.
3. `./mvnw verify` passe avec `JAVA_HOME` pointant sur le JDK 27.
4. Si le schéma a changé : script SQL mis à jour et `ddl-auto=validate` démarre sans erreur.
