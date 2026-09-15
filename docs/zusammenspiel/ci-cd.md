# CI/CD-Pipeline

!!! info "In Bearbeitung"
    Dieses Kapitel wird noch geschrieben.

## Überblick

Wie OKW-Tests in eine CI/CD-Pipeline integriert werden — von Unit-Tests
über Integrationstests bis zum Release.

## Die vier Stages

| Stage | Trigger | Was passiert |
|---|---|---|
| 1 — Lib Test | Push auf `main` | `pip install -e .` + Tests |
| 2 — TestPyPI | Git Tag `v*` | Package bauen, auf TestPyPI hochladen |
| 3 — Integration | Nach TestPyPI | Frisches venv, Package von TestPyPI, okw-examples Tests |
| 4 — PyPI + GitHub | Stage 3 grün | Auf PyPI veröffentlichen, GitHub Mirror pushen |
