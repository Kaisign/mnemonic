# STATE
updated: 2026-11-14

## Goal
- Choose hosting for the booking app: A (self-managed VPS) vs B (managed platform); costs in EUR/month

## Current
- Inputs collected and corrected; final totals pending

## Next
1. Monthly totals, yearly difference
2. Scenario: traffic doubles

## Decisions
- A: VPS 40 + backups 12 (corrected from 8) + admin 1 h x 30 (reduced from 2 h by automation); unlimited traffic
- B: plan 65 incl. backups, maintenance, DB up to 10 GB; egress 100 GB free then 0.05/GB
- Expected traffic 300 GB/month
- Ignored (same for both): domain, email, CDN; DB 3 GB fits both

## Blockers
- (none)

## Notes
- (none)
