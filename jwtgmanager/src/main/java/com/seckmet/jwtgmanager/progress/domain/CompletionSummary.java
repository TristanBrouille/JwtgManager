package com.seckmet.jwtgmanager.progress.domain;

/** Indicateurs agrégés d'un ensemble d'espèces suivies, par monnaie. */
public record CompletionSummary(double completion, int done, int tracked, long lvl40, long lvl40Target,
                                long dnaInvested, long dnaRemaining,
                                long superDnaInvested, long superDnaRemaining,
                                long amberInvested, long amberRemaining) {
}
