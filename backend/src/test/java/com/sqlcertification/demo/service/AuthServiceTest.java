package com.sqlcertification.demo.service;

import org.junit.jupiter.api.Test;
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.security.core.authority.SimpleGrantedAuthority;

import java.util.List;

import static org.assertj.core.api.Assertions.assertThat;

class AuthServiceTest {

    private final AuthService authService = new AuthService();

    @Test
    void getCurrentUser_shouldReturnGuestWhenNotAuthenticated() {
        var guest = authService.getCurrentUser(null);

        assertThat(guest.isAuthenticated()).isFalse();
        assertThat(guest.getRoles()).isEmpty();
    }

    @Test
    void getCurrentUser_shouldMapRolesFromAuthorities() {
        var authentication = new UsernamePasswordAuthenticationToken(
                "demo",
                "n/a",
                List.of(
                        new SimpleGrantedAuthority("ROLE_LEARNER"),
                        new SimpleGrantedAuthority("OIDC_USER")
                )
        );

        var user = authService.getCurrentUser(authentication);

        assertThat(user.isAuthenticated()).isTrue();
        assertThat(user.getUsername()).isEqualTo("demo");
        assertThat(user.getRoles()).contains("learner");
    }
}
