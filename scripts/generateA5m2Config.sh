#!/usr/bin/env bash
set -euo pipefail

scriptDir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
projectRoot="$(dirname "$scriptDir")"
a5m2Dir="${projectRoot}/a5m2"

# shellcheck disable=SC1091
source "${scriptDir}/lib/db.sh"
# shellcheck disable=SC1091
source "${scriptDir}/lib/a5m2.sh"

loadEnv "${projectRoot}"
cd "${projectRoot}"

mkdir -p "${a5m2Dir}/generated"

dbRegisterName="$(buildA5m2DbRegisterName)"
safeDbRegisterName="$(echo "${dbRegisterName}" | tr ' /()' '____')"

dblistFilePath="${a5m2Dir}/generated/${safeDbRegisterName}.a5dblist"
connectBatFilePath="${a5m2Dir}/generated/connect.bat"
connectionInfoFilePath="${a5m2Dir}/generated/connection.txt"

generateA5m2DblistFile "${dblistFilePath}"
generateA5m2ConnectBat "${connectBatFilePath}"
generateA5m2ConnectionInfo "${connectionInfoFilePath}"

echo "=== A5:SQL Mk-2 接続設定を生成しました ==="
echo ""
echo "生成ファイル:"
echo "  ${dblistFilePath}"
echo "  ${connectBatFilePath}"
echo "  ${connectionInfoFilePath}"
echo ""
echo "接続情報:"
echo "  DB登録名: ${dbRegisterName}"
echo "  Host:     ${POSTGRES_HOST}:${POSTGRES_PORT}"
echo "  Database: ${POSTGRES_DB}"
echo "  User:     ${POSTGRES_USER}"
echo ""
echo "A5:SQL Mk-2 でのインポート手順:"
echo "  1. [データベース] → [データベースの追加と削除]"
echo "  2. [インポート] → 上記 .a5dblist を選択"
echo "  3. パスワード (${POSTGRES_PASSWORD}) を入力して接続"
