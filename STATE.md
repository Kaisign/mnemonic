# STATE
updated: 2026-11-14

## Goal
- Git-based, token-cheap memory for coding agents; installed via <own-domain>

## Current
- v0.4.0: everything in one repo (shared/ submonics, artifacts/), automation hooks, auto memory lookup; 101 tests pass
- v0.2.0 shared memory (mn sub) untested with a real hub
- Real-data test (local only, no data in repo): replay -19% tokens, +2% USD in-session; resumes after cache expiry -80% cost; Q&A -40% tokens, 14/14 with automatic memory lookup (11/14 before)

## Next
1. Test install in <owner>/test-repo from a fresh session (incl. shared memory step)
2. Sistemas links mnemonic-test#shared/infra and records web01/DNS facts
3. Optional: benchmark at 50K+ history and with a larger model

## Decisions
- Single STATE.md, no history file -> fixed cost; git log is history
- Long-term memory on demand via memory/INDEX.md -> zero cost when unused
- Preferences inside AGENTS.md -> no extra read
- CLAUDE.md imports AGENTS.md + STATE.md -> loaded at start, no tool call
- Telegraphic English, lists not tables -> fewest tokens, still human-readable
- No vendor names except required adapter filename -> user rule
- mn in POSIX sh -> runs anywhere with git
- Self-hosted nginx + Let's Encrypt, cron git pull every 5 min -> publish = push to main
- Shared memory default in-repo (shared/<name>, link 'self'); other repos link owner/repo#shared/<name>; separate hub optional
- Long-term memory searched automatically when STATE.md lacks a fact -> real test missed 3/7 without it

## Blockers
- Only claude adapter supported for now

## Notes
- Tests: sh tests/test.sh
- Webroot: /var/www/html/<own-domain> on web01 (<server-ip>)
