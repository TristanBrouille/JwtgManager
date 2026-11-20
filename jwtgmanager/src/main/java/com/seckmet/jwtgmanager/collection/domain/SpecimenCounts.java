package com.seckmet.jwtgmanager.collection.domain;

import com.seckmet.jwtgmanager.shared.domain.InvalidLevelUpException;

import com.seckmet.jwtgmanager.shared.domain.Level;

import java.util.Optional;

/** Nombre de spécimens détenus à chaque palier. Immuable. */
public record SpecimenCounts(int lvl10, int lvl20, int lvl30, int lvl40) {

    public static final SpecimenCounts NONE = new SpecimenCounts(0, 0, 0, 0);

    public SpecimenCounts {
        if (lvl10 < 0 || lvl20 < 0 || lvl30 < 0 || lvl40 < 0) {
            throw new IllegalArgumentException("Un nombre de spécimens ne peut pas être négatif");
        }
    }

    public int at(Level level) {
        return switch (level) {
            case L10 -> lvl10;
            case L20 -> lvl20;
            case L30 -> lvl30;
            case L40 -> lvl40;
        };
    }

    /** Unités de palier détenues : n10 + 2·n20 + 4·n30 + 8·n40. */
    public long units() {
        return (long) lvl10 * Level.L10.multiplier() + (long) lvl20 * Level.L20.multiplier()
                + (long) lvl30 * Level.L30.multiplier() + (long) lvl40 * Level.L40.multiplier();
    }

    /**
     * Équivalent en niveaux 40, formule « Avancement » de JWTG.xlsx :
     * un niveau 10 vaut 1/48 de niveau 40, un niveau 20 1/6, un niveau 30 5/12, un niveau 40 vaut 1.
     */
    public double lvl40Equivalent() {
        return lvl10 / 48.0 + lvl20 / 6.0 + lvl30 * 5.0 / 12.0 + lvl40;
    }

    /**
     * Unités de palier qu'il reste à payer pour l'objectif, comme la colonne « Rest » de JWTG.xlsx :
     * tout l'ADN déjà investi compte, quel que soit le palier (6 niveaux 30 = 24 unités = 3 niveaux 40).
     */
    public long unitsToReach(int target) {
        return Math.max(0, (long) target * Level.L40.multiplier() - units());
    }

    /** Objectif atteint : au moins {@code target} spécimens au niveau 40. */
    public boolean reached(int target) {
        return lvl40 >= target;
    }

    /**
     * Fait monter {@code quantity} spécimens de {@code from} (vide = nouveau spécimen) vers {@code to}.
     */
    public SpecimenCounts levelUp(Optional<Level> from, Level to, int quantity) {
        validate(from, to, quantity);
        SpecimenCounts result = this;
        if (from.isPresent()) {
            int available = at(from.get());
            if (available < quantity) {
                throw new NotEnoughSpecimensException(from.get(), available, quantity);
            }
            result = result.with(from.get(), available - quantity);
        }
        return result.with(to, result.at(to) + quantity);
    }

    /** Annule une montée de niveau précédemment appliquée. */
    public SpecimenCounts revertLevelUp(Optional<Level> from, Level to, int quantity) {
        validate(from, to, quantity);
        int available = at(to);
        if (available < quantity) {
            throw new NotEnoughSpecimensException(to, available, quantity);
        }
        SpecimenCounts result = with(to, available - quantity);
        return from.map(f -> result.with(f, result.at(f) + quantity)).orElse(result);
    }

    private static void validate(Optional<Level> from, Level to, int quantity) {
        if (quantity <= 0) {
            throw new InvalidLevelUpException("La quantité doit être positive");
        }
        if (from.isPresent() && from.get().compareTo(to) >= 0) {
            throw new InvalidLevelUpException("Le niveau cible doit être supérieur au niveau de départ");
        }
    }

    private SpecimenCounts with(Level level, int value) {
        return switch (level) {
            case L10 -> new SpecimenCounts(value, lvl20, lvl30, lvl40);
            case L20 -> new SpecimenCounts(lvl10, value, lvl30, lvl40);
            case L30 -> new SpecimenCounts(lvl10, lvl20, value, lvl40);
            case L40 -> new SpecimenCounts(lvl10, lvl20, lvl30, value);
        };
    }
}
