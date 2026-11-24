package com.seckmet.jwtgmanager.catalog.application;

import com.seckmet.jwtgmanager.catalog.domain.CatalogRepository;
import com.seckmet.jwtgmanager.catalog.domain.CreatureSheet;
import com.seckmet.jwtgmanager.catalog.domain.HybridRecipe;
import com.seckmet.jwtgmanager.catalog.domain.Species;
import com.seckmet.jwtgmanager.shared.application.NotFoundException;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.Comparator;
import java.util.List;
import java.util.Map;
import java.util.function.Function;
import java.util.stream.Collectors;
import java.util.stream.IntStream;

@Service
@Transactional(readOnly = true)
public class CatalogService {

    private final CatalogRepository catalog;
    private final CreatureMedia media;

    public CatalogService(CatalogRepository catalog, CreatureMedia media) {
        this.catalog = catalog;
        this.media = media;
    }

    public List<RarityView> rarities() {
        return catalog.rarities().stream()
                .sorted(Comparator.comparingInt(r -> r.sortOrder()))
                .map(r -> new RarityView(r.code(), r.label(), r.sortOrder()))
                .toList();
    }

    public List<SpeciesView> species() {
        return catalog.species().stream().map(CatalogService::toView).toList();
    }

    public Map<Integer, SpeciesView> speciesById() {
        return species().stream().collect(Collectors.toMap(SpeciesView::id, Function.identity()));
    }

    public SpeciesView species(int id) {
        return catalog.speciesById(id).map(CatalogService::toView)
                .orElseThrow(() -> new NotFoundException("Espèce " + id + " introuvable"));
    }

    /** Tous les hybrides et super hybrides du catalogue, avec leurs composants connus. */
    public List<HybridView> hybrids() {
        Map<Integer, List<Integer>> components = catalog.hybridRecipes().stream()
                .collect(Collectors.toMap(HybridRecipe::hybridId, HybridRecipe::componentIds));
        return catalog.species().stream()
                .filter(Species::hybrid)
                .map(s -> new HybridView(s.id(), s.name(), s.hybridKind().name(),
                        components.getOrDefault(s.id(), List.of())))
                .sorted(Comparator.comparing(HybridView::name))
                .toList();
    }

    /** Fiche d'une espèce avec sa recette, les hybrides qui l'utilisent et ses statistiques de jeu. */
    public SpeciesDetailView detail(int id) {
        SpeciesView species = species(id);
        List<HybridRecipe> recipes = catalog.hybridRecipes();
        List<Integer> components = recipes.stream()
                .filter(r -> r.hybridId() == id)
                .findFirst().map(HybridRecipe::componentIds).orElse(List.of());
        List<Integer> usedIn = recipes.stream()
                .filter(r -> r.componentIds().contains(id))
                .map(HybridRecipe::hybridId)
                .toList();
        SpeciesDetailView.Sheet sheet = catalog.sheetOf(id).map(this::toSheet).orElse(null);
        return new SpeciesDetailView(species, components, usedIn, sheet);
    }

    private SpeciesDetailView.Sheet toSheet(CreatureSheet c) {
        List<SpeciesDetailView.Level> levels = IntStream.range(0, CreatureSheet.LEVELS)
                .mapToObj(i -> new SpeciesDetailView.Level((i + 1) * 10, c.health().get(i), c.attack().get(i),
                        media.portraitUrl(c.sourceKey(), i + 1)))
                .toList();
        return new SpeciesDetailView.Sheet(c.region(), c.creatureClass(), c.releaseDate(), levels,
                c.ferocity(), c.coins(), c.coinMinutes(), c.coinsPerMinute(), c.hatchMinutes(),
                c.dnaBuy(), c.dnaSell(), media.imageUrl(c.sourceKey()), media.sourcePageUrl(c.sourceKey()));
    }

    private static SpeciesView toView(Species s) {
        return new SpeciesView(s.id(), s.name(), s.rarityCode(), s.dnaCost(), s.amberCost(),
                s.hybridKind().name(), s.defaultUnlocked());
    }
}
