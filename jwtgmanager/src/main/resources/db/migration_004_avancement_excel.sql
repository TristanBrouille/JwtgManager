-- Migration 004 : avancement selon la formule de JWTG.xlsx (vue player_species_progress).
BEGIN;
DROP VIEW IF EXISTS player_species_progress;
-- ========== Vue de calcul (KPI par espèce) ==========
-- Avancement (formule de JWTG.xlsx) = (n10/48 + n20/6 + 5·n30/12 + n40) / objectif, 100 % seulement
-- quand l'objectif de niveaux 40 est atteint (sinon plafonné à 99 %).
-- Reste = unités pour amener les meilleurs spécimens jusqu'à l'objectif, × coût (paliers : 1, 2, 4, 8).
CREATE VIEW player_species_progress AS
SELECT ps.user_id,
       s.id   AS species_id,
       s.name,
       s.rarity_code,
       s.hybrid_kind,
       ps.target_lvl40,
       CASE WHEN NOT ps.unlocked THEN 'amber'
            WHEN s.hybrid_kind = 'SUPER_HYBRID' THEN 'super_dna' ELSE 'dna' END AS currency,
       c.unit_cost,
       c.units,
       r.units_remaining,
       CASE WHEN ps.target_lvl40 = 0 OR r.units_remaining = 0 THEN 1
            ELSE LEAST(0.99, (ps.count_lvl10 / 48.0 + ps.count_lvl20 / 6.0 + ps.count_lvl30 * 5.0 / 12.0
                              + ps.count_lvl40) / ps.target_lvl40) END                 AS progress,
       c.units * COALESCE(c.unit_cost, 0)                                              AS invested,
       r.units_remaining * COALESCE(c.unit_cost, 0)                                    AS remaining
FROM player_species ps
JOIN species s ON s.id = ps.species_id
CROSS JOIN LATERAL (
    SELECT CASE WHEN ps.unlocked THEN s.dna_cost ELSE s.amber_cost END AS unit_cost,
           ps.count_lvl10 + 2 * ps.count_lvl20 + 4 * ps.count_lvl30 + 8 * ps.count_lvl40 AS units
) c
CROSS JOIN LATERAL (
    SELECT u40, u30, u20, u10,
           4 * u30 + 6 * u20 + 7 * u10 + 8 * (ps.target_lvl40 - u40 - u30 - u20 - u10) AS units_remaining
    FROM (SELECT LEAST(ps.count_lvl40, ps.target_lvl40) AS u40) a
    CROSS JOIN LATERAL (SELECT LEAST(ps.count_lvl30, ps.target_lvl40 - a.u40) AS u30) b
    CROSS JOIN LATERAL (SELECT LEAST(ps.count_lvl20, ps.target_lvl40 - a.u40 - b.u30) AS u20) d
    CROSS JOIN LATERAL (SELECT LEAST(ps.count_lvl10, ps.target_lvl40 - a.u40 - b.u30 - d.u20) AS u10) e
) r;
COMMIT;
