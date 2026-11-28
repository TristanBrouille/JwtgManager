package com.seckmet.jwtgmanager.tournament.domain;

import org.junit.jupiter.api.Test;

import static org.assertj.core.api.Assertions.assertThat;

class FighterTest {

    @Test
    void ferocityMatchesTheGameAtEveryLevel() {
        // Vélociraptor, wiki Jurassic World : santé 217/371/565/800, attaque 83/142/216/306.
        assertThat(Fighter.ferocityOf(217, 83)).isEqualTo(151);
        assertThat(Fighter.ferocityOf(371, 142)).isEqualTo(258);
        assertThat(Fighter.ferocityOf(565, 216)).isEqualTo(393);
        assertThat(Fighter.ferocityOf(800, 306)).isEqualTo(556);
        // Acrocanthosaurus niveau 40 (paleo.gg) : fureur 2993.
        assertThat(Fighter.ferocityOf(4309, 1646)).isEqualTo(2993);
    }

    @Test
    void profileFollowsAttackToHealthRatio() {
        assertThat(Profile.of(1000, 150)).isEqualTo(Profile.TANK);
        assertThat(Profile.of(1000, 310)).isEqualTo(Profile.BALANCED);
        assertThat(Profile.of(1000, 730)).isEqualTo(Profile.STRIKER);
    }

    @Test
    void pairNeedsTwoBalancedOrATankWithAStriker() {
        assertThat(Profile.pairWorks(Profile.BALANCED, Profile.BALANCED)).isTrue();
        assertThat(Profile.pairWorks(Profile.TANK, Profile.STRIKER)).isTrue();
        assertThat(Profile.pairWorks(Profile.STRIKER, Profile.TANK)).isTrue();
        assertThat(Profile.pairWorks(Profile.TANK, Profile.TANK)).isFalse();
        assertThat(Profile.pairWorks(Profile.BALANCED, Profile.STRIKER)).isFalse();
    }

    @Test
    void leagueBoundsBelongToTheLowerLeague() {
        assertThat(League.of(0)).contains(League.NEWBORN);
        assertThat(League.of(800)).contains(League.NEWBORN);
        assertThat(League.of(801)).contains(League.HUNTER);
        assertThat(League.of(1500)).contains(League.HUNTER);
        assertThat(League.of(3000)).contains(League.PREDATOR);
        assertThat(League.of(3001)).contains(League.DOMINANT);
    }

    @Test
    void eachLeagueBoundsTheFerocityOfEveryDino() {
        assertThat(League.DOMINANT.accepts(799)).isFalse();
        assertThat(League.DOMINANT.accepts(800)).isTrue();
        assertThat(League.PREDATOR.accepts(1200)).isTrue();
        assertThat(League.PREDATOR.accepts(1201)).isFalse();
        assertThat(League.PREDATOR.accepts(399)).isFalse();
        assertThat(League.NEWBORN.accepts(321)).isFalse();
    }

    @Test
    void dualClassCountsForItsMainClass() {
        assertThat(CreatureClass.fromCode("carnivore-surface")).contains(CreatureClass.CARNIVORE);
        assertThat(CreatureClass.fromCode("inconnu")).isEmpty();
    }
}
