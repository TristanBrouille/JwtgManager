package com.seckmet.jwtgmanager.investment.infrastructure;

import com.seckmet.jwtgmanager.shared.domain.Currency;
import com.seckmet.jwtgmanager.shared.domain.Level;
import com.seckmet.jwtgmanager.investment.domain.Investment;
import com.seckmet.jwtgmanager.investment.domain.InvestmentRepository;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;
import java.util.UUID;

@Repository
class JpaInvestmentRepository implements InvestmentRepository {

    private final InvestmentSpringRepository jpa;

    JpaInvestmentRepository(InvestmentSpringRepository jpa) {
        this.jpa = jpa;
    }

    @Override
    public List<Investment> byUser(UUID userId) {
        return jpa.findByUserId(userId).stream().map(JpaInvestmentRepository::toDomain).toList();
    }

    @Override
    public Optional<Investment> byIdAndUser(long id, UUID userId) {
        return jpa.findByIdAndUserId(id, userId).map(JpaInvestmentRepository::toDomain);
    }

    @Override
    public Investment save(Investment i) {
        InvestmentJpaEntity saved = jpa.save(new InvestmentJpaEntity(i.userId(), i.speciesId(),
                i.from().map(l -> (short) l.value()).orElse(null), (short) i.to().value(), (short) i.quantity(),
                Math.toIntExact(i.cost()), i.currency().name().toLowerCase(java.util.Locale.ROOT), i.investedOn()));
        return toDomain(saved);
    }

    @Override
    public void delete(Investment investment) {
        jpa.deleteById(investment.id());
    }

    private static Investment toDomain(InvestmentJpaEntity e) {
        return new Investment(e.getId(), e.getUserId(), e.getSpeciesId(),
                Optional.ofNullable(e.getFromLevel()).map(Short::intValue).map(Level::of),
                Level.of(e.getToLevel()), e.getQuantity(), e.getCost(),
                Currency.valueOf(e.getCurrency().toUpperCase(java.util.Locale.ROOT)), e.getInvestedOn());
    }
}
