#!/usr/bin/env bash
set -euo pipefail

scriptDir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
projectRoot="$(dirname "$scriptDir")"
backendDir="${projectRoot}/backend"

cd "${backendDir}"

if [[ ! -x "./gradlew" ]]; then
    chmod +x ./gradlew
fi

echo "=== Spring Boot API 起動 (Gradle / port 8080) ==="
echo "DB: ${POSTGRES_HOST:-localhost}:${POSTGRES_PORT:-5432}/${POSTGRES_DB:-sql_certification}"
echo ""

./gradlew bootRun
