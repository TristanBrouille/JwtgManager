package com.seckmet.jwtgmanager.tournament.domain;

import java.util.ArrayList;
import java.util.Comparator;
import java.util.EnumMap;
import java.util.HashMap;
import java.util.LinkedHashMap;
import java.util.LinkedHashSet;
import java.util.List;
import java.util.Map;
import java.util.Optional;
import java.util.Set;

/**
 * Répartit les spécimens du joueur en trios pour un tournoi : chaque dino d'un trio doit avoir une
 * fureur dans la fourchette de la ligue du trio ({@link League#accepts(int)}). Sous cette règle, on
 * laisse le moins de dinos possible de côté.
 *
 * <ol>
 *   <li>Les classes sont regroupées en ensembles compatibles (en jurassique : herbivore + amphibien,
 *       carnivore + ptérosaure ; ailleurs : les 3 classes de la région).</li>
 *   <li>On forme les trios un par un, toujours le meilleur disponible (qualité, puis fureurs les plus
 *       proches, puis fureur totale), en préférant ceux qui laissent possible le plus grand nombre de
 *       trios « 2 d'une classe + 1 d'une autre » avec les dinos restants.</li>
 *   <li>On s'arrête quand plus aucun trio ne respecte les fourchettes de fureur : les dinos restants
 *       sont rendus à part.</li>
 * </ol>
 * Les trios sont rangés dans la ligue de leur fureur totale ; les dinos restants sont rendus à part.
 */
public final class TeamBuilder {

    /** Nombre de dinos seuls essayés autour de la fureur de la paire. */
    private static final int SINGLE_NEIGHBOURS = 2;

    /** Spécimens identiques (même espèce, même palier) détenus par le joueur. */
    public record Stock(Fighter fighter, int count) {
        public Stock {
            if (count < 0) {
                throw new IllegalArgumentException("Nombre de spécimens négatif");
            }
        }
    }

    /** Trios formés et spécimens restés sans trio. */
    public record Result(List<Team> teams, List<Stock> leftovers) {
    }

    private record Candidate(Tournament.Composition composition, Fighter a, Fighter b, Fighter c,
                             TeamQuality quality, double ratio, int total) {
    }

    private static final Comparator<Candidate> BEST_FIRST = Comparator
            .comparing(Candidate::quality)
            .thenComparingDouble(Candidate::ratio)
            .thenComparing(Comparator.comparingInt(Candidate::total).reversed())
            .thenComparingInt(c -> c.a().speciesId())
            .thenComparingInt(c -> c.b().speciesId())
            .thenComparingInt(c -> c.c().speciesId())
            .thenComparingInt(c -> c.a().level() + c.b().level() * 100 + c.c().level() * 10_000);

    private TeamBuilder() {
    }

    public static Result build(Tournament tournament, List<Stock> stocks) {
        Map<Fighter, Integer> left = new LinkedHashMap<>();
        Set<CreatureClass> playable = new LinkedHashSet<>();
        tournament.compositions().forEach(c -> {
            playable.add(c.pair());
            playable.add(c.single());
        });
        for (Stock s : stocks) {
            if (s.count() > 0 && playable.contains(s.fighter().creatureClass())) {
                left.merge(s.fighter(), s.count(), Integer::sum);
            }
        }

        List<Candidate> formed = new ArrayList<>();
        for (List<CreatureClass> group : groups(tournament)) {
            List<Tournament.Composition> compositions = tournament.compositions().stream()
                    .filter(c -> group.contains(c.pair()))
                    .toList();
            while (true) {
                Map<CreatureClass, Integer> counts = classCounts(left, group);
                int bound = maxTeams(counts);
                if (bound == 0) {
                    break;
                }
                // Meilleur trio parmi ceux qui laissent possible le maximum de trios restant ;
                // à défaut (fureurs trop éloignées), le meilleur trio encore formable.
                List<Candidate> candidates = compositions.stream()
                        .map(c -> bestOf(c, left))
                        .flatMap(Optional::stream)
                        .toList();
                Optional<Candidate> best = candidates.stream()
                        .filter(c -> feasibleAfter(counts, c.composition(), bound - 1))
                        .min(BEST_FIRST)
                        .or(() -> candidates.stream().min(BEST_FIRST));
                if (best.isEmpty()) {
                    break;
                }
                Candidate chosen = best.get();
                for (Fighter f : List.of(chosen.a(), chosen.b(), chosen.c())) {
                    left.merge(f, -1, Integer::sum);
                }
                formed.add(chosen);
            }
        }
        return new Result(rank(tournament, formed), leftovers(left));
    }

