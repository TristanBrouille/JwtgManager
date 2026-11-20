package com.seckmet.jwtgmanager.progress.exposition;

import com.seckmet.jwtgmanager.progress.application.DashboardView;

import java.time.LocalDate;
import java.util.List;

public record DashboardResponse(
        String currencyFilter,
        Summary summary,
        Double previousCompletion,
        int hybridsUnlocked,
        int hybridsTotal,
        int superHybridsUnlocked,
        int superHybridsTotal,
        List<Rarity> byRarity,
        List<Closest> closest,
        Projection dna,
        Projection superDna,
        Projection amber) {

    public record Summary(double completion, int done, int tracked, long lvl40, long lvl40Target,
                          long dnaInvested, long dnaRemaining, long superDnaInvested, long superDnaRemaining,
                          long amberInvested, long amberRemaining) {
    }

    public record Rarity(String code, String label, double completion, int done, int tracked,
                         long dnaRemaining, long superDnaRemaining, long amberRemaining) {
    }

    public record Closest(int speciesId, String name, String rarityCode, double progress, long remaining,
                          String currency) {
    }

    public record Projection(long remaining, long weeklyIncome, Long weeks, LocalDate finishDate) {
    }

    static DashboardResponse from(DashboardView v) {
        var s = v.summary();
        return new DashboardResponse(v.currencyFilter(),
                new Summary(s.completion(), s.done(), s.tracked(), s.lvl40(), s.lvl40Target(), s.dnaInvested(),
                        s.dnaRemaining(), s.superDnaInvested(), s.superDnaRemaining(), s.amberInvested(),
                        s.amberRemaining()),
                v.previousCompletion(), v.hybridsUnlocked(), v.hybridsTotal(),
                v.superHybridsUnlocked(), v.superHybridsTotal(),
                v.byRarity().stream().map(r -> new Rarity(r.code(), r.label(), r.completion(), r.done(), r.tracked(),
                        r.dnaRemaining(), r.superDnaRemaining(), r.amberRemaining())).toList(),
                v.closest().stream().map(c -> new Closest(c.speciesId(), c.name(), c.rarityCode(), c.progress(),
                        c.remaining(), c.currency())).toList(),
                projection(v.dna()), projection(v.superDna()), projection(v.amber()));
    }

    private static Projection projection(DashboardView.Projection p) {
        return new Projection(p.remaining(), p.weeklyIncome(), p.weeks(), p.finishDate());
    }
}
