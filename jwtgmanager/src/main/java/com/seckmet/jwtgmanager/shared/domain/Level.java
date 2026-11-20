package com.seckmet.jwtgmanager.shared.domain;

import java.util.Arrays;
import java.util.Optional;

/** Palier d'une espèce. Le multiplicateur est appliqué au coût unitaire de l'espèce. */
public enum Level {
    L10(10, 1), L20(20, 2), L30(30, 4), L40(40, 8);

    private final int value;
    private final int multiplier;

    Level(int value, int multiplier) {
        this.value = value;
        this.multiplier = multiplier;
    }

    public int value() { return value; }

    public int multiplier() { return multiplier; }

    /** Palier suivant (pour une fusion), vide au niveau 40. */
    public Optional<Level> next() {
        Level[] all = values();
        return ordinal() + 1 < all.length ? Optional.of(all[ordinal() + 1]) : Optional.empty();
    }

    public static Level of(int value) {
        return Arrays.stream(values()).filter(l -> l.value == value).findFirst()
                .orElseThrow(() -> new InvalidLevelUpException("Niveau inconnu : " + value + " (10, 20, 30 ou 40)"));
    }
}
