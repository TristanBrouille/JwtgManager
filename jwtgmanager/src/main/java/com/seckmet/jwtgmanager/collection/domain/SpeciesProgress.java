package com.seckmet.jwtgmanager.collection.domain;

import com.seckmet.jwtgmanager.shared.domain.Currency;

import java.util.OptionalLong;

/**
 * Avancement d'une espèce.
 * {@code units} : unités de palier déjà payées ; {@code unitsRemaining} : unités restant à payer (peut valoir 0
 * avant que l'objectif soit atteint) ; {@code done} : objectif de niveaux 40 atteint.
 * {@code unitCost} vide = coût inconnu : investi et reste valent alors 0.
 */
public record SpeciesProgress(Currency currency, OptionalLong unitCost, long units, long unitsRemaining,
                              double progress, boolean done, long invested, long remaining) {
}
