package com.seckmet.jwtgmanager.investment.infrastructure;

import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.GenerationType;
import jakarta.persistence.Id;
import jakarta.persistence.Table;

import java.time.Instant;
import java.time.LocalDate;
import java.util.UUID;

@Entity
@Table(name = "investment")
public class InvestmentJpaEntity {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;
    @Column(name = "user_id", nullable = false)
    private UUID userId;
    @Column(name = "species_id", nullable = false)
    private Integer speciesId;
    @Column(name = "from_level")
    private Short fromLevel;
    @Column(name = "to_level", nullable = false)
    private Short toLevel;
    @Column(nullable = false)
    private Short quantity;
    @Column(nullable = false)
    private Integer cost;
    @Column(nullable = false)
    private String currency;
    @Column(name = "invested_on", nullable = false)
    private LocalDate investedOn;
    @Column(name = "created_at", nullable = false)
    private Instant createdAt;

    protected InvestmentJpaEntity() {
    }

    InvestmentJpaEntity(UUID userId, int speciesId, Short fromLevel, short toLevel, short quantity, int cost,
                        String currency, LocalDate investedOn) {
        this.userId = userId;
        this.speciesId = speciesId;
        this.fromLevel = fromLevel;
        this.toLevel = toLevel;
        this.quantity = quantity;
        this.cost = cost;
        this.currency = currency;
        this.investedOn = investedOn;
        this.createdAt = Instant.now();
    }

    public Long getId() { return id; }
    public UUID getUserId() { return userId; }
    public Integer getSpeciesId() { return speciesId; }
    public Short getFromLevel() { return fromLevel; }
    public Short getToLevel() { return toLevel; }
    public Short getQuantity() { return quantity; }
    public Integer getCost() { return cost; }
    public String getCurrency() { return currency; }
    public LocalDate getInvestedOn() { return investedOn; }
}
