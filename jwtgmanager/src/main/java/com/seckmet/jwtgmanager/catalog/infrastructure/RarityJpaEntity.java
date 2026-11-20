package com.seckmet.jwtgmanager.catalog.infrastructure;

import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.Id;
import jakarta.persistence.Table;
import org.hibernate.annotations.JdbcTypeCode;
import org.hibernate.type.SqlTypes;

@Entity
@Table(name = "rarity")
public class RarityJpaEntity {
    @Id
    @JdbcTypeCode(SqlTypes.CHAR)
    @Column(name = "code", length = 1)
    private String code;
    @Column(name = "label", nullable = false)
    private String label;
    @Column(name = "sort_order", nullable = false)
    private Short sortOrder;

    protected RarityJpaEntity() {
    }

    public String getCode() { return code; }
    public String getLabel() { return label; }
    public Short getSortOrder() { return sortOrder; }
}
