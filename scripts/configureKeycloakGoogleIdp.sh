#!/usr/bin/env bash
set -euo pipefail

keycloakUrl="${KEYCLOAK_URL:-http://localhost:8180}"
keycloakAdmin="${KEYCLOAK_ADMIN:-admin}"
keycloakAdminPassword="${KEYCLOAK_ADMIN_PASSWORD:-admin}"
realmName="${KEYCLOAK_REALM:-demo-shop}"
googleClientId="${GOOGLE_CLIENT_ID:-}"
googleClientSecret="${GOOGLE_CLIENT_SECRET:-}"
maxRetries="${KEYCLOAK_CONFIG_MAX_RETRIES:-30}"
retryIntervalSeconds="${KEYCLOAK_CONFIG_RETRY_INTERVAL:-3}"

if [[ -z "${googleClientId}" || -z "${googleClientSecret}" ]]; then
  echo "configureKeycloakGoogleIdp: GOOGLE_CLIENT_ID / GOOGLE_CLIENT_SECRET が未設定のため Google IdP はスキップします。"
  exit 0
fi

if ! command -v curl &> /dev/null; then
  echo "configureKeycloakGoogleIdp: curl が見つかりません。"
  exit 1
fi

echo "configureKeycloakGoogleIdp: Keycloak の起動を待機しています (${keycloakUrl})..."

adminToken=""
for ((attempt = 1; attempt <= maxRetries; attempt++)); do
  tokenResponse="$(curl -sS -X POST "${keycloakUrl}/realms/master/protocol/openid-connect/token" \
    -H "Content-Type: application/x-www-form-urlencoded" \
    -d "client_id=admin-cli" \
    -d "username=${keycloakAdmin}" \
    -d "password=${keycloakAdminPassword}" \
    -d "grant_type=password" || true)"

  adminToken="$(printf '%s' "${tokenResponse}" | grep -o '"access_token":"[^"]*"' | head -n 1 | cut -d'"' -f4)"

  if [[ -n "${adminToken}" ]]; then
    break
  fi

  echo "  試行 ${attempt}/${maxRetries}: Keycloak 未準備、${retryIntervalSeconds}秒後に再試行..."
  sleep "${retryIntervalSeconds}"
done

if [[ -z "${adminToken}" ]]; then
  echo "configureKeycloakGoogleIdp: Keycloak 管理トークンの取得に失敗しました。"
  exit 1
fi

idpPayload="$(cat <<EOF
{
  "alias": "google",
  "displayName": "Google",
  "providerId": "google",
  "enabled": true,
  "updateProfileFirstLoginMode": "on",
  "trustEmail": true,
  "storeToken": false,
  "addReadTokenRoleOnCreate": false,
  "authenticateByDefault": false,
  "linkOnly": false,
  "firstBrokerLoginFlowAlias": "first broker login",
  "config": {
    "clientId": "${googleClientId}",
    "clientSecret": "${googleClientSecret}",
    "defaultScope": "openid profile email",
    "hostedDomain": "",
    "useJwksUrl": "true",
    "syncMode": "IMPORT",
    "guiOrder": "1"
  }
}
EOF
)"

httpStatus="$(curl -sS -o /tmp/keycloak-google-idp-response.json -w "%{http_code}" \
  -X PUT "${keycloakUrl}/admin/realms/${realmName}/identity-provider/instances/google" \
  -H "Authorization: Bearer ${adminToken}" \
  -H "Content-Type: application/json" \
  -d "${idpPayload}")"

if [[ "${httpStatus}" != "204" && "${httpStatus}" != "200" ]]; then
  echo "configureKeycloakGoogleIdp: Google IdP の更新に失敗しました (HTTP ${httpStatus})。"
  cat /tmp/keycloak-google-idp-response.json
  exit 1
fi

echo "configureKeycloakGoogleIdp: Google IdP を有効化しました。"
echo "  Google Cloud Console のリダイレクト URI:"
echo "    ${keycloakUrl}/realms/${realmName}/broker/google/endpoint"
