package com.seckmet.jwtgmanager.investment.application;

import com.seckmet.jwtgmanager.catalog.application.CatalogService;
import com.seckmet.jwtgmanager.catalog.application.SpeciesView;
import com.seckmet.jwtgmanager.collection.application.CollectionService;
import com.seckmet.jwtgmanager.collection.application.LevelUpResult;
import com.seckmet.jwtgmanager.shared.domain.Currency;
import com.seckmet.jwtgmanager.shared.domain.Level;
import com.seckmet.jwtgmanager.investment.domain.Investment;
import com.seckmet.jwtgmanager.investment.domain.InvestmentRepository;
import com.seckmet.jwtgmanager.shared.application.NotFoundException;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDate;
import java.util.Comparator;
import java.util.List;
import java.util.Map;
import java.util.Optional;
import java.util.UUID;

@Service
public class InvestmentService {

    private final InvestmentRepository investments;
    private final CollectionService collection;
    private final CatalogService catalog;

    public InvestmentService(InvestmentRepository investments, CollectionService collection, CatalogService catalog) {
        this.investments = investments;
        this.collection = collection;
        this.catalog = catalog;
    }

    @Transactional(readOnly = true)
    public List<InvestmentView> list(UUID userId) {
        Map<Integer, SpeciesView> byId = catalog.speciesById();
        return investments.byUser(userId).stream()
                .sorted(Comparator.comparing(Investment::investedOn).thenComparing(Investment::id).reversed())
                .map(i -> toView(i, byId.get(i.speciesId()).name()))
                .toList();
    }

    @Transactional
    public InvestmentView record(UUID userId, RecordInvestmentCommand command) {
        Optional<Level> from = Optional.ofNullable(command.fromLevel()).map(Level::of);
        Level to = Level.of(command.toLevel());
        LevelUpResult result = collection.levelUp(userId, command.speciesId(), from, to, command.quantity());
        Investment saved = investments.save(new Investment(null, userId, command.speciesId(), from, to,
                command.quantity(), result.cost(), Currency.valueOf(result.currency()),
                command.investedOn() == null ? LocalDate.now() : command.investedOn()));
        return toView(saved, result.speciesName());
    }

    /** Annule un investissement : les spécimens reviennent à leur palier de départ. */
    @Transactional
    public void cancel(UUID userId, long investmentId) {
        Investment investment = investments.byIdAndUser(investmentId, userId)
                .orElseThrow(() -> new NotFoundException("Investissement " + investmentId + " introuvable"));
        collection.revertLevelUp(userId, investment.speciesId(), investment.from(), investment.to(), investment.quantity());
        investments.delete(investment);
    }

    private static InvestmentView toView(Investment i, String name) {
        return new InvestmentView(i.id(), i.speciesId(), name, i.from().map(Level::value).orElse(null),
                i.to().value(), i.quantity(), i.cost(), i.currency().name(), i.investedOn());
    }
}
