package com.seckmet.jwtgmanager.account.application;

public record AuthResult(String token, UserView user) {
}
