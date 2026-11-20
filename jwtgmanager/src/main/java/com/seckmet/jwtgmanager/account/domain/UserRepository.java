package com.seckmet.jwtgmanager.account.domain;

import java.util.Optional;
import java.util.UUID;

public interface UserRepository {
    Optional<User> byEmail(Email email);

    Optional<User> byId(UUID id);

    boolean existsByEmail(Email email);

    void save(User user);
}
