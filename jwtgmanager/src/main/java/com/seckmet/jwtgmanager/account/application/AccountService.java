package com.seckmet.jwtgmanager.account.application;

import com.seckmet.jwtgmanager.account.domain.Email;
import com.seckmet.jwtgmanager.account.domain.PasswordHasher;
import com.seckmet.jwtgmanager.account.domain.User;
import com.seckmet.jwtgmanager.account.domain.UserRepository;
import com.seckmet.jwtgmanager.shared.application.ConflictException;
import com.seckmet.jwtgmanager.shared.application.NotFoundException;
import com.seckmet.jwtgmanager.shared.application.UnauthorizedException;
import org.springframework.context.ApplicationEventPublisher;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.UUID;

@Service
public class AccountService {

    private final UserRepository users;
    private final PasswordHasher hasher;
    private final TokenIssuer tokens;
    private final ApplicationEventPublisher events;

    public AccountService(UserRepository users, PasswordHasher hasher, TokenIssuer tokens,
                          ApplicationEventPublisher events) {
        this.users = users;
        this.hasher = hasher;
        this.tokens = tokens;
        this.events = events;
    }

    @Transactional
    public AuthResult register(RegisterCommand command) {
        Email email = new Email(command.email());
        if (users.existsByEmail(email)) {
            throw new ConflictException("Un compte existe déjà avec cet e-mail");
        }
        User user = User.register(email, command.pseudo(), command.password(), hasher);
        users.save(user);
        events.publishEvent(new UserRegistered(user.id()));
        return new AuthResult(tokens.issue(user), toView(user));
    }

    @Transactional(readOnly = true)
    public AuthResult login(LoginCommand command) {
        User user = users.byEmail(new Email(command.email()))
                .filter(u -> u.passwordMatches(command.password(), hasher))
                .orElseThrow(() -> new UnauthorizedException("E-mail ou mot de passe incorrect"));
        return new AuthResult(tokens.issue(user), toView(user));
    }

    @Transactional(readOnly = true)
    public UserView me(UUID userId) {
        return users.byId(userId).map(AccountService::toView)
                .orElseThrow(() -> new NotFoundException("Compte introuvable"));
    }

    private static UserView toView(User u) {
        return new UserView(u.id(), u.email().value(), u.pseudo(), u.role().name());
    }
}
