package com.seckmet.jwtgmanager.collection.application;

public record UpdateSpeciesCommand(boolean unlocked, int lvl10, int lvl20, int lvl30, int lvl40, int targetLvl40) {
}
