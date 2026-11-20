package com.seckmet.jwtgmanager.account.infrastructure;

import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.Id;
import jakarta.persistence.Table;

import java.time.Instant;
import java.util.UUID;

@Entity
@Table(name = "app_user")
public class UserJpaEntity {
    @Id
    private UUID id;
    @Column(nullable = false, unique = true)
    private String email;
    @Column(nullable = false)
    private String pseudo;
    @Column(name = "password_hash", nullable = false)
    private String passwordHash;
    @Column(nullable = false)
    private String role;
    @Column(name = "created_at", nullable = false)
    private Instant createdAt;

    protected UserJpaEntity() {
    }

    UserJpaEntity(UUID id, String email, String pseudo, String passwordHash, String role, Instant createdAt) {
        this.id = id;
        this.email = email;
        this.pseudo = pseudo;
        this.passwordHash = passwordHash;
        this.role = role;
        this.createdAt = createdAt;
    }

    public UUID getId() { return id; }
    public String getEmail() { return email; }
    public String getPseudo() { return pseudo; }
    public String getPasswordHash() { return passwordHash; }
    public String getRole() { return role; }
    public Instant getCreatedAt() { return createdAt; }
}
