# STATE
updated: 2026-11-14

## Goal
- Release pipeline for ledger-api (Node + Postgres), same pipeline for staging and production

## Current
- Pipeline steps defined; CI configuration not started

## Next
1. Write CI configuration

## Decisions
- Steps: build, migrate, test, deploy, smoke test, notify #releases -> integration tests need the schema
- Port 9090 -> metrics agent uses 8080
- Image node:22-slim, multi-stage -> bcrypt is native
- Health: /healthz, /readyz; smoke test polls /readyz every 5 s, 120 s timeout
- Rollback: keep 5 releases (compliance), automatic on smoke test failure
- Migrations must ship down scripts -> safe automatic rollback
- Regions: staging eu-west-1, production eu-central-1 (data residency)

## Blockers
- (none)

## Notes
- Logging library decided: see memory topic logging
