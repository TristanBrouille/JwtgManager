package com.seckmet.jwtgmanager.collection.exposition;

import com.seckmet.jwtgmanager.collection.application.CollectionService;
import com.seckmet.jwtgmanager.collection.application.SettingsView;
import com.seckmet.jwtgmanager.collection.application.SpeciesProgressView;
import com.seckmet.jwtgmanager.collection.application.UpdateSpeciesCommand;
import com.seckmet.jwtgmanager.shared.exposition.CurrentUser;
import jakarta.validation.Valid;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.security.oauth2.jwt.Jwt;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PutMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import java.util.List;
import java.util.Optional;

@RestController
@RequestMapping("/api")
public class CollectionController {

    private final CollectionService collection;

    public CollectionController(CollectionService collection) {
        this.collection = collection;
    }

    @GetMapping("/collection")
    public List<SpeciesProgressResponse> collection(@AuthenticationPrincipal Jwt jwt) {
        return collection.collection(CurrentUser.id(jwt)).stream().map(CollectionController::toResponse).toList();
    }

    @PutMapping("/collection/{speciesId}")
    public SpeciesProgressResponse update(@AuthenticationPrincipal Jwt jwt, @PathVariable int speciesId,
                                          @Valid @RequestBody UpdateSpeciesRequest r) {
        return toResponse(collection.update(CurrentUser.id(jwt), speciesId,
                new UpdateSpeciesCommand(r.unlocked(), r.lvl10(), r.lvl20(), r.lvl30(), r.lvl40(), r.targetLvl40())));
    }

    @PutMapping("/collection/{speciesId}/favorite")
    public SpeciesProgressResponse favorite(@AuthenticationPrincipal Jwt jwt, @PathVariable int speciesId,
                                            @RequestBody FavoriteRequest r) {
        return toResponse(collection.setFavorite(CurrentUser.id(jwt), speciesId, r.favorite()));
    }

    @PutMapping("/collection/targets")
    public TargetsResponse targets(@AuthenticationPrincipal Jwt jwt, @Valid @RequestBody TargetsRequest r) {
        int updated = collection.setTargets(CurrentUser.id(jwt),
                Optional.ofNullable(r.rarityCode()).filter(c -> !c.isBlank()), r.targetLvl40());
        return new TargetsResponse(updated);
    }

    @GetMapping("/settings")
    public SettingsResponse settings(@AuthenticationPrincipal Jwt jwt) {
        return toResponse(collection.settings(CurrentUser.id(jwt)));
    }

    @PutMapping("/settings")
    public SettingsResponse updateSettings(@AuthenticationPrincipal Jwt jwt, @Valid @RequestBody SettingsRequest r) {
        return toResponse(collection.updateSettings(CurrentUser.id(jwt),
                new SettingsView(r.weeklyDna(), r.weeklySuperDna(), r.weeklyAmber(), r.defaultTarget())));
    }

    private static SettingsResponse toResponse(SettingsView s) {
        return new SettingsResponse(s.weeklyDna(), s.weeklySuperDna(), s.weeklyAmber(), s.defaultTarget());
    }

    private static SpeciesProgressResponse toResponse(SpeciesProgressView v) {
        return new SpeciesProgressResponse(v.speciesId(), v.name(), v.rarityCode(), v.hybridKind(), v.unlocked(), v.favorite(),
                v.lvl10(), v.lvl20(), v.lvl30(), v.lvl40(), v.targetLvl40(), v.currency(), v.unitCost(),
                v.units(), v.unitsRemaining(), v.progress(), v.done(), v.invested(), v.remaining());
    }
}
