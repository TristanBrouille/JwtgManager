package com.seckmet.jwtgmanager.catalog.domain;

import java.time.LocalDate;
import java.util.List;
import java.util.Objects;

/**
 * Fiche de jeu d'une espèce (statistiques, économie, éclosion), importée depuis paleo.gg.
 * {@code health} et {@code attack} donnent une valeur par palier : niveaux 10, 20, 30 et 40.
 */
public record CreatureSheet(int speciesId, String sourceKey, String region, String creatureClass,
                            LocalDate releaseDate, List<Integer> health, List<Integer> attack,
                            Integer ferocity, Long coins, Integer coinMinutes, Integer coinsPerMinute,
                            Integer hatchMinutes, Long dnaBuy, Long dnaSell) {

    public static final int LEVELS = 4;

    public CreatureSheet {
        Objects.requireNonNull(sourceKey);
        health = List.copyOf(health);
        attack = List.copyOf(attack);
        if (health.size() != LEVELS || attack.size() != LEVELS) {
            throw new IllegalArgumentException("Santé et attaque attendues pour les 4 paliers");
        }
    }
}
