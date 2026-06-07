#!/usr/bin/env bash
set -euo pipefail

scriptDir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
projectRoot="$(dirname "$scriptDir")"

# shellcheck disable=SC1091
source "${scriptDir}/lib/db.sh"

loadEnv "${projectRoot}"
cd "${projectRoot}"

if isDockerMode; then
    if ! docker compose ps --status running postgres 2>/dev/null | grep -q postgres; then
        echo "エラー: Docker の PostgreSQL コンテナが起動していません。"
        echo "  ./scripts/setup.sh を実行してください。"
        exit 1
    fi
else
    requirePsql
fi

connectPsql
