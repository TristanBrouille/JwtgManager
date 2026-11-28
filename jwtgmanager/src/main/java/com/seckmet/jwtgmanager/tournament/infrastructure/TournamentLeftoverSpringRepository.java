package com.seckmet.jwtgmanager.tournament.infrastructure;

import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;
import java.util.UUID;

interface TournamentLeftoverSpringRepository
        extends JpaRepository<TournamentLeftoverJpaEntity, TournamentLeftoverJpaEntity.Key> {
    List<TournamentLeftoverJpaEntity> findByIdUserId(UUID userId);
}
