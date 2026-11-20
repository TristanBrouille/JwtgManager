package com.seckmet.jwtgmanager.creature.domain;

import jakarta.persistence.Embeddable;
import java.util.concurrent.atomic.AtomicLong;

@Embeddable
public record CreatureId(long value) {
    private static final AtomicLong NEXT_ID = new AtomicLong();
    public static CreatureId next() {
        return new CreatureId(NEXT_ID.getAndIncrement());
    }
}
