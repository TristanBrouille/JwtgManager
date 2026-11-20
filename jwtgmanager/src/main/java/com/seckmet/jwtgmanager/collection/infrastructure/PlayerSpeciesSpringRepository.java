package com.seckmet.jwtgmanager.collection.infrastructure;

import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;
import java.util.UUID;

interface PlayerSpeciesSpringRepository extends JpaRepository<PlayerSpeciesJpaEntity, PlayerSpeciesJpaEntity.Key> {
    List<PlayerSpeciesJpaEntity> findByIdUserId(UUID userId);
}
