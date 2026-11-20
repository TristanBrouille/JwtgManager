-- Migration 006 : terminé = avancement à 100 % ET reste à 0 (vue player_species_progress).
BEGIN;
DROP VIEW IF EXISTS player_species_progress;
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
       CASE WHEN NOT ps.unlocked THEN 'amber'
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
    SELECT CASE WHEN ps.unlocked THEN s.dna_cost ELSE s.amber_cost END AS unit_cost,
           ps.count_lvl10 + 2 * ps.count_lvl20 + 4 * ps.count_lvl30 + 8 * ps.count_lvl40 AS units
) c;
COMMIT;
