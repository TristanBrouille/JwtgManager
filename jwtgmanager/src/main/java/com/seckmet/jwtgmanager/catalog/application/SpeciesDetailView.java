package com.seckmet.jwtgmanager.catalog.application;

import java.time.LocalDate;
import java.util.List;

/**
 * Fiche complète d'une espèce : catalogue, recette, hybrides qui l'utilisent et fiche de jeu.
 * {@code sheet} est null si l'espèce n'a pas de fiche importée.
 */
public record SpeciesDetailView(SpeciesView species, List<Integer> componentIds, List<Integer> usedInIds,
                                Sheet sheet) {

    public record Sheet(String region, String creatureClass, LocalDate releaseDate,
                        List<Level> levels, Integer ferocity, Long coins, Integer coinMinutes,
                        Integer coinsPerMinute, Integer hatchMinutes, Long dnaBuy, Long dnaSell,
                        String imageUrl, String sourceUrl) {
    }

    public record Level(int level, int health, int attack, String portraitUrl) {
    }
}
