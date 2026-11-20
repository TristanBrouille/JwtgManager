package com.seckmet.jwtgmanager.account.domain;

import com.seckmet.jwtgmanager.shared.domain.DomainException;

public class WeakPasswordException extends DomainException {
    public WeakPasswordException() {
        super("Le mot de passe doit contenir au moins 8 caractères");
    }
}
