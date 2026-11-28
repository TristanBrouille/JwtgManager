package com.seckmet.jwtgmanager.tournament.domain;

import java.util.Arrays;
import java.util.Optional;

/** Classe de combat d'une créature (codes paleo.gg). */
public enum CreatureClass {
    HERBIVORE("herbivore", "Herbivore"),
    AMPHIBIAN("amphibian", "Amphibien"),
    CARNIVORE("carnivore", "Carnivore"),
    PTEROSAUR("pterosaur", "Ptérosaure"),
    SURFACE("surface", "Surface"),
    CAVE("cave", "Grotte"),
    REEF("reef", "Récif"),
    SNOW("snow", "Glace"),
    CAVERN("cavern", "Caverne"),
    SAVANNAH("savannah", "Savane");

    private final String code;
    private final String label;

    CreatureClass(String code, String label) {
        this.code = code;
        this.label = label;
    }

    public String code() { return code; }

    public String label() { return label; }

    /**
     * Classe principale d'un code paleo.gg ; une classe double (« carnivore-surface ») compte
     * pour sa première partie.
     */
    public static Optional<CreatureClass> fromCode(String code) {
        if (code == null) {
            return Optional.empty();
        }
        String main = code.split("-")[0];
        return Arrays.stream(values()).filter(c -> c.code.equals(main)).findFirst();
    }
}
