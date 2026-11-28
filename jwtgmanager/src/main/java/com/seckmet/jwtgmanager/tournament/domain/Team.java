package com.seckmet.jwtgmanager.tournament.domain;

import java.util.List;
import java.util.Objects;

/** Trio proposé : les 2 dinos de la paire puis le dino seul. */
public record Team(Tournament tournament, League league, int rank, Tournament.Composition composition,
                   List<Fighter> members) {

    public Team {
        Objects.requireNonNull(tournament);
        Objects.requireNonNull(league);
        Objects.requireNonNull(composition);
        members = List.copyOf(members);
        if (members.size() != 3) {
            throw new IllegalArgumentException("Une équipe compte 3 dinos");
        }
    }

    public int totalFerocity() {
        return members.stream().mapToInt(Fighter::ferocity).sum();
    }

    public TeamQuality quality() {
        return TeamQuality.of(members.get(0), members.get(1), members.get(2));
    }

    /** Écart de fureur entre le plus fort et le plus faible du trio. */
    public int ferocityGap() {
        int max = members.stream().mapToInt(Fighter::ferocity).max().orElse(0);
        int min = members.stream().mapToInt(Fighter::ferocity).min().orElse(0);
        return max - min;
    }
}
