package com.seckmet.jwtgmanager.collection.infrastructure;

import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.Id;
import jakarta.persistence.Table;

import java.util.UUID;

@Entity
@Table(name = "player_settings")
public class PlayerSettingsJpaEntity {
    @Id
    @Column(name = "user_id")
    private UUID userId;
    @Column(name = "weekly_dna", nullable = false)
    private Integer weeklyDna;
    @Column(name = "weekly_super_dna", nullable = false)
    private Integer weeklySuperDna;
    @Column(name = "weekly_amber", nullable = false)
    private Integer weeklyAmber;
    @Column(name = "default_target", nullable = false)
    private Short defaultTarget;

    protected PlayerSettingsJpaEntity() {
    }

    PlayerSettingsJpaEntity(UUID userId, int weeklyDna, int weeklySuperDna, int weeklyAmber, short defaultTarget) {
        this.userId = userId;
        this.weeklyDna = weeklyDna;
        this.weeklySuperDna = weeklySuperDna;
        this.weeklyAmber = weeklyAmber;
        this.defaultTarget = defaultTarget;
    }

    public UUID getUserId() { return userId; }
    public Integer getWeeklyDna() { return weeklyDna; }
    public Integer getWeeklySuperDna() { return weeklySuperDna; }
    public Integer getWeeklyAmber() { return weeklyAmber; }
    public Short getDefaultTarget() { return defaultTarget; }
}
