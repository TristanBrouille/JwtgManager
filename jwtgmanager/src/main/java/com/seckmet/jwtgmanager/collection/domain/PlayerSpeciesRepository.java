package com.seckmet.jwtgmanager.collection.domain;

import java.util.List;
import java.util.Optional;
import java.util.UUID;

public interface PlayerSpeciesRepository {
    List<PlayerSpecies> byUser(UUID userId);

    Optional<PlayerSpecies> byUserAndSpecies(UUID userId, int speciesId);

    void save(PlayerSpecies species);

    void saveAll(List<PlayerSpecies> species);
}
