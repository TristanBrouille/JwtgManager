package com.seckmet.jwtgmanager.account.domain;

import org.junit.jupiter.api.Test;

import static org.assertj.core.api.Assertions.assertThat;
import static org.assertj.core.api.Assertions.assertThatThrownBy;

class UserTest {

    private final PasswordHasher fakeHasher = new PasswordHasher() {
        public String hash(String raw) { return "h:" + raw; }
        public boolean matches(String raw, String hash) { return hash.equals("h:" + raw); }
    };

    @Test
    void email_isNormalized() {
        assertThat(new Email("  Demo@JWTG.Local ").value()).isEqualTo("demo@jwtg.local");
    }

    @Test
    void email_rejectsInvalidFormat() {
        assertThatThrownBy(() -> new Email("pas-un-mail")).isInstanceOf(InvalidEmailException.class);
    }

    @Test
    void register_hashesPassword_andChecksIt() {
        User u = User.register(new Email("a@b.fr"), "Rex", "motdepasse", fakeHasher);
        assertThat(u.passwordHash()).isEqualTo("h:motdepasse");
        assertThat(u.passwordMatches("motdepasse", fakeHasher)).isTrue();
        assertThat(u.passwordMatches("autre", fakeHasher)).isFalse();
        assertThat(u.role()).isEqualTo(Role.USER);
    }

    @Test
    void register_rejectsShortPassword() {
        assertThatThrownBy(() -> User.register(new Email("a@b.fr"), "Rex", "court", fakeHasher))
                .isInstanceOf(WeakPasswordException.class);
    }
}
