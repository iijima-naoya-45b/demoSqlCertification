#!/usr/bin/env bash
set -euo pipefail

scriptDir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
projectRoot="$(dirname "$scriptDir")"

cd "${projectRoot}"

if ! command -v docker &> /dev/null; then
    echo "エラー: Docker がインストールされていません。Docker Desktop をインストールしてください。"
    exit 1
fi

echo "=== SQL検証用サンプルアプリ Docker 起動 ==="
echo "DB + API + Web UI をビルドして起動します..."
echo ""

docker compose up -d --build

echo ""
echo "起動完了。以下の URL にアクセスできます:"
echo "  Web UI:  http://localhost:5173"
echo "  API:     http://localhost:8080/api/dashboard/stats"
echo "  DB:      localhost:5432 (sql_certification / sqluser / sqlpass)"
echo ""
echo "ログ確認:  docker compose logs -f"
echo "停止:      docker compose down"
echo ""
echo "データ再投入: ./scripts/seed.sh reset"
