package com.seckmet.jwtgmanager.collection.domain;

import com.seckmet.jwtgmanager.shared.domain.InvalidLevelUpException;
import com.seckmet.jwtgmanager.shared.domain.Level;
import org.junit.jupiter.api.Test;

import java.util.Optional;

import static org.assertj.core.api.Assertions.assertThat;
import static org.assertj.core.api.Assertions.assertThatThrownBy;
import static org.assertj.core.api.Assertions.within;

class SpecimenCountsTest {

    @Test
    void units_weightEachLevelByItsMultiplier() {
        assertThat(new SpecimenCounts(1, 1, 1, 1).units()).isEqualTo(1 + 2 + 4 + 8);
        assertThat(new SpecimenCounts(0, 4, 4, 0).units()).isEqualTo(24);
    }

    @Test
    void lvl40Equivalent_followsTheExcelFormula() {
        assertThat(new SpecimenCounts(0, 0, 0, 3).lvl40Equivalent()).isEqualTo(3.0);
        assertThat(new SpecimenCounts(0, 4, 4, 0).lvl40Equivalent() / 3).isCloseTo(0.7778, within(1e-4));
        assertThat(new SpecimenCounts(1, 0, 0, 1).lvl40Equivalent() / 3).isCloseTo(0.3403, within(1e-4));
    }

    @Test
    void unitsToReach_countsAllInvestedDna_likeExcelRest() {
        assertThat(new SpecimenCounts(0, 0, 0, 3).unitsToReach(3)).isZero();
        assertThat(new SpecimenCounts(0, 0, 6, 0).unitsToReach(3)).isZero();
        assertThat(new SpecimenCounts(0, 4, 4, 0).unitsToReach(3)).isZero();
        assertThat(new SpecimenCounts(1, 0, 0, 1).unitsToReach(3)).isEqualTo(24 - 9);
        assertThat(SpecimenCounts.NONE.unitsToReach(3)).isEqualTo(24);
    }

    @Test
    void reached_onlyWithTheLevel40Target() {
        assertThat(new SpecimenCounts(0, 0, 6, 0).reached(3)).isFalse();
        assertThat(new SpecimenCounts(0, 0, 0, 3).reached(3)).isTrue();
    }

    @Test
    void levelUp_fromNewSpecimen_addsAtTargetLevel() {
        SpecimenCounts result = SpecimenCounts.NONE.levelUp(Optional.empty(), Level.L40, 2);
        assertThat(result).isEqualTo(new SpecimenCounts(0, 0, 0, 2));
    }

    @Test
    void levelUp_movesSpecimensBetweenLevels() {
        SpecimenCounts result = new SpecimenCounts(0, 3, 0, 0).levelUp(Optional.of(Level.L20), Level.L30, 2);
        assertThat(result).isEqualTo(new SpecimenCounts(0, 1, 2, 0));
    }

    @Test
    void levelUp_refusesWhenNotEnoughSpecimens() {
        assertThatThrownBy(() -> new SpecimenCounts(1, 0, 0, 0).levelUp(Optional.of(Level.L10), Level.L40, 2))
                .isInstanceOf(NotEnoughSpecimensException.class);
    }

    @Test
    void levelUp_refusesDowngrade() {
        assertThatThrownBy(() -> new SpecimenCounts(0, 0, 1, 0).levelUp(Optional.of(Level.L30), Level.L20, 1))
                .isInstanceOf(InvalidLevelUpException.class);
    }

    @Test
    void revertLevelUp_restoresPreviousCounts() {
        SpecimenCounts before = new SpecimenCounts(2, 1, 0, 0);
        SpecimenCounts after = before.levelUp(Optional.of(Level.L10), Level.L30, 2);
        assertThat(after.revertLevelUp(Optional.of(Level.L10), Level.L30, 2)).isEqualTo(before);
    }
}
