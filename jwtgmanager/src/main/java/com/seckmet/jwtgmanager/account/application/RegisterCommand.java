package com.seckmet.jwtgmanager.account.application;

public record RegisterCommand(String email, String pseudo, String password) {
}
