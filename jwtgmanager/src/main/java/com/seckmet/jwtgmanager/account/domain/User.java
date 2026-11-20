package com.seckmet.jwtgmanager.account.domain;

import java.time.Instant;
import java.util.Objects;
import java.util.UUID;

/** Compte joueur. */
public class User {
    public static final int MIN_PASSWORD_LENGTH = 8;

    private final UUID id;
    private final Email email;
    private final String pseudo;
    private final String passwordHash;
    private final Role role;
    private final Instant createdAt;

    public User(UUID id, Email email, String pseudo, String passwordHash, Role role, Instant createdAt) {
        this.id = Objects.requireNonNull(id);
        this.email = Objects.requireNonNull(email);
        if (pseudo == null || pseudo.isBlank()) {
            throw new IllegalArgumentException("Le pseudo est obligatoire");
        }
        this.pseudo = pseudo.trim();
        this.passwordHash = Objects.requireNonNull(passwordHash);
        this.role = Objects.requireNonNull(role);
        this.createdAt = Objects.requireNonNull(createdAt);
    }

    /** Crée un nouveau joueur à partir d'un mot de passe en clair, haché par le {@link PasswordHasher}. */
    public static User register(Email email, String pseudo, String rawPassword, PasswordHasher hasher) {
        if (rawPassword == null || rawPassword.length() < MIN_PASSWORD_LENGTH) {
            throw new WeakPasswordException();
        }
        return new User(UUID.randomUUID(), email, pseudo, hasher.hash(rawPassword), Role.USER, Instant.now());
    }

    public boolean passwordMatches(String rawPassword, PasswordHasher hasher) {
        return rawPassword != null && hasher.matches(rawPassword, passwordHash);
    }

    public UUID id() { return id; }
    public Email email() { return email; }
    public String pseudo() { return pseudo; }
    public String passwordHash() { return passwordHash; }
    public Role role() { return role; }
    public Instant createdAt() { return createdAt; }
}
