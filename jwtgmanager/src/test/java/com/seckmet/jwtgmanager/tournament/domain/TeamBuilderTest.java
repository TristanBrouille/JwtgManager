package com.seckmet.jwtgmanager.tournament.domain;

import org.junit.jupiter.api.Test;

import java.util.ArrayList;
import java.util.EnumMap;
import java.util.List;
import java.util.Map;
import java.util.Set;
import java.util.stream.Collectors;

import static com.seckmet.jwtgmanager.tournament.domain.CreatureClass.*;
import static org.assertj.core.api.Assertions.assertThat;

class TeamBuilderTest {

    /** Attaque = 0,31 × santé : profil équilibré, fureur ≈ 0,6225 × santé. */
    private static Fighter balanced(int id, CreatureClass c, int health) {
        return new Fighter(id, 40, c, health, (int) Math.round(health * 0.31));
    }

    private static TeamBuilder.Stock one(Fighter f) {
        return new TeamBuilder.Stock(f, 1);
    }

    private static int placed(TeamBuilder.Result r) {
        return r.teams().size() * 3;
    }

    private static int leftover(TeamBuilder.Result r) {
        return r.leftovers().stream().mapToInt(TeamBuilder.Stock::count).sum();
    }

    @Test
    void usesEverySpecimenWhenClassCountsAllowIt() {
        List<TeamBuilder.Stock> stocks = new ArrayList<>();
        // 6 herbivores et 3 amphibiens de fureurs très variées : 3 trios possibles, aucun reste.
        int[] herbivores = {300, 320, 900, 950, 2000, 2100};
        for (int i = 0; i < herbivores.length; i++) {
            stocks.add(one(balanced(i + 1, HERBIVORE, herbivores[i])));
        }
        stocks.add(one(balanced(10, AMPHIBIAN, 310)));
        stocks.add(one(balanced(11, AMPHIBIAN, 930)));
        stocks.add(one(balanced(12, AMPHIBIAN, 2050)));

        TeamBuilder.Result result = TeamBuilder.build(Tournament.JURASSIC, stocks);

        assertThat(result.teams()).hasSize(3);
        assertThat(result.leftovers()).isEmpty();
        // Le meilleur appariement regroupe les fureurs voisines : trois trios idéaux.
        assertThat(result.teams()).allSatisfy(t -> assertThat(t.quality()).isEqualTo(TeamQuality.IDEAL));
    }

    @Test
    void rejectsTwoWeakDinosWithOneStrong() {
        // 2 dinos à ~200 de fureur et 1 à ~2000 : total en prédateur, mais 200 < 400 et 2000 > 1200.
        List<TeamBuilder.Stock> stocks = List.of(
                one(balanced(1, SNOW, 321)), one(balanced(2, SNOW, 321)), one(balanced(3, CAVERN, 3212)));

        TeamBuilder.Result result = TeamBuilder.build(Tournament.CENOZOIC, stocks);

        assertThat(result.teams()).isEmpty();
        assertThat(leftover(result)).isEqualTo(3);
    }

    @Test
    void dominantNeedsEveryDinoAt800OrMore() {
        // 1250 + 1250 + 701 = 3201 : ligue dominant, mais 701 < 800.
        List<TeamBuilder.Stock> stocks = List.of(
                one(balanced(1, SURFACE, 2008)), one(balanced(2, SURFACE, 2008)), one(balanced(3, CAVE, 1125)));

        assertThat(TeamBuilder.build(Tournament.AQUATIC, stocks).teams()).isEmpty();
    }

    @Test
    void everyDinoFitsTheRangeOfItsLeague() {
        List<TeamBuilder.Stock> stocks = new ArrayList<>();
        int id = 1;
        for (int health = 150; health <= 3200; health += 23) {
            stocks.add(one(balanced(id++, id % 3 == 0 ? REEF : id % 3 == 1 ? CAVE : SURFACE, health)));
        }

        TeamBuilder.Result result = TeamBuilder.build(Tournament.AQUATIC, stocks);

        assertThat(result.teams()).isNotEmpty().allSatisfy(t ->
                assertThat(t.members()).allSatisfy(f -> assertThat(t.league().accepts(f.ferocity())).isTrue()));
        assertThat(placed(result) + leftover(result)).isEqualTo(stocks.size());
    }

    @Test
    void leavesOutOnlyWhatClassCountsForce() {
        // 7 carnivores pour 1 ptérosaure : un seul trio, 5 carnivores sans partenaire.
        List<TeamBuilder.Stock> stocks = List.of(
                new TeamBuilder.Stock(balanced(1, CARNIVORE, 400), 7), one(balanced(2, PTEROSAUR, 400)));

        TeamBuilder.Result result = TeamBuilder.build(Tournament.JURASSIC, stocks);

        assertThat(result.teams()).hasSize(1);
        assertThat(leftover(result)).isEqualTo(5);
    }

