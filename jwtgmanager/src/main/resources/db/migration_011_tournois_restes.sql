-- Migration 011 : tous les spécimens sont répartis en trios ; on garde ceux restés sans trio.
BEGIN;

CREATE TABLE tournament_leftover (
    user_id     UUID     NOT NULL REFERENCES tournament_plan(user_id) ON DELETE CASCADE,
    tournament  TEXT     NOT NULL CHECK (tournament IN ('JURASSIC','AQUATIC','CENOZOIC')),
    species_id  INTEGER  NOT NULL REFERENCES species(id) ON DELETE CASCADE,
    level       SMALLINT NOT NULL CHECK (level IN (10,20,30,40)),
    class_code  TEXT     NOT NULL,
    health      INTEGER  NOT NULL,
    attack      INTEGER  NOT NULL,
    quantity    SMALLINT NOT NULL CHECK (quantity > 0),
    PRIMARY KEY (user_id, tournament, species_id, level)
);

-- Les anciens calculs (top 5 par ligue) sont périmés.
DELETE FROM tournament_plan;

COMMIT;
