package com.seckmet.jwtgmanager.security.domain;

import jakarta.persistence.Embeddable;
import java.util.concurrent.atomic.AtomicLong;

@Embeddable
public record UserId(Long value) {
    private static final AtomicLong NEXT_ID = new AtomicLong();
    public static UserId next() {
        return new UserId(NEXT_ID.getAndIncrement());
    }
}