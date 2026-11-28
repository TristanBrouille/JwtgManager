package com.seckmet.jwtgmanager.tournament.domain;

import java.util.Arrays;
import java.util.Optional;

/**
 * Ligue d'un tournoi selon la fureur totale de l'équipe (somme des 3 dinos).
 * Une borne haute appartient à sa ligue : 800 est encore « nouveau-né / proie / rare ».
 *
 * <p>Chaque dino doit aussi avoir une fureur dans la fourchette de la ligue, pour éviter un trio
 * déséquilibré (2 dinos à 200 et 1 à 2000). Repères : au moins 800 en dominant, au plus 1 200 en
 * prédateur ; les autres ligues suivent la même proportion (minimum = 8/30 de la borne basse,
 * maximum = 12/30 de la borne haute).
 */
public enum League {
    NEWBORN("Nouveau-né / Proie / Rare", 0, 800, 0, 320),
    HUNTER("Chasseur", 800, 1500, 213, 600),
    PREDATOR("Prédateur", 1500, 3000, 400, 1200),
    DOMINANT("Dominant", 3000, Integer.MAX_VALUE, 800, Integer.MAX_VALUE);

    private final String label;
    private final int above;
    private final int upTo;
    private final int minUnit;
    private final int maxUnit;

    League(String label, int above, int upTo, int minUnit, int maxUnit) {
        this.label = label;
        this.above = above;
        this.upTo = upTo;
        this.minUnit = minUnit;
        this.maxUnit = maxUnit;
    }

    /** Fureur minimale d'un dino dans cette ligue (incluse). */
    public int minUnit() { return minUnit; }

    /** Fureur maximale d'un dino dans cette ligue (incluse) ; {@link Integer#MAX_VALUE} si aucune. */
    public int maxUnit() { return maxUnit; }

    public boolean accepts(int unitFerocity) {
        return unitFerocity >= minUnit && unitFerocity <= maxUnit;
    }

    public String label() { return label; }

    /** Fureur minimale exclue (0 inclus pour la première ligue). */
    public int above() { return above; }

    /** Fureur maximale incluse ; {@link Integer#MAX_VALUE} pour la ligue dominant. */
    public int upTo() { return upTo; }

    public boolean capped() {
        return upTo != Integer.MAX_VALUE;
    }

    public static Optional<League> of(int totalFerocity) {
        if (totalFerocity < 0) {
            return Optional.empty();
        }
        return Arrays.stream(values())
                .filter(l -> totalFerocity <= l.upTo && (totalFerocity > l.above || l == NEWBORN))
                .findFirst();
    }
}
