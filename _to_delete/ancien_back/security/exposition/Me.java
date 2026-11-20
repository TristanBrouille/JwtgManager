package com.seckmet.jwtgmanager.security.exposition;

import java.util.List;

public record Me(String email, List<String> roles) {}
