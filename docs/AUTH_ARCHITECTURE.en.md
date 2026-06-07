# Authentication Architecture (Keycloak + Cookie Session)

**English** | [日本語](AUTH_ARCHITECTURE.ja.md)

DemoShop uses **Keycloak (OIDC)** for login and **Spring Session cookies** for API sessions.  
The frontend does not store JWTs in localStorage; it uses `credentials: 'include'` in a BFF-style setup.

## Component Diagram

```mermaid
flowchart TB
    subgraph Browser["Browser (localhost:5173)"]
        FE["React (Bulletproof)"]
        Cookie["DEMO_SHOP_SESSION Cookie\nHttpOnly / SameSite=Lax"]
    end

    subgraph Proxy["nginx (frontend container)"]
        NGX["Proxies /api, /oauth2, /login to backend"]
    end

    subgraph Backend["Spring Boot API (8080)"]
        SEC["SecurityConfig\nOAuth2 Client"]
        AUTH["AuthController"]
        API["REST API / Sandbox"]
        SESS["HttpSession"]
    end

    subgraph IdP["Keycloak (8180)"]
        KC["Realm: demo-shop\nClient: demoshop-api"]
    end

    subgraph DB["PostgreSQL"]
        PG["Business data + auditLogs"]
    end

    FE --> NGX
    NGX --> SEC
    SEC --> SESS
    SEC --> KC
    AUTH --> SESS
    API --> PG
    Cookie -.-> FE
    SEC -.-> Cookie
```

## Login Sequence (Authorization Code Flow)

```mermaid
sequenceDiagram
    actor User as User
    participant FE as React
    participant NGX as nginx
    participant API as Spring Boot
    participant KC as Keycloak

    User->>FE: Click "Login with Keycloak"
    FE->>NGX: GET /oauth2/authorization/keycloak
    NGX->>API: proxy
    API->>KC: authorization redirect
    KC->>User: login page
    User->>KC: credentials
    KC->>API: redirect + authorization code
    API->>KC: exchange code for tokens
    KC-->>API: ID Token / Access Token
    API->>API: create HttpSession
    API-->>FE: Set-Cookie: DEMO_SHOP_SESSION\nredirect → localhost:5173/
    FE->>NGX: GET /api/auth/me (credentials: include)
    NGX->>API: request with cookie
    API-->>FE: AuthUser JSON
```

## API Request Sequence

```mermaid
sequenceDiagram
    participant FE as React
    participant NGX as nginx
    participant API as Spring Boot
    participant DB as PostgreSQL

    FE->>NGX: GET /api/customers (Cookie)
    NGX->>API: proxy + cookie
    API->>API: validate session
    alt unauthenticated
        API-->>FE: 401 Unauthorized
        FE->>FE: redirect to /login
    else authenticated
        API->>DB: MyBatis SELECT
        DB-->>API: rows
        API-->>FE: 200 JSON
    end
```

## Sandbox POST with CSRF

```mermaid
sequenceDiagram
    participant FE as React
    participant API as Spring Boot
    participant VAL as SqlSecurityValidator
    participant AUD as SandboxAuditService
    participant DB as PostgreSQL

    FE->>API: POST /api/sandbox/execute\nCookie + X-XSRF-TOKEN
    API->>API: session + CSRF check
    API->>VAL: SQL audit check
    alt DELETE detected
        VAL-->>API: SqlSandboxBlockedException
        API->>AUD: log BLOCKED to auditLogs
        API-->>FE: 403 auditStatus: BLOCKED
    else SELECT only
        API->>DB: readOnly query
        DB-->>API: result
        API->>AUD: log ALLOWED to auditLogs
        API-->>FE: 200 JSON
    end
```

## Backend Class Diagram (Auth)

```mermaid
classDiagram
    class SecurityConfig {
        +SecurityFilterChain securityFilterChain()
        +CorsConfigurationSource corsConfigurationSource()
    }

    class AuthController {
        +getCurrentUser(Authentication) AuthUser
        +getAuthConfig() Map
    }

    class AuthService {
        +getCurrentUser(Authentication) AuthUser
    }

    class OAuth2LoginSuccessHandler {
        +onAuthenticationSuccess()
    }

    class KeycloakGrantedAuthoritiesMapper {
        +mapAuthorities(OidcUser) Collection
        +oidcUserService() OAuth2UserService
    }

    class AuthUser {
        +String userId
        +String username
        +String email
        +List~String~ roles
        +boolean authenticated
    }

    SecurityConfig --> OAuth2LoginSuccessHandler
    SecurityConfig --> KeycloakGrantedAuthoritiesMapper
    AuthController --> AuthService
    AuthService --> AuthUser
```

## Demo Keycloak Accounts

| User | Password | Roles |
|------|----------|-------|
| demo | demopass | learner |
| admin | adminpass | admin, learner |

Keycloak admin console: http://localhost:8180 (admin / admin)

## Local Dev Without Keycloak

Tests use `app.security.enabled=false` to skip authentication.

```bash
APP_SECURITY_ENABLED=false ./scripts/runBackend.sh
```
