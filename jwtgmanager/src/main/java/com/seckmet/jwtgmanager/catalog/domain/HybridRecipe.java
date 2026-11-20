package com.seckmet.jwtgmanager.catalog.domain;

import java.util.List;

/** Un hybride et les espèces qui le composent. */
public record HybridRecipe(int hybridId, List<Integer> componentIds) {
    public HybridRecipe {
        componentIds = List.copyOf(componentIds);
        if (componentIds.contains(hybridId)) {
            throw new IllegalArgumentException("Un hybride ne peut pas être son propre composant");
        }
    }
}
