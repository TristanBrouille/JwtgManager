package com.seckmet.jwtgmanager.catalog.application;

import com.seckmet.jwtgmanager.catalog.domain.CatalogRepository;
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

@Service
@Transactional(readOnly = true)
public class CatalogService {

    private final CatalogRepository catalog;

    public CatalogService(CatalogRepository catalog) {
        this.catalog = catalog;
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

    private static SpeciesView toView(Species s) {
        return new SpeciesView(s.id(), s.name(), s.rarityCode(), s.dnaCost(), s.amberCost(),
                s.hybridKind().name(), s.defaultUnlocked());
    }
}
