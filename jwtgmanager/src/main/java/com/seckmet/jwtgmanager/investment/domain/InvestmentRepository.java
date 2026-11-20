package com.seckmet.jwtgmanager.investment.domain;

import java.util.List;
import java.util.Optional;
import java.util.UUID;

public interface InvestmentRepository {
    List<Investment> byUser(UUID userId);

    Optional<Investment> byIdAndUser(long id, UUID userId);

    Investment save(Investment investment);

    void delete(Investment investment);
}
