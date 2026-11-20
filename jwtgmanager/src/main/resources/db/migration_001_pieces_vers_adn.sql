-- Renommage métier : la monnaie « pièces » s'appelle « ADN ».
BEGIN;
DROP VIEW IF EXISTS player_species_progress;
ALTER TABLE species RENAME COLUMN coin_cost TO dna_cost;
ALTER TABLE player_settings RENAME COLUMN weekly_coins TO weekly_dna;
ALTER TABLE progress_snapshot RENAME COLUMN coins_remaining TO dna_remaining;
ALTER TABLE investment DROP CONSTRAINT IF EXISTS investment_currency_check;
UPDATE investment SET currency = 'dna' WHERE currency = 'coins';
ALTER TABLE investment ADD CONSTRAINT investment_currency_check CHECK (currency IN ('dna','amber'));
COMMIT;
CREATE VIEW player_species_progress AS
SELECT ps.user_id,
       s.id   AS species_id,
       s.name,
       s.rarity_code,
       ps.target_lvl40,
       CASE WHEN ps.unlocked THEN 'dna' ELSE 'amber' END                       AS currency,
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
