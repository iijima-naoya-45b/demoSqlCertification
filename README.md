# SQL Practice Sample Project

A PostgreSQL sample database for SQL learning and validation.

## Documentation

| Language | File |
|----------|------|
| 日本語 | [README.ja.md](README.ja.md) |
| English | [README.en.md](README.en.md) |

## Quick Start

```bash
chmod +x scripts/*.sh
./scripts/setup.sh      # Docker
./scripts/connect.sh    # Connect with psql
```

## Connection (Local Validation)

This project is for **local SQL practice only**. The credentials below are dummy values and safe to document publicly.

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

### A5:SQL Mk-2 Login

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

**Import file:** `a5m2/sql_certification-docker.a5dblist` or `a5m2/sql_certification-local.a5dblist`

### DBeaver Login

| DBeaver field | Value |
|---------------|-------|
| Connection type | PostgreSQL |
| Host | `localhost` |
| Port | `5432` |
| Database | `sql_certification` |
| Username | `sqluser` |
| Password | `sqlpass` |
| JDBC URL | `jdbc:postgresql://localhost:5432/sql_certification` |

1. Start DB → DBeaver → **New Database Connection** → **PostgreSQL**
2. Enter values above → **Test Connection** → **Finish**

See [README.ja.md](README.ja.md) / [README.en.md](README.en.md) for full steps.
