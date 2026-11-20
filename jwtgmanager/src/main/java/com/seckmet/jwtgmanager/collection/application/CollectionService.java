package com.seckmet.jwtgmanager.collection.application;

import com.seckmet.jwtgmanager.account.application.UserRegistered;
import com.seckmet.jwtgmanager.catalog.application.CatalogService;
import com.seckmet.jwtgmanager.catalog.application.SpeciesView;
import com.seckmet.jwtgmanager.collection.domain.CompletionCalculator;
import com.seckmet.jwtgmanager.shared.domain.Currency;
import com.seckmet.jwtgmanager.shared.domain.InvalidLevelUpException;
import com.seckmet.jwtgmanager.shared.domain.Level;
import com.seckmet.jwtgmanager.collection.domain.PlayerSettings;
import com.seckmet.jwtgmanager.collection.domain.PlayerSettingsRepository;
import com.seckmet.jwtgmanager.collection.domain.PlayerSpecies;
import com.seckmet.jwtgmanager.collection.domain.PlayerSpeciesRepository;
import com.seckmet.jwtgmanager.collection.domain.SpecimenCounts;
import com.seckmet.jwtgmanager.collection.domain.SpeciesProgress;
import com.seckmet.jwtgmanager.collection.domain.UnitCosts;
import com.seckmet.jwtgmanager.shared.application.NotFoundException;
import org.springframework.context.ApplicationEventPublisher;
import org.springframework.context.event.EventListener;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.Comparator;
import java.util.List;
import java.util.Map;
import java.util.Optional;
import java.util.OptionalLong;
import java.util.UUID;

@Service
public class CollectionService {

    private final PlayerSpeciesRepository playerSpecies;
    private final PlayerSettingsRepository settings;
    private final CatalogService catalog;
    private final ApplicationEventPublisher events;

    public CollectionService(PlayerSpeciesRepository playerSpecies, PlayerSettingsRepository settings,
                             CatalogService catalog, ApplicationEventPublisher events) {
        this.playerSpecies = playerSpecies;
        this.settings = settings;
        this.catalog = catalog;
        this.events = events;
    }

    /** Crée le suivi de toutes les espèces du catalogue pour un nouveau joueur. */
    @EventListener
    @Transactional
    public void onUserRegistered(UserRegistered event) {
        PlayerSettings defaults = PlayerSettings.defaults(event.userId());
        settings.save(defaults);
        playerSpecies.saveAll(catalog.species().stream()
                .map(s -> PlayerSpecies.start(event.userId(), s.id(), s.defaultUnlocked(), defaults.defaultTarget()))
                .toList());
        events.publishEvent(new CollectionChanged(event.userId()));
    }

    @Transactional(readOnly = true)
    public List<SpeciesProgressView> collection(UUID userId) {
        Map<Integer, SpeciesView> catalogById = catalog.speciesById();
        return playerSpecies.byUser(userId).stream()
                .filter(ps -> catalogById.containsKey(ps.speciesId()))
                .map(ps -> toView(ps, catalogById.get(ps.speciesId())))
                .sorted(Comparator.comparing(SpeciesProgressView::name))
                .toList();
    }

    @Transactional
    public SpeciesProgressView update(UUID userId, int speciesId, UpdateSpeciesCommand command) {
        PlayerSpecies ps = find(userId, speciesId);
        ps.update(command.unlocked(),
                new SpecimenCounts(command.lvl10(), command.lvl20(), command.lvl30(), command.lvl40()),
                command.targetLvl40());
        playerSpecies.save(ps);
        events.publishEvent(new CollectionChanged(userId));
        return toView(ps, catalog.species(speciesId));
    }

    /** Ajoute ou retire une espèce des favoris (accès rapide depuis le tableau de bord). */
    @Transactional
    public SpeciesProgressView setFavorite(UUID userId, int speciesId, boolean favorite) {
        PlayerSpecies ps = find(userId, speciesId);
        ps.markFavorite(favorite);
        playerSpecies.save(ps);
        return toView(ps, catalog.species(speciesId));
    }

