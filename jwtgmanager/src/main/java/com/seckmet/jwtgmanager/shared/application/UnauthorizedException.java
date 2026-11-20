package com.seckmet.jwtgmanager.shared.application;

public class UnauthorizedException extends RuntimeException {
    public UnauthorizedException(String message) {
        super(message);
    }
}
