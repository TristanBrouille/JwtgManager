package com.seckmet.jwtgmanager.collection.domain;

import com.seckmet.jwtgmanager.shared.domain.InvalidLevelUpException;


import com.seckmet.jwtgmanager.shared.domain.Level;

import java.time.Instant;
import java.util.Objects;
import java.util.Optional;
import java.util.UUID;

/** Suivi d'une espèce par un joueur : déblocage, spécimens par palier et objectif de niveaux 40. */
public class PlayerSpecies {
    public static final int MAX_TARGET = 99;

    private final UUID userId;
    private final int speciesId;
    private boolean unlocked;
    private SpecimenCounts counts;
    private int targetLvl40;
    private boolean favorite;
    private Instant updatedAt;

    public PlayerSpecies(UUID userId, int speciesId, boolean unlocked, SpecimenCounts counts,
                         int targetLvl40, Instant updatedAt) {
        this(userId, speciesId, unlocked, counts, targetLvl40, false, updatedAt);
    }

    public PlayerSpecies(UUID userId, int speciesId, boolean unlocked, SpecimenCounts counts,
                         int targetLvl40, boolean favorite, Instant updatedAt) {
        this.favorite = favorite;
        this.userId = Objects.requireNonNull(userId);
        this.speciesId = speciesId;
        this.unlocked = unlocked;
        this.counts = Objects.requireNonNull(counts);
        this.targetLvl40 = checkTarget(targetLvl40);
        this.updatedAt = updatedAt;
    }

    public static PlayerSpecies start(UUID userId, int speciesId, boolean unlocked, int target) {
        return new PlayerSpecies(userId, speciesId, unlocked, SpecimenCounts.NONE, target, Instant.now());
    }

    public boolean tracked() {
        return targetLvl40 > 0;
    }

    public void update(boolean unlocked, SpecimenCounts counts, int target) {
        this.unlocked = unlocked;
        this.counts = Objects.requireNonNull(counts);
        this.targetLvl40 = checkTarget(target);
        touch();
    }

    /** Épingle (ou retire) l'espèce des favoris du joueur, pour un accès rapide. */
    public void markFavorite(boolean favorite) {
        this.favorite = favorite;
        touch();
    }

    public void changeTarget(int target) {
        this.targetLvl40 = checkTarget(target);
        touch();
    }

    public void levelUp(Optional<Level> from, Level to, int quantity) {
        counts = counts.levelUp(from, to, quantity);
        touch();
    }

    public void revertLevelUp(Optional<Level> from, Level to, int quantity) {
        counts = counts.revertLevelUp(from, to, quantity);
        touch();
    }

    private void touch() {
        updatedAt = Instant.now();
    }

    private static int checkTarget(int target) {
        if (target < 0 || target > MAX_TARGET) {
            throw new InvalidLevelUpException("L'objectif doit être compris entre 0 et " + MAX_TARGET);
        }
        return target;
    }

    public UUID userId() { return userId; }
    public int speciesId() { return speciesId; }
    public boolean unlocked() { return unlocked; }
    public SpecimenCounts counts() { return counts; }
    public int targetLvl40() { return targetLvl40; }
    public boolean favorite() { return favorite; }
    public Instant updatedAt() { return updatedAt; }
}
