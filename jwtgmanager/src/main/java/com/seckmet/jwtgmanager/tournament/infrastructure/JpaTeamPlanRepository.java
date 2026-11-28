package com.seckmet.jwtgmanager.tournament.infrastructure;

import com.seckmet.jwtgmanager.tournament.domain.CreatureClass;
import com.seckmet.jwtgmanager.tournament.domain.Fighter;
import com.seckmet.jwtgmanager.tournament.domain.League;
import com.seckmet.jwtgmanager.tournament.domain.Team;
import com.seckmet.jwtgmanager.tournament.domain.TeamPlan;
import com.seckmet.jwtgmanager.tournament.domain.TeamPlanRepository;
import com.seckmet.jwtgmanager.tournament.domain.Tournament;
import org.springframework.stereotype.Repository;

import java.util.ArrayList;
import java.util.List;
import java.util.Optional;
import java.util.UUID;

@Repository
class JpaTeamPlanRepository implements TeamPlanRepository {

    private final TournamentPlanSpringRepository plans;
    private final TournamentTeamSpringRepository teams;
    private final TournamentLeftoverSpringRepository leftovers;

    JpaTeamPlanRepository(TournamentPlanSpringRepository plans, TournamentTeamSpringRepository teams,
                          TournamentLeftoverSpringRepository leftovers) {
        this.plans = plans;
        this.teams = teams;
        this.leftovers = leftovers;
    }

    @Override
    public Optional<TeamPlan> byUser(UUID userId) {
        return plans.findById(userId).map(p -> new TeamPlan(p.getUserId(), p.getComputedAt(),
                p.getCollectionHash(),
                teams.findByUserId(userId).stream().map(JpaTeamPlanRepository::toDomain).toList(),
                leftovers.findByIdUserId(userId).stream().map(JpaTeamPlanRepository::toDomain).toList()));
    }

    @Override
    public void replace(TeamPlan plan) {
        teams.deleteAllInBatch(teams.findByUserId(plan.userId()));
        leftovers.deleteAllInBatch(leftovers.findByIdUserId(plan.userId()));
        plans.saveAndFlush(new TournamentPlanJpaEntity(plan.userId(), plan.computedAt(), plan.collectionHash()));
        teams.saveAll(plan.teams().stream().map(t -> toEntity(plan.userId(), t)).toList());
        leftovers.saveAll(plan.leftovers().stream().map(l -> toEntity(plan.userId(), l)).toList());
    }

    private static TournamentTeamJpaEntity toEntity(UUID userId, Team t) {
        List<TournamentTeamJpaEntity.Member> members = new ArrayList<>();
        for (int i = 0; i < t.members().size(); i++) {
            Fighter f = t.members().get(i);
            members.add(new TournamentTeamJpaEntity.Member((short) (i + 1), f.speciesId(), (short) f.level(),
                    f.health(), f.attack(), f.ferocity(), f.profile().name()));
        }
        return new TournamentTeamJpaEntity(userId, t.tournament().name(), t.league().name(), (short) t.rank(),
                t.composition().pair().name(), t.composition().single().name(), t.totalFerocity(), members);
    }

    private static TournamentLeftoverJpaEntity toEntity(UUID userId, TeamPlan.Leftover l) {
        Fighter f = l.fighter();
        return new TournamentLeftoverJpaEntity(
                new TournamentLeftoverJpaEntity.Key(userId, l.tournament().name(), f.speciesId(), (short) f.level()),
                f.creatureClass().name(), f.health(), f.attack(), (short) l.count());
    }

    private static TeamPlan.Leftover toDomain(TournamentLeftoverJpaEntity e) {
        TournamentLeftoverJpaEntity.Key k = e.getId();
        return new TeamPlan.Leftover(Tournament.valueOf(k.tournament()),
                new Fighter(k.speciesId(), k.level(), CreatureClass.valueOf(e.getClassCode()), e.getHealth(),
                        e.getAttack()),
                e.getQuantity());
    }

    private static Team toDomain(TournamentTeamJpaEntity e) {
        Tournament.Composition composition = new Tournament.Composition(
                CreatureClass.valueOf(e.getPairClass()), CreatureClass.valueOf(e.getSingleClass()));
        List<Fighter> fighters = e.getMembers().stream()
                .sorted((a, b) -> Short.compare(a.slot(), b.slot()))
                .map(m -> new Fighter(m.speciesId(), m.level(),
                        m.slot() == 3 ? composition.single() : composition.pair(), m.health(), m.attack()))
                .toList();
        return new Team(Tournament.valueOf(e.getTournament()), League.valueOf(e.getLeague()), e.getRank(),
                composition, fighters);
    }
}
