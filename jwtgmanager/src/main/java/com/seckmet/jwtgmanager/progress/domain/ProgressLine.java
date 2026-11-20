package com.seckmet.jwtgmanager.progress.domain;

import com.seckmet.jwtgmanager.shared.domain.Currency;

/** Une espèce suivie, telle que vue par les indicateurs. */
public record ProgressLine(int speciesId, String name, String rarityCode, Currency currency, boolean costKnown,
                           boolean done, int lvl40, int target, double progress, long invested, long remaining) {
}
