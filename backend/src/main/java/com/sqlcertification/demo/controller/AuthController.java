package com.sqlcertification.demo.controller;

import com.sqlcertification.demo.model.AuthConfigResponse;
import com.sqlcertification.demo.model.AuthUser;
import com.sqlcertification.demo.service.AuthService;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.security.core.Authentication;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/api/auth")
public class AuthController {

    private final AuthService authService;
    private final String loginUrl;
    private final boolean googleLoginEnabled;
    private final String googleLoginUrl;

    public AuthController(
            AuthService authService,
            @Value("${app.auth.login-url:/oauth2/authorization/keycloak}") String loginUrl,
            @Value("${app.auth.google-login-enabled:false}") boolean googleLoginEnabled,
            @Value("${app.auth.google-login-url:/oauth2/authorization/keycloak?idp=google}") String googleLoginUrl
    ) {
        this.authService = authService;
        this.loginUrl = loginUrl;
        this.googleLoginEnabled = googleLoginEnabled;
        this.googleLoginUrl = googleLoginUrl;
    }

    @GetMapping("/me")
    public AuthUser getCurrentUser(Authentication authentication) {
        return authService.getCurrentUser(authentication);
    }

    @GetMapping("/config")
    public AuthConfigResponse getAuthConfig() {
        return new AuthConfigResponse(
                loginUrl,
                "/api/auth/logout",
                googleLoginEnabled,
                googleLoginUrl
        );
    }
}
