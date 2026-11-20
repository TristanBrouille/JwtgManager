package com.seckmet.jwtgmanager.progress.application;

import java.time.LocalDate;

public record HistoryPointView(LocalDate day, double completion, long lvl40Count, long lvl40Target) {
}
