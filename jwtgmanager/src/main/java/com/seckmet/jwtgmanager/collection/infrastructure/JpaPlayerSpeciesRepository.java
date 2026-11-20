package com.seckmet.jwtgmanager.collection.infrastructure;

import com.seckmet.jwtgmanager.collection.domain.PlayerSpecies;
import com.seckmet.jwtgmanager.collection.domain.PlayerSpeciesRepository;
import com.seckmet.jwtgmanager.collection.domain.SpecimenCounts;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;
import java.util.UUID;

@Repository
class JpaPlayerSpeciesRepository implements PlayerSpeciesRepository {

    private final PlayerSpeciesSpringRepository jpa;

    JpaPlayerSpeciesRepository(PlayerSpeciesSpringRepository jpa) {
        this.jpa = jpa;
    }

    @Override
    public List<PlayerSpecies> byUser(UUID userId) {
        return jpa.findByIdUserId(userId).stream().map(JpaPlayerSpeciesRepository::toDomain).toList();
    }

    @Override
    public Optional<PlayerSpecies> byUserAndSpecies(UUID userId, int speciesId) {
        return jpa.findById(new PlayerSpeciesJpaEntity.Key(userId, speciesId)).map(JpaPlayerSpeciesRepository::toDomain);
    }

    @Override
    public void save(PlayerSpecies species) {
        jpa.save(toEntity(species));
    }

    @Override
    public void saveAll(List<PlayerSpecies> species) {
        jpa.saveAll(species.stream().map(JpaPlayerSpeciesRepository::toEntity).toList());
    }

    private static PlayerSpecies toDomain(PlayerSpeciesJpaEntity e) {
        return new PlayerSpecies(e.getId().userId(), e.getId().speciesId(), e.isUnlocked(),
                new SpecimenCounts(e.getLvl10(), e.getLvl20(), e.getLvl30(), e.getLvl40()),
                e.getTargetLvl40(), e.isFavorite(), e.getUpdatedAt());
    }

    private static PlayerSpeciesJpaEntity toEntity(PlayerSpecies p) {
        var c = p.counts();
        return new PlayerSpeciesJpaEntity(new PlayerSpeciesJpaEntity.Key(p.userId(), p.speciesId()), p.unlocked(),
                (short) c.lvl10(), (short) c.lvl20(), (short) c.lvl30(), (short) c.lvl40(),
                (short) p.targetLvl40(), p.favorite(), p.updatedAt());
    }
}
