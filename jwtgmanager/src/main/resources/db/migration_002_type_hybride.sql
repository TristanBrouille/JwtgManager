-- Migration 002 : type d'hybride (aucun / hybride / super hybride) et fusion des hybrides en double.
-- Source : couleurs de police de JWTG.xlsx (bleu = hybride, rouge = super hybride, hybride d'hybrides).
BEGIN;

ALTER TABLE species ADD COLUMN hybrid_kind TEXT NOT NULL DEFAULT 'NONE'
    CHECK (hybrid_kind IN ('NONE', 'HYBRID', 'SUPER_HYBRID'));

-- 9 hybrides créés en double à cause d'une orthographe différente dans la colonne « Hybride » de l'Excel
CREATE TEMP TABLE dup_map (dup TEXT, canon TEXT) ON COMMIT DROP;
INSERT INTO dup_map VALUES
  ('Andrewtherium', 'Andrewterium'),  ('Archaeophicyon', 'Archeaophicyon'),  ('Baghesaurus', 'Bagehesaurus'),  ('Crtolobourgiania', 'Cryolobourgiania'),  ('Dracoceratops', 'Dracocératops'),  ('Kaprodactylus', 'Kaprodacthylus'),  ('Kiilasaurus', 'Koolasaurus'),  ('Pteraquetzal', 'Ptéraquetzal'),  ('Scorpios Rex Gen 2', 'Scorpios Rex Gén 2');

UPDATE hybrid_recipe r SET hybrid_id = c.id
FROM dup_map m JOIN species d ON d.name = m.dup JOIN species c ON c.name = m.canon
WHERE r.hybrid_id = d.id;

UPDATE player_species pc SET unlocked = pc.unlocked OR pd.unlocked
FROM dup_map m JOIN species d ON d.name = m.dup JOIN species c ON c.name = m.canon
JOIN player_species pd ON pd.species_id = d.id
WHERE pc.species_id = c.id AND pc.user_id = pd.user_id;

UPDATE investment i SET species_id = c.id
FROM dup_map m JOIN species d ON d.name = m.dup JOIN species c ON c.name = m.canon
WHERE i.species_id = d.id;

DELETE FROM species s USING dup_map m WHERE s.name = m.dup;

UPDATE species SET hybrid_kind = 'HYBRID' WHERE name IN ('Alangasaure','Allonogmius','Andrewterium','Andrewtherium','Ankylodocus','Archaeophicyon','Archeaophicyon','Armormata','Bagehesaurus','Baghesaurus','Carnoraptor','Cerazinosaure','Chromaspinus','Compsovenator','Crtolobourgiania','Cryolobourgiania','Dakoderma','Dilophoboa','Doplotator','Draco Lux','Dracoceratops','Dracocératops','Dreadactylus','Dunkleosaure','Entelorhacos','Erliphosaurus','Fukuimimus','Geolasmosaurus','Giganocephalus','Gillirhynchops','Glythronax','Gorgosuchus','Hynecoprion','Iguanosuchus','Indominus Rex','Indominus Rex Gen 2','Indricoceros','Kaprodacthylus','Kaprodactylus','Kiilasaurus','Koolasaurus','Labyrinthosaure','Leptostega','Limnorhynque','Liosichtodon','Mammotherium','Megarchelon','Megistocurus','Metrialong','Metriaphodon','Nundagosaure','Ophiacomimus','Ophthacerapsis','Ostaposaure','Pachyceratops','Pachygalosaure','Parasaura','Pelecanipteryx','Poukadei','Priotrodon','Pteraquetzal','Ptéraquetzal','Rajastega','Rhinoprotodon','Sah Panthera','Scorpios Rex','Scorpios Rex Gen 2','Scorpios Rex Gén 2','Secodontognathus','Segnosuchus','Skoolasaure','Smithetoceras','Spinoceratops','Spinoraptor','Stegoceratops','Suchoripterus','Suprannotitan','Tapejalosaurus','Tropeogopterus','Tyrannolophosaure','Unayrhynchus','Xinathodon','Yudon','Zalmonodon');
UPDATE species SET hybrid_kind = 'SUPER_HYBRID' WHERE name IN ('Dimetrocarnus','Diplosuchus','Gigakylocephalus','Hydraboa','Indoraptor','Indoraptor Gen 2','Megalocevia','Monostegotops','Pelecachtylus','Quetzaljara','Skoonasaure','Spinotasuchus','Spinotops','Tapejalocephalus');

ALTER TABLE species DROP COLUMN is_hybrid;

COMMIT;
