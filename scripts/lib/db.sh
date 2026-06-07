#!/usr/bin/env bash

loadEnv() {
    local projectRoot="$1"

    if [[ -f "${projectRoot}/.env" ]]; then
        set -a
        # shellcheck disable=SC1091
        source "${projectRoot}/.env"
        set +a
    fi

    export DB_MODE="${DB_MODE:-docker}"
    export POSTGRES_HOST="${POSTGRES_HOST:-localhost}"
    export POSTGRES_PORT="${POSTGRES_PORT:-5432}"
    export POSTGRES_DB="${POSTGRES_DB:-sql_certification}"
    export POSTGRES_USER="${POSTGRES_USER:-sqluser}"
    export POSTGRES_PASSWORD="${POSTGRES_PASSWORD:-sqlpass}"
    export POSTGRES_ADMIN_USER="${POSTGRES_ADMIN_USER:-}"
    export POSTGRES_ADMIN_PASSWORD="${POSTGRES_ADMIN_PASSWORD:-}"
    export POSTGRES_ADMIN_HOST="${POSTGRES_ADMIN_HOST:-localhost}"
    export POSTGRES_ADMIN_PORT="${POSTGRES_ADMIN_PORT:-5432}"

    if [[ -z "${POSTGRES_ADMIN_USER}" ]]; then
        if id postgres &> /dev/null; then
            export POSTGRES_ADMIN_USER="postgres"
        else
            export POSTGRES_ADMIN_USER="$(whoami)"
        fi
    fi
}

requirePsql() {
    if ! command -v psql &> /dev/null; then
        echo "エラー: psql が見つかりません。PostgreSQL クライアントをインストールしてください。"
        echo "  macOS (Homebrew): brew install libpq && brew link --force libpq"
        exit 1
    fi
}

isDockerMode() {
    [[ "${DB_MODE}" == "docker" ]]
}

