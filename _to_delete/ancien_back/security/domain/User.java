package com.seckmet.jwtgmanager.security.domain;

import jakarta.persistence.*;
import lombok.Data;


@Entity
@Data
@Table(name = "users")
public class User {
    @EmbeddedId
    private UserId id;
    private String username;
    private String email;
    private String password;
    @Enumerated(EnumType.STRING)
    private Role role;

}
