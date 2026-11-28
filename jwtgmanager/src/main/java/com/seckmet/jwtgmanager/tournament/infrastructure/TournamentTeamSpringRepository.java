package com.seckmet.jwtgmanager.tournament.infrastructure;

import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;
import java.util.UUID;

interface TournamentTeamSpringRepository extends JpaRepository<TournamentTeamJpaEntity, Long> {
    List<TournamentTeamJpaEntity> findByUserId(UUID userId);
}
