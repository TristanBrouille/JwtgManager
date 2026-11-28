package com.seckmet.jwtgmanager.tournament.domain;

import java.util.ArrayList;
import java.util.List;

import static com.seckmet.jwtgmanager.tournament.domain.CreatureClass.*;

/**
 * Tournoi d'une région. Une équipe compte 3 dinos : 2 d'une classe (la paire) et 1 d'une autre.
 * En jurassique, la paire et le 3e dino forment un duo herbivore / amphibien ou carnivore / ptérosaure ;
 * ailleurs, n'importe quelles 2 classes différentes de la région.
 */
public enum Tournament {
    JURASSIC("Jurassique", "jurassic", List.of(
            new Composition(HERBIVORE, AMPHIBIAN), new Composition(AMPHIBIAN, HERBIVORE),
            new Composition(CARNIVORE, PTEROSAUR), new Composition(PTEROSAUR, CARNIVORE))),
    AQUATIC("Aquatique", "aquatic", allPairs(SURFACE, CAVE, REEF)),
    CENOZOIC("Cénozoïque", "cenozoic", allPairs(SNOW, CAVERN, SAVANNAH));

    /** Classe de la paire (2 dinos) et classe du dino seul. */
    public record Composition(CreatureClass pair, CreatureClass single) {
    }

    private final String label;
    private final String regionCode;
    private final List<Composition> compositions;

    Tournament(String label, String regionCode, List<Composition> compositions) {
        this.label = label;
        this.regionCode = regionCode;
        this.compositions = compositions;
    }

    public String label() { return label; }

    public String regionCode() { return regionCode; }

    public List<Composition> compositions() { return compositions; }

    private static List<Composition> allPairs(CreatureClass... classes) {
        List<Composition> all = new ArrayList<>();
        for (CreatureClass pair : classes) {
            for (CreatureClass single : classes) {
                if (pair != single) {
                    all.add(new Composition(pair, single));
                }
            }
        }
        return List.copyOf(all);
    }
}
