package com.seckmet.jwtgmanager.collection.infrastructure;

import org.springframework.data.jpa.repository.JpaRepository;

import java.util.UUID;

interface PlayerSettingsSpringRepository extends JpaRepository<PlayerSettingsJpaEntity, UUID> {
}
