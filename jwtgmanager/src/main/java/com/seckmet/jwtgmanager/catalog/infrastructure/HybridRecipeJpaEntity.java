package com.seckmet.jwtgmanager.catalog.infrastructure;

import jakarta.persistence.Column;
import jakarta.persistence.Embeddable;
import jakarta.persistence.EmbeddedId;
import jakarta.persistence.Entity;
import jakarta.persistence.Table;

import java.io.Serializable;

@Entity
@Table(name = "hybrid_recipe")
public class HybridRecipeJpaEntity {

    @Embeddable
    public record Key(@Column(name = "hybrid_id") Integer hybridId,
                      @Column(name = "component_id") Integer componentId) implements Serializable {
    }

    @EmbeddedId
    private Key id;

    protected HybridRecipeJpaEntity() {
    }

    public Key getId() { return id; }
}
