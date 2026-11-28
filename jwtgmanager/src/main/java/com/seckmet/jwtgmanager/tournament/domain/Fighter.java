package com.seckmet.jwtgmanager.tournament.domain;

import java.util.Objects;

/** Un spécimen du joueur à un palier donné, avec ses statistiques de combat à ce palier. */
public record Fighter(int speciesId, int level, CreatureClass creatureClass, int health, int attack) {

    public Fighter {
        Objects.requireNonNull(creatureClass);
        if (health <= 0 || attack < 0) {
            throw new IllegalArgumentException("Statistiques de combat invalides");
        }
    }

    /**
     * Fureur = santé × 5/16 + attaque, arrondie. Vérifiée sur les 404 créatures de paleo.gg
     * et sur les fureurs par niveau du wiki Jurassic World (ex. Vélociraptor : 151, 258, 393, 556).
     */
    public int ferocity() {
        return ferocityOf(health, attack);
    }

    public Profile profile() {
        return Profile.of(health, attack);
    }

    public static int ferocityOf(int health, int attack) {
        return (int) Math.floor(health * 5.0 / 16.0 + attack + 0.5);
    }
}
