package com.seckmet.jwtgmanager.investment.application;

import java.time.LocalDate;

/** {@code fromLevel} null = nouveau spécimen. */
public record RecordInvestmentCommand(int speciesId, Integer fromLevel, int toLevel, int quantity, LocalDate investedOn) {
}
