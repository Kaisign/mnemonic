# STATE
updated: 2026-11-14

## Goal
- Git-based, token-cheap memory for coding agents; installed via <own-domain>

## Current
- v0.1.0 published (/, /install.md, /mn); install untested in a real session
- Benchmark tests/bench: 16/16 both conditions, memory context -60%, agent tokens -1% (fixed overhead dominates short sample)

## Next
1. Test install in <owner>/test-repo from a fresh session
2. Long-transcript benchmark variant to show agent-level savings (pending user)
3. Continuity test: second session resumes from STATE.md

## Decisions
- Single STATE.md, no history file -> fixed cost; git log is history
- Long-term memory on demand via memory/INDEX.md -> zero cost when unused
- Preferences inside AGENTS.md -> no extra read
- CLAUDE.md imports AGENTS.md + STATE.md -> loaded at start, no tool call
- Telegraphic English, lists not tables -> fewest tokens, still human-readable
- No vendor names except required adapter filename -> user rule
- mn in POSIX sh -> runs anywhere with git
- Self-hosted nginx + Let's Encrypt, cron git pull every 5 min -> publish = push to main

## Blockers
- Only claude adapter supported for now

## Notes
- Tests: sh tests/test.sh
- Webroot: /var/www/html/<own-domain> on web01 (<server-ip>)
