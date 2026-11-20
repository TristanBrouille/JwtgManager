package com.seckmet.jwtgmanager.catalog.domain;

/**
 * Nature d'une espèce : espèce de base, hybride (fusion de deux espèces)
 * ou super hybride (hybride dont au moins un composant est lui-même un hybride).
 */
public enum HybridKind {
    NONE, HYBRID, SUPER_HYBRID;

    public boolean isHybrid() {
        return this != NONE;
    }
}
