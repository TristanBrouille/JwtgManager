package com.seckmet.jwtgmanager.collection.domain;

import org.junit.jupiter.api.Test;

import java.util.UUID;

import static org.assertj.core.api.Assertions.assertThat;

class PlayerSpeciesTest {

    @Test
    void favorite_canBePinnedAndUnpinned() {
        PlayerSpecies rex = PlayerSpecies.start(UUID.randomUUID(), 1, true, 3);
        assertThat(rex.favorite()).isFalse();
        rex.markFavorite(true);
        assertThat(rex.favorite()).isTrue();
        rex.markFavorite(false);
        assertThat(rex.favorite()).isFalse();
    }
}
