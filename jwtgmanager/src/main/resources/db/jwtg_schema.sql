-- JWTG Manager — schéma PostgreSQL
-- Catalogue partagé (rarity, species, hybrid_recipe) + données par joueur.

-- ========== Catalogue du jeu (commun à tous les joueurs) ==========

CREATE TABLE rarity (
    code        CHAR(1) PRIMARY KEY,          -- C, R, E, L, T
    label       TEXT    NOT NULL,             -- Commun, Rare, Extra rare, Légendaire, Tournoi
    sort_order  SMALLINT NOT NULL
);

INSERT INTO rarity VALUES
  ('C','Commun',1),('R','Rare',2),('E','Extra rare',3),('L','Légendaire',4),('T','Tournoi',5);

CREATE TABLE species (
    id           SERIAL PRIMARY KEY,
    name         TEXT    NOT NULL UNIQUE,
    rarity_code  CHAR(1) NOT NULL REFERENCES rarity(code),
    dna_cost    INTEGER CHECK (dna_cost  >= 0),   -- coût d'un palier en ADN, ou en super ADN pour un super hybride (NULL = inconnu)
    amber_cost   INTEGER CHECK (amber_cost >= 0),   -- coût d'un palier en ambre (NULL = inconnu)
    hybrid_kind  TEXT    NOT NULL DEFAULT 'NONE'
                 CHECK (hybrid_kind IN ('NONE', 'HYBRID', 'SUPER_HYBRID')),  -- super hybride = hybride d'hybrides
    default_unlocked BOOLEAN NOT NULL DEFAULT FALSE  -- valeur initiale de player_species.unlocked à l'inscription
);

-- Un hybride (ou super hybride) est lui-même une espèce ; ses composants sont d'autres espèces.
CREATE TABLE hybrid_recipe (
    hybrid_id     INTEGER NOT NULL REFERENCES species(id) ON DELETE CASCADE,
    component_id  INTEGER NOT NULL REFERENCES species(id) ON DELETE CASCADE,
    PRIMARY KEY (hybrid_id, component_id),
    CHECK (hybrid_id <> component_id)
);

-- ========== Joueurs ==========