runAdminPsql() {
    local sqlCommand="$1"
    shift
    local extraArgs=("$@")

    if isDockerMode; then
        if [[ ${#extraArgs[@]} -gt 0 ]]; then
            docker compose exec -T postgres \
                psql -v ON_ERROR_STOP=1 -U "${POSTGRES_ADMIN_USER}" -d postgres \
                "${extraArgs[@]}" \
                -c "${sqlCommand}"
        else
            docker compose exec -T postgres \
                psql -v ON_ERROR_STOP=1 -U "${POSTGRES_ADMIN_USER}" -d postgres \
                -c "${sqlCommand}"
        fi
        return
    fi

    if [[ -n "${POSTGRES_ADMIN_PASSWORD}" ]]; then
        if [[ ${#extraArgs[@]} -gt 0 ]]; then
            PGPASSWORD="${POSTGRES_ADMIN_PASSWORD}" psql \
                -h "${POSTGRES_ADMIN_HOST}" \
                -p "${POSTGRES_ADMIN_PORT}" \
                -U "${POSTGRES_ADMIN_USER}" \
                -d postgres \
                -v ON_ERROR_STOP=1 \
                "${extraArgs[@]}" \
                -c "${sqlCommand}"
        else
            PGPASSWORD="${POSTGRES_ADMIN_PASSWORD}" psql \
                -h "${POSTGRES_ADMIN_HOST}" \
                -p "${POSTGRES_ADMIN_PORT}" \
                -U "${POSTGRES_ADMIN_USER}" \
                -d postgres \
                -v ON_ERROR_STOP=1 \
                -c "${sqlCommand}"
        fi
    else
        if [[ ${#extraArgs[@]} -gt 0 ]]; then
            psql \
                -h "${POSTGRES_ADMIN_HOST}" \
                -p "${POSTGRES_ADMIN_PORT}" \
                -U "${POSTGRES_ADMIN_USER}" \
                -d postgres \
                -v ON_ERROR_STOP=1 \
                "${extraArgs[@]}" \
                -c "${sqlCommand}"
        else
            psql \
                -h "${POSTGRES_ADMIN_HOST}" \
                -p "${POSTGRES_ADMIN_PORT}" \
                -U "${POSTGRES_ADMIN_USER}" \
                -d postgres \
                -v ON_ERROR_STOP=1 \
                -c "${sqlCommand}"
        fi
    fi
}

runPsql() {
    local sqlCommand="$1"

    if isDockerMode; then
        docker compose exec -T postgres \
            psql -v ON_ERROR_STOP=1 -U "${POSTGRES_USER}" -d "${POSTGRES_DB}" \
            -c "${sqlCommand}"
        return
    fi

    PGPASSWORD="${POSTGRES_PASSWORD}" psql \
        -h "${POSTGRES_HOST}" \
        -p "${POSTGRES_PORT}" \
        -U "${POSTGRES_USER}" \
        -d "${POSTGRES_DB}" \
        -v ON_ERROR_STOP=1 \
        -c "${sqlCommand}"
}

runSqlFile() {
    local sqlFilePath="$1"

    if [[ ! -f "${sqlFilePath}" ]]; then
        echo "エラー: SQLファイルが見つかりません: ${sqlFilePath}"
        exit 1
    fi

    echo "実行中: ${sqlFilePath}"

    if isDockerMode; then
        docker compose exec -T postgres \
            psql -v ON_ERROR_STOP=1 -U "${POSTGRES_USER}" -d "${POSTGRES_DB}" \
            < "${sqlFilePath}"
        return
    fi

    PGPASSWORD="${POSTGRES_PASSWORD}" psql \
        -h "${POSTGRES_HOST}" \
        -p "${POSTGRES_PORT}" \
        -U "${POSTGRES_USER}" \
        -d "${POSTGRES_DB}" \
        -v ON_ERROR_STOP=1 \
        -f "${sqlFilePath}"
}

waitForDb() {
    local maxRetry=30
    local retryCount=0

    echo "データベースの起動を待機しています..."

    while [[ ${retryCount} -lt ${maxRetry} ]]; do
        if isDockerMode; then
            if docker compose exec -T postgres pg_isready -U "${POSTGRES_USER}" -d "${POSTGRES_DB}" > /dev/null 2>&1; then
                return 0
            fi
        else
            if PGPASSWORD="${POSTGRES_PASSWORD}" pg_isready \
                -h "${POSTGRES_HOST}" \
                -p "${POSTGRES_PORT}" \
                -U "${POSTGRES_USER}" \
                -d "${POSTGRES_DB}" > /dev/null 2>&1; then
                return 0
            fi
        fi

        retryCount=$((retryCount + 1))
        sleep 2
    done

    echo "エラー: データベースへの接続がタイムアウトしました。"
    echo "  DB_MODE=${DB_MODE}"
    echo "  Host=${POSTGRES_HOST}:${POSTGRES_PORT}"
    echo "  Database=${POSTGRES_DB}"
    echo "  User=${POSTGRES_USER}"
    exit 1
}

connectPsql() {
    if isDockerMode; then
        docker compose exec postgres psql -U "${POSTGRES_USER}" -d "${POSTGRES_DB}"
        return
    fi

    PGPASSWORD="${POSTGRES_PASSWORD}" psql \
        -h "${POSTGRES_HOST}" \
        -p "${POSTGRES_PORT}" \
        -U "${POSTGRES_USER}" \
        -d "${POSTGRES_DB}"
}

printConnectionInfo() {
    echo ""
    echo "接続情報:"
    echo "  モード:   ${DB_MODE}"
    echo "  Host:     ${POSTGRES_HOST}"
    echo "  Port:     ${POSTGRES_PORT}"
    echo "  Database: ${POSTGRES_DB}"
    echo "  User:     ${POSTGRES_USER}"
    echo "  Password: ${POSTGRES_PASSWORD}"
    echo ""
    echo "接続コマンド:"
    echo "  ./scripts/connect.sh"
    echo ""
    echo "SQL投入コマンド:"
    echo "  ./scripts/seed.sh          # スキーマ + データ + インデックス + ANALYZE"
    echo "  ./scripts/seed.sh reset    # 削除してから再投入"
    echo "  ./scripts/seed.sh schema   # スキーマのみ (sql/init/*_schema_*)"
    echo "  ./scripts/seed.sh data     # シードデータのみ (sql/init/*_seed_*)"
    echo "  ./scripts/seed.sh indexes  # インデックスのみ (sql/init/*_indexes*)"
    echo "  ./scripts/seed.sh analyze  # 統計更新のみ (sql/init/99)"
}

createLocalDatabaseIfNeeded() {
    requirePsql

    echo "ローカル PostgreSQL の DB / ユーザーを確認しています..."
    echo "  管理者ユーザー: ${POSTGRES_ADMIN_USER}"

    if ! runAdminPsql "SELECT 1;" > /dev/null 2>&1; then
        echo "エラー: 管理者ユーザー (${POSTGRES_ADMIN_USER}) で PostgreSQL に接続できません。"
        echo "  .env の POSTGRES_ADMIN_USER / POSTGRES_ADMIN_PASSWORD を確認してください。"
        echo "  macOS (Homebrew) の場合は POSTGRES_ADMIN_USER=\$(whoami) が一般的です。"
        exit 1
    fi

    local roleExists
    roleExists=$(runAdminPsql "SELECT 1 FROM pg_roles WHERE rolname = '${POSTGRES_USER}';" -t 2>/dev/null | tr -d '[:space:]' || true)

    if [[ "${roleExists}" != "1" ]]; then
        echo "ユーザー ${POSTGRES_USER} を作成します..."
        runAdminPsql "CREATE ROLE ${POSTGRES_USER} WITH LOGIN PASSWORD '${POSTGRES_PASSWORD}';"
    else
        echo "ユーザー ${POSTGRES_USER} は既に存在します。"
        runAdminPsql "ALTER ROLE ${POSTGRES_USER} WITH LOGIN PASSWORD '${POSTGRES_PASSWORD}';" > /dev/null 2>&1 || true
    fi

    local dbExists
    dbExists=$(runAdminPsql "SELECT 1 FROM pg_database WHERE datname = '${POSTGRES_DB}';" -t 2>/dev/null | tr -d '[:space:]' || true)

    if [[ "${dbExists}" != "1" ]]; then
        echo "データベース ${POSTGRES_DB} を作成します..."
        runAdminPsql "CREATE DATABASE ${POSTGRES_DB} OWNER ${POSTGRES_USER};"
    else
        echo "データベース ${POSTGRES_DB} は既に存在します。"
    fi

    runAdminPsql "GRANT ALL PRIVILEGES ON DATABASE ${POSTGRES_DB} TO ${POSTGRES_USER};" > /dev/null 2>&1 || true
}
