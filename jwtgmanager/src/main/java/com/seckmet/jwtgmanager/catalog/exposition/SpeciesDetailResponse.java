package com.seckmet.jwtgmanager.catalog.exposition;

import java.time.LocalDate;
import java.util.List;

public record SpeciesDetailResponse(int id, String name, String rarityCode, String hybridKind,
                                    Long dnaCost, Long amberCost, List<Integer> componentIds,
                                    List<Integer> usedInIds, Sheet sheet) {

    public record Sheet(String region, String creatureClass, LocalDate releaseDate, List<Level> levels,
                        Integer ferocity, Long coins, Integer coinMinutes, Integer coinsPerMinute,
                        Integer hatchMinutes, Long dnaBuy, Long dnaSell, String imageUrl, String sourceUrl) {
    }

    public record Level(int level, int health, int attack, String portraitUrl) {
    }
}
