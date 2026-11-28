package com.seckmet.jwtgmanager.tournament.exposition;

import com.seckmet.jwtgmanager.shared.exposition.CurrentUser;
import com.seckmet.jwtgmanager.tournament.application.TournamentService;
import com.seckmet.jwtgmanager.tournament.application.TournamentView;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.security.oauth2.jwt.Jwt;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/api/tournaments")
public class TournamentController {

    private final TournamentService tournaments;

    public TournamentController(TournamentService tournaments) {
        this.tournaments = tournaments;
    }

    /** Derniers trios calculés (aucun calcul n'est lancé ici). */
    @GetMapping
    public TournamentResponse latest(@AuthenticationPrincipal Jwt jwt) {
        return TournamentResponse.of(tournaments.view(CurrentUser.id(jwt)));
    }

    /** Recalcule les trios à partir de la collection actuelle. */
    @PostMapping("/compute")
    public TournamentResponse compute(@AuthenticationPrincipal Jwt jwt) {
        return TournamentResponse.of(tournaments.compute(CurrentUser.id(jwt)));
    }
}
