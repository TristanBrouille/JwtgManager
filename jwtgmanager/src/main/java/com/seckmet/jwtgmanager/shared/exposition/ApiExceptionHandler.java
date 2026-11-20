package com.seckmet.jwtgmanager.shared.exposition;

import com.seckmet.jwtgmanager.shared.application.ConflictException;
import com.seckmet.jwtgmanager.shared.application.NotFoundException;
import com.seckmet.jwtgmanager.shared.application.UnauthorizedException;
import com.seckmet.jwtgmanager.shared.domain.DomainException;
import org.springframework.http.HttpStatus;
import org.springframework.http.ProblemDetail;
import org.springframework.web.bind.MethodArgumentNotValidException;
import org.springframework.web.bind.annotation.ExceptionHandler;
import org.springframework.web.bind.annotation.RestControllerAdvice;

import java.util.stream.Collectors;

@RestControllerAdvice
public class ApiExceptionHandler {

    @ExceptionHandler(NotFoundException.class)
    ProblemDetail notFound(NotFoundException e) {
        return problem(HttpStatus.NOT_FOUND, "Introuvable", e.getMessage());
    }

    @ExceptionHandler(ConflictException.class)
    ProblemDetail conflict(ConflictException e) {
        return problem(HttpStatus.CONFLICT, "Conflit", e.getMessage());
    }

    @ExceptionHandler(UnauthorizedException.class)
    ProblemDetail unauthorized(UnauthorizedException e) {
        return problem(HttpStatus.UNAUTHORIZED, "Non autorisé", e.getMessage());
    }

    @ExceptionHandler(DomainException.class)
    ProblemDetail domain(DomainException e) {
        return problem(HttpStatus.UNPROCESSABLE_CONTENT, "Règle métier non respectée", e.getMessage());
    }

    @ExceptionHandler(MethodArgumentNotValidException.class)
    ProblemDetail invalid(MethodArgumentNotValidException e) {
        String detail = e.getBindingResult().getFieldErrors().stream()
                .map(f -> f.getField() + " : " + f.getDefaultMessage())
                .collect(Collectors.joining(" ; "));
        return problem(HttpStatus.BAD_REQUEST, "Requête invalide", detail);
    }

    private static ProblemDetail problem(HttpStatus status, String title, String detail) {
        ProblemDetail pd = ProblemDetail.forStatusAndDetail(status, detail);
        pd.setTitle(title);
        return pd;
    }
}
