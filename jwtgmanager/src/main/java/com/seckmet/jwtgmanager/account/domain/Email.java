package com.seckmet.jwtgmanager.account.domain;

import java.util.Locale;
import java.util.regex.Pattern;

/** Adresse e-mail normalisée (minuscules, sans espaces). */
public record Email(String value) {
    private static final Pattern FORMAT = Pattern.compile("^[^@\\s]+@[^@\\s]+\\.[^@\\s]+$");

    public Email {
        if (value == null) {
            throw new InvalidEmailException("L'e-mail est obligatoire");
        }
        value = value.trim().toLowerCase(Locale.ROOT);
        if (!FORMAT.matcher(value).matches()) {
            throw new InvalidEmailException("Format d'e-mail invalide : " + value);
        }
    }
}
