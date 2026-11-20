package com.seckmet.jwtgmanager.catalog.infrastructure;

import org.springframework.data.jpa.repository.JpaRepository;

interface HybridRecipeSpringRepository extends JpaRepository<HybridRecipeJpaEntity, HybridRecipeJpaEntity.Key> {
}
