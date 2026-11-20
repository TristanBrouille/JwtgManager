package com.seckmet.jwtgmanager.account.infrastructure;

import com.seckmet.jwtgmanager.account.application.TokenIssuer;
import com.seckmet.jwtgmanager.account.domain.User;
import org.springframework.security.oauth2.jose.jws.MacAlgorithm;
import org.springframework.security.oauth2.jwt.JwsHeader;
import org.springframework.security.oauth2.jwt.JwtClaimsSet;
import org.springframework.security.oauth2.jwt.JwtEncoder;
import org.springframework.security.oauth2.jwt.JwtEncoderParameters;
import org.springframework.stereotype.Component;

import java.time.Instant;

@Component
class JwtTokenIssuer implements TokenIssuer {

    private final JwtEncoder encoder;
    private final JwtProperties properties;

    JwtTokenIssuer(JwtEncoder encoder, JwtProperties properties) {
        this.encoder = encoder;
        this.properties = properties;
    }

    @Override
    public String issue(User user) {
        Instant now = Instant.now();
        JwtClaimsSet claims = JwtClaimsSet.builder()
                .issuer("jwtg-manager")
                .issuedAt(now)
                .expiresAt(now.plus(properties.tokenValidity()))
                .subject(user.id().toString())
                .claim("email", user.email().value())
                .claim("pseudo", user.pseudo())
                .claim("roles", java.util.List.of(user.role().name()))
                .build();
        JwsHeader header = JwsHeader.with(MacAlgorithm.HS256).build();
        return encoder.encode(JwtEncoderParameters.from(header, claims)).getTokenValue();
    }
}
