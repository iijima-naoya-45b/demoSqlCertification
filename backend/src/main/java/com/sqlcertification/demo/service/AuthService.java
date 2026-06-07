package com.sqlcertification.demo.service;

import com.sqlcertification.demo.model.AuthUser;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.GrantedAuthority;
import org.springframework.security.oauth2.client.authentication.OAuth2AuthenticationToken;
import org.springframework.security.oauth2.core.oidc.user.OidcUser;
import org.springframework.security.oauth2.core.user.OAuth2User;
import org.springframework.stereotype.Service;

import java.util.ArrayList;
import java.util.List;
import java.util.Map;

@Service
public class AuthService {

    public AuthUser getCurrentUser(Authentication authentication) {
        if (authentication == null || !authentication.isAuthenticated()) {
            return buildGuestUser();
        }

        AuthUser authUser = new AuthUser();
        authUser.setAuthenticated(true);
        authUser.setRoles(extractRoles(authentication));

        if (authentication instanceof OAuth2AuthenticationToken oauthToken
                && oauthToken.getPrincipal() instanceof OidcUser oidcUser) {
            authUser.setUserId(oidcUser.getSubject());
            authUser.setUsername(oidcUser.getPreferredUsername());
            authUser.setEmail(oidcUser.getEmail());
            authUser.setDisplayName(oidcUser.getFullName());
            return authUser;
        }

        if (authentication.getPrincipal() instanceof OAuth2User oauth2User) {
            Map<String, Object> attributes = oauth2User.getAttributes();
            authUser.setUserId(stringValue(attributes.get("sub")));
            authUser.setUsername(stringValue(attributes.get("preferred_username")));
            authUser.setEmail(stringValue(attributes.get("email")));
            authUser.setDisplayName(stringValue(attributes.get("name")));
            return authUser;
        }

        authUser.setUsername(authentication.getName());
        return authUser;
    }

    private AuthUser buildGuestUser() {
        AuthUser guest = new AuthUser();
        guest.setAuthenticated(false);
        guest.setRoles(List.of());
        return guest;
    }

    private List<String> extractRoles(Authentication authentication) {
        List<String> roles = new ArrayList<>();
        for (GrantedAuthority authority : authentication.getAuthorities()) {
            String role = authority.getAuthority();
            if (role.startsWith("ROLE_")) {
                roles.add(role.substring("ROLE_".length()).toLowerCase());
            } else {
                roles.add(role.toLowerCase());
            }
        }
        return roles;
    }

    private String stringValue(Object value) {
        return value == null ? null : String.valueOf(value);
    }
}
