package com.seckmet.jwtgmanager.account.application;

import java.util.UUID;

public record UserView(UUID id, String email, String pseudo, String role) {
}
