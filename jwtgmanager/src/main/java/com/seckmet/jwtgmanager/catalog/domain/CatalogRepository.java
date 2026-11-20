package com.seckmet.jwtgmanager.catalog.domain;

import java.util.List;
import java.util.Optional;

public interface CatalogRepository {
    List<Rarity> rarities();

    List<Species> species();

    Optional<Species> speciesById(int id);

    List<HybridRecipe> hybridRecipes();
}
