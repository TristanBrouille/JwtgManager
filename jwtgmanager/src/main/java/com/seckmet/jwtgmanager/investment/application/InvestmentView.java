package com.seckmet.jwtgmanager.investment.application;

import java.time.LocalDate;

public record InvestmentView(long id, int speciesId, String speciesName, Integer fromLevel, int toLevel,
                             int quantity, long cost, String currency, LocalDate investedOn) {
}
