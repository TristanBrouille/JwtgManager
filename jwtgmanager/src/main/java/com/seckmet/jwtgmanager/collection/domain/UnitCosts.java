package com.seckmet.jwtgmanager.collection.domain;

import com.seckmet.jwtgmanager.shared.domain.Currency;

import java.util.OptionalLong;

/**
 * Coût d'un palier unitaire d'une espèce (null = inconnu).
 * {@code dna} est exprimé en ADN, ou en super ADN pour un super hybride.
 */
public record UnitCosts(Long dna, Long amber, boolean superHybrid) {

    /** Ambre si l'espèce n'est pas débloquée, sauf si son coût ambre est inconnu : on retombe alors sur l'ADN. */
    public Currency currencyFor(boolean unlocked) {
        boolean amberKnown = amber != null && amber > 0;
        return Currency.of(unlocked || !amberKnown, superHybrid);
    }

    public OptionalLong in(Currency currency) {
        Long value = currency == Currency.AMBER ? amber : dna;
        return value == null || value == 0 ? OptionalLong.empty() : OptionalLong.of(value);
    }
}
