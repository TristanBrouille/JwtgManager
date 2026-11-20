package com.seckmet.jwtgmanager.catalog.application;

public record SpeciesView(int id, String name, String rarityCode, Long dnaCost, Long amberCost,
                          String hybridKind, boolean defaultUnlocked) {

    public boolean hybrid() {
        return !"NONE".equals(hybridKind);
    }
}
