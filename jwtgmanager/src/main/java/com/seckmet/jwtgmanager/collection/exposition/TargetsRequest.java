package com.seckmet.jwtgmanager.collection.exposition;

import jakarta.validation.constraints.Max;
import jakarta.validation.constraints.Min;

/** {@code rarityCode} vide = toutes les espèces. */
public record TargetsRequest(String rarityCode,
                             @Min(value = 0, message = "doit être positif") @Max(value = 99, message = "99 maximum") int targetLvl40) {
}
