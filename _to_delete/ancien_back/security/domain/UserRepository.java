package com.seckmet.jwtgmanager.security.domain;

public interface UserRepository {
    User ofEmail(String email);
    User save(User user);
}
