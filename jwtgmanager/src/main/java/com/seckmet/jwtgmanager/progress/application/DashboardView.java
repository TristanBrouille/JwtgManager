package com.seckmet.jwtgmanager.progress.application;

import java.time.LocalDate;
import java.util.List;

public record DashboardView(
        String currencyFilter,
        Summary summary,
        Double previousCompletion,
        int hybridsUnlocked,
        int hybridsTotal,
        int superHybridsUnlocked,
        int superHybridsTotal,
        List<RarityBreakdown> byRarity,
        List<ClosestSpecies> closest,
        Projection dna,
        Projection superDna,
        Projection amber,
        FavoritesProjection favorites) {

    public record Summary(double completion, int done, int tracked, long lvl40, long lvl40Target,
                          long dnaInvested, long dnaRemaining, long superDnaInvested, long superDnaRemaining,
                          long amberInvested, long amberRemaining) {
    }

    public record RarityBreakdown(String code, String label, double completion, int done, int tracked,
                                  long dnaRemaining, long superDnaRemaining, long amberRemaining) {
    }

    public record ClosestSpecies(int speciesId, String name, String rarityCode, double progress,
                                 long remaining, String currency) {
    }

    public record Projection(long remaining, long weeklyIncome, Long weeks, LocalDate finishDate) {
    }

    /**
     * Budget restant pour terminer les espèces favorites suivies : {@code species} favorites comptées,
     * dont {@code unknownCost} sans coût renseigné (non chiffrées), {@code done} déjà terminées.
     */
    public record FavoritesProjection(int species, int done, int unknownCost, Projection dna, Projection superDna,
                                      Projection amber) {
    }
}
