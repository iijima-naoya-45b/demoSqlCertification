package com.sqlcertification.demo.controller;

import com.sqlcertification.demo.model.AuthUser;
import com.sqlcertification.demo.service.AuthService;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.security.core.Authentication;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import java.util.Map;

@RestController
@RequestMapping("/api/auth")
public class AuthController {

    private final AuthService authService;
    private final String loginUrl;

    public AuthController(
            AuthService authService,
            @Value("${app.auth.login-url:/oauth2/authorization/keycloak}") String loginUrl
    ) {
        this.authService = authService;
        this.loginUrl = loginUrl;
    }

    @GetMapping("/me")
    public AuthUser getCurrentUser(Authentication authentication) {
        return authService.getCurrentUser(authentication);
    }

    @GetMapping("/config")
    public Map<String, String> getAuthConfig() {
        return Map.of(
                "loginUrl", loginUrl,
                "logoutUrl", "/api/auth/logout"
        );
    }
}
