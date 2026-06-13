package com.sqlcertification.demo.config;

import com.sqlcertification.demo.security.KeycloakGrantedAuthoritiesMapper;
import com.sqlcertification.demo.security.KeycloakOAuth2AuthorizationRequestResolver;
import com.sqlcertification.demo.security.OAuth2LoginSuccessHandler;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.boot.autoconfigure.condition.ConditionalOnProperty;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.http.HttpMethod;
import org.springframework.security.config.annotation.web.builders.HttpSecurity;
import org.springframework.security.config.annotation.web.configuration.EnableWebSecurity;
import org.springframework.security.config.http.SessionCreationPolicy;
import org.springframework.security.web.SecurityFilterChain;
import org.springframework.security.web.authentication.HttpStatusEntryPoint;
import org.springframework.security.web.csrf.CookieCsrfTokenRepository;
import org.springframework.web.cors.CorsConfiguration;
import org.springframework.web.cors.CorsConfigurationSource;
import org.springframework.web.cors.UrlBasedCorsConfigurationSource;

import java.util.List;

import static org.springframework.http.HttpStatus.UNAUTHORIZED;

@Configuration
@EnableWebSecurity
@ConditionalOnProperty(name = "app.security.enabled", havingValue = "true", matchIfMissing = true)
public class SecurityConfig {

    private final OAuth2LoginSuccessHandler loginSuccessHandler;
    private final KeycloakGrantedAuthoritiesMapper keycloakGrantedAuthoritiesMapper;
    private final KeycloakOAuth2AuthorizationRequestResolver authorizationRequestResolver;
    private final String allowedOrigins;
    private final String logoutSuccessUrl;

    public SecurityConfig(
            OAuth2LoginSuccessHandler loginSuccessHandler,
            KeycloakGrantedAuthoritiesMapper keycloakGrantedAuthoritiesMapper,
            KeycloakOAuth2AuthorizationRequestResolver authorizationRequestResolver,
            @Value("${app.cors.allowed-origins}") String allowedOrigins,
            @Value("${app.auth.logout-success-url:http://localhost:5173/login}") String logoutSuccessUrl
    ) {
        this.loginSuccessHandler = loginSuccessHandler;
        this.keycloakGrantedAuthoritiesMapper = keycloakGrantedAuthoritiesMapper;
        this.authorizationRequestResolver = authorizationRequestResolver;
        this.allowedOrigins = allowedOrigins;
        this.logoutSuccessUrl = logoutSuccessUrl;
    }

    @Bean
    public SecurityFilterChain securityFilterChain(HttpSecurity http) throws Exception {
        http
                .cors(cors -> cors.configurationSource(corsConfigurationSource()))
                .csrf(csrf -> csrf
                        .csrfTokenRepository(CookieCsrfTokenRepository.withHttpOnlyFalse())
                        .ignoringRequestMatchers("/api/sandbox/execute")
                )
                .sessionManagement(session -> session
                        .sessionCreationPolicy(SessionCreationPolicy.IF_REQUIRED)
                )
                .authorizeHttpRequests(auth -> auth
                        .requestMatchers(
                                "/api/auth/**",
                                "/oauth2/**",
                                "/login/**",
                                "/error"
                        ).permitAll()
                        .requestMatchers(HttpMethod.GET, "/actuator/health").permitAll()
                        .anyRequest().authenticated()
                )
                .exceptionHandling(ex -> ex
                        .authenticationEntryPoint(new HttpStatusEntryPoint(UNAUTHORIZED))
                )
                .oauth2Login(oauth2 -> oauth2
                        .authorizationEndpoint(authorization -> authorization
                                .authorizationRequestResolver(authorizationRequestResolver)
                        )
                        .userInfoEndpoint(userInfo -> userInfo
                                .oidcUserService(keycloakGrantedAuthoritiesMapper.oidcUserService())
                        )
                        .successHandler(loginSuccessHandler)
                )
                .logout(logout -> logout
                        .logoutUrl("/api/auth/logout")
                        .logoutSuccessUrl(logoutSuccessUrl)
                        .invalidateHttpSession(true)
                        .deleteCookies("JSESSIONID", "SESSION")
                        .clearAuthentication(true)
                );

        return http.build();
    }

    @Bean
    public CorsConfigurationSource corsConfigurationSource() {
        CorsConfiguration config = new CorsConfiguration();
        config.setAllowedOrigins(List.of(allowedOrigins.split(",")));
        config.setAllowedMethods(List.of("GET", "POST", "PUT", "DELETE", "OPTIONS"));
        config.setAllowedHeaders(List.of("*"));
        config.setAllowCredentials(true);
        config.setMaxAge(3600L);

        UrlBasedCorsConfigurationSource source = new UrlBasedCorsConfigurationSource();
        source.registerCorsConfiguration("/**", config);
        return source;
    }
}
