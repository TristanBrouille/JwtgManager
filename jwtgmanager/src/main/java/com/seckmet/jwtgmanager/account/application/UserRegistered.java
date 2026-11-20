package com.seckmet.jwtgmanager.account.application;

import java.util.UUID;

/** Publié quand un joueur vient de s'inscrire. */
public record UserRegistered(UUID userId) {
}
