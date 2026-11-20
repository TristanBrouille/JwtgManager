package com.seckmet.jwtgmanager.collection.domain;

import java.util.Optional;
import java.util.UUID;

public interface PlayerSettingsRepository {
    Optional<PlayerSettings> byUser(UUID userId);

    void save(PlayerSettings settings);
}
