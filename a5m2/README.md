# A5:SQL Mk-2 接続ガイド

このプロジェクトの PostgreSQL に [A5:SQL Mk-2](https://a5m2.mmatsubara.com/) から接続するための設定ファイルです。

## 接続情報（デフォルト）

| 項目 | 値 |
|------|-----|
| DB登録名 (Docker) | `sql_certification (docker)` |
| DB登録名 (Local) | `sql_certification (local)` |
| サーバー名 | `localhost` |
| ポート番号 | `5432` |
| データベース名 | `sql_certification` |
| ユーザーID | `sqluser` |
| パスワード | `sqlpass` |
| プロトコルバージョン | `3.0 (PostgreSQL 7.4～)` |
| 初期スキーマ | `public` |

## 方法1: 接続情報ファイルをインポート（推奨）

1. A5:SQL Mk-2 を起動
2. **[データベース]** → **[データベースの追加と削除]**
3. **[インポート]** をクリック
4. 以下のいずれかを選択
   - Docker 利用時: `a5m2/sql_certification-docker.a5dblist`
   - ローカル利用時: `a5m2/sql_certification-local.a5dblist`
5. インポート後、DB をダブルクリックして接続
6. パスワード入力を求められたら `sqlpass` を入力

> エクスポート形式の仕様上、`.a5dblist` にはパスワードが含まれません。

## 方法2: GUI で手動設定

1. **[データベース]** → **[データベースの追加と削除]** → **[追加]**
2. **[PostgreSQL(直接接続)]** を選択
3. 接続情報を入力

| 画面項目 | 入力値 |
|----------|--------|
| サーバー名 | `localhost` |
| ポート番号 | `5432` |
| データベース名 | `sql_certification` |
| ユーザーID | `sqluser` |
| パスワード | `sqlpass` |
| パスワードを保存する | チェック推奨 |
| プロトコルバージョン | `3.0 (PostgreSQL 7.4～)` |

4. **[テスト接続]** で確認 → **[OK]**
5. DB登録名を `sql_certification (docker)` または `sql_certification (local)` に設定

## 方法3: 起動パラメータで接続（Windows）

```bat
REM Docker 環境
a5m2\connect-docker.bat "C:\Program Files\A5M2\A5M2.exe"

REM ローカル環境
a5m2\connect-local.bat "C:\Program Files\A5M2\A5M2.exe"
```

A5M2.exe のパスを省略した場合、一般的なインストール先を自動検索します。

## 方法4: .env から接続設定を生成

`.env` の内容に合わせて接続ファイルを再生成できます。

```bash
./scripts/generateA5m2Config.sh
```

生成先: `a5m2/generated/`

- `*.a5dblist` — インポート用
- `connect.bat` — 起動・接続用
- `connection.txt` — 接続情報一覧

## 接続前の確認

DB が起動していることを確認してください。

```bash
# Docker
./scripts/setup.sh

# ローカル
./scripts/setupLocal.sh

# データ投入
./scripts/seed.sh reset
```

## 接続できない場合

1. PostgreSQL が起動しているか確認
2. ポート `5432` が Docker とローカルで競合していないか確認
3. ローカル PostgreSQL の場合、`pg_hba.conf` で接続が許可されているか確認

```conf
# IPv4 local connections:
host    all    all    127.0.0.1/32    scram-sha-256
```

設定変更後は PostgreSQL を再起動してください。

## ファイル一覧

```
a5m2/
├── README.md
├── sql_certification-docker.a5dblist   # Docker用インポートファイル
├── sql_certification-local.a5dblist    # ローカル用インポートファイル
├── connect-docker.bat                  # Docker用起動スクリプト
├── connect-local.bat                   # ローカル用起動スクリプト
└── generated/                          # generateA5m2Config.sh の出力先
```
