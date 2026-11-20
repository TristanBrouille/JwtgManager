package com.seckmet.jwtgmanager.investment.exposition;

import com.seckmet.jwtgmanager.investment.application.InvestmentService;
import com.seckmet.jwtgmanager.investment.application.InvestmentView;
import com.seckmet.jwtgmanager.investment.application.RecordInvestmentCommand;
import com.seckmet.jwtgmanager.shared.exposition.CurrentUser;
import jakarta.validation.Valid;
import org.springframework.http.HttpStatus;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.security.oauth2.jwt.Jwt;
import org.springframework.web.bind.annotation.DeleteMapping;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.ResponseStatus;
import org.springframework.web.bind.annotation.RestController;

import java.util.List;

@RestController
@RequestMapping("/api/investments")
public class InvestmentController {

    private final InvestmentService investments;

    public InvestmentController(InvestmentService investments) {
        this.investments = investments;
    }

    @GetMapping
    public List<InvestmentResponse> list(@AuthenticationPrincipal Jwt jwt) {
        return investments.list(CurrentUser.id(jwt)).stream().map(InvestmentController::toResponse).toList();
    }

    @PostMapping
    @ResponseStatus(HttpStatus.CREATED)
    public InvestmentResponse record(@AuthenticationPrincipal Jwt jwt, @Valid @RequestBody RecordInvestmentRequest r) {
        return toResponse(investments.record(CurrentUser.id(jwt),
                new RecordInvestmentCommand(r.speciesId(), r.fromLevel(), r.toLevel(), r.quantity(), r.investedOn())));
    }

    @DeleteMapping("/{id}")
    @ResponseStatus(HttpStatus.NO_CONTENT)
    public void cancel(@AuthenticationPrincipal Jwt jwt, @PathVariable long id) {
        investments.cancel(CurrentUser.id(jwt), id);
    }

    private static InvestmentResponse toResponse(InvestmentView v) {
        return new InvestmentResponse(v.id(), v.speciesId(), v.speciesName(), v.fromLevel(), v.toLevel(),
                v.quantity(), v.cost(), v.currency(), v.investedOn());
    }
}
