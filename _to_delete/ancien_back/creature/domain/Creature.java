package com.seckmet.jwtgmanager.creature.domain;

import jakarta.persistence.EmbeddedId;
import jakarta.persistence.Entity;
import lombok.Data;

@Entity
@Data
public class Creature {
    @EmbeddedId
    private CreatureId id;
    private String name;
    private Rarity rarity;
    private Region region;
    private Class creatureClass;
    private Hybride creatureHybride;
    private Integer dnaPrice;
    private Integer amberPrice;
}
