package com.seckmet.jwtgmanager.tournament.application;

import com.seckmet.jwtgmanager.catalog.application.CatalogService;
import com.seckmet.jwtgmanager.catalog.application.CombatSheetView;
import com.seckmet.jwtgmanager.catalog.application.SpeciesView;
import com.seckmet.jwtgmanager.collection.application.CollectionService;
import com.seckmet.jwtgmanager.collection.application.SpeciesProgressView;
import com.seckmet.jwtgmanager.tournament.domain.CreatureClass;
import com.seckmet.jwtgmanager.tournament.domain.Fighter;
import com.seckmet.jwtgmanager.tournament.domain.League;
import com.seckmet.jwtgmanager.tournament.domain.Team;
import com.seckmet.jwtgmanager.tournament.domain.TeamBuilder;
import com.seckmet.jwtgmanager.tournament.domain.TeamPlan;
import com.seckmet.jwtgmanager.tournament.domain.TeamPlanRepository;
import com.seckmet.jwtgmanager.tournament.domain.TeamQuality;
import com.seckmet.jwtgmanager.tournament.domain.Tournament;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.nio.charset.StandardCharsets;
import java.security.MessageDigest;
import java.security.NoSuchAlgorithmException;
import java.time.Instant;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.Comparator;
import java.util.HexFormat;
import java.util.List;
import java.util.Map;
import java.util.Optional;
import java.util.UUID;
import java.util.stream.Collectors;

/** Calcul à la demande des trios de tournoi d'un joueur, et lecture du dernier calcul. */
@Service
public class TournamentService {

    private static final int[] LEVELS = {10, 20, 30, 40};

    private final CollectionService collection;
    private final CatalogService catalog;
    private final TeamPlanRepository plans;

    public TournamentService(CollectionService collection, CatalogService catalog, TeamPlanRepository plans) {
        this.collection = collection;
        this.catalog = catalog;
        this.plans = plans;
    }

    /** Recalcule tous les trios du joueur à partir de sa collection actuelle. */
    @Transactional
    public TournamentView compute(UUID userId) {
        List<SpeciesProgressView> owned = ownedSpecies(userId);
        Map<Integer, CombatSheetView> sheets = catalog.combatSheets();
        List<TeamBuilder.Stock> stocks = stocks(owned, sheets);
        List<Team> teams = new ArrayList<>();
        List<TeamPlan.Leftover> leftovers = new ArrayList<>();
        for (Tournament tournament : Tournament.values()) {
            TeamBuilder.Result result = TeamBuilder.build(tournament, stocks);
            teams.addAll(result.teams());
            result.leftovers().forEach(l -> leftovers.add(new TeamPlan.Leftover(tournament, l.fighter(), l.count())));
        }
        plans.replace(new TeamPlan(userId, Instant.now(), fingerprint(owned), teams, leftovers));
        return view(userId);
    }

    @Transactional(readOnly = true)
    public TournamentView view(UUID userId) {
        Optional<TeamPlan> plan = plans.byUser(userId);
        Map<Integer, SpeciesView> species = catalog.speciesById();
        Map<Integer, CombatSheetView> sheets = catalog.combatSheets();
        List<Team> teams = plan.map(TeamPlan::teams).orElse(List.of());
        List<TeamPlan.Leftover> leftovers = plan.map(TeamPlan::leftovers).orElse(List.of());
        boolean outdated = plan.isPresent() && !plan.get().collectionHash().equals(fingerprint(ownedSpecies(userId)));

        List<TournamentView.TournamentBlock> blocks = Arrays.stream(Tournament.values())
                .map(t -> block(t, teams, leftovers, species, sheets))
                .toList();
        return new TournamentView(plan.map(TeamPlan::computedAt).orElse(null), outdated, blocks);
    }

