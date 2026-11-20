package com.seckmet.jwtgmanager.investment.domain;

import com.seckmet.jwtgmanager.shared.domain.Currency;
import com.seckmet.jwtgmanager.shared.domain.Level;

import java.time.LocalDate;
import java.util.Objects;
import java.util.Optional;
import java.util.UUID;

/** Montée de niveau enregistrée, avec son coût figé au moment de l'opération. */
public record Investment(Long id, UUID userId, int speciesId, Optional<Level> from, Level to, int quantity,
                         long cost, Currency currency, LocalDate investedOn) {
    public Investment {
        Objects.requireNonNull(userId);
        Objects.requireNonNull(from);
        Objects.requireNonNull(to);
        Objects.requireNonNull(currency);
        Objects.requireNonNull(investedOn);
        if (quantity <= 0) {
            throw new IllegalArgumentException("La quantité doit être positive");
        }
        if (cost < 0) {
            throw new IllegalArgumentException("Le coût ne peut pas être négatif");
        }
    }
}
