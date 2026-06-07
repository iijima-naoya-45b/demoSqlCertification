#!/usr/bin/env bash
set -euo pipefail

scriptDir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
projectRoot="$(dirname "$scriptDir")"

# shellcheck disable=SC1091
source "${scriptDir}/lib/db.sh"

cd "${projectRoot}"

echo "=== SQL検証用サンプルDB セットアップ (Docker) ==="

if ! command -v docker &> /dev/null; then
    echo "エラー: Docker がインストールされていません。Docker Desktop をインストールしてください。"
    echo "  ローカル PostgreSQL を使う場合: ./scripts/setupLocal.sh"
    exit 1
fi

export DB_MODE="docker"
loadEnv "${projectRoot}"

echo "PostgreSQL + API + Web UI を起動しています..."
docker compose up -d --build

waitForDb

echo ""
echo "初回起動時は docker-entrypoint-initdb.d により SQL が自動投入されます。"
echo "再投入が必要な場合: ./scripts/seed.sh reset"
printConnectionInfo

echo "Webアプリ:"
echo "  UI:  http://localhost:5173"
echo "  API: http://localhost:8080"
echo ""
echo "Docker セットアップ完了!"
