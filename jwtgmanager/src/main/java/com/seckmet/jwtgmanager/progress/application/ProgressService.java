package com.seckmet.jwtgmanager.progress.application;

import com.seckmet.jwtgmanager.catalog.application.CatalogService;
import com.seckmet.jwtgmanager.catalog.application.RarityView;
import com.seckmet.jwtgmanager.collection.application.CollectionChanged;
import com.seckmet.jwtgmanager.collection.application.CollectionService;
import com.seckmet.jwtgmanager.collection.application.SettingsView;
import com.seckmet.jwtgmanager.collection.application.SpeciesProgressView;
import com.seckmet.jwtgmanager.progress.domain.CompletionAggregator;
import com.seckmet.jwtgmanager.progress.domain.CompletionSummary;
import com.seckmet.jwtgmanager.progress.domain.ProgressLine;
import com.seckmet.jwtgmanager.progress.domain.ProgressSnapshot;
import com.seckmet.jwtgmanager.progress.domain.ProgressSnapshotRepository;
import com.seckmet.jwtgmanager.shared.domain.Currency;
import org.springframework.context.event.EventListener;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDate;
import java.util.Comparator;
import java.util.List;
import java.util.Optional;
import java.util.Set;
import java.util.UUID;
import java.util.stream.Collectors;

@Service
public class ProgressService {

    private static final int CLOSEST_LIMIT = 6;

    private final CollectionService collection;
    private final CatalogService catalog;
    private final ProgressSnapshotRepository snapshots;

    public ProgressService(CollectionService collection, CatalogService catalog, ProgressSnapshotRepository snapshots) {
        this.collection = collection;
        this.catalog = catalog;
        this.snapshots = snapshots;
    }

    /** Tableau de bord, éventuellement filtré sur une monnaie (DNA ou AMBER). */
    @Transactional(readOnly = true)
    public DashboardView dashboard(UUID userId, Optional<Currency> currency) {
        List<SpeciesProgressView> all = collection.collection(userId);
        List<ProgressLine> lines = all.stream()
                .filter(SpeciesProgressView::tracked)
                .map(ProgressService::toLine)
                .filter(l -> currency.isEmpty() || l.currency() == currency.get())
                .toList();
        CompletionSummary summary = CompletionAggregator.summarize(lines);

        List<DashboardView.RarityBreakdown> byRarity = catalog.rarities().stream()
                .map(r -> breakdown(r, lines))
                .toList();

        List<DashboardView.ClosestSpecies> closest = lines.stream()
                .filter(l -> !l.done() && l.costKnown())
                .sorted(Comparator.comparingLong(ProgressLine::remaining))
                .limit(CLOSEST_LIMIT)
                .map(l -> new DashboardView.ClosestSpecies(l.speciesId(), l.name(), l.rarityCode(), l.progress(),
                        l.remaining(), l.currency().name()))
                .toList();

        Set<Integer> unlockedIds = all.stream().filter(SpeciesProgressView::unlocked)
                .map(SpeciesProgressView::speciesId).collect(Collectors.toSet());
        var hybrids = catalog.hybrids().stream().filter(h -> "HYBRID".equals(h.kind())).toList();
        var superHybrids = catalog.hybrids().stream().filter(h -> "SUPER_HYBRID".equals(h.kind())).toList();
        int hybridsUnlocked = (int) hybrids.stream().filter(h -> unlockedIds.contains(h.hybridId())).count();
        int superHybridsUnlocked = (int) superHybrids.stream().filter(h -> unlockedIds.contains(h.hybridId())).count();

        SettingsView settings = collection.settings(userId);
        LocalDate today = LocalDate.now();
        List<ProgressSnapshot> history = snapshots.byUser(userId);
        Double previous = history.stream().filter(s -> s.takenOn().isBefore(today))
                .reduce((a, b) -> b).map(ProgressSnapshot::completion).orElse(null);

        return new DashboardView(
                currency.map(Enum::name).orElse("ALL"),
                new DashboardView.Summary(summary.completion(), summary.done(), summary.tracked(), summary.lvl40(),
                        summary.lvl40Target(), summary.dnaInvested(), summary.dnaRemaining(),
                        summary.superDnaInvested(), summary.superDnaRemaining(),
                        summary.amberInvested(), summary.amberRemaining()),
                previous,
                hybridsUnlocked, hybrids.size(), superHybridsUnlocked, superHybrids.size(),
                byRarity, closest,
                projection(summary.dnaRemaining(), settings.weeklyDna(), today),
                projection(summary.superDnaRemaining(), settings.weeklySuperDna(), today),
                projection(summary.amberRemaining(), settings.weeklyAmber(), today));
    }

    @Transactional(readOnly = true)
    public List<HistoryPointView> history(UUID userId) {
        return snapshots.byUser(userId).stream()
                .map(s -> new HistoryPointView(s.takenOn(), s.completion(), s.lvl40Count(), s.lvl40Target()))
                .toList();
    }

    /** Met à jour le point du jour après chaque modification de la collection. */
    @EventListener
    @Transactional
    public void onCollectionChanged(CollectionChanged event) {
        List<ProgressLine> lines = collection.collection(event.userId()).stream()
                .filter(SpeciesProgressView::tracked).map(ProgressService::toLine).toList();
        snapshots.upsert(ProgressSnapshot.of(event.userId(), LocalDate.now(), CompletionAggregator.summarize(lines)));
    }

    private static DashboardView.RarityBreakdown breakdown(RarityView r, List<ProgressLine> lines) {
        CompletionSummary s = CompletionAggregator.summarize(
                lines.stream().filter(l -> l.rarityCode().equals(r.code())).toList());
        return new DashboardView.RarityBreakdown(r.code(), r.label(), s.completion(), s.done(), s.tracked(),
                s.dnaRemaining(), s.superDnaRemaining(), s.amberRemaining());
    }

    private static DashboardView.Projection projection(long remaining, long weekly, LocalDate today) {
        Optional<Long> weeks = CompletionAggregator.weeksToFinish(remaining, weekly);
        return new DashboardView.Projection(remaining, weekly, weeks.orElse(null),
                CompletionAggregator.finishDate(today, weeks).orElse(null));
    }

    private static ProgressLine toLine(SpeciesProgressView v) {
        return new ProgressLine(v.speciesId(), v.name(), v.rarityCode(), Currency.valueOf(v.currency()),
                v.unitCost() != null, v.done(), v.lvl40(), v.targetLvl40(), v.progress(),
                v.invested(), v.remaining());
    }
}
