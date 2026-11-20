package com.seckmet.jwtgmanager.account.exposition;

import jakarta.validation.constraints.Email;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Size;

public record RegisterRequest(
        @NotBlank(message = "obligatoire") @Email(message = "format invalide") String email,
        @NotBlank(message = "obligatoire") @Size(max = 40, message = "40 caractères maximum") String pseudo,
        @NotBlank(message = "obligatoire") @Size(min = 8, message = "8 caractères minimum") String password) {
}
