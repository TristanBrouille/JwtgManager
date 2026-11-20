package com.seckmet.jwtgmanager.catalog.infrastructure;

import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.GenerationType;
import jakarta.persistence.Id;
import jakarta.persistence.Table;
import org.hibernate.annotations.JdbcTypeCode;
import org.hibernate.type.SqlTypes;

@Entity
@Table(name = "species")
public class SpeciesJpaEntity {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Integer id;
    @Column(nullable = false, unique = true)
    private String name;
    @JdbcTypeCode(SqlTypes.CHAR)
    @Column(name = "rarity_code", length = 1, nullable = false)
    private String rarityCode;
    @Column(name = "dna_cost")
    private Integer dnaCost;
    @Column(name = "amber_cost")
    private Integer amberCost;
    @Column(name = "hybrid_kind", nullable = false)
    private String hybridKind;
    @Column(name = "default_unlocked", nullable = false)
    private boolean defaultUnlocked;

    protected SpeciesJpaEntity() {
    }

    public Integer getId() { return id; }
    public String getName() { return name; }
    public String getRarityCode() { return rarityCode; }
    public Integer getDnaCost() { return dnaCost; }
    public Integer getAmberCost() { return amberCost; }
    public String getHybridKind() { return hybridKind; }
    public boolean isDefaultUnlocked() { return defaultUnlocked; }
}
