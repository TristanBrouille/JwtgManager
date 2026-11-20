package com.seckmet.jwtgmanager.catalog.infrastructure;

import org.springframework.data.jpa.repository.JpaRepository;

interface SpeciesSpringRepository extends JpaRepository<SpeciesJpaEntity, Integer> {
}
