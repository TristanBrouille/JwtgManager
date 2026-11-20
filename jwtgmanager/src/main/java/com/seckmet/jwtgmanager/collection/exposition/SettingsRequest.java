package com.seckmet.jwtgmanager.collection.exposition;

import jakarta.validation.constraints.Max;
import jakarta.validation.constraints.Min;

public record SettingsRequest(@Min(value = 0, message = "doit être positif") long weeklyDna,
                              @Min(value = 0, message = "doit être positif") long weeklySuperDna,
                              @Min(value = 0, message = "doit être positif") long weeklyAmber,
                              @Min(value = 0, message = "doit être positif") @Max(value = 99, message = "99 maximum") int defaultTarget) {
}
