# SQL Practice Sample Project

**English** | [日本語](README.ja.md)

A sample PostgreSQL database for SQL learning and validation.  
The schema is themed around e-commerce and internal HR management, with exercises covering JOINs, aggregation, subqueries, window functions, and more.

## Prerequisites

You can run PostgreSQL using either of the following options.

| Method | Requirements |
|--------|--------------|
| Docker (recommended) | [Docker Desktop](https://www.docker.com/products/docker-desktop/) |
| Local | PostgreSQL 16+ with `psql` and `pg_isready` available |

## Quick Start

### Option A: Run with Docker (DB + Web App)

```bash
chmod +x scripts/*.sh
./scripts/setup.sh          # Start PostgreSQL + API + React UI
./scripts/connect.sh        # Connect with psql
```

Open http://localhost:5173 in your browser for the Web UI.

### Option B: Run with Local PostgreSQL

```bash
# 1. Start PostgreSQL (macOS Homebrew example)
brew install postgresql@16
brew services start postgresql@16

# 2. Create environment config
cp .env.example .env
# Set DB_MODE=local in .env
# On macOS, set POSTGRES_ADMIN_USER to your OS username

# 3. Create DB and load seed data
chmod +x scripts/*.sh
./scripts/setupLocal.sh

# 4. Connect with psql
./scripts/connect.sh
```

### Load SQL from the Terminal

`seed.sh` works for both Docker and local environments.

```bash
# Load schema + data + indexes
./scripts/seed.sh

# Drop all objects and reload
./scripts/seed.sh reset

# Load individually
./scripts/seed.sh schema
./scripts/seed.sh data
./scripts/seed.sh indexes
./scripts/seed.sh drop
```

Switch the target environment with `DB_MODE` in `.env` (defaults to `docker`).

```bash
# Example: run seed in local mode
DB_MODE=local ./scripts/seed.sh reset
```

> **Note**: Docker and local PostgreSQL cannot both use port `5432` at the same time.  
> For local use, run `docker compose down` or change `POSTGRES_PORT` in `.env`.

## Web App (Gradle + MyBatis + Bulletproof React)

**DemoShop** — a sample e-commerce admin UI.  
Backend: Gradle + Spring Boot + MyBatis (Mapper XML). Frontend: Bulletproof React + Zod + TanStack Query.

### Authentication (Keycloak + Cookie Session)

Login uses **Keycloak**; sessions are stored in an **HttpOnly cookie** (`SameSite=Lax`).  
Architecture diagrams: [docs/AUTH_ARCHITECTURE.en.md](docs/AUTH_ARCHITECTURE.en.md)

| Service | URL |
|---------|-----|
| Web UI | http://localhost:5173 |
| Keycloak | http://localhost:8180 (admin: admin / admin) |

Demo users: `demo` / `demopass` (learner), `admin` / `adminpass` (admin)

#### Google sign-in (optional)

**Keycloak can federate Google as an external OAuth 2.0 IdP.** The app still uses Keycloak as its OIDC client; Google is configured inside Keycloak, not as a second Spring registration.

1. Create an OAuth 2.0 client in [Google Cloud Console](https://console.cloud.google.com/)
2. Add authorized redirect URI:
   - `http://localhost:8180/realms/demo-shop/broker/google/endpoint`
3. Set in `.env` (see `.env.example`):
   ```bash
   GOOGLE_CLIENT_ID=your-client-id.apps.googleusercontent.com
   GOOGLE_CLIENT_SECRET=your-client-secret
   APP_AUTH_GOOGLE_LOGIN_ENABLED=true
   ```
4. Restart with `docker compose up -d --build` (`keycloak-config` enables the IdP)

The login page shows a **Sign in with Google** button. First-time users receive the `learner` role.

### Run with Docker (recommended)

```bash
./scripts/setup.sh          # Initial setup (DB + API + UI)
# or
./scripts/runApp.sh         # Rebuild and start
```

| URL | Description |
|-----|-------------|
| http://localhost:5173 | Web UI (nginx proxies `/api` to the API) |
| http://localhost:8080 | Spring Boot API (direct access) |

```bash
docker compose up -d --build   # Manual start
docker compose down            # Stop all services
docker compose logs -f         # View logs
```

### Local development (without Docker for the app)

| Component | Requirements |
|-----------|----------------|
| API (backend) | JDK 17+, Gradle (`gradlew` included) |
| UI (frontend) | Node.js 20+ |

```bash
# 1. Start DB and load seed data
./scripts/setup.sh          # or ./scripts/setupLocal.sh
./scripts/seed.sh reset     # if you need to reload data

# 2. Backend API (terminal 1)
./scripts/runBackend.sh     # ./gradlew bootRun

# 3. Frontend (terminal 2)
./scripts/runFrontend.sh
```

### Running tests

```bash
# Backend (JUnit 5 + Mockito + MockMvc)
cd backend && ./gradlew test

# Frontend (Vitest + Testing Library + Zod schema validation)
cd frontend && npm run test
```

### API Endpoints

| Method | Path | Description |
|--------|------|-------------|
| GET | `/api/dashboard/stats` | Dashboard statistics |
| GET | `/api/customers` | Customer list (filter + paging) |
| GET | `/api/customers/{id}` | Customer detail |
| GET | `/api/orders` | Order list |
| GET | `/api/orders/{id}` | Order detail |
| GET | `/api/products` | Product list |
| GET | `/api/employees` | Employee list |
| GET | `/api/exercises` | Exercise list |
| GET | `/api/exercises/{id}` | Exercise detail |
| POST | `/api/sandbox/execute` | Run SQL (SELECT/EXPLAIN only; DELETE etc. blocked by audit) |

### Layout

**backend/** (Gradle + MyBatis)
- `build.gradle.kts` — build definition
- `src/main/resources/mapper/*.xml` — MyBatis Mapper XML
- `src/test/java/` — service unit tests and controller tests

**frontend/** (Bulletproof React)
- `src/app/` — providers and router
- `src/features/` — feature modules (dashboard, customers, orders, products, employees)
- `src/components/ui/` — shared UI components
- `src/lib/api-client.ts` — API client with Zod response validation

## Connection Details

This project is for **local SQL practice and validation only**.  
The credentials below are dummy values and are safe to document publicly (see below).

### Common Connection Info

| Item | Value |
|------|-------|
| Host | `localhost` |
| Port | `5432` |
| Database | `sql_certification` |
| User | `sqluser` |
| Password | `sqlpass` |

Connection URL:

```
postgresql://sqluser:sqlpass@localhost:5432/sql_certification
```

### Log in with A5:SQL Mk-2

Use the following values when connecting from [A5:SQL Mk-2](https://a5m2.mmatsubara.com/).

| A5M2 field | Value |
|------------|-------|
| Connection type | PostgreSQL (direct) |
| Server | `localhost` |
| Port | `5432` |
| Database | `sql_certification` |
| User ID | `sqluser` |
| Password | `sqlpass` |
| Protocol version | `3.0 (PostgreSQL 7.4+)` |
| Initial schema | `public` |
| DB name (Docker) | `sql_certification (docker)` |
| DB name (Local) | `sql_certification (local)` |

#### Steps (manual GUI setup)

1. Start the database first (`./scripts/setup.sh` or `./scripts/setupLocal.sh`)
2. Launch A5:SQL Mk-2
3. Open **Database** → **Add/Remove Databases** → **Add**
4. Select **PostgreSQL (direct)**
5. Enter the connection details above
6. Click **Test Connection**, then **OK**
7. Set a DB registration name and save
8. Double-click the database in the tree to log in

#### Steps (import config — recommended)

1. Start the database first
2. Open **Database** → **Add/Remove Databases** → **Import**
3. Select one of the following files:
   - Docker: `a5m2/sql_certification-docker.a5dblist`
   - Local: `a5m2/sql_certification-local.a5dblist`
4. Double-click the imported database
5. Enter password `sqlpass` when prompted

> `.a5dblist` files do not include passwords, so you must enter it at login.

#### Connect via launch parameters on Windows

```bat
a5m2\connect-docker.bat
a5m2\connect-local.bat
```

#### Regenerate connection config from `.env`

```bash
./scripts/generateA5m2Config.sh
```

See [a5m2/README.md](a5m2/README.md) for more details.

### Log in with DBeaver

Use the following values when connecting from [DBeaver](https://dbeaver.io/).

| DBeaver field | Value |
|---------------|-------|
| Connection type | PostgreSQL |
| Host | `localhost` |
| Port | `5432` |
| Database | `sql_certification` |
| Username | `sqluser` |
| Password | `sqlpass` |
| Connection name (optional) | `sql_certification (local)`, etc. |
| JDBC URL | `jdbc:postgresql://localhost:5432/sql_certification` |

#### Steps

1. Start the database first (`./scripts/setup.sh` or `./scripts/setupLocal.sh`)
2. Launch DBeaver
3. Click **New Database Connection** (or **Database** → **New Database Connection**)
4. Select **PostgreSQL** → **Next**
5. On the **Main** tab, enter the connection details above
6. Check **Save password** (optional)
7. Click **Test Connection**, then **Finish**
8. Open `sql_certification` in the Database Navigator

#### Troubleshooting

- Verify the database is running (`docker compose ps` or `pg_isready -h localhost -p 5432`)
- Check for port `5432` conflicts between Docker and local PostgreSQL
- For local validation, **SSL** is usually **not required** on the SSL tab

### Is it safe to publish credentials in the README?

**Yes, for this project's intended use.** The assumptions are:

| Aspect | This project's scope |
|--------|------------------------|
| Purpose | Local SQL practice and validation |
| Target | `localhost` only (not exposed to the internet) |
| Data | Fictional sample data (no PII or confidential data) |
| Credentials | Fixed dummy values (not for production use) |

Do **not** document or commit credentials in the following cases:

- Production or staging database connections
- Real domains, internal hostnames, or VPN routes
- Data containing personal or confidential information
- Custom passwords set in `.env` (`.env` is already gitignored)

As long as you do not put production secrets in this repository, documenting connection info in the README is fine.

## Directory Structure

```
demoSqlCertification/
├── docker-compose.yml    # PostgreSQL container definition
├── backend/              # Spring Boot + MyBatis API
├── frontend/             # React + Tailwind UI
├── sql/
│   ├── init/             # Schema, data, indexes (by domain)
│   ├── reset/            # DROP scripts for reset
│   └── docs/             # Schema docs (SCHEMA.en.md)
├── exercises/            # Exercise problems (01–06)
├── answers/              # Sample answers
├── a5m2/                 # A5:SQL Mk-2 connection config
└── scripts/
    ├── lib/db.sh         # Shared DB connection utilities
    ├── lib/a5m2.sh       # A5:SQL Mk-2 config generator
    ├── setup.sh          # Docker initial setup
    ├── setupLocal.sh     # Local PostgreSQL setup
    ├── seed.sh           # Load schema and seed data
    ├── generateA5m2Config.sh  # Generate A5M2 connection config
    ├── connect.sh        # psql connection
    ├── reset.sh          # Reset database
    ├── runExercise.sh    # Display/run exercises
    ├── runApp.sh         # Start DB + API + UI via Docker
    ├── runBackend.sh     # Start Spring Boot API (local dev)
    └── runFrontend.sh    # Start React dev server (local dev)
```

## Database Schema

### Database scale

| Layer | Count |
|-------|-------|
| Tables | **105** (35 master + 70 transaction) |
| Views | 6 |
| Functions | 5 |
| Procedures | 6 |
| Triggers | 5 |

### Key table row counts

| Table | Domain | Rows |
|-------|--------|------|
| `customers` | Customer | 10,000 |
| `orders` | Order | 50,000 |
| `orderItems` | Order | ~150,000 |
| `products` | Catalog | 2,000 |
| `employees` | HR | 500 |

See [sql/docs/SCHEMA.en.md](sql/docs/SCHEMA.en.md) for full schema documentation.

### ER Diagram (Overview)

```
departments ──< employees (managerId: self-reference)
categories  ──< products ──< orderItems >── orders >── customers
categories  ──< categories (parentCategoryId: hierarchy)
products    ──< productReviews >── customers
employees   ──< orders
employees   ──< salaryHistory
```

## Exercises

| File | Topic | Difficulty | Questions |
|------|-------|------------|-----------|
| `01_basic_select.sql` | Basic SELECT / WHERE / ORDER BY | ★☆☆ | 5 |
| `02_join.sql` | INNER / LEFT JOIN, self-join | ★★☆ | 6 |
| `03_aggregation.sql` | GROUP BY / HAVING / aggregate functions | ★★☆ | 6 |
| `04_subquery.sql` | Subqueries / EXISTS | ★★☆ | 5 |
| `05_window_function.sql` | RANK / ROW_NUMBER / window functions | ★★★ | 5 |
| `06_advanced.sql` | CTE / CASE / date functions | ★★★ | 5 |
| `07_explain.sql` | EXPLAIN / EXPLAIN ANALYZE | ★★★ | 5 |
| `08_routines.sql` | Functions, procedures, triggers | ★★★ | 6 |

### How to Use Exercises

```bash
# Show exercise problems
./scripts/runExercise.sh 01

# Run sample answers and view results
./scripts/runExercise.sh 01 --answer
```

To practice manually in psql:

```bash
./scripts/connect.sh

-- List tables
\dt

-- Show table structure
\d employees

-- Sample query
SELECT * FROM v_orderSummary LIMIT 5;
```

## Common Commands

### Docker

```bash
docker compose up -d --build  # Start DB + API + UI
docker compose down           # Stop all services
docker compose logs -f        # All service logs
docker compose logs -f backend
./scripts/runApp.sh           # Rebuild and start
./scripts/seed.sh reset       # Reload data (while container is running)
./scripts/reset.sh            # Full reset (removes volumes)
```

### Local

```bash
brew services start postgresql@16   # Start DB (Homebrew)
brew services stop postgresql@16    # Stop DB
./scripts/seed.sh reset             # Reload data
./scripts/reset.sh                  # Same as above (with confirmation prompt)
```

## Reset Database

```bash
./scripts/reset.sh
```

- **Docker**: Removes volumes and recreates the container (SQL is auto-loaded on first start)
- **Local**: Drops all tables and reloads via `seed.sh reset`

## Environment Variables (.env)

| Variable | Description | Default |
|----------|-------------|---------|
| `DB_MODE` | `docker` or `local` | `docker` |
| `POSTGRES_HOST` | DB host | `localhost` |
| `POSTGRES_PORT` | DB port | `5432` |
| `POSTGRES_DB` | Database name | `sql_certification` |
| `POSTGRES_USER` | Connection user | `sqluser` |
| `POSTGRES_PASSWORD` | Connection password | `sqlpass` |
| `POSTGRES_ADMIN_USER` | Admin user for local setup | OS username or `postgres` |
| `POSTGRES_ADMIN_PASSWORD` | Admin password | empty (peer auth) |
