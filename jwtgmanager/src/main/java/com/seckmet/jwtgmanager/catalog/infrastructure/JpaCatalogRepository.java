package com.seckmet.jwtgmanager.catalog.infrastructure;

import com.seckmet.jwtgmanager.catalog.domain.CatalogRepository;
import com.seckmet.jwtgmanager.catalog.domain.HybridKind;
import com.seckmet.jwtgmanager.catalog.domain.HybridRecipe;
import com.seckmet.jwtgmanager.catalog.domain.Rarity;
import com.seckmet.jwtgmanager.catalog.domain.Species;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;
import java.util.TreeMap;
import java.util.stream.Collectors;

@Repository
class JpaCatalogRepository implements CatalogRepository {

    private final RaritySpringRepository rarities;
    private final SpeciesSpringRepository species;
    private final HybridRecipeSpringRepository recipes;

    JpaCatalogRepository(RaritySpringRepository rarities, SpeciesSpringRepository species,
                         HybridRecipeSpringRepository recipes) {
        this.rarities = rarities;
        this.species = species;
        this.recipes = recipes;
    }

    @Override
    public List<Rarity> rarities() {
        return rarities.findAll().stream()
                .map(r -> new Rarity(r.getCode(), r.getLabel(), r.getSortOrder()))
                .toList();
    }

    @Override
    public List<Species> species() {
        return species.findAll().stream().map(JpaCatalogRepository::toDomain).toList();
    }

    @Override
    public Optional<Species> speciesById(int id) {
        return species.findById(id).map(JpaCatalogRepository::toDomain);
    }

    @Override
    public List<HybridRecipe> hybridRecipes() {
        return recipes.findAll().stream()
                .collect(Collectors.groupingBy(r -> r.getId().hybridId(), TreeMap::new,
                        Collectors.mapping(r -> r.getId().componentId(), Collectors.toList())))
                .entrySet().stream()
                .map(e -> new HybridRecipe(e.getKey(), e.getValue()))
                .toList();
    }

    private static Species toDomain(SpeciesJpaEntity e) {
        return new Species(e.getId(), e.getName(), e.getRarityCode(),
                e.getDnaCost() == null ? null : e.getDnaCost().longValue(),
                e.getAmberCost() == null ? null : e.getAmberCost().longValue(),
                HybridKind.valueOf(e.getHybridKind()), e.isDefaultUnlocked());
    }
}
