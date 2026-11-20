-- Migration 007 : espèce non débloquée sans coût ambre -> comptée en ADN (vue player_species_progress).
BEGIN;
DROP VIEW IF EXISTS player_species_progress;
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
COMMIT;
