package com.seckmet.jwtgmanager.collection.exposition;

public record SpeciesProgressResponse(
        int speciesId, String name, String rarityCode, String hybridKind,
        boolean unlocked, boolean favorite, int lvl10, int lvl20, int lvl30, int lvl40, int targetLvl40,
        String currency, Long unitCost, long units, long unitsRemaining,
        double progress, boolean done, long invested, long remaining) {
}
