package com.seckmet.jwtgmanager.progress.infrastructure;

import com.seckmet.jwtgmanager.progress.domain.ProgressSnapshot;
import com.seckmet.jwtgmanager.progress.domain.ProgressSnapshotRepository;
import org.springframework.stereotype.Repository;

import java.math.BigDecimal;
import java.math.RoundingMode;
import java.util.List;
import java.util.UUID;

@Repository
class JpaProgressSnapshotRepository implements ProgressSnapshotRepository {

    private final ProgressSnapshotSpringRepository jpa;

    JpaProgressSnapshotRepository(ProgressSnapshotSpringRepository jpa) {
        this.jpa = jpa;
    }

    @Override
    public List<ProgressSnapshot> byUser(UUID userId) {
        return jpa.findByUserIdOrderByTakenOnAsc(userId).stream()
                .map(e -> new ProgressSnapshot(e.getUserId(), e.getTakenOn(),
                        e.getCompletionPct().doubleValue() / 100.0, e.getLvl40Count(), e.getLvl40Target(),
                        e.getDnaRemaining(), e.getSuperDnaRemaining(), e.getAmberRemaining()))
                .toList();
    }

    @Override
    public void upsert(ProgressSnapshot s) {
        ProgressSnapshotJpaEntity entity = jpa.findByUserIdAndTakenOn(s.userId(), s.takenOn())
                .orElseGet(() -> new ProgressSnapshotJpaEntity(s.userId(), s.takenOn()));
        entity.update(BigDecimal.valueOf(s.completion() * 100).setScale(2, RoundingMode.HALF_UP),
                Math.toIntExact(s.lvl40Count()), Math.toIntExact(s.lvl40Target()),
                s.dnaRemaining(), s.superDnaRemaining(), s.amberRemaining());
        jpa.save(entity);
    }
}
