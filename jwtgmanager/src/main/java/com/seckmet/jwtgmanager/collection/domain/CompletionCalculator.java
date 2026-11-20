package com.seckmet.jwtgmanager.collection.domain;

import com.seckmet.jwtgmanager.shared.domain.Currency;
import com.seckmet.jwtgmanager.shared.domain.Level;

import java.util.Optional;
import java.util.OptionalLong;

/** Calcule l'avancement d'une espèce suivie par un joueur. */
public final class CompletionCalculator {

    /** Plafond d'avancement tant que l'objectif de niveaux 40 n'est pas réellement atteint. */
    static final double MAX_UNFINISHED = 0.99;

    private CompletionCalculator() {
    }

    /**
     * Avancement = équivalent niveaux 40 / objectif (formule de JWTG.xlsx), plafonné à 100 %.
     * 100 % n'est affiché que lorsque l'objectif de niveaux 40 est réellement atteint.
     * Terminé = avancement à 100 % ET reste à 0.
     * Reste = (8 × objectif − unités déjà payées) × coût, comme la colonne « Rest » de l'Excel ; investi = unités × coût.
     */
    public static SpeciesProgress progress(PlayerSpecies species, UnitCosts costs) {
        Currency currency = costs.currencyFor(species.unlocked());
        OptionalLong unitCost = costs.in(currency);
        SpecimenCounts counts = species.counts();
        int target = species.targetLvl40();
        long unitsRemaining = counts.unitsToReach(target);
        double progress = target == 0 || counts.reached(target)
                ? 1.0
                : Math.min(MAX_UNFINISHED, counts.lvl40Equivalent() / target);
        boolean done = progress >= 1.0 && unitsRemaining == 0;
        long cost = unitCost.orElse(0);
        return new SpeciesProgress(currency, unitCost, counts.units(), unitsRemaining, progress, done,
                counts.units() * cost, unitsRemaining * cost);
    }

    /** Coût d'une montée de niveau : (multiplicateur cible − multiplicateur départ) × coût unitaire × quantité. */
    public static long levelUpCost(Optional<Level> from, Level to, int quantity, long unitCost) {
        int fromMultiplier = from.map(Level::multiplier).orElse(0);
        return (long) (to.multiplier() - fromMultiplier) * unitCost * quantity;
    }
}
