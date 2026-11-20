-- Migration 008 : espèces favorites (accès rapide depuis le tableau de bord).
ALTER TABLE player_species ADD COLUMN favorite BOOLEAN NOT NULL DEFAULT FALSE;
