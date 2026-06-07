#!/usr/bin/env bash
set -euo pipefail

scriptDir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
projectRoot="$(dirname "$scriptDir")"

# shellcheck disable=SC1091
source "${scriptDir}/lib/db.sh"

cd "${projectRoot}"

echo "=== SQL検証用サンプルDB ローカルセットアップ ==="

if [[ ! -f "${projectRoot}/.env" ]]; then
    echo ".env が見つからないため .env.example から作成します..."
    cp "${projectRoot}/.env.example" "${projectRoot}/.env"
    sed -i '' 's/^DB_MODE=docker/DB_MODE=local/' "${projectRoot}/.env" 2>/dev/null \
        || sed -i 's/^DB_MODE=docker/DB_MODE=local/' "${projectRoot}/.env"
    echo "  POSTGRES_ADMIN_USER=$(whoami)" >> "${projectRoot}/.env"
    echo ".env を作成しました。必要に応じて編集してください。"
fi

export DB_MODE="local"
loadEnv "${projectRoot}"

requirePsql

if ! command -v pg_isready &> /dev/null; then
    echo "エラー: pg_isready が見つかりません。PostgreSQL をインストールしてください。"
    echo "  macOS (Homebrew): brew install postgresql@16"
    exit 1
fi

if ! pg_isready -h "${POSTGRES_ADMIN_HOST}" -p "${POSTGRES_ADMIN_PORT}" > /dev/null 2>&1; then
    echo "エラー: ローカル PostgreSQL が起動していません。"
    echo ""
    echo "起動例 (macOS Homebrew):"
    echo "  brew services start postgresql@16"
    echo "  または"
    echo "  pg_ctl -D /opt/homebrew/var/postgresql@16 start"
    exit 1
fi

createLocalDatabaseIfNeeded
waitForDb

echo ""
echo "スキーマ・シードデータを投入します..."
"${scriptDir}/seed.sh" all

printConnectionInfo

echo "ローカルセットアップ完了!"
