package com.seckmet.jwtgmanager.tournament.application;

import java.time.Instant;
import java.util.List;

/**
 * Trios calculés du joueur, regroupés par tournoi puis par ligue.
 * {@code computedAt} est null si aucun calcul n'a encore été lancé ; {@code outdated} indique que la
 * collection a changé depuis le dernier calcul.
 */
public record TournamentView(Instant computedAt, boolean outdated, List<TournamentBlock> tournaments) {

    /**
     * {@code specimens} : dinos du joueur jouables dans ce tournoi ; {@code placed} : ceux répartis en
     * trios ; {@code leftovers} : ceux restés sans trio, faute de partenaire d'une autre classe.
     */
    public record TournamentBlock(String code, String label, int specimens, int placed, int teamCount,
                                  int idealTeams, List<LeagueBlock> leagues, List<LeftoverView> leftovers) {
    }

    public record LeftoverView(MemberView specimen, int count) {
    }

    /** {@code minUnit} / {@code maxUnit} : fureur autorisée pour chaque dino ({@code maxUnit} null si aucune). */
    public record LeagueBlock(String code, String label, int above, Integer upTo, int minUnit, Integer maxUnit,
                              List<TeamView> teams) {
    }

    public record TeamView(int rank, int totalFerocity, int ferocityGap, String pairClass, String singleClass,
                           String quality, String qualityLabel, List<MemberView> members) {
    }

    public record MemberView(int speciesId, String name, int level, String creatureClass, int health,
                             int attack, int ferocity, String profile, String profileLabel, String portraitUrl) {
    }
}
