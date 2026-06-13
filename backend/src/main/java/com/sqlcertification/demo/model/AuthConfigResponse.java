package com.sqlcertification.demo.model;

public class AuthConfigResponse {

    private final String loginUrl;
    private final String logoutUrl;
    private final boolean googleLoginEnabled;
    private final String googleLoginUrl;

    public AuthConfigResponse(
            String loginUrl,
            String logoutUrl,
            boolean googleLoginEnabled,
            String googleLoginUrl
    ) {
        this.loginUrl = loginUrl;
        this.logoutUrl = logoutUrl;
        this.googleLoginEnabled = googleLoginEnabled;
        this.googleLoginUrl = googleLoginUrl;
    }

    public String getLoginUrl() {
        return loginUrl;
    }

    public String getLogoutUrl() {
        return logoutUrl;
    }

    public boolean isGoogleLoginEnabled() {
        return googleLoginEnabled;
    }

    public String getGoogleLoginUrl() {
        return googleLoginUrl;
    }
}
