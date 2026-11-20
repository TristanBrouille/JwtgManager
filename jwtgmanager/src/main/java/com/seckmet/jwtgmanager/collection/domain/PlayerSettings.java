package com.seckmet.jwtgmanager.collection.domain;

import com.seckmet.jwtgmanager.shared.domain.InvalidLevelUpException;

import java.util.Objects;
import java.util.UUID;

/** Réglages du joueur : revenus hebdomadaires (ADN, super ADN, ambre) et objectif par défaut. */
public class PlayerSettings {
    private final UUID userId;
    private long weeklyDna;
    private long weeklySuperDna;
    private long weeklyAmber;
    private int defaultTarget;

    public PlayerSettings(UUID userId, long weeklyDna, long weeklySuperDna, long weeklyAmber, int defaultTarget) {
        this.userId = Objects.requireNonNull(userId);
        update(weeklyDna, weeklySuperDna, weeklyAmber, defaultTarget);
    }

    public static PlayerSettings defaults(UUID userId) {
        return new PlayerSettings(userId, 0, 0, 0, 3);
    }

    public void update(long weeklyDna, long weeklySuperDna, long weeklyAmber, int defaultTarget) {
        if (weeklyDna < 0 || weeklySuperDna < 0 || weeklyAmber < 0) {
            throw new InvalidLevelUpException("Les revenus hebdomadaires ne peuvent pas être négatifs");
        }
        if (defaultTarget < 0 || defaultTarget > PlayerSpecies.MAX_TARGET) {
            throw new InvalidLevelUpException("L'objectif par défaut doit être compris entre 0 et " + PlayerSpecies.MAX_TARGET);
        }
        this.weeklyDna = weeklyDna;
        this.weeklySuperDna = weeklySuperDna;
        this.weeklyAmber = weeklyAmber;
        this.defaultTarget = defaultTarget;
    }

    public UUID userId() { return userId; }
    public long weeklyDna() { return weeklyDna; }
    public long weeklySuperDna() { return weeklySuperDna; }
    public long weeklyAmber() { return weeklyAmber; }
    public int defaultTarget() { return defaultTarget; }
}
