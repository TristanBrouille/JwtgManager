package com.seckmet.jwtgmanager.shared.application;

public class ConflictException extends RuntimeException {
    public ConflictException(String message) {
        super(message);
    }
}
