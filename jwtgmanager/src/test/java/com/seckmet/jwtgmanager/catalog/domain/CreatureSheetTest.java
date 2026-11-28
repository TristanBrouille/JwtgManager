package com.seckmet.jwtgmanager.catalog.domain;

import org.junit.jupiter.api.Test;

import java.time.LocalDate;
import java.util.List;

import static org.assertj.core.api.Assertions.assertThat;
import static org.assertj.core.api.Assertions.assertThatThrownBy;

class CreatureSheetTest {

    @Test
    void keepsOneValuePerLevel() {
        CreatureSheet acro = sheet(List.of(1166, 1998, 3046, 4309), List.of(446, 763, 1163, 1646));
        assertThat(acro.health()).containsExactly(1166, 1998, 3046, 4309);
        assertThat(acro.attack().getLast()).isEqualTo(1646);
    }

    @Test
    void rejectsIncompleteLevels() {
        assertThatThrownBy(() -> sheet(List.of(1166, 1998), List.of(446, 763, 1163, 1646)))
                .isInstanceOf(IllegalArgumentException.class);
    }

    private static CreatureSheet sheet(List<Integer> health, List<Integer> attack) {
        return new CreatureSheet(1, "acrocanthosaurus", "Jurassique", "Carnivore", "jurassic", "carnivore",
                LocalDate.of(2017, 11, 3),
                health, attack, 2993, 230_400L, 180, 1280, 360, 10_000L, 5_000L);
    }
}