    /** Range les trios par ligue, du plus fort au plus faible. */
    private static List<Team> rank(Tournament tournament, List<Candidate> formed) {
        Map<League, List<Candidate>> byLeague = new EnumMap<>(League.class);
        for (Candidate c : formed) {
            League.of(c.total()).ifPresent(l -> byLeague.computeIfAbsent(l, k -> new ArrayList<>()).add(c));
        }
        List<Team> teams = new ArrayList<>();
        byLeague.forEach((league, list) -> {
            list.sort(Comparator.comparingInt(Candidate::total).reversed().thenComparing(BEST_FIRST));
            for (int i = 0; i < list.size(); i++) {
                Candidate c = list.get(i);
                teams.add(new Team(tournament, league, i + 1, c.composition(), List.of(c.a(), c.b(), c.c())));
            }
        });
        return teams;
    }

    private static List<Stock> leftovers(Map<Fighter, Integer> left) {
        return left.entrySet().stream()
                .filter(e -> e.getValue() > 0)
                .map(e -> new Stock(e.getKey(), e.getValue()))
                .sorted(Comparator.comparingInt((Stock s) -> s.fighter().ferocity()).reversed())
                .toList();
    }

    /** Meilleur trio de cette composition parmi les spécimens restants. */
    private static Optional<Candidate> bestOf(Tournament.Composition composition, Map<Fighter, Integer> left) {
        List<Fighter> pairSide = available(left, composition.pair());
        List<Fighter> singleSide = available(left, composition.single());
        if (pairSide.isEmpty() || singleSide.isEmpty()) {
            return Optional.empty();
        }
        int[] singleFerocity = singleSide.stream().mapToInt(Fighter::ferocity).toArray();
        Candidate best = null;
        for (int i = 0; i < pairSide.size(); i++) {
            Fighter a = pairSide.get(i);
            for (int j = i; j < pairSide.size(); j++) {
                if (i == j && left.get(a) < 2) {
                    continue;
                }
                Fighter b = pairSide.get(j);
                int center = nearest(singleFerocity, a.ferocity(), b.ferocity());
                int from = Math.max(0, center - SINGLE_NEIGHBOURS);
                int to = Math.min(singleSide.size() - 1, center + SINGLE_NEIGHBOURS);
                for (int k = from; k <= to; k++) {
                    Candidate candidate = candidate(composition, a, b, singleSide.get(k));
                    if (fitsItsLeague(candidate) && (best == null || BEST_FIRST.compare(candidate, best) < 0)) {
                        best = candidate;
                    }
                }
            }
        }
        return Optional.ofNullable(best);
    }

    /** Chaque dino a une fureur dans la fourchette de la ligue du trio. */
    private static boolean fitsItsLeague(Candidate c) {
        return League.of(c.total())
                .filter(l -> l.accepts(c.a().ferocity()) && l.accepts(c.b().ferocity()) && l.accepts(c.c().ferocity()))
                .isPresent();
    }

    private static Candidate candidate(Tournament.Composition composition, Fighter a, Fighter b, Fighter c) {
        int max = Math.max(Math.max(a.ferocity(), b.ferocity()), c.ferocity());
        int min = Math.max(1, Math.min(Math.min(a.ferocity(), b.ferocity()), c.ferocity()));
        return new Candidate(composition, a, b, c, TeamQuality.of(a, b, c), (double) max / min,
                a.ferocity() + b.ferocity() + c.ferocity());
    }

    /**
     * Index du dino seul qui rapproche le plus les fureurs du trio, la paire valant {@code low} et
     * {@code high} : dans l'intervalle si possible (le plus fort), sinon le plus proche de part ou d'autre.
     */
    private static int nearest(int[] sorted, int low, int high) {
        int above = lowerBound(sorted, high + 1);   // premier strictement au-dessus de high
        if (above > 0 && sorted[above - 1] >= low) {
            return above - 1;
        }
        int below = above - 1;                      // dernier sous low (ou -1)
        if (below < 0) {
            return above;
        }
        if (above >= sorted.length) {
            return below;
        }
        double ratioAbove = (double) sorted[above] / low;
        double ratioBelow = (double) high / Math.max(1, sorted[below]);
        return ratioAbove <= ratioBelow ? above : below;
    }

