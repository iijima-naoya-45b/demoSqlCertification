@echo off
setlocal

REM A5:SQL Mk-2 でローカル PostgreSQL の sql_certification DB に接続
REM 使い方: connect-local.bat [A5M2.exe のパス]

set "a5m2ExePath=%~1"
if "%a5m2ExePath%"=="" (
    if exist "C:\Program Files\A5M2\A5M2.exe" (
        set "a5m2ExePath=C:\Program Files\A5M2\A5M2.exe"
    ) else if exist "C:\Program Files (x86)\A5M2\A5M2.exe" (
        set "a5m2ExePath=C:\Program Files (x86)\A5M2\A5M2.exe"
    ) else (
        echo エラー: A5M2.exe のパスを指定してください。
        exit /b 1
    )
)

set "dbRegisterName=sql_certification (local)"
set "connectionString=__ConnectionType=Internal;ProviderName=PostgreSQL;SavePassword=True;UseUnicodeMetaData=True;ServerName=localhost;Port=5432;Database=sql_certification;UserName=sqluser;Password=sqlpass;DBType=PostgreSQL;ProtocolVersion=30;InitialSchemaName=public"

echo A5:SQL Mk-2 を起動して接続します...
"%a5m2ExePath%" /SetDB "%dbRegisterName%=%connectionString%" /Connect "%dbRegisterName%"
