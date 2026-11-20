package com.seckmet.jwtgmanager.account.exposition;

import jakarta.validation.constraints.NotBlank;

public record LoginRequest(@NotBlank(message = "obligatoire") String email,
                           @NotBlank(message = "obligatoire") String password) {
}
