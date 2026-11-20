package com.seckmet.jwtgmanager.shared.domain;

/** Violation d'une règle métier. */
public abstract class DomainException extends RuntimeException {
    protected DomainException(String message) {
        super(message);
    }
}
