package com.seckmet.jwtgmanager.investment.infrastructure;

import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;
import java.util.Optional;
import java.util.UUID;

interface InvestmentSpringRepository extends JpaRepository<InvestmentJpaEntity, Long> {
    List<InvestmentJpaEntity> findByUserId(UUID userId);

    Optional<InvestmentJpaEntity> findByIdAndUserId(Long id, UUID userId);
}
