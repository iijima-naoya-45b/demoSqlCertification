#!/usr/bin/env bash
set -euo pipefail

scriptDir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
projectRoot="$(dirname "$scriptDir")"

# shellcheck disable=SC1091
source "${scriptDir}/lib/db.sh"

usage() {
    echo "使い方: $0 <演習番号(01-06)> [--answer]"
    echo ""
    echo "例:"
    echo "  $0 01           # 演習01の問題を表示"
    echo "  $0 01 --answer  # 演習01の解答を実行"
    exit 1
}

if [[ $# -lt 1 ]]; then
    usage
fi

exerciseNumber="$1"
showAnswer=false

if [[ "${2:-}" == "--answer" ]]; then
    showAnswer=true
fi

loadEnv "${projectRoot}"
cd "${projectRoot}"

if $showAnswer; then
    sqlFile=$(ls answers/${exerciseNumber}_*.sql 2>/dev/null | head -1)
else
    sqlFile=$(ls exercises/${exerciseNumber}_*.sql 2>/dev/null | head -1)
fi

if [[ -z "${sqlFile}" ]]; then
    echo "エラー: ファイルが見つかりません (演習番号: ${exerciseNumber}, 解答: ${showAnswer})"
    exit 1
fi

if $showAnswer; then
    echo "=== 解答を実行: ${sqlFile} (DB_MODE=${DB_MODE}) ==="
    runSqlFile "${sqlFile}"
else
    echo "=== 演習問題: ${sqlFile} ==="
    cat "${sqlFile}"
fi