    /**
     * Nombre maximal de trios formables avec ces effectifs, toutes les compositions entre classes
     * différentes étant permises.
     */
    static int maxTeams(Map<CreatureClass, Integer> counts) {
        int total = counts.values().stream().mapToInt(Integer::intValue).sum();
        int lo = 0;
        int hi = total / 3;
        while (lo < hi) {
            int mid = (lo + hi + 1) >>> 1;
            if (feasible(new ArrayList<>(counts.values()), mid)) {
                lo = mid;
            } else {
                hi = mid - 1;
            }
        }
        return lo;
    }

    private static boolean feasibleAfter(Map<CreatureClass, Integer> counts, Tournament.Composition c, int teams) {
        Map<CreatureClass, Integer> after = new HashMap<>(counts);
        after.merge(c.pair(), -2, Integer::sum);
        after.merge(c.single(), -1, Integer::sum);
        if (after.get(c.pair()) < 0 || after.get(c.single()) < 0) {
            return false;
        }
        return feasible(new ArrayList<>(after.values()), teams);
    }

    /**
     * Peut-on former {@code teams} trios ? On cherche le nombre de paires p de chaque classe
     * (somme = teams) ; chaque classe fournit alors au plus min(effectif − 2p, teams − p) dinos seuls
     * (un dino seul accompagne une paire d'une autre classe), et il en faut teams au total.
     */
    static boolean feasible(List<Integer> counts, int teams) {
        return teams == 0 || feasible(counts, 0, teams, teams, 0);
    }

    private static boolean feasible(List<Integer> counts, int index, int pairsLeft, int teams, int singles) {
        if (index == counts.size()) {
            return pairsLeft == 0 && singles >= teams;
        }
        int n = counts.get(index);
        int maxPairs = Math.min(pairsLeft, n / 2);
        for (int p = maxPairs; p >= 0; p--) {
            int single = Math.min(n - 2 * p, teams - p);
            if (feasible(counts, index + 1, pairsLeft - p, teams, singles + single)) {
                return true;
            }
        }
        return false;
    }

    private static Map<CreatureClass, Integer> classCounts(Map<Fighter, Integer> left, List<CreatureClass> group) {
        Map<CreatureClass, Integer> counts = new LinkedHashMap<>();
        group.forEach(c -> counts.put(c, 0));
        left.forEach((f, n) -> {
            if (counts.containsKey(f.creatureClass())) {
                counts.merge(f.creatureClass(), n, Integer::sum);
            }
        });
        return counts;
    }

    /** Ensembles de classes qui peuvent se combiner entre elles dans ce tournoi. */
    static List<List<CreatureClass>> groups(Tournament tournament) {
        List<Set<CreatureClass>> groups = new ArrayList<>();
        for (Tournament.Composition c : tournament.compositions()) {
            Set<CreatureClass> merged = new LinkedHashSet<>();
            groups.removeIf(g -> {
                if (g.contains(c.pair()) || g.contains(c.single())) {
                    merged.addAll(g);
                    return true;
                }
                return false;
            });
            merged.add(c.pair());
            merged.add(c.single());
            groups.add(merged);
        }
        return groups.stream().map(g -> (List<CreatureClass>) new ArrayList<>(g)).toList();
    }

    private static List<Fighter> available(Map<Fighter, Integer> left, CreatureClass creatureClass) {
        return left.entrySet().stream()
                .filter(e -> e.getValue() > 0 && e.getKey().creatureClass() == creatureClass)
                .map(Map.Entry::getKey)
                .sorted(Comparator.comparingInt(Fighter::ferocity)
                        .thenComparingInt(Fighter::speciesId)
                        .thenComparingInt(Fighter::level))
                .toList();
    }

    private static int lowerBound(int[] sorted, int value) {
        int lo = 0;
        int hi = sorted.length;
        while (lo < hi) {
            int mid = (lo + hi) >>> 1;
            if (sorted[mid] < value) {
                lo = mid + 1;
            } else {
                hi = mid;
            }
        }
        return lo;
    }
}
