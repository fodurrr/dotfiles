# PostgreSQL Setup Guide

Quick reference for PostgreSQL on macOS via Homebrew.

## Installation

PostgreSQL is included in the `developer` and `hacker` profiles:

```bash
./install.sh --profile=developer
```

## One-Time Setup

After installation, create the standard dev credentials (`postgres:postgres`):

```bash
# Start the service
brew services start postgresql@17

# Create postgres superuser with password
createuser -s postgres
psql -d postgres -c "ALTER USER postgres WITH PASSWORD 'postgres';"
```

## Service Management

```bash
brew services start postgresql@17   # Start
brew services stop postgresql@17    # Stop
brew services restart postgresql@17 # Restart
brew services list                  # Check status
```

## Common Commands

```bash
# Connect to PostgreSQL
psql -U postgres

# Create a database
createdb -U postgres myapp_dev

# Drop a database
dropdb -U postgres myapp_dev

# List databases
psql -U postgres -c "\l"

# List users
psql -U postgres -c "\du"
```

## TablePlus Connection

| Field | Value |
|-------|-------|
| Name | `Local Dev` |
| Host | `localhost` |
| Port | `5432` |
| User | `postgres` |
| Password | `postgres` |
| Database | `postgres` |

## Phoenix/Ecto Config

Standard `config/dev.exs` settings:

```elixir
config :myapp, MyApp.Repo,
  username: "postgres",
  password: "postgres",
  hostname: "localhost",
  database: "myapp_dev",
  port: 5432
```

## Troubleshooting

**Command not found (`psql`, `createuser`)**
```bash
source ~/.zshrc  # Reload shell to get PATH
```

**Connection refused**
```bash
brew services start postgresql@17
```

**Database does not exist**
```bash
createdb -U postgres your_database_name
```
