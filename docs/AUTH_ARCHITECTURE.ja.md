# 認証アーキテクチャ（Keycloak + Cookie セッション）

[English](AUTH_ARCHITECTURE.en.md) | **日本語**

DemoShop は **Keycloak（OIDC）** でログインし、**Spring Session Cookie** で API セッションを管理します。  
フロントエンドは JWT を localStorage に保存せず、`credentials: 'include'` で Cookie ベースの BFF 構成です。

## コンポーネント構成

```mermaid
flowchart TB
    subgraph Browser["ブラウザ (localhost:5173)"]
        FE["React (Bulletproof)"]
        Cookie["DEMO_SHOP_SESSION Cookie\nHttpOnly / SameSite=Lax"]
    end

    subgraph Proxy["nginx (frontend コンテナ)"]
        NGX["/api, /oauth2, /login を backend にプロキシ"]
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
        PG["業務データ + auditLogs"]
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

## ログインシーケンス（Authorization Code Flow）

```mermaid
sequenceDiagram
    actor User as ユーザー
    participant FE as React
    participant NGX as nginx
    participant API as Spring Boot
    participant KC as Keycloak

    User->>FE: 「Keycloakでログイン」クリック
    FE->>NGX: GET /oauth2/authorization/keycloak
    NGX->>API: プロキシ
    API->>KC: 認可リクエスト (redirect)
    KC->>User: ログイン画面
    User->>KC: ユーザー名/パスワード
    KC->>API: redirect + authorization code
    API->>KC: code → token 交換
    KC-->>API: ID Token / Access Token
    API->>API: HttpSession 作成
    API-->>FE: Set-Cookie: DEMO_SHOP_SESSION\nredirect → localhost:5173/
    FE->>NGX: GET /api/auth/me (credentials: include)
    NGX->>API: Cookie 付きリクエスト
    API-->>FE: AuthUser JSON
```

## API リクエストシーケンス

```mermaid
sequenceDiagram
    participant FE as React
    participant NGX as nginx
    participant API as Spring Boot
    participant DB as PostgreSQL

    FE->>NGX: GET /api/customers (Cookie)
    NGX->>API: プロキシ + Cookie
    API->>API: セッション検証
    alt 未認証
        API-->>FE: 401 Unauthorized
        FE->>FE: /login へリダイレクト
    else 認証済み
        API->>DB: MyBatis SELECT
        DB-->>API: 結果
        API-->>FE: 200 JSON
    end
```

## SQL サンドボックス POST（CSRF 付き）

```mermaid
sequenceDiagram
    participant FE as React
    participant API as Spring Boot
    participant VAL as SqlSecurityValidator
    participant AUD as SandboxAuditService
    participant DB as PostgreSQL

    FE->>API: POST /api/sandbox/execute\nCookie + X-XSRF-TOKEN
    API->>API: セッション + CSRF 検証
    API->>VAL: SQL 監査チェック
    alt DELETE 等を検出
        VAL-->>API: SqlSandboxBlockedException
        API->>AUD: auditLogs に BLOCKED 記録
        API-->>FE: 403 + auditStatus: BLOCKED
    else SELECT のみ
        API->>DB: readOnly 実行
        DB-->>API: 結果
        API->>AUD: auditLogs に ALLOWED 記録
        API-->>FE: 200 結果 JSON
    end
```

## バックエンド クラス図（認証関連）

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

## フロントエンド クラス図（認証関連）

```mermaid
classDiagram
    class AuthProvider {
        +user: AuthUser
        +isAuthenticated: boolean
        +login()
        +logout()
    }

    class ProtectedRoute {
        +children: ReactNode
    }

    class LoginPage {
        +render()
    }

    class apiClient {
        +apiGet()
        +apiPost()
        +credentials: include
    }

    class getAuth {
        +getCurrentUser()
        +getAuthConfig()
    }

    AuthProvider --> getAuth
    ProtectedRoute --> AuthProvider
    LoginPage --> AuthProvider
    getAuth --> apiClient
```

## Cookie / セキュリティ設定

| 項目 | 値 |
|------|-----|
| セッション Cookie 名 | `DEMO_SHOP_SESSION` |
| HttpOnly | `true`（JS から不可） |
| SameSite | `Lax` |
| Secure | ローカル `false` / 本番 `true` 推奨 |
| CSRF | `CookieCsrfTokenRepository`（POST 時 `X-XSRF-TOKEN`） |

## Keycloak デモアカウント

| ユーザー | パスワード | ロール |
|---------|-----------|--------|
| demo | demopass | learner |
| admin | adminpass | admin, learner |

Keycloak 管理コンソール: http://localhost:8180 （admin / admin）

## ローカル開発（Keycloak なし）

テスト実行時は `app.security.enabled=false` で認証をスキップします。

```bash
APP_SECURITY_ENABLED=false ./scripts/runBackend.sh
```
