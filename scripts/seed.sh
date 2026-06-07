#!/usr/bin/env bash
set -euo pipefail

scriptDir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
projectRoot="$(dirname "$scriptDir")"
initDir="${projectRoot}/sql/init"
resetDir="${projectRoot}/sql/reset"

# shellcheck disable=SC1091
source "${scriptDir}/lib/db.sh"

loadEnv "${projectRoot}"
cd "${projectRoot}"

usage() {
    echo "使い方: $0 [all | reset | drop | schema | data | indexes | analyze]"
    echo ""
    echo "  all      スキーマ + データ + インデックス + 統計更新（デフォルト）"
    echo "  reset    全削除後に all を実行"
    echo "  drop     全テーブル・ビューを削除"
    echo "  schema   sql/init/ の 01〜13 を実行"
    echo "  data     sql/init/ の 20〜23 を実行"
    echo "  indexes  sql/init/ の *_indexes*.sql を実行"
    echo "  analyze  sql/init/ の 99 を実行"
    echo ""
    echo "環境変数 DB_MODE で実行先を切り替えます:"
    echo "  docker  Docker Compose の PostgreSQL（デフォルト）"
    echo "  local   ローカルにインストールした PostgreSQL"
    exit 1
}

runSeedStep() {
    local stepName="$1"
    local sqlFilePath="$2"

    echo ""
    echo "=== ${stepName} ==="
    runSqlFile "${sqlFilePath}"
}

runInitFiles() {
    local pattern="$1"
    local stepLabel="$2"
    local matchedFiles=()

    shopt -s nullglob
    matchedFiles=("${initDir}"/${pattern})
    shopt -u nullglob

    if [[ ${#matchedFiles[@]} -eq 0 ]]; then
        echo "エラー: 実行対象の SQL ファイルが見つかりません (pattern=${pattern})"
        exit 1
    fi

    for sqlFilePath in "${matchedFiles[@]}"; do
        runSeedStep "${stepLabel}: $(basename "${sqlFilePath}")" "${sqlFilePath}"
    done
}

runSchema() {
    runInitFiles "01_*.sql" "スキーマ"
    runInitFiles "*_schema_*.sql" "スキーマ"
}

runData() {
    runInitFiles "2[0-3]_seed_*.sql" "データ"
}

runIndexes() {
    runInitFiles "*_indexes*.sql" "インデックス"
}

runAnalyze() {
    runInitFiles "99_*.sql" "統計更新"
}

runAll() {
    runSchema
    runData
    runIndexes
    runAnalyze
}

target="${1:-all}"

case "${target}" in
    drop)
        runSeedStep "全オブジェクト削除" "${resetDir}/00_drop.sql"
        ;;
    schema)
        runSchema
        ;;
    data)
        runData
        ;;
    indexes)
        runIndexes
        ;;
    analyze)
        runAnalyze
        ;;
    all)
        runAll
        ;;
    reset)
        runSeedStep "全オブジェクト削除" "${resetDir}/00_drop.sql"
        runAll
        ;;
    -h|--help|help)
        usage
        ;;
    *)
        echo "エラー: 不明な引数です: ${target}"
        usage
        ;;
esac

echo ""
echo "=== 投入完了 (DB_MODE=${DB_MODE}, target=${target}) ==="
