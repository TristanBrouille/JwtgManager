package com.seckmet.jwtgmanager.shared.exposition;

import org.springframework.security.oauth2.jwt.Jwt;

import java.util.UUID;

/** Lit l'identifiant du joueur connecté depuis le jeton JWT (claim « sub »). */
public final class CurrentUser {
    private CurrentUser() {
    }

    public static UUID id(Jwt jwt) {
        return UUID.fromString(jwt.getSubject());
    }
}
