# OKW Environment Docker — Basic Example

Demonstrates the OKW environment provisioning lifecycle with Docker containers.

## What it shows

- `ENV_Start` — register a component from YAML
- `ENV_BuildAndRun` — pull image, create and start container
- `ENV_WaitForReady` — poll health check until ready
- `ENV_SnapshotOnFail` — freeze container state on test failure
- `ENV_Stop` — stop and destroy all containers

## Prerequisites

- Python 3.10+
- A reachable Docker host with the Engine API exposed (TCP)
- No local Docker installation required — only the Python SDK

## Setup

```bash
pip install robotframework-okw-env-docker
```

Configure the Docker host:

```bash
export DOCKER_HOST=tcp://your-docker-host:2375
```

## Run

```bash
cd env-docker/basic
robot tests/ENV_Docker_Basic.robot
```

## Component YAML

Each environment component is defined in `components/*.yaml`:

```yaml
PostgresDB:
  provider: docker
  image: postgres
  version: "17"
  port: 5432
  env:
    POSTGRES_DB: testdb
    POSTGRES_USER: testuser
    POSTGRES_PASSWORD: testpass
  healthcheck: "pg_isready -U testuser -d testdb"
  timeout: 30s
```

After `ENV_BuildAndRun`, all YAML keys are available as Robot Framework
variables: `${PostgresDB.port}`, `${PostgresDB.env.POSTGRES_DB}`, etc.

## Signal vs. NOISE

| Signal | NOISE (hidden) |
|---|---|
| `ENV_Start PostgresDB` | Docker API, image pull, container config |
| `ENV_WaitForReady PostgresDB` | Health check polling, timeout logic |
| `${PostgresDB.env.POSTGRES_DB}` | YAML parsing, variable publishing |
| `ENV_Stop` | Container stop, remove, cleanup |
