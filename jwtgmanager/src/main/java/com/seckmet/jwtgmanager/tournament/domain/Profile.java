package com.seckmet.jwtgmanager.tournament.domain;

/**
 * Profil de combat selon le rapport attaque / santé. La plupart des créatures du jeu ont un rapport
 * proche de 0,31 (équilibré) ; un tank a beaucoup de santé pour peu d'attaque, un frappeur l'inverse.
 */
public enum Profile {
    TANK("Tank"), BALANCED("Équilibré"), STRIKER("Frappeur");

    /** En dessous : tank. */
    public static final double TANK_MAX_RATIO = 0.27;
    /** Au-dessus : frappeur. */
    public static final double STRIKER_MIN_RATIO = 0.45;

    private final String label;

    Profile(String label) {
        this.label = label;
    }

    public String label() { return label; }

    public static Profile of(int health, int attack) {
        if (health <= 0) {
            throw new IllegalArgumentException("La santé doit être positive");
        }
        double ratio = (double) attack / health;
        if (ratio < TANK_MAX_RATIO) {
            return TANK;
        }
        return ratio > STRIKER_MIN_RATIO ? STRIKER : BALANCED;
    }

    /** Paire de même classe acceptée : deux équilibrés, ou un tank avec un frappeur. */
    public static boolean pairWorks(Profile a, Profile b) {
        return a == BALANCED && b == BALANCED
                || a == TANK && b == STRIKER
                || a == STRIKER && b == TANK;
    }
}
