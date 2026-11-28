-- Migration 014 : l'écart de 10 % dans un trio est remplacé par une fourchette de fureur par dino
-- propre à chaque ligue. Les trios calculés avec l'ancienne règle sont effacés : relancer le calcul.
DELETE FROM tournament_plan;
