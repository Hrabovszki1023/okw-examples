*** Settings ***
Documentation     OKW Environment Docker — Basic integration examples.
...               Demonstrates the ENV keyword lifecycle with a PostgreSQL container.
...
...               Requires a reachable Docker host. Configure via:
...               - Environment variable DOCKER_HOST (e.g. tcp://192.168.1.100:2375)
...               - Or docker_host key in the component YAML

Library           okw_env_docker.library.OkwEnvDockerLibrary
...               components_dir=${CURDIR}${/}..${/}components

*** Test Cases ***
PostgreSQL Container Starten Und Pruefen
    [Documentation]    Startet einen PostgreSQL-Container, wartet auf Health-Check,
    ...                loggt die publizierten Variablen und raeumt auf.
    ENV_Start          PostgresDB
    ENV_BuildAndRun
    ENV_WaitForReady   PostgresDB

    Log    Container ID: ${PostgresDB.ID}
    Log    Image: ${PostgresDB.image}
    Log    Port: ${PostgresDB.port}
    Log    DB Name: ${PostgresDB.env.POSTGRES_DB}

    [Teardown]    ENV_Stop

PostgreSQL Mit Snapshot Bei Fehler
    [Documentation]    Demonstriert ENV_SnapshotOnFail im Teardown.
    ...                Der Test selbst ist trivial — der Teardown zeigt das Muster.
    ENV_Start          PostgresDB
    ENV_BuildAndRun
    ENV_WaitForReady   PostgresDB

    Log    PostgreSQL ist bereit: ${PostgresDB.env.POSTGRES_DB}

    [Teardown]    Run Keywords    ENV_SnapshotOnFail    ENV_Stop
