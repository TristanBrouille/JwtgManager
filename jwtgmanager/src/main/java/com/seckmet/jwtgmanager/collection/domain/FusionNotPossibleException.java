package com.seckmet.jwtgmanager.collection.domain;

import com.seckmet.jwtgmanager.shared.domain.DomainException;

public class FusionNotPossibleException extends DomainException {
    public FusionNotPossibleException(String message) {
        super(message);
    }
}
