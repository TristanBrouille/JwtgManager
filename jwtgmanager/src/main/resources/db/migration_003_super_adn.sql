-- Migration 003 : troisième monnaie, le super ADN (paliers des super hybrides débloqués).
BEGIN;
ALTER TABLE player_settings ADD COLUMN weekly_super_dna INTEGER NOT NULL DEFAULT 0 CHECK (weekly_super_dna >= 0);
ALTER TABLE progress_snapshot ADD COLUMN super_dna_remaining BIGINT NOT NULL DEFAULT 0;
ALTER TABLE investment DROP CONSTRAINT IF EXISTS investment_currency_check;
ALTER TABLE investment ADD CONSTRAINT investment_currency_check CHECK (currency IN ('dna','super_dna','amber'));
UPDATE investment i SET currency = 'super_dna'
FROM species s WHERE s.id = i.species_id AND s.hybrid_kind = 'SUPER_HYBRID' AND i.currency = 'dna';
DROP VIEW IF EXISTS player_species_progress;
CREATE VIEW player_species_progress AS
SELECT ps.user_id,
       s.id   AS species_id,
       s.name,
       s.rarity_code,
       ps.target_lvl40,
       CASE WHEN NOT ps.unlocked THEN 'amber'
            WHEN s.hybrid_kind = 'SUPER_HYBRID' THEN 'super_dna' ELSE 'dna' END AS currency,
       CASE WHEN ps.unlocked THEN s.dna_cost ELSE s.amber_cost END              AS unit_cost,
       (ps.count_lvl10 + 2*ps.count_lvl20 + 4*ps.count_lvl30 + 8*ps.count_lvl40) AS units,
       8 * ps.target_lvl40                                                       AS units_needed,
       CASE WHEN ps.target_lvl40 = 0 THEN 1
            ELSE LEAST(1, (ps.count_lvl10 + 2*ps.count_lvl20 + 4*ps.count_lvl30 + 8*ps.count_lvl40)::numeric
                          / (8 * ps.target_lvl40)) END                           AS progress,
       (ps.count_lvl10 + 2*ps.count_lvl20 + 4*ps.count_lvl30 + 8*ps.count_lvl40)
         * CASE WHEN ps.unlocked THEN s.dna_cost ELSE s.amber_cost END          AS invested,
       GREATEST(0, 8*ps.target_lvl40
         - (ps.count_lvl10 + 2*ps.count_lvl20 + 4*ps.count_lvl30 + 8*ps.count_lvl40))
         * CASE WHEN ps.unlocked THEN s.dna_cost ELSE s.amber_cost END          AS remaining
FROM player_species ps
JOIN species s ON s.id = ps.species_id;
COMMIT;
