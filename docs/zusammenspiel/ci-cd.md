---
source_hash: 590872f9624d
---

# CI/CD Pipeline

!!! info "Work in progress"
    This chapter is still being written.

## Overview

How OKW tests are integrated into a CI/CD pipeline — from unit tests via
integration tests to the release.

## The Four Stages

| Stage | Trigger | What happens |
|---|---|---|
| 1 — Lib Test | Push to `main` | `pip install -e .` + tests |
| 2 — TestPyPI | Git tag `v*` | Build package, upload to TestPyPI |
| 3 — Integration | After TestPyPI | Fresh venv, package from TestPyPI, okw-examples tests |
| 4 — PyPI + GitHub | Stage 3 green | Publish to PyPI, push GitHub mirror |
