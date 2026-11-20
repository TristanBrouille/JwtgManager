package com.seckmet.jwtgmanager.catalog.domain;

import java.util.Objects;

/** Rareté d'une espèce (C, R, E, L, T). */
public record Rarity(String code, String label, int sortOrder) {
    public Rarity {
        Objects.requireNonNull(code);
        Objects.requireNonNull(label);
        if (code.length() != 1) {
            throw new IllegalArgumentException("Le code de rareté doit faire un caractère");
        }
    }
}
