package com.seckmet.jwtgmanager.catalog.application;

import java.util.List;

/** Santé et attaque par palier (niveaux 10, 20, 30, 40), avec la région et la classe (codes paleo.gg). */
public record CombatSheetView(int speciesId, String sourceKey, String regionCode, String classCode,
                              List<Integer> health, List<Integer> attack) {
}
