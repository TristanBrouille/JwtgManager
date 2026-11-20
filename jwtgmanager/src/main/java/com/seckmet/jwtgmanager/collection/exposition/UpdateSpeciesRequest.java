package com.seckmet.jwtgmanager.collection.exposition;

import jakarta.validation.constraints.Max;
import jakarta.validation.constraints.Min;

public record UpdateSpeciesRequest(
        boolean unlocked,
        @Min(value = 0, message = "doit être positif") int lvl10,
        @Min(value = 0, message = "doit être positif") int lvl20,
        @Min(value = 0, message = "doit être positif") int lvl30,
        @Min(value = 0, message = "doit être positif") int lvl40,
        @Min(value = 0, message = "doit être positif") @Max(value = 99, message = "99 maximum") int targetLvl40) {
}
