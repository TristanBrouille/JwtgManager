package com.seckmet.jwtgmanager.tournament.exposition;

import com.seckmet.jwtgmanager.tournament.application.TournamentView;

import java.time.Instant;
import java.util.List;

public record TournamentResponse(Instant computedAt, boolean outdated, List<Tournament> tournaments) {

    public record Tournament(String code, String label, int specimens, int placed, int teamCount, int idealTeams,
                             List<League> leagues, List<Leftover> leftovers) {
    }

    public record League(String code, String label, int above, Integer upTo, int minUnit, Integer maxUnit,
                         List<Team> teams) {
    }

    public record Team(int rank, int totalFerocity, int ferocityGap, String pairClass, String singleClass,
                       String quality, String qualityLabel, List<Member> members) {
    }

    public record Member(int speciesId, String name, int level, String creatureClass, int health, int attack,
                         int ferocity, String profile, String profileLabel, String portraitUrl) {
    }

    public record Leftover(Member specimen, int count) {
    }

    static TournamentResponse of(TournamentView v) {
        return new TournamentResponse(v.computedAt(), v.outdated(), v.tournaments().stream()
                .map(t -> new Tournament(t.code(), t.label(), t.specimens(), t.placed(), t.teamCount(),
                        t.idealTeams(),
                        t.leagues().stream()
                                .map(l -> new League(l.code(), l.label(), l.above(), l.upTo(), l.minUnit(), l.maxUnit(),
                                        l.teams().stream()
                                        .map(team -> new Team(team.rank(), team.totalFerocity(), team.ferocityGap(),
                                                team.pairClass(), team.singleClass(), team.quality(),
                                                team.qualityLabel(),
                                                team.members().stream().map(TournamentResponse::member).toList()))
                                        .toList()))
                                .toList(),
                        t.leftovers().stream().map(l -> new Leftover(member(l.specimen()), l.count())).toList()))
                .toList());
    }

    private static Member member(TournamentView.MemberView m) {
        return new Member(m.speciesId(), m.name(), m.level(), m.creatureClass(), m.health(), m.attack(),
                m.ferocity(), m.profile(), m.profileLabel(), m.portraitUrl());
    }
}
