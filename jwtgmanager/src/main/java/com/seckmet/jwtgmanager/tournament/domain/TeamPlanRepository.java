package com.seckmet.jwtgmanager.tournament.domain;

import java.util.Optional;
import java.util.UUID;

public interface TeamPlanRepository {
    Optional<TeamPlan> byUser(UUID userId);

    /** Remplace les trios précédents du joueur. */
    void replace(TeamPlan plan);
}
