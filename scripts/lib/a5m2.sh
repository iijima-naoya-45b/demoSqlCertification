#!/usr/bin/env bash

buildA5m2ConnectionString() {
    local includePassword="$1"
    local savePassword="False"
    local passwordValue=""

    if [[ "${includePassword}" == "true" ]]; then
        savePassword="True"
        passwordValue="${POSTGRES_PASSWORD}"
    fi

    echo "__ConnectionType=Internal;ProviderName=PostgreSQL;SavePassword=${savePassword};UseUnicodeMetaData=True;ServerName=${POSTGRES_HOST};Port=${POSTGRES_PORT};Database=${POSTGRES_DB};UserName=${POSTGRES_USER};Password=${passwordValue};DBType=PostgreSQL;ProtocolVersion=30;InitialSchemaName=public"
}

buildA5m2DbRegisterName() {
    echo "sql_certification (${DB_MODE})"
}

generateA5m2DblistFile() {
    local outputFilePath="$1"
    local dbRegisterName
    local connectionString

    dbRegisterName="$(buildA5m2DbRegisterName)"
    connectionString="$(buildA5m2ConnectionString "false")"

    cat > "${outputFilePath}" <<EOF
${dbRegisterName}=${connectionString}
EOF
}

generateA5m2ConnectBat() {
    local outputFilePath="$1"
    local dbRegisterName
    local connectionString

    dbRegisterName="$(buildA5m2DbRegisterName)"
    connectionString="$(buildA5m2ConnectionString "true")"

    cat > "${outputFilePath}" <<EOF
@echo off
setlocal enabledelayedexpansion

REM A5:SQL Mk-2 で sql_certification DB に接続する起動スクリプト
REM 使い方: connect.bat [A5M2.exe のパス]
REM 例: connect.bat "C:\Program Files\A5M2\A5M2.exe"

set "a5m2ExePath=%~1"
if "%a5m2ExePath%"=="" (
    if exist "C:\Program Files\A5M2\A5M2.exe" (
        set "a5m2ExePath=C:\Program Files\A5M2\A5M2.exe"
    ) else if exist "C:\Program Files (x86)\A5M2\A5M2.exe" (
        set "a5m2ExePath=C:\Program Files (x86)\A5M2\A5M2.exe"
    ) else (
        echo エラー: A5M2.exe のパスを指定してください。
        echo 例: connect.bat "C:\Program Files\A5M2\A5M2.exe"
        exit /b 1
    )
)

echo A5:SQL Mk-2 を起動して接続します...
echo   DB登録名: ${dbRegisterName}

"%a5m2ExePath%" /SetDB "${dbRegisterName}=${connectionString}" /Connect "${dbRegisterName}"
EOF
}

generateA5m2ConnectionInfo() {
    local outputFilePath="$1"
    local dbRegisterName

    dbRegisterName="$(buildA5m2DbRegisterName)"

    cat > "${outputFilePath}" <<EOF
# A5:SQL Mk-2 接続情報
# 生成日時: $(date '+%Y-%m-%d %H:%M:%S')

DB登録名: ${dbRegisterName}
DB_MODE: ${DB_MODE}
サーバー名: ${POSTGRES_HOST}
ポート番号: ${POSTGRES_PORT}
データベース名: ${POSTGRES_DB}
ユーザーID: ${POSTGRES_USER}
パスワード: ${POSTGRES_PASSWORD}
プロトコルバージョン: 3.0 (PostgreSQL 7.4～)
初期スキーマ: public

# GUI で手動設定する場合
# 1. [データベース] → [データベースの追加と削除]
# 2. [追加] → [PostgreSQL(直接接続)]
# 3. 上記の接続情報を入力して [テスト接続]
# 4. DB登録名に「${dbRegisterName}」を指定

# 接続文字列 (/SetDB 用)
$(buildA5m2ConnectionString "true")
EOF
}
