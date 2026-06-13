package com.sqlcertification.demo.controller;

import com.sqlcertification.demo.model.AuthUser;
import com.sqlcertification.demo.service.AuthService;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.autoconfigure.web.servlet.WebMvcTest;
import org.springframework.security.test.context.support.WithMockUser;
import org.springframework.test.context.bean.override.mockito.MockitoBean;
import org.springframework.test.web.servlet.MockMvc;

import java.util.List;

import static org.mockito.ArgumentMatchers.any;
import static org.mockito.Mockito.when;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.get;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.jsonPath;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.status;

@WebMvcTest(AuthController.class)
class AuthControllerTest {

    @Autowired
    private MockMvc mockMvc;

    @MockitoBean
    private AuthService authService;

    @Test
    @WithMockUser(username = "demo")
    void getCurrentUser_shouldReturnAuthenticatedUser() throws Exception {
        AuthUser authUser = new AuthUser();
        authUser.setAuthenticated(true);
        authUser.setUsername("demo");
        authUser.setEmail("demo@demoshop.local");
        authUser.setDisplayName("Demo Learner");
        authUser.setRoles(List.of("learner"));

        when(authService.getCurrentUser(any())).thenReturn(authUser);

        mockMvc.perform(get("/api/auth/me"))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.username").value("demo"))
                .andExpect(jsonPath("$.authenticated").value(true))
                .andExpect(jsonPath("$.roles[0]").value("learner"));
    }

    @Test
    void getAuthConfig_shouldReturnLoginUrls() throws Exception {
        mockMvc.perform(get("/api/auth/config"))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.loginUrl").value("/oauth2/authorization/keycloak"))
                .andExpect(jsonPath("$.logoutUrl").value("/api/auth/logout"))
                .andExpect(jsonPath("$.googleLoginEnabled").value(false))
                .andExpect(jsonPath("$.googleLoginUrl").value("/oauth2/authorization/keycloak?idp=google"));
    }
}
