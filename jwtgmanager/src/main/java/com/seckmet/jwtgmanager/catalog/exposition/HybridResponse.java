package com.seckmet.jwtgmanager.catalog.exposition;

import java.util.List;

public record HybridResponse(int hybridId, String name, String kind, List<Integer> componentIds) {
}
