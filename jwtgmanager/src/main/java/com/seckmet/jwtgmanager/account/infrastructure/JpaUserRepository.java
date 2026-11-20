package com.seckmet.jwtgmanager.account.infrastructure;

import com.seckmet.jwtgmanager.account.domain.Email;
import com.seckmet.jwtgmanager.account.domain.Role;
import com.seckmet.jwtgmanager.account.domain.User;
import com.seckmet.jwtgmanager.account.domain.UserRepository;
import org.springframework.stereotype.Repository;

import java.util.Optional;
import java.util.UUID;

@Repository
class JpaUserRepository implements UserRepository {

    private final UserSpringRepository jpa;

    JpaUserRepository(UserSpringRepository jpa) {
        this.jpa = jpa;
    }

    @Override
    public Optional<User> byEmail(Email email) {
        return jpa.findByEmail(email.value()).map(JpaUserRepository::toDomain);
    }

    @Override
    public Optional<User> byId(UUID id) {
        return jpa.findById(id).map(JpaUserRepository::toDomain);
    }

    @Override
    public boolean existsByEmail(Email email) {
        return jpa.existsByEmail(email.value());
    }

    @Override
    public void save(User u) {
        jpa.save(new UserJpaEntity(u.id(), u.email().value(), u.pseudo(), u.passwordHash(),
                u.role().name(), u.createdAt()));
    }

    private static User toDomain(UserJpaEntity e) {
        return new User(e.getId(), new Email(e.getEmail()), e.getPseudo(), e.getPasswordHash(),
                Role.valueOf(e.getRole()), e.getCreatedAt());
    }
}
