package com.seckmet.jwtgmanager.catalog.application;

import java.util.List;

/** {@code kind} : HYBRID ou SUPER_HYBRID ; composants vides si la recette n'est pas renseignée. */
public record HybridView(int hybridId, String name, String kind, List<Integer> componentIds) {
}
