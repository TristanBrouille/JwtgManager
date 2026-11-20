package com.seckmet.jwtgmanager.collection.domain;

import com.seckmet.jwtgmanager.shared.domain.Currency;
import com.seckmet.jwtgmanager.shared.domain.Level;
import org.junit.jupiter.api.Test;

import java.util.Optional;
import java.util.UUID;

import static org.assertj.core.api.Assertions.assertThat;
import static org.assertj.core.api.Assertions.within;

class CompletionCalculatorTest {

    private static final UUID USER = UUID.randomUUID();

    @Test
    void unlockedSpecies_isPaidInDna() {
        PlayerSpecies triceratops = new PlayerSpecies(USER, 1, true, new SpecimenCounts(0, 0, 0, 3), 3, null);
        SpeciesProgress p = CompletionCalculator.progress(triceratops, new UnitCosts(100L, null, false));
        assertThat(p.currency()).isEqualTo(Currency.DNA);
        assertThat(p.invested()).isEqualTo(2400);
        assertThat(p.remaining()).isZero();
        assertThat(p.progress()).isEqualTo(1.0);
    }

    @Test
    void lockedSpecies_isPaidInAmber() {
        PlayerSpecies euoplo = new PlayerSpecies(USER, 2, false, new SpecimenCounts(1, 0, 0, 1), 3, null);
        SpeciesProgress p = CompletionCalculator.progress(euoplo, new UnitCosts(1000L, 25000L, false));
        assertThat(p.currency()).isEqualTo(Currency.AMBER);
        assertThat(p.invested()).isEqualTo(9 * 25000);
        assertThat(p.remaining()).isEqualTo((24 - 9) * 25000L);
        assertThat(p.progress()).isCloseTo((1 / 48.0 + 1) / 3, within(1e-9));
    }

    @Test
    void unlockedSuperHybrid_isPaidInSuperDna() {
        PlayerSpecies indoraptor = new PlayerSpecies(USER, 5, true, new SpecimenCounts(0, 0, 1, 0), 3, null);
        SpeciesProgress p = CompletionCalculator.progress(indoraptor, new UnitCosts(500L, null, true));
        assertThat(p.currency()).isEqualTo(Currency.SUPER_DNA);
        assertThat(p.invested()).isEqualTo(4 * 500);
    }

    @Test
    void lockedSuperHybrid_isPaidInAmber() {
        PlayerSpecies ps = new PlayerSpecies(USER, 6, false, SpecimenCounts.NONE, 3, null);
        assertThat(CompletionCalculator.progress(ps, new UnitCosts(500L, 20000L, true)).currency()).isEqualTo(Currency.AMBER);
    }

    @Test
    void unknownCost_countsProgressButNoMoney() {
        PlayerSpecies dodo = new PlayerSpecies(USER, 3, false, new SpecimenCounts(0, 1, 0, 0), 3, null);
        SpeciesProgress p = CompletionCalculator.progress(dodo, new UnitCosts(null, null, false));
        assertThat(p.unitCost()).isEmpty();
        assertThat(p.invested()).isZero();
        assertThat(p.remaining()).isZero();
        assertThat(p.units()).isEqualTo(2);
    }

    @Test
    void lockedSpecies_withoutAmberCost_fallsBackToDna() {
        PlayerSpecies dodo = new PlayerSpecies(USER, 3, false, new SpecimenCounts(0, 1, 0, 0), 3, null);
        SpeciesProgress p = CompletionCalculator.progress(dodo, new UnitCosts(5950L, null, false));
        assertThat(p.currency()).isEqualTo(Currency.DNA);
        assertThat(p.invested()).isEqualTo(2 * 5950);
        assertThat(p.remaining()).isEqualTo((24 - 2) * 5950L);
    }

    @Test
    void lockedSuperHybrid_withoutAmberCost_fallsBackToSuperDna() {
        PlayerSpecies ps = new PlayerSpecies(USER, 10, false, SpecimenCounts.NONE, 3, null);
        assertThat(CompletionCalculator.progress(ps, new UnitCosts(500L, null, true)).currency()).isEqualTo(Currency.SUPER_DNA);
    }

    @Test
    void lowerLevels_neverReachHundredPercent_withoutTheLevel40Target() {
        PlayerSpecies ps = new PlayerSpecies(USER, 7, true, new SpecimenCounts(0, 4, 4, 0), 3, null);
        SpeciesProgress p = CompletionCalculator.progress(ps, new UnitCosts(500L, null, false));
        assertThat(p.progress()).isCloseTo(0.7778, within(1e-4));
        assertThat(p.done()).isFalse();
        assertThat(p.remaining()).isZero();
    }

    @Test
    void sixLevel30_leaveNothingToPay_butAreNotFinished() {
        PlayerSpecies ps = new PlayerSpecies(USER, 9, true, new SpecimenCounts(0, 0, 6, 0), 3, null);
        SpeciesProgress p = CompletionCalculator.progress(ps, new UnitCosts(500L, null, false));
        assertThat(p.remaining()).isZero();
        assertThat(p.done()).isFalse();
        assertThat(p.progress()).isCloseTo(6 * 5 / 12.0 / 3, within(1e-9));
    }

    @Test
    void manyLevel30_areCappedBelowHundredPercent() {
        PlayerSpecies ps = new PlayerSpecies(USER, 8, true, new SpecimenCounts(0, 0, 9, 0), 3, null);
        assertThat(CompletionCalculator.progress(ps, new UnitCosts(100L, null, false)).progress()).isEqualTo(0.99);
    }

    @Test
    void progress_isCappedAtOne() {
        PlayerSpecies ps = new PlayerSpecies(USER, 4, true, new SpecimenCounts(0, 0, 0, 5), 3, null);
        assertThat(CompletionCalculator.progress(ps, new UnitCosts(100L, null, false)).progress()).isEqualTo(1.0);
    }

    @Test
    void levelUpCost_isMultiplierDifferenceTimesUnitCostTimesQuantity() {
        assertThat(CompletionCalculator.levelUpCost(Optional.empty(), Level.L40, 1, 3750)).isEqualTo(30000);
        assertThat(CompletionCalculator.levelUpCost(Optional.of(Level.L20), Level.L40, 2, 100)).isEqualTo(1200);
    }
}
