package com.seckmet.jwtgmanager.account.exposition;

import java.util.UUID;

public record UserResponse(UUID id, String email, String pseudo, String role) {
}
