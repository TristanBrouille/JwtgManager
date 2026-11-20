package com.seckmet.jwtgmanager.account.domain;

import com.seckmet.jwtgmanager.shared.domain.DomainException;

public class InvalidEmailException extends DomainException {
    public InvalidEmailException(String message) {
        super(message);
    }
}
