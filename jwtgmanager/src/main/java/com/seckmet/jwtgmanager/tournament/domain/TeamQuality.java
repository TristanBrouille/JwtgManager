package com.seckmet.jwtgmanager.tournament.domain;

/** Qualité d'un trio : paire complémentaire ou non. */
public enum TeamQuality {
    /** Paire complémentaire : 2 équilibrés, ou un tank avec un frappeur. */
    IDEAL("Idéal"),
    /** Paire non complémentaire. */
    UNMATCHED_PAIR("Paire non complémentaire");

    private final String label;

    TeamQuality(String label) {
        this.label = label;
    }

    public String label() { return label; }

    static TeamQuality of(Fighter pairA, Fighter pairB, Fighter single) {
        return Profile.pairWorks(pairA.profile(), pairB.profile()) ? IDEAL : UNMATCHED_PAIR;
    }
}