    /** Fixe l'objectif de niveaux 40 pour toutes les espèces d'une rareté, ou toutes si {@code rarityCode} est vide. */
    @Transactional
    public int setTargets(UUID userId, Optional<String> rarityCode, int target) {
        Map<Integer, SpeciesView> catalogById = catalog.speciesById();
        List<PlayerSpecies> changed = playerSpecies.byUser(userId).stream()
                .filter(ps -> rarityCode.isEmpty()
                        || catalogById.containsKey(ps.speciesId())
                        && catalogById.get(ps.speciesId()).rarityCode().equals(rarityCode.get()))
                .toList();
        changed.forEach(ps -> ps.changeTarget(target));
        playerSpecies.saveAll(changed);
        events.publishEvent(new CollectionChanged(userId));
        return changed.size();
    }

    @Transactional
    public LevelUpResult levelUp(UUID userId, int speciesId, Optional<Level> from, Level to, int quantity) {
        PlayerSpecies ps = find(userId, speciesId);
        SpeciesView species = catalog.species(speciesId);
        UnitCosts costs = costsOf(species);
        Currency currency = costs.currencyFor(ps.unlocked());
        OptionalLong unitCost = costs.in(currency);
        if (unitCost.isEmpty()) {
            throw new InvalidLevelUpException("Coût unitaire inconnu pour " + species.name() + " en " + currency.label());
        }
        ps.levelUp(from, to, quantity);
        playerSpecies.save(ps);
        events.publishEvent(new CollectionChanged(userId));
        long cost = CompletionCalculator.levelUpCost(from, to, quantity, unitCost.getAsLong());
        return new LevelUpResult(species.name(), cost, currency.name());
    }

    @Transactional
    public void revertLevelUp(UUID userId, int speciesId, Optional<Level> from, Level to, int quantity) {
        PlayerSpecies ps = find(userId, speciesId);
        ps.revertLevelUp(from, to, quantity);
        playerSpecies.save(ps);
        events.publishEvent(new CollectionChanged(userId));
    }

    @Transactional(readOnly = true)
    public SettingsView settings(UUID userId) {
        PlayerSettings s = settings.byUser(userId).orElseGet(() -> PlayerSettings.defaults(userId));
        return new SettingsView(s.weeklyDna(), s.weeklySuperDna(), s.weeklyAmber(), s.defaultTarget());
    }

    @Transactional
    public SettingsView updateSettings(UUID userId, SettingsView command) {
        PlayerSettings s = settings.byUser(userId).orElseGet(() -> PlayerSettings.defaults(userId));
        s.update(command.weeklyDna(), command.weeklySuperDna(), command.weeklyAmber(), command.defaultTarget());
        settings.save(s);
        return new SettingsView(s.weeklyDna(), s.weeklySuperDna(), s.weeklyAmber(), s.defaultTarget());
    }

    private PlayerSpecies find(UUID userId, int speciesId) {
        return playerSpecies.byUserAndSpecies(userId, speciesId)
                .orElseThrow(() -> new NotFoundException("Espèce " + speciesId + " non suivie par ce joueur"));
    }

    private static UnitCosts costsOf(SpeciesView s) {
        return new UnitCosts(s.dnaCost(), s.amberCost(), "SUPER_HYBRID".equals(s.hybridKind()));
    }

    private static SpeciesProgressView toView(PlayerSpecies ps, SpeciesView s) {
        SpeciesProgress p = CompletionCalculator.progress(ps, costsOf(s));
        SpecimenCounts c = ps.counts();
        return new SpeciesProgressView(s.id(), s.name(), s.rarityCode(), s.hybridKind(), ps.unlocked(), ps.favorite(),
                c.lvl10(), c.lvl20(), c.lvl30(), c.lvl40(), ps.targetLvl40(),
                p.currency().name(), p.unitCost().isPresent() ? p.unitCost().getAsLong() : null,
                p.units(), p.unitsRemaining(), p.progress(), p.done(), p.invested(), p.remaining());
    }
}
