---
source_hash: 1f1584a454cb
---

# Combining Libraries

!!! info "Work in progress"
    This chapter is still being written.

## Overview

OKW shows its strength when several libraries work together in one test.
All OKW libraries share the same keyword philosophy and combine
seamlessly.

## Typical Combinations

| Combination | Use case |
|---|---|
| Docker + Web Selenium | Start container, test web application |
| REST API + Web Selenium | Create test data via API, verify UI |
| Kafka + REST + GUI | Send message, verify API processing, verify result in GUI |
| SSH + GUI | Configure server, verify the effect in the application |
| Proxmox + Docker + GUI | Provision VM, start container, test application |
