package com.seckmet.jwtgmanager.progress.domain;

import java.util.List;
import java.util.UUID;

public interface ProgressSnapshotRepository {
    /** Points du joueur triés par date croissante. */
    List<ProgressSnapshot> byUser(UUID userId);

    /** Crée ou remplace le point du jour. */
    void upsert(ProgressSnapshot snapshot);
}
