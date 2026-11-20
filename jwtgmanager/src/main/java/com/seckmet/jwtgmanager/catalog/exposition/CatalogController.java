package com.seckmet.jwtgmanager.catalog.exposition;

import com.seckmet.jwtgmanager.catalog.application.CatalogService;
import org.springframework.web.bind.annotation.GetMapping;
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

    @GetMapping("/hybrids")
    public List<HybridResponse> hybrids() {
        return catalog.hybrids().stream()
                .map(h -> new HybridResponse(h.hybridId(), h.name(), h.kind(), h.componentIds())).toList();
    }
}
