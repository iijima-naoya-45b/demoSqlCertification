# SQL検証用サンプルプロジェクト

[English](README.en.md) | **日本語**

PostgreSQL を使った SQL 学習・検証用のサンプルデータベースです。  
EC サイト + 社内人事管理をテーマに、JOIN・集計・サブクエリ・ウィンドウ関数などの演習が行えます。

## 前提条件

以下のいずれかの方法で PostgreSQL を利用できます。

| 方法 | 必要なもの |
|------|-----------|
| Docker（推奨） | [Docker Desktop](https://www.docker.com/products/docker-desktop/) |
| ローカル | PostgreSQL 16 以上（`psql`, `pg_isready` が使えること） |

## クイックスタート

### 方法A: Docker で起動（DB + Webアプリ）

```bash
chmod +x scripts/*.sh
./scripts/setup.sh          # PostgreSQL + API + React UI を一括起動
./scripts/connect.sh        # psql で DB 接続
```

ブラウザで http://localhost:5173 を開くと Web UI が利用できます。

### 方法B: ローカル PostgreSQL で起動

```bash
# 1. PostgreSQL を起動（macOS Homebrew の例）
brew install postgresql@16
brew services start postgresql@16

# 2. 環境設定を作成
cp .env.example .env
# .env の DB_MODE=local に変更
# macOS の場合は POSTGRES_ADMIN_USER に OS ユーザー名を設定

# 3. DB作成 + シード投入
chmod +x scripts/*.sh
./scripts/setupLocal.sh

# 4. psql で接続
./scripts/connect.sh
```

### ターミナルから SQL を投入する

Docker / ローカル共通で `seed.sh` が使えます。

```bash
# スキーマ + データ + インデックスを投入
./scripts/seed.sh

# 全削除してから再投入
./scripts/seed.sh reset

# 個別に投入
./scripts/seed.sh schema
./scripts/seed.sh data
./scripts/seed.sh indexes
./scripts/seed.sh drop
```

`DB_MODE` は `.env` で切り替えます（未設定時は `docker`）。

```bash
# ローカルモードで seed を実行する例
DB_MODE=local ./scripts/seed.sh reset
```

> **注意**: Docker とローカル PostgreSQL を同時にポート `5432` で起動すると競合します。  
> ローカル利用時は `docker compose down` で Docker を停止するか、`.env` の `POSTGRES_PORT` を変更してください。

## Webアプリ（Gradle + MyBatis + Bulletproof React）

**DemoShop** というサンプル通販サイトの管理画面です。  
バックエンドは Gradle + Spring Boot + MyBatis（Mapper XML）、フロントエンドは Bulletproof React 構成 + Zod + TanStack Query です。

### 認証（Keycloak + Cookie セッション）

ログインは **Keycloak** で行い、セッションは **HttpOnly Cookie**（`SameSite=Lax`）で管理します。  
アーキテクチャ図（シーケンス図・クラス図）: [docs/AUTH_ARCHITECTURE.ja.md](docs/AUTH_ARCHITECTURE.ja.md)

| サービス | URL |
|---------|-----|
| Web UI | http://localhost:5173 |
| Keycloak | http://localhost:8180 （管理: admin / admin） |

デモユーザー: `demo` / `demopass`（learner）、`admin` / `adminpass`（admin）

### Docker で一括起動（推奨）

```bash
./scripts/setup.sh          # 初回セットアップ（DB + API + UI）
# または
./scripts/runApp.sh         # ビルドし直して起動
```

| URL | 説明 |
|-----|------|
| http://localhost:5173 | Web UI（nginx が `/api` を API にプロキシ） |
| http://localhost:8080 | Spring Boot API（直接アクセス用） |

```bash
docker compose up -d --build   # 手動で起動する場合
docker compose down            # 停止
docker compose logs -f         # ログ確認
```

### ローカル開発（Docker なし）

| コンポーネント | 必要なもの |
|---------------|-----------|
| API (backend) | JDK 17 以上、Gradle（`gradlew` 同梱） |
| UI (frontend) | Node.js 20 以上 |

```bash
# 1. DB を起動・シード投入
./scripts/setup.sh          # または ./scripts/setupLocal.sh
./scripts/seed.sh reset     # データ再投入が必要な場合

# 2. バックエンド API（ターミナル1）
./scripts/runBackend.sh     # ./gradlew bootRun

# 3. フロントエンド（ターミナル2）
./scripts/runFrontend.sh
```

### テスト実行

```bash
# バックエンド（JUnit 5 + Mockito + MockMvc）
cd backend && ./gradlew test

# フロントエンド（Vitest + Testing Library + Zod スキーマ検証）
cd frontend && npm run test
```

### API エンドポイント

| メソッド | パス | 説明 |
|---------|------|------|
| GET | `/api/dashboard/stats` | ダッシュボード統計 |
| GET | `/api/customers` | 顧客一覧（フィルタ・ページング） |
| GET | `/api/customers/{id}` | 顧客詳細 |
| GET | `/api/orders` | 注文一覧 |
| GET | `/api/orders/{id}` | 注文詳細 |
| GET | `/api/products` | 商品一覧 |
| GET | `/api/employees` | 従業員一覧 |
| GET | `/api/exercises` | 演習問題一覧 |
| GET | `/api/exercises/{id}` | 演習問題詳細 |
| POST | `/api/sandbox/execute` | SQL実行（SELECT/EXPLAIN のみ、DELETE等は監査で拒否） |

### 構成

**backend/**（Gradle + MyBatis）
- `build.gradle.kts` — ビルド定義
- `src/main/resources/mapper/*.xml` — MyBatis Mapper XML
- `src/test/java/` — Service 単体テスト・Controller テスト

**frontend/**（Bulletproof React）
- `src/app/` — Provider・Router
- `src/features/` — 機能単位（dashboard, customers, orders, products, employees）
- `src/components/ui/` — 共通 UI
- `src/lib/api-client.ts` — Zod によるレスポンス検証付き API クライアント

## 接続情報

このプロジェクトは **ローカル検証・SQL演習専用** です。  
接続情報はダミー値であり、README やリポジトリに記載して問題ありません（後述）。

### 共通接続情報

| 項目 | 値 |
|------|-----|
| ホスト | `localhost` |
| ポート | `5432` |
| データベース名 | `sql_certification` |
| ユーザー | `sqluser` |
| パスワード | `sqlpass` |

接続 URL:

```
postgresql://sqluser:sqlpass@localhost:5432/sql_certification
```

### A5:SQL Mk-2 でログインする

[A5:SQL Mk-2](https://a5m2.mmatsubara.com/) から接続する場合は、以下を入力してください。

| A5M2 の画面項目 | 入力値 |
|----------------|--------|
| 接続タイプ | PostgreSQL（直接接続） |
| サーバー名 | `localhost` |
| ポート番号 | `5432` |
| データベース名 | `sql_certification` |
| ユーザーID | `sqluser` |
| パスワード | `sqlpass` |
| プロトコルバージョン | `3.0 (PostgreSQL 7.4～)` |
| 初期スキーマ | `public` |
| DB登録名（Docker） | `sql_certification (docker)` |
| DB登録名（ローカル） | `sql_certification (local)` |

#### 手順（GUI で手動設定）

1. 先に DB を起動する（`./scripts/setup.sh` または `./scripts/setupLocal.sh`）
2. A5:SQL Mk-2 を起動
3. **[データベース]** → **[データベースの追加と削除]** → **[追加]**
4. **[PostgreSQL(直接接続)]** を選択
5. 上記の接続情報を入力
6. **[テスト接続]** で成功を確認 → **[OK]**
7. DB登録名を設定して追加
8. データベースツリーから DB をダブルクリックしてログイン

#### 手順（インポートで接続・推奨）

1. 先に DB を起動する
2. **[データベース]** → **[データベースの追加と削除]** → **[インポート]**
3. 以下のファイルを選択
   - Docker: `a5m2/sql_certification-docker.a5dblist`
   - ローカル: `a5m2/sql_certification-local.a5dblist`
4. インポート後、DB をダブルクリック
5. パスワードを求められたら `sqlpass` を入力

> `.a5dblist` にはパスワードが含まれないため、接続時に手入力が必要です。

#### Windows から起動パラメータで接続

```bat
a5m2\connect-docker.bat
a5m2\connect-local.bat
```

#### `.env` から接続設定を再生成

```bash
./scripts/generateA5m2Config.sh
```

詳細は [a5m2/README.md](a5m2/README.md) を参照してください。

### DBeaver でログインする

[DBeaver](https://dbeaver.io/) から接続する場合は、以下を入力してください。

| DBeaver の画面項目 | 入力値 |
|-------------------|--------|
| 接続タイプ | PostgreSQL |
| ホスト | `localhost` |
| ポート | `5432` |
| データベース | `sql_certification` |
| ユーザー名 | `sqluser` |
| パスワード | `sqlpass` |
| 接続名（任意） | `sql_certification (local)` など |
| JDBC URL | `jdbc:postgresql://localhost:5432/sql_certification` |

#### 手順

1. 先に DB を起動する（`./scripts/setup.sh` または `./scripts/setupLocal.sh`）
2. DBeaver を起動
3. **[新しい接続]**（または **データベース** → **新しい接続**）
4. **PostgreSQL** を選択 → **[次へ]**
5. **メイン** タブで上記の接続情報を入力
6. **[パスワードを保存]** にチェック（任意）
7. **[接続をテスト]** で成功を確認 → **[完了]**
8. データベースナビゲーターから `sql_certification` を開く

#### 接続できない場合

- DB が起動しているか確認（`docker compose ps` または `pg_isready -h localhost -p 5432`）
- Docker とローカル PostgreSQL がポート `5432` で競合していないか確認
- **SSL** タブはローカル検証では通常 **使用しない** で問題ありません

### 認証情報を README に記載してよいか

**はい、このプロジェクトの用途であれば問題ありません。** 想定は次のとおりです。

| 観点 | このプロジェクトの前提 |
|------|------------------------|
| 用途 | ローカルでの SQL 検証・演習 |
| 接続先 | `localhost` のみ（インターネット公開しない） |
| データ | 架空のサンプルデータ（個人情報・機密情報なし） |
| 認証情報 | 固定のダミー値（本番環境では使わない） |

以下の場合は README への記載やリポジトリへのコミットを避けてください。

- 本番 DB やステージング環境の接続情報
- 実在するドメイン・社内ホスト名・VPN 経路
- 個人情報を含むデータや機密データ
- `.env` に独自のパスワードを設定した場合（`.env` 自体は gitignore 済み）

本番用の認証情報をこのリポジトリに入れない運用であれば、README に接続情報を載せて問題ありません。

## ディレクトリ構成

```
demoSqlCertification/
├── docker-compose.yml    # PostgreSQL コンテナ定義
├── backend/              # Spring Boot + MyBatis API
├── frontend/             # React + Tailwind UI
├── sql/
│   ├── init/             # スキーマ・データ・インデックス（ドメイン別）
│   ├── reset/            # リセット用 DROP
│   └── docs/             # スキーマ設計書 (SCHEMA.ja.md)
├── exercises/            # 演習問題（01〜06）
├── answers/              # 模範解答
├── a5m2/                 # A5:SQL Mk-2 接続設定
└── scripts/
    ├── lib/db.sh         # DB接続共通ライブラリ
    ├── lib/a5m2.sh       # A5:SQL Mk-2 設定生成
    ├── setup.sh          # Docker 初回セットアップ
    ├── setupLocal.sh     # ローカル PostgreSQL セットアップ
    ├── seed.sh           # スキーマ・シード投入
    ├── generateA5m2Config.sh  # A5M2 接続設定生成
    ├── connect.sh        # psql 接続
    ├── reset.sh          # DBリセット
    ├── runExercise.sh    # 演習の表示・解答実行
    ├── runApp.sh         # Docker で DB + API + UI 一括起動
    ├── runBackend.sh     # Spring Boot API 起動（ローカル開発）
    └── runFrontend.sh    # React 開発サーバー起動（ローカル開発）
```

## データベース構成

### データベース規模

| 区分 | 数 |
|------|-----|
| テーブル合計 | **105**（マスタ35 + トランザクション70） |
| ビュー | 6 |
| 関数 | 5 |
| ストアドプロシージャ | 6 |
| トリガー | 5 |

### 主要テーブルのレコード数（目安）

| テーブル | ドメイン | 件数 |
|----------|----------|------|
| `customers` | Customer | 10,000 |
| `orders` | Order | 50,000 |
| `orderItems` | Order | 約 150,000 |
| `products` | Catalog | 2,000 |
| `employees` | HR | 500 |
| `productReviews` | Marketing | 約 20,000 |
| `auditLogs` | System | 60,000+ |

スキーマ・マスタ・ルーチンの詳細は [sql/docs/SCHEMA.ja.md](sql/docs/SCHEMA.ja.md) を参照してください。

### ER図（概要）

```
departments ──< employees (managerId: 自己参照)
categories  ──< products ──< orderItems >── orders >── customers
categories  ──< categories (parentCategoryId: 階層)
products    ──< productReviews >── customers
employees   ──< orders
employees   ──< salaryHistory
```

## 演習一覧

| ファイル | テーマ | 難易度 | 問題数 |
|----------|--------|--------|--------|
| `01_basic_select.sql` | 基本 SELECT / WHERE / ORDER BY | ★☆☆ | 5 |
| `02_join.sql` | INNER / LEFT JOIN、自己結合 | ★★☆ | 6 |
| `03_aggregation.sql` | GROUP BY / HAVING / 集計関数 | ★★☆ | 6 |
| `04_subquery.sql` | サブクエリ / EXISTS | ★★☆ | 5 |
| `05_window_function.sql` | RANK / ROW_NUMBER / ウィンドウ関数 | ★★★ | 5 |
| `06_advanced.sql` | CTE / CASE / 日付関数 | ★★★ | 5 |
| `07_explain.sql` | EXPLAIN / EXPLAIN ANALYZE | ★★★ | 5 |
| `08_routines.sql` | 関数・プロシージャ・トリガー | ★★★ | 6 |

### 演習の使い方

```bash
# 問題を表示
./scripts/runExercise.sh 01

# 模範解答を実行して結果を確認
./scripts/runExercise.sh 01 --answer
```

psql に接続して手動で練習する場合:

```bash
./scripts/connect.sh

-- テーブル一覧
\dt

-- テーブル構造の確認
\d employees

-- サンプルクエリ
SELECT * FROM v_orderSummary LIMIT 5;
```

## よく使うコマンド

### Docker

```bash
docker compose up -d --build  # DB + API + UI 起動
docker compose down           # 全サービス停止
docker compose logs -f        # 全サービスのログ
docker compose logs -f backend
./scripts/runApp.sh           # ビルドして起動
./scripts/seed.sh reset       # データ再投入（コンテナ起動中）
./scripts/reset.sh            # ボリューム削除して完全リセット
```

### ローカル

```bash
brew services start postgresql@16   # DB起動（Homebrew）
brew services stop postgresql@16    # DB停止
./scripts/seed.sh reset             # データ再投入
./scripts/reset.sh                  # 同上（確認プロンプトあり）
```

## データベースのリセット

```bash
./scripts/reset.sh
```

- **Docker**: ボリュームごと削除して再作成（初回起動時に SQL 自動投入）
- **ローカル**: 全テーブル削除後に `seed.sh reset` で再投入

## 環境変数 (.env)

| 変数 | 説明 | デフォルト |
|------|------|-----------|
| `DB_MODE` | `docker` または `local` | `docker` |
| `POSTGRES_HOST` | DBホスト | `localhost` |
| `POSTGRES_PORT` | DBポート | `5432` |
| `POSTGRES_DB` | データベース名 | `sql_certification` |
| `POSTGRES_USER` | 接続ユーザー | `sqluser` |
| `POSTGRES_PASSWORD` | 接続パスワード | `sqlpass` |
| `POSTGRES_ADMIN_USER` | ローカルセットアップ用の管理者 | OSユーザー名 or `postgres` |
| `POSTGRES_ADMIN_PASSWORD` | 管理者パスワード | 空（peer認証） |