    @Test
    void neverPlacesASpecimenTwice() {
        List<TeamBuilder.Stock> stocks = List.of(
                new TeamBuilder.Stock(balanced(1, SURFACE, 400), 4),
                new TeamBuilder.Stock(balanced(2, CAVE, 420), 3),
                new TeamBuilder.Stock(balanced(3, REEF, 390), 2));

        TeamBuilder.Result result = TeamBuilder.build(Tournament.AQUATIC, stocks);

        Map<Integer, Integer> used = result.teams().stream().flatMap(t -> t.members().stream())
                .collect(Collectors.toMap(Fighter::speciesId, f -> 1, Integer::sum));
        assertThat(used.get(1)).isLessThanOrEqualTo(4);
        assertThat(used.get(2)).isLessThanOrEqualTo(3);
        assertThat(used.getOrDefault(3, 0)).isLessThanOrEqualTo(2);
        assertThat(placed(result) + leftover(result)).isEqualTo(9);
        assertThat(result.teams()).hasSize(3);
    }

    @Test
    void respectsJurassicPairings() {
        List<TeamBuilder.Stock> stocks = List.of(
                one(balanced(1, HERBIVORE, 400)), one(balanced(2, HERBIVORE, 420)),
                one(balanced(3, AMPHIBIAN, 410)), one(balanced(4, CARNIVORE, 400)),
                one(balanced(5, CARNIVORE, 405)), one(balanced(6, CARNIVORE, 405)));

        TeamBuilder.Result result = TeamBuilder.build(Tournament.JURASSIC, stocks);

        for (Team t : result.teams()) {
            Set<CreatureClass> classes = t.members().stream().map(Fighter::creatureClass).collect(Collectors.toSet());
            assertThat(classes).isIn(Set.of(HERBIVORE, AMPHIBIAN), Set.of(CARNIVORE, PTEROSAUR));
        }
        // Sans ptérosaure, les 3 carnivores restent sans trio.
        assertThat(result.teams()).hasSize(1);
        assertThat(leftover(result)).isEqualTo(3);
    }

    @Test
    void prefersATankWithAStrikerToTwoTanks() {
        Fighter tank = new Fighter(1, 40, REEF, 1000, 150);      // fureur 463
        Fighter striker = new Fighter(2, 40, REEF, 400, 340);    // fureur 465
        Fighter tank2 = new Fighter(3, 40, REEF, 1000, 160);     // fureur 473
        Fighter cave = balanced(4, CAVE, 750);                   // fureur 467
        Fighter cave2 = balanced(5, CAVE, 2000);

        TeamBuilder.Result result = TeamBuilder.build(Tournament.AQUATIC,
                List.of(one(tank), one(striker), one(tank2), one(cave), one(cave2)));

        assertThat(result.teams()).anySatisfy(t -> {
            assertThat(t.members()).contains(tank, striker, cave);
            assertThat(t.quality()).isEqualTo(TeamQuality.IDEAL);
        });
    }

    @Test
    void maxTeamsFollowsClassCounts() {
        Map<CreatureClass, Integer> counts = new EnumMap<>(CreatureClass.class);
        counts.put(SURFACE, 1);
        counts.put(CAVE, 1);
        counts.put(REEF, 1);
        assertThat(TeamBuilder.maxTeams(counts)).isZero();   // il faut 2 dinos d'une même classe
        counts.put(SURFACE, 2);
        assertThat(TeamBuilder.maxTeams(counts)).isEqualTo(1);
        counts.put(SURFACE, 10);
        assertThat(TeamBuilder.maxTeams(counts)).isEqualTo(2); // chaque trio a besoin d'une autre classe
    }

    @Test
    void groupsJurassicClassesByDuo() {
        assertThat(TeamBuilder.groups(Tournament.JURASSIC)).containsExactlyInAnyOrder(
                List.of(HERBIVORE, AMPHIBIAN), List.of(CARNIVORE, PTEROSAUR));
        assertThat(TeamBuilder.groups(Tournament.AQUATIC)).hasSize(1);
    }

    @Test
    void teamsAreRankedInTheLeagueOfTheirTotal() {
        TeamBuilder.Result result = TeamBuilder.build(Tournament.AQUATIC, List.of(
                one(balanced(1, SURFACE, 400)), one(balanced(2, SURFACE, 400)), one(balanced(3, CAVE, 400))));

        Team team = result.teams().getFirst();
        assertThat(team.totalFerocity()).isBetween(701, 800);
        assertThat(team.league()).isEqualTo(League.NEWBORN);
        assertThat(team.rank()).isEqualTo(1);
    }
}
