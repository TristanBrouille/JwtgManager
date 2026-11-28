package com.seckmet.jwtgmanager.tournament.infrastructure;

import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.Id;
import jakarta.persistence.Table;

import java.time.Instant;
import java.util.UUID;

@Entity
@Table(name = "tournament_plan")
public class TournamentPlanJpaEntity {
    @Id
    @Column(name = "user_id")
    private UUID userId;
    @Column(name = "computed_at", nullable = false)
    private Instant computedAt;
    @Column(name = "collection_hash", nullable = false)
    private String collectionHash;

    protected TournamentPlanJpaEntity() {
    }

    TournamentPlanJpaEntity(UUID userId, Instant computedAt, String collectionHash) {
        this.userId = userId;
        this.computedAt = computedAt;
        this.collectionHash = collectionHash;
    }

    public UUID getUserId() { return userId; }
    public Instant getComputedAt() { return computedAt; }
    public String getCollectionHash() { return collectionHash; }
}
