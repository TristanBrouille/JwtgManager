package com.seckmet.jwtgmanager.tournament.domain;

import java.time.Instant;
import java.util.List;
import java.util.Objects;
import java.util.UUID;

/**
 * Trios calculés pour un joueur, avec les spécimens restés sans trio et l'empreinte de sa collection
 * au moment du calcul.
 */
public record TeamPlan(UUID userId, Instant computedAt, String collectionHash, List<Team> teams,
                       List<Leftover> leftovers) {

    /** Spécimens identiques non placés dans un tournoi. */
    public record Leftover(Tournament tournament, Fighter fighter, int count) {
    }


    public TeamPlan {
        Objects.requireNonNull(userId);
        Objects.requireNonNull(computedAt);
        Objects.requireNonNull(collectionHash);
        teams = List.copyOf(teams);
        leftovers = List.copyOf(leftovers);
    }
}
