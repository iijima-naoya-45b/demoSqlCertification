#!/usr/bin/env bash
set -euo pipefail

scriptDir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
projectRoot="$(dirname "$scriptDir")"

# shellcheck disable=SC1091
source "${scriptDir}/lib/db.sh"

loadEnv "${projectRoot}"
cd "${projectRoot}"

echo "=== データベースをリセットします (DB_MODE=${DB_MODE}) ==="

if isDockerMode; then
    echo "コンテナとボリュームを削除して再作成します。"
else
    echo "全テーブルを削除してシードデータを再投入します。"
fi

read -r -p "続行しますか? (y/N): " confirm

if [[ "${confirm}" != "y" && "${confirm}" != "Y" ]]; then
    echo "キャンセルしました。"
    exit 0
fi

if isDockerMode; then
    docker compose down -v
    docker compose up -d
    waitForDb
    echo "リセット完了! (Docker 初回起動時に SQL が自動投入されます)"
else
    "${scriptDir}/seed.sh" reset
    echo "リセット完了!"
fi
