package com.seckmet.jwtgmanager.collection.infrastructure;

import com.seckmet.jwtgmanager.collection.domain.PlayerSettings;
import com.seckmet.jwtgmanager.collection.domain.PlayerSettingsRepository;
import org.springframework.stereotype.Repository;

import java.util.Optional;
import java.util.UUID;

@Repository
class JpaPlayerSettingsRepository implements PlayerSettingsRepository {

    private final PlayerSettingsSpringRepository jpa;

    JpaPlayerSettingsRepository(PlayerSettingsSpringRepository jpa) {
        this.jpa = jpa;
    }

    @Override
    public Optional<PlayerSettings> byUser(UUID userId) {
        return jpa.findById(userId).map(e -> new PlayerSettings(e.getUserId(), e.getWeeklyDna(),
                e.getWeeklySuperDna(), e.getWeeklyAmber(), e.getDefaultTarget()));
    }

    @Override
    public void save(PlayerSettings s) {
        jpa.save(new PlayerSettingsJpaEntity(s.userId(), Math.toIntExact(s.weeklyDna()),
                Math.toIntExact(s.weeklySuperDna()), Math.toIntExact(s.weeklyAmber()), (short) s.defaultTarget()));
    }
}
