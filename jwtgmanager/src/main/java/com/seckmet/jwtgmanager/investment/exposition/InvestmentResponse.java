package com.seckmet.jwtgmanager.investment.exposition;

import java.time.LocalDate;

public record InvestmentResponse(long id, int speciesId, String speciesName, Integer fromLevel, int toLevel,
                                 int quantity, long cost, String currency, LocalDate investedOn) {
}