CREATE TABLE app_user (
    id          UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    email       TEXT NOT NULL UNIQUE,
    pseudo      TEXT NOT NULL,
    password_hash TEXT NOT NULL,
    role        TEXT NOT NULL DEFAULT 'USER' CHECK (role IN ('USER','ADMIN')),
    created_at  TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE TABLE player_settings (
    user_id         UUID PRIMARY KEY REFERENCES app_user(id) ON DELETE CASCADE,
    weekly_dna    INTEGER NOT NULL DEFAULT 0 CHECK (weekly_dna >= 0),
    weekly_super_dna INTEGER NOT NULL DEFAULT 0 CHECK (weekly_super_dna >= 0),
    weekly_amber    INTEGER NOT NULL DEFAULT 0 CHECK (weekly_amber >= 0),
    default_target  SMALLINT NOT NULL DEFAULT 3 CHECK (default_target >= 0)
);

-- État de la collection d'un joueur pour une espèce.
-- unlocked = TRUE  -> les paliers se paient en ADN (super ADN pour un super hybride)
-- unlocked = FALSE -> les paliers se paient en ambre (en ADN si le coût ambre est inconnu)
-- Hybride débloqué = la ligne de l'hybride avec unlocked = TRUE.
CREATE TABLE player_species (
    user_id       UUID    NOT NULL REFERENCES app_user(id) ON DELETE CASCADE,
    species_id    INTEGER NOT NULL REFERENCES species(id)  ON DELETE CASCADE,
    unlocked      BOOLEAN  NOT NULL DEFAULT FALSE,
    count_lvl10   SMALLINT NOT NULL DEFAULT 0 CHECK (count_lvl10 >= 0),
    count_lvl20   SMALLINT NOT NULL DEFAULT 0 CHECK (count_lvl20 >= 0),
    count_lvl30   SMALLINT NOT NULL DEFAULT 0 CHECK (count_lvl30 >= 0),
    count_lvl40   SMALLINT NOT NULL DEFAULT 0 CHECK (count_lvl40 >= 0),
    target_lvl40  SMALLINT NOT NULL DEFAULT 3 CHECK (target_lvl40 >= 0),
    favorite      BOOLEAN  NOT NULL DEFAULT FALSE,   -- épinglée par le joueur (accès rapide)
    updated_at    TIMESTAMPTZ NOT NULL DEFAULT now(),
    PRIMARY KEY (user_id, species_id)
);

-- Journal des montées de niveau (niveaux : 10, 20, 30, 40 ; from_level NULL = nouveau spécimen).
CREATE TABLE investment (
    id           BIGSERIAL PRIMARY KEY,
    user_id      UUID    NOT NULL REFERENCES app_user(id) ON DELETE CASCADE,
    species_id   INTEGER NOT NULL REFERENCES species(id),
    from_level   SMALLINT CHECK (from_level IN (10,20,30)),
    to_level     SMALLINT NOT NULL CHECK (to_level IN (10,20,30,40)),
    quantity     SMALLINT NOT NULL DEFAULT 1 CHECK (quantity > 0),
    cost         INTEGER  NOT NULL CHECK (cost >= 0),          -- figé au moment de l'enregistrement
    currency     TEXT     NOT NULL CHECK (currency IN ('dna','super_dna','amber')),
    invested_on  DATE     NOT NULL DEFAULT current_date,
    created_at   TIMESTAMPTZ NOT NULL DEFAULT now(),
    CHECK (from_level IS NULL OR to_level > from_level)
);
CREATE INDEX investment_user_date_idx ON investment (user_id, invested_on DESC);

-- Point de la courbe d'évolution (un par jour et par joueur).
CREATE TABLE progress_snapshot (
    id               BIGSERIAL PRIMARY KEY,
    user_id          UUID NOT NULL REFERENCES app_user(id) ON DELETE CASCADE,
    taken_on         DATE NOT NULL DEFAULT current_date,
    completion_pct   NUMERIC(5,2) NOT NULL,
    lvl40_count      INTEGER NOT NULL,
    lvl40_target     INTEGER NOT NULL,
    dna_remaining  BIGINT  NOT NULL,
    super_dna_remaining BIGINT NOT NULL DEFAULT 0,
    amber_remaining  BIGINT  NOT NULL,
    UNIQUE (user_id, taken_on)
);

-- ========== Vue de calcul (KPI par espèce) ==========
-- Avancement (formule de JWTG.xlsx) = (n10/48 + n20/6 + 5·n30/12 + n40) / objectif, 100 % seulement
-- quand l'objectif de niveaux 40 est atteint (sinon plafonné à 99 %).
-- Reste (colonne « Rest » de l'Excel) = (8 × objectif − unités payées) × coût, paliers : 1, 2, 4, 8.
CREATE VIEW player_species_progress AS
SELECT ps.user_id,
       s.id   AS species_id,
       s.name,
       s.rarity_code,
       s.hybrid_kind,
       ps.target_lvl40,
       CASE WHEN NOT ps.unlocked AND COALESCE(s.amber_cost, 0) > 0 THEN 'amber'
            WHEN s.hybrid_kind = 'SUPER_HYBRID' THEN 'super_dna' ELSE 'dna' END AS currency,
       c.unit_cost,
       c.units,
       GREATEST(0, 8 * ps.target_lvl40 - c.units)                                       AS units_remaining,
       ps.count_lvl40 >= ps.target_lvl40 AND 8 * ps.target_lvl40 <= c.units            AS done,  -- 100 % ET reste à 0
       CASE WHEN ps.count_lvl40 >= ps.target_lvl40 THEN 1
            ELSE LEAST(0.99, (ps.count_lvl10 / 48.0 + ps.count_lvl20 / 6.0 + ps.count_lvl30 * 5.0 / 12.0
                              + ps.count_lvl40) / ps.target_lvl40) END                 AS progress,
       c.units * COALESCE(c.unit_cost, 0)                                              AS invested,
       GREATEST(0, 8 * ps.target_lvl40 - c.units) * COALESCE(c.unit_cost, 0)           AS remaining
FROM player_species ps
JOIN species s ON s.id = ps.species_id
CROSS JOIN LATERAL (
    SELECT CASE WHEN NOT ps.unlocked AND COALESCE(s.amber_cost, 0) > 0 THEN s.amber_cost
                ELSE s.dna_cost END AS unit_cost,
           ps.count_lvl10 + 2 * ps.count_lvl20 + 4 * ps.count_lvl30 + 8 * ps.count_lvl40 AS units
) c;
