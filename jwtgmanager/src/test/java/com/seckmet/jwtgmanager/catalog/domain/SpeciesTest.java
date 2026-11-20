package com.seckmet.jwtgmanager.catalog.domain;

import org.junit.jupiter.api.Test;

import static org.assertj.core.api.Assertions.assertThat;

class SpeciesTest {

    @Test
    void superHybrid_isAlsoAHybrid() {
        Species indoraptor = new Species(1, "Indoraptor", "L", null, null, HybridKind.SUPER_HYBRID, false);
        Species triceratops = new Species(2, "Triceratops", "C", 100L, null, HybridKind.NONE, true);
        assertThat(indoraptor.hybrid()).isTrue();
        assertThat(triceratops.hybrid()).isFalse();
    }
}
