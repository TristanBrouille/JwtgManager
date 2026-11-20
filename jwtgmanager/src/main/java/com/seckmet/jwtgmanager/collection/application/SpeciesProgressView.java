package com.seckmet.jwtgmanager.collection.application;

public record SpeciesProgressView(
        int speciesId, String name, String rarityCode, String hybridKind,
        boolean unlocked, boolean favorite, int lvl10, int lvl20, int lvl30, int lvl40, int targetLvl40,
        String currency, Long unitCost, long units, long unitsRemaining,
        double progress, boolean reached, long invested, long remaining) {

    public boolean tracked() {
        return targetLvl40 > 0;
    }

    public boolean done() {
        return tracked() && reached;
    }
}
