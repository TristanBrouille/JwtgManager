package com.seckmet.jwtgmanager.progress.infrastructure;

import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.GenerationType;
import jakarta.persistence.Id;
import jakarta.persistence.Table;

import java.math.BigDecimal;
import java.time.LocalDate;
import java.util.UUID;

@Entity
@Table(name = "progress_snapshot")
public class ProgressSnapshotJpaEntity {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;
    @Column(name = "user_id", nullable = false)
    private UUID userId;
    @Column(name = "taken_on", nullable = false)
    private LocalDate takenOn;
    @Column(name = "completion_pct", nullable = false, precision = 5, scale = 2)
    private BigDecimal completionPct;
    @Column(name = "lvl40_count", nullable = false)
    private Integer lvl40Count;
    @Column(name = "lvl40_target", nullable = false)
    private Integer lvl40Target;
    @Column(name = "dna_remaining", nullable = false)
    private Long dnaRemaining;
    @Column(name = "super_dna_remaining", nullable = false)
    private Long superDnaRemaining;
    @Column(name = "amber_remaining", nullable = false)
    private Long amberRemaining;

    protected ProgressSnapshotJpaEntity() {
    }

    ProgressSnapshotJpaEntity(UUID userId, LocalDate takenOn) {
        this.userId = userId;
        this.takenOn = takenOn;
    }

    void update(BigDecimal completionPct, int lvl40Count, int lvl40Target, long dnaRemaining, long superDnaRemaining,
                long amberRemaining) {
        this.completionPct = completionPct;
        this.lvl40Count = lvl40Count;
        this.lvl40Target = lvl40Target;
        this.dnaRemaining = dnaRemaining;
        this.superDnaRemaining = superDnaRemaining;
        this.amberRemaining = amberRemaining;
    }

    public UUID getUserId() { return userId; }
    public LocalDate getTakenOn() { return takenOn; }
    public BigDecimal getCompletionPct() { return completionPct; }
    public Integer getLvl40Count() { return lvl40Count; }
    public Integer getLvl40Target() { return lvl40Target; }
    public Long getDnaRemaining() { return dnaRemaining; }
    public Long getSuperDnaRemaining() { return superDnaRemaining; }
    public Long getAmberRemaining() { return amberRemaining; }
}
