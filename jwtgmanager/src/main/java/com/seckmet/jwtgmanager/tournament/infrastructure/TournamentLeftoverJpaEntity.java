package com.seckmet.jwtgmanager.tournament.infrastructure;

import jakarta.persistence.Column;
import jakarta.persistence.Embeddable;
import jakarta.persistence.EmbeddedId;
import jakarta.persistence.Entity;
import jakarta.persistence.Table;

import java.io.Serializable;
import java.util.UUID;

@Entity
@Table(name = "tournament_leftover")
public class TournamentLeftoverJpaEntity {

    @Embeddable
    public record Key(@Column(name = "user_id") UUID userId,
                      @Column(name = "tournament") String tournament,
                      @Column(name = "species_id") Integer speciesId,
                      @Column(name = "level") Short level) implements Serializable {
    }

    @EmbeddedId
    private Key id;
    @Column(name = "class_code", nullable = false)
    private String classCode;
    @Column(nullable = false)
    private int health;
    @Column(nullable = false)
    private int attack;
    @Column(nullable = false)
    private short quantity;

    protected TournamentLeftoverJpaEntity() {
    }

    TournamentLeftoverJpaEntity(Key id, String classCode, int health, int attack, short quantity) {
        this.id = id;
        this.classCode = classCode;
        this.health = health;
        this.attack = attack;
        this.quantity = quantity;
    }

    public Key getId() { return id; }
    public String getClassCode() { return classCode; }
    public int getHealth() { return health; }
    public int getAttack() { return attack; }
    public short getQuantity() { return quantity; }
}
