package com.seckmet.jwtgmanager.progress.infrastructure;

import org.springframework.data.jpa.repository.JpaRepository;

import java.time.LocalDate;
import java.util.List;
import java.util.Optional;
import java.util.UUID;

interface ProgressSnapshotSpringRepository extends JpaRepository<ProgressSnapshotJpaEntity, Long> {
    List<ProgressSnapshotJpaEntity> findByUserIdOrderByTakenOnAsc(UUID userId);

    Optional<ProgressSnapshotJpaEntity> findByUserIdAndTakenOn(UUID userId, LocalDate takenOn);
}
