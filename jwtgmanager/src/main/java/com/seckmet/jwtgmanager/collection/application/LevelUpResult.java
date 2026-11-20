package com.seckmet.jwtgmanager.collection.application;

/** Résultat d'une montée de niveau : coût figé et monnaie utilisée. */
public record LevelUpResult(String speciesName, long cost, String currency) {
}
