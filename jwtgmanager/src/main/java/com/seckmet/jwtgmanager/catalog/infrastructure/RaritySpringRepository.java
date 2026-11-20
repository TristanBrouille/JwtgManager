package com.seckmet.jwtgmanager.catalog.infrastructure;

import org.springframework.data.jpa.repository.JpaRepository;

interface RaritySpringRepository extends JpaRepository<RarityJpaEntity, String> {
}
