package com.seckmet.jwtgmanager.account.exposition;

import com.seckmet.jwtgmanager.account.application.AccountService;
import com.seckmet.jwtgmanager.account.application.AuthResult;
import com.seckmet.jwtgmanager.account.application.LoginCommand;
import com.seckmet.jwtgmanager.account.application.RegisterCommand;
import com.seckmet.jwtgmanager.account.application.UserView;
import com.seckmet.jwtgmanager.shared.exposition.CurrentUser;
import jakarta.validation.Valid;
import org.springframework.http.HttpStatus;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.security.oauth2.jwt.Jwt;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.ResponseStatus;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/api/auth")
public class AuthController {

    private final AccountService accounts;

    public AuthController(AccountService accounts) {
        this.accounts = accounts;
    }

    @PostMapping("/register")
    @ResponseStatus(HttpStatus.CREATED)
    public AuthResponse register(@Valid @RequestBody RegisterRequest request) {
        return toResponse(accounts.register(new RegisterCommand(request.email(), request.pseudo(), request.password())));
    }

    @PostMapping("/login")
    public AuthResponse login(@Valid @RequestBody LoginRequest request) {
        return toResponse(accounts.login(new LoginCommand(request.email(), request.password())));
    }

    @GetMapping("/me")
    public UserResponse me(@AuthenticationPrincipal Jwt jwt) {
        return toResponse(accounts.me(CurrentUser.id(jwt)));
    }

    private static AuthResponse toResponse(AuthResult result) {
        return new AuthResponse(result.token(), toResponse(result.user()));
    }

    private static UserResponse toResponse(UserView u) {
        return new UserResponse(u.id(), u.email(), u.pseudo(), u.role());
    }
}
