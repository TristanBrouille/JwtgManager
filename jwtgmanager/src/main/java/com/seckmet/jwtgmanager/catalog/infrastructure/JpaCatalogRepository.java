package com.seckmet.jwtgmanager.catalog.infrastructure;

import com.seckmet.jwtgmanager.catalog.domain.CatalogRepository;
import com.seckmet.jwtgmanager.catalog.domain.CreatureSheet;
import com.seckmet.jwtgmanager.catalog.domain.HybridKind;
import com.seckmet.jwtgmanager.catalog.domain.HybridRecipe;
import com.seckmet.jwtgmanager.catalog.domain.Rarity;
import com.seckmet.jwtgmanager.catalog.domain.Species;
import org.springframework.stereotype.Repository;

import java.util.Arrays;
import java.util.List;
import java.util.Optional;
import java.util.TreeMap;
import java.util.stream.Collectors;

@Repository
class JpaCatalogRepository implements CatalogRepository {

    private final RaritySpringRepository rarities;
    private final SpeciesSpringRepository species;
    private final HybridRecipeSpringRepository recipes;
    private final CreatureSheetSpringRepository sheets;

    JpaCatalogRepository(RaritySpringRepository rarities, SpeciesSpringRepository species,
                         HybridRecipeSpringRepository recipes, CreatureSheetSpringRepository sheets) {
        this.rarities = rarities;
        this.species = species;
        this.recipes = recipes;
        this.sheets = sheets;
    }

    @Override
    public Optional<CreatureSheet> sheetOf(int speciesId) {
        return sheets.findById(speciesId).map(JpaCatalogRepository::toDomain);
    }

    @Override
    public List<CreatureSheet> sheets() {
        return sheets.findAll().stream().map(JpaCatalogRepository::toDomain).toList();
    }

    private static CreatureSheet toDomain(CreatureSheetJpaEntity e) {
        return new CreatureSheet(e.getSpeciesId(), e.getSourceKey(), e.getRegion(), e.getCreatureClass(),
                e.getRegionCode(), e.getClassCode(), e.getReleaseDate(),
                Arrays.asList(e.getHealthLvl10(), e.getHealthLvl20(), e.getHealthLvl30(), e.getHealthLvl40()),
                Arrays.asList(e.getAttackLvl10(), e.getAttackLvl20(), e.getAttackLvl30(), e.getAttackLvl40()),
                e.getFerocity(), e.getCoins(), e.getCoinMinutes(), e.getCoinsPerMinute(), e.getHatchMinutes(),
                e.getDnaBuy(), e.getDnaSell());
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
