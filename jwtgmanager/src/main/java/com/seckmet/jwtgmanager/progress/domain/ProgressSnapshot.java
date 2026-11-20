package com.seckmet.jwtgmanager.progress.domain;

import java.time.LocalDate;
import java.util.Objects;
import java.util.UUID;

/** Point de la courbe d'évolution : un par joueur et par jour. */
public record ProgressSnapshot(UUID userId, LocalDate takenOn, double completion, long lvl40Count,
                               long lvl40Target, long dnaRemaining, long superDnaRemaining,
                               long amberRemaining) {
    public ProgressSnapshot {
        Objects.requireNonNull(userId);
        Objects.requireNonNull(takenOn);
        if (completion < 0 || completion > 1) {
            throw new IllegalArgumentException("La complétion doit être comprise entre 0 et 1");
        }
    }

    public static ProgressSnapshot of(UUID userId, LocalDate day, CompletionSummary s) {
        return new ProgressSnapshot(userId, day, s.completion(), s.lvl40(), s.lvl40Target(),
                s.dnaRemaining(), s.superDnaRemaining(), s.amberRemaining());
    }
}
