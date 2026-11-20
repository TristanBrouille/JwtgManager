package com.seckmet.jwtgmanager.collection.domain;

import com.seckmet.jwtgmanager.shared.domain.Level;

import com.seckmet.jwtgmanager.shared.domain.DomainException;

public class NotEnoughSpecimensException extends DomainException {
    public NotEnoughSpecimensException(Level level, int available, int requested) {
        super("Pas assez de spécimens au niveau " + level.value() + " : " + available
                + " disponible(s), " + requested + " demandé(s)");
    }
}
