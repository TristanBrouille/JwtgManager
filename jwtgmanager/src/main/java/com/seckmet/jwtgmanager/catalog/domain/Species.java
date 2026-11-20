package com.seckmet.jwtgmanager.catalog.domain;

import java.util.Objects;
import java.util.OptionalLong;

/**
 * Espèce du catalogue du jeu. Les coûts sont ceux d'un palier unitaire (niv. 10) ;
 * un coût absent signifie qu'il n'est pas encore renseigné.
 */
public record Species(int id, String name, String rarityCode, Long dnaCost, Long amberCost,
                      HybridKind hybridKind, boolean defaultUnlocked) {

    public Species {
        Objects.requireNonNull(name);
        Objects.requireNonNull(rarityCode);
        Objects.requireNonNull(hybridKind);
        if (dnaCost != null && dnaCost < 0 || amberCost != null && amberCost < 0) {
            throw new IllegalArgumentException("Un coût ne peut pas être négatif");
        }
    }

    public boolean hybrid() {
        return hybridKind.isHybrid();
    }

    public OptionalLong dnaCostValue() {
        return dnaCost == null ? OptionalLong.empty() : OptionalLong.of(dnaCost);
    }

    public OptionalLong amberCostValue() {
        return amberCost == null ? OptionalLong.empty() : OptionalLong.of(amberCost);
    }
}
