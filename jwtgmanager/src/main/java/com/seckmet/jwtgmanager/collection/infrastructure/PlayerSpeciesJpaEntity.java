package com.seckmet.jwtgmanager.collection.infrastructure;

import jakarta.persistence.Column;
import jakarta.persistence.Embeddable;
import jakarta.persistence.EmbeddedId;
import jakarta.persistence.Entity;
import jakarta.persistence.Table;

import java.io.Serializable;
import java.time.Instant;
import java.util.UUID;

@Entity
@Table(name = "player_species")
public class PlayerSpeciesJpaEntity {

    @Embeddable
    public record Key(@Column(name = "user_id") UUID userId,
                      @Column(name = "species_id") Integer speciesId) implements Serializable {
    }

    @EmbeddedId
    private Key id;
    @Column(nullable = false)
    private boolean unlocked;
    @Column(name = "count_lvl10", nullable = false)
    private Short lvl10;
    @Column(name = "count_lvl20", nullable = false)
    private Short lvl20;
    @Column(name = "count_lvl30", nullable = false)
    private Short lvl30;
    @Column(name = "count_lvl40", nullable = false)
    private Short lvl40;
    @Column(name = "target_lvl40", nullable = false)
    private Short targetLvl40;
    @Column(nullable = false)
    private boolean favorite;
    @Column(name = "updated_at", nullable = false)
    private Instant updatedAt;

    protected PlayerSpeciesJpaEntity() {
    }

    PlayerSpeciesJpaEntity(Key id, boolean unlocked, short lvl10, short lvl20, short lvl30, short lvl40,
                           short targetLvl40, boolean favorite, Instant updatedAt) {
        this.id = id;
        this.unlocked = unlocked;
        this.lvl10 = lvl10;
        this.lvl20 = lvl20;
        this.lvl30 = lvl30;
        this.lvl40 = lvl40;
        this.targetLvl40 = targetLvl40;
        this.favorite = favorite;
        this.updatedAt = updatedAt;
    }

    public Key getId() { return id; }
    public boolean isUnlocked() { return unlocked; }
    public Short getLvl10() { return lvl10; }
    public Short getLvl20() { return lvl20; }
    public Short getLvl30() { return lvl30; }
    public Short getLvl40() { return lvl40; }
    public Short getTargetLvl40() { return targetLvl40; }
    public boolean isFavorite() { return favorite; }
    public Instant getUpdatedAt() { return updatedAt; }
}
