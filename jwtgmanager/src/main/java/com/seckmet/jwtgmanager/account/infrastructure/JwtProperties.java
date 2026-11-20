package com.seckmet.jwtgmanager.account.infrastructure;

import org.springframework.boot.context.properties.ConfigurationProperties;

import java.time.Duration;
import java.util.List;

@ConfigurationProperties(prefix = "jwtg.security")
public record JwtProperties(String jwtSecret, Duration tokenValidity, List<String> allowedOrigins) {
    public JwtProperties {
        if (jwtSecret == null || jwtSecret.length() < 32) {
            throw new IllegalStateException("jwtg.security.jwt-secret doit faire au moins 32 caractères");
        }
        if (tokenValidity == null) {
            tokenValidity = Duration.ofDays(7);
        }
        if (allowedOrigins == null || allowedOrigins.isEmpty()) {
            allowedOrigins = List.of("http://localhost:4200");
        }
    }
}
