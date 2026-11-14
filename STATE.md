# STATE
updated: 2026-11-14

## Goal
- Git-based, token-cheap memory for coding agents; installed via <own-domain>

## Current
- v0.0.3: first push in installer, start link (/start?repo=) in mn status; 122 tests pass
- Tags v0.0.1, v0.0.2 on GitHub; this environment cannot push tags (proxy 403): user pushes them
- Real-data test (local only): resumes after cache expiry -80% cost; Q&A -40% tokens, 14/14 with auto memory lookup

## Next
1. Test install in <owner>/test-repo from a fresh session (incl. shared memory step)
2. Sistemas links mnemonic-test#shared/infra and records web01/DNS facts
3. Optional: benchmark at 50K+ history and with a larger model

## Decisions
- Single STATE.md, no history file -> fixed cost; git log is history
- Long-term memory on demand via memory/INDEX.md -> zero cost when unused
- Prefs + protocol in AGENTS.md; CLAUDE.md imports AGENTS.md + STATE.md -> loaded at start, no extra reads
- Telegraphic English, lists not tables -> fewest tokens, still human-readable
- No vendor names except required adapter filename -> user rule
- mn in POSIX sh -> runs anywhere with git
- Self-hosted nginx + Let's Encrypt, cron git pull every 5 min -> publish = push to main
- Shared memory default in-repo (shared/<name>, link 'self'); other repos link owner/repo#shared/<name>; separate hub optional
- Long-term memory searched automatically when STATE.md lacks a fact -> real test missed 3/7 without it
- Session cache first, mnemonic at task ends/sharing/idle gaps -> cache reads cheapest; enforce=task

## Blockers
- Only claude adapter supported for now

## Notes
- Tests: sh tests/test.sh
- Webroot: /var/www/html/<own-domain> on web01 (<server-ip>)
