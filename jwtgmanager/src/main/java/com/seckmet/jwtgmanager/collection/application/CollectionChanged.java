package com.seckmet.jwtgmanager.collection.application;

import java.util.UUID;

/** Publié après toute modification de la collection d'un joueur. */
public record CollectionChanged(UUID userId) {
}
