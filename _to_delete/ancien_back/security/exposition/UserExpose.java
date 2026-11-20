package com.seckmet.jwtgmanager.security.exposition;

import com.seckmet.jwtgmanager.security.domain.Role;

public record UserExpose(String username, Role role) {
}