    private TournamentView.TournamentBlock block(Tournament t, List<Team> allTeams, List<TeamPlan.Leftover> allLeftovers,
                                                 Map<Integer, SpeciesView> species,
                                                 Map<Integer, CombatSheetView> sheets) {
        List<Team> teams = allTeams.stream().filter(team -> team.tournament() == t).toList();
        List<TournamentView.LeftoverView> leftovers = allLeftovers.stream()
                .filter(l -> l.tournament() == t)
                .sorted(Comparator.comparingInt((TeamPlan.Leftover l) -> l.fighter().ferocity()).reversed())
                .map(l -> new TournamentView.LeftoverView(member(l.fighter(), species, sheets), l.count()))
                .toList();
        int placed = teams.size() * 3;
        int left = leftovers.stream().mapToInt(TournamentView.LeftoverView::count).sum();
        int ideal = (int) teams.stream().filter(team -> team.quality() == TeamQuality.IDEAL).count();
        List<TournamentView.LeagueBlock> leagues = Arrays.stream(League.values())
                .map(l -> new TournamentView.LeagueBlock(l.name(), l.label(), l.above(),
                        l.capped() ? l.upTo() : null, l.minUnit(),
                        l.maxUnit() == Integer.MAX_VALUE ? null : l.maxUnit(),
                        teams.stream()
                                .filter(team -> team.league() == l)
                                .sorted(Comparator.comparingInt(Team::rank))
                                .map(team -> toView(team, species, sheets))
                                .toList()))
                .toList();
        return new TournamentView.TournamentBlock(t.name(), t.label(), placed + left, placed, teams.size(), ideal,
                leagues, leftovers);
    }

    private TournamentView.TeamView toView(Team team, Map<Integer, SpeciesView> species,
                                           Map<Integer, CombatSheetView> sheets) {
        return new TournamentView.TeamView(team.rank(), team.totalFerocity(), team.ferocityGap(),
                team.composition().pair().label(), team.composition().single().label(),
                team.quality().name(), team.quality().label(),
                team.members().stream().map(f -> member(f, species, sheets)).toList());
    }

    private TournamentView.MemberView member(Fighter f, Map<Integer, SpeciesView> species,
                                             Map<Integer, CombatSheetView> sheets) {
        SpeciesView s = species.get(f.speciesId());
        CombatSheetView sheet = sheets.get(f.speciesId());
        return new TournamentView.MemberView(f.speciesId(), s == null ? "Espèce n°" + f.speciesId() : s.name(),
                f.level(), f.creatureClass().label(), f.health(), f.attack(), f.ferocity(),
                f.profile().name(), f.profile().label(),
                sheet == null ? null : catalog.portraitUrl(sheet.sourceKey(), f.level()));
    }

    private List<SpeciesProgressView> ownedSpecies(UUID userId) {
        return collection.collection(userId).stream()
                .filter(s -> s.lvl10() + s.lvl20() + s.lvl30() + s.lvl40() > 0)
                .toList();
    }

    private static List<TeamBuilder.Stock> stocks(List<SpeciesProgressView> owned,
                                                  Map<Integer, CombatSheetView> sheets) {
        List<TeamBuilder.Stock> stocks = new ArrayList<>();
        for (SpeciesProgressView s : owned) {
            CombatSheetView sheet = sheets.get(s.speciesId());
            Optional<CreatureClass> creatureClass = Optional.ofNullable(sheet)
                    .flatMap(c -> CreatureClass.fromCode(c.classCode()));
            if (creatureClass.isEmpty()) {
                continue;
            }
            int[] counts = {s.lvl10(), s.lvl20(), s.lvl30(), s.lvl40()};
            for (int i = 0; i < LEVELS.length; i++) {
                if (counts[i] > 0) {
                    Fighter fighter = new Fighter(s.speciesId(), LEVELS[i], creatureClass.get(),
                            sheet.health().get(i), sheet.attack().get(i));
                    stocks.add(new TeamBuilder.Stock(fighter, counts[i]));
                }
            }
        }
        return stocks;
    }

    /** Empreinte des spécimens détenus, pour signaler un calcul périmé. */
    private static String fingerprint(List<SpeciesProgressView> owned) {
        String canonical = owned.stream()
                .sorted(Comparator.comparingInt(SpeciesProgressView::speciesId))
                .map(s -> s.speciesId() + ":" + s.lvl10() + "," + s.lvl20() + "," + s.lvl30() + "," + s.lvl40())
                .collect(Collectors.joining(";"));
        try {
            byte[] hash = MessageDigest.getInstance("SHA-256").digest(canonical.getBytes(StandardCharsets.UTF_8));
            return HexFormat.of().formatHex(hash);
        } catch (NoSuchAlgorithmException e) {
            throw new IllegalStateException(e);
        }
    }
}
