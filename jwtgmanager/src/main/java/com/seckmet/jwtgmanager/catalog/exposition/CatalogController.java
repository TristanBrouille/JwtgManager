package com.seckmet.jwtgmanager.catalog.exposition;

import com.seckmet.jwtgmanager.catalog.application.CatalogService;
import com.seckmet.jwtgmanager.catalog.application.SpeciesDetailView;
import com.seckmet.jwtgmanager.catalog.application.SpeciesView;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import java.util.List;

@RestController
@RequestMapping("/api/catalog")
public class CatalogController {

    private final CatalogService catalog;

    public CatalogController(CatalogService catalog) {
        this.catalog = catalog;
    }

    @GetMapping("/rarities")
    public List<RarityResponse> rarities() {
        return catalog.rarities().stream()
                .map(r -> new RarityResponse(r.code(), r.label(), r.sortOrder())).toList();
    }

    @GetMapping("/species/{id}")
    public SpeciesDetailResponse species(@PathVariable int id) {
        SpeciesDetailView d = catalog.detail(id);
        SpeciesView s = d.species();
        SpeciesDetailView.Sheet c = d.sheet();
        SpeciesDetailResponse.Sheet sheet = c == null ? null : new SpeciesDetailResponse.Sheet(
                c.region(), c.creatureClass(), c.releaseDate(),
                c.levels().stream().map(l -> new SpeciesDetailResponse.Level(l.level(), l.health(), l.attack(),
                        l.portraitUrl())).toList(),
                c.ferocity(), c.coins(), c.coinMinutes(), c.coinsPerMinute(), c.hatchMinutes(),
                c.dnaBuy(), c.dnaSell(), c.imageUrl(), c.sourceUrl());
        return new SpeciesDetailResponse(s.id(), s.name(), s.rarityCode(), s.hybridKind(), s.dnaCost(),
                s.amberCost(), d.componentIds(), d.usedInIds(), sheet);
    }

    @GetMapping("/hybrids")
    public List<HybridResponse> hybrids() {
        return catalog.hybrids().stream()
                .map(h -> new HybridResponse(h.hybridId(), h.name(), h.kind(), h.componentIds())).toList();
    }
}
