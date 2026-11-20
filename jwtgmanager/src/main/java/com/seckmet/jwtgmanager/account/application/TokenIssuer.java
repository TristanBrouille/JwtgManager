package com.seckmet.jwtgmanager.account.application;

import com.seckmet.jwtgmanager.account.domain.User;

public interface TokenIssuer {
    String issue(User user);
}
