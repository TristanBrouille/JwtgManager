package com.seckmet.jwtgmanager.progress.exposition;

import com.seckmet.jwtgmanager.progress.application.HistoryPointView;
import com.seckmet.jwtgmanager.progress.application.ProgressService;
import com.seckmet.jwtgmanager.shared.domain.Currency;
import com.seckmet.jwtgmanager.shared.exposition.CurrentUser;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.security.oauth2.jwt.Jwt;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

import java.time.LocalDate;
import java.util.List;
import java.util.Locale;
import java.util.Optional;

@RestController
@RequestMapping("/api")
public class ProgressController {

    private final ProgressService progress;

    public ProgressController(ProgressService progress) {
        this.progress = progress;
    }

    /** {@code currency} : ALL (défaut), DNA ou AMBER. */
    @GetMapping("/dashboard")
    public DashboardResponse dashboard(@AuthenticationPrincipal Jwt jwt,
                                       @RequestParam(defaultValue = "ALL") String currency) {
        Optional<Currency> filter = "ALL".equalsIgnoreCase(currency)
                ? Optional.empty() : Optional.of(Currency.valueOf(currency.toUpperCase(Locale.ROOT)));
        return DashboardResponse.from(progress.dashboard(CurrentUser.id(jwt), filter));
    }

    @GetMapping("/progress/history")
    public List<HistoryPointResponse> history(@AuthenticationPrincipal Jwt jwt) {
        return progress.history(CurrentUser.id(jwt)).stream().map(HistoryPointResponse::from).toList();
    }

    public record HistoryPointResponse(LocalDate day, double completion, long lvl40Count, long lvl40Target) {
        static HistoryPointResponse from(HistoryPointView v) {
            return new HistoryPointResponse(v.day(), v.completion(), v.lvl40Count(), v.lvl40Target());
        }
    }
}
