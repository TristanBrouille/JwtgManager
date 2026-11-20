package com.seckmet.jwtgmanager.progress.domain;

import java.time.LocalDate;
import java.util.Collection;
import java.util.Optional;

/** Agrège l'avancement des espèces suivies et projette la date de fin selon le budget. */
public final class CompletionAggregator {
    private CompletionAggregator() {
    }

    /** Complétion = moyenne de l'avancement des espèces suivies (comme la ligne « Moyenne » de JWTG.xlsx). */
    public static CompletionSummary summarize(Collection<ProgressLine> lines) {
        double progressSum = 0;
        long l40 = 0, l40Target = 0;
        long dnaInvested = 0, dnaRemaining = 0, superDnaInvested = 0, superDnaRemaining = 0;
        long amberInvested = 0, amberRemaining = 0;
        int done = 0;
        for (ProgressLine l : lines) {
            progressSum += l.progress();
            l40 += Math.min(l.lvl40(), l.target());
            l40Target += l.target();
            if (l.done()) {
                done++;
            }
            switch (l.currency()) {
                case DNA -> {
                    dnaInvested += l.invested();
                    dnaRemaining += l.remaining();
                }
                case SUPER_DNA -> {
                    superDnaInvested += l.invested();
                    superDnaRemaining += l.remaining();
                }
                case AMBER -> {
                    amberInvested += l.invested();
                    amberRemaining += l.remaining();
                }
            }
        }
        double completion = lines.isEmpty() ? 0 : progressSum / lines.size();
        return new CompletionSummary(completion, done, lines.size(), l40, l40Target,
                dnaInvested, dnaRemaining, superDnaInvested, superDnaRemaining, amberInvested, amberRemaining);
    }

    /** Nombre de semaines pour financer {@code remaining} avec {@code weeklyIncome}, vide si le revenu est nul. */
    public static Optional<Long> weeksToFinish(long remaining, long weeklyIncome) {
        if (remaining <= 0) {
            return Optional.of(0L);
        }
        if (weeklyIncome <= 0) {
            return Optional.empty();
        }
        return Optional.of((remaining + weeklyIncome - 1) / weeklyIncome);
    }

    public static Optional<LocalDate> finishDate(LocalDate today, Optional<Long> weeks) {
        return weeks.map(today::plusWeeks);
    }
}
