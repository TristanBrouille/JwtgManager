package com.seckmet.jwtgmanager.investment.exposition;

import jakarta.validation.constraints.Max;
import jakarta.validation.constraints.Min;

import java.time.LocalDate;

public record RecordInvestmentRequest(
        int speciesId,
        Integer fromLevel,
        int toLevel,
        @Min(value = 1, message = "au moins 1") @Max(value = 99, message = "99 maximum") int quantity,
        LocalDate investedOn) {
}
