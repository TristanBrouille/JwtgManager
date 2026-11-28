-- Migration 013 : écart de fureur limité à 10 % dans un trio. Les trios calculés avec l'ancienne
-- règle (30 %) sont effacés : relancer le calcul depuis l'onglet Tournois.
DELETE FROM tournament_plan;
