package com.seckmet.jwtgmanager.catalog.infrastructure;

import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.Id;
import jakarta.persistence.Table;

import java.time.LocalDate;

@Entity
@Table(name = "creature_sheet")
public class CreatureSheetJpaEntity {
    @Id
    @Column(name = "species_id")
    private Integer speciesId;
    @Column(name = "source_key", nullable = false, unique = true)
    private String sourceKey;
    private String region;
    @Column(name = "creature_class")
    private String creatureClass;
    @Column(name = "release_date")
    private LocalDate releaseDate;
    @Column(name = "health_lvl10") private Integer healthLvl10;
    @Column(name = "health_lvl20") private Integer healthLvl20;
    @Column(name = "health_lvl30") private Integer healthLvl30;
    @Column(name = "health_lvl40") private Integer healthLvl40;
    @Column(name = "attack_lvl10") private Integer attackLvl10;
    @Column(name = "attack_lvl20") private Integer attackLvl20;
    @Column(name = "attack_lvl30") private Integer attackLvl30;
    @Column(name = "attack_lvl40") private Integer attackLvl40;
    private Integer ferocity;
    private Long coins;
    @Column(name = "coin_minutes") private Integer coinMinutes;
    @Column(name = "coins_per_minute") private Integer coinsPerMinute;
    @Column(name = "hatch_minutes") private Integer hatchMinutes;
    @Column(name = "dna_buy") private Long dnaBuy;
    @Column(name = "dna_sell") private Long dnaSell;

    protected CreatureSheetJpaEntity() {
    }

    public Integer getSpeciesId() { return speciesId; }
    public String getSourceKey() { return sourceKey; }
    public String getRegion() { return region; }
    public String getCreatureClass() { return creatureClass; }
    public LocalDate getReleaseDate() { return releaseDate; }
    public Integer getHealthLvl10() { return healthLvl10; }
    public Integer getHealthLvl20() { return healthLvl20; }
    public Integer getHealthLvl30() { return healthLvl30; }
    public Integer getHealthLvl40() { return healthLvl40; }
    public Integer getAttackLvl10() { return attackLvl10; }
    public Integer getAttackLvl20() { return attackLvl20; }
    public Integer getAttackLvl30() { return attackLvl30; }
    public Integer getAttackLvl40() { return attackLvl40; }
    public Integer getFerocity() { return ferocity; }
    public Long getCoins() { return coins; }
    public Integer getCoinMinutes() { return coinMinutes; }
    public Integer getCoinsPerMinute() { return coinsPerMinute; }
    public Integer getHatchMinutes() { return hatchMinutes; }
    public Long getDnaBuy() { return dnaBuy; }
    public Long getDnaSell() { return dnaSell; }
}
