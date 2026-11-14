# STATE
updated: 2026-11-14

## Goal
- Git-based, token-cheap memory for coding agents; installed from github.com/<owner>/mnemonic

## Current
- Paused after v0.0.6; repo private; resume guide: CONTINUE.md
- 0.0.6 tests in README: -36% tokens at 24K history; resume with/without 5/5 vs 3/5

## Next
1. v0.0.7 fixes from 0.0.6 tests: check info before first commit; INDEX template wording (auto lookup); amend counted by hook; 6 sections mandatory in protocol; staged STATE.md not stale; start prompt for non-GitHub remotes; no counters in STATE
2. Multi-day real project and parallel sessions test (install in <owner>/test-repo)
3. Private repo breaks raw URLs: install by clone or make public again

## Decisions
- Single STATE.md, no history file -> fixed cost; git log is history
- Long-term memory on demand via memory/INDEX.md -> zero cost when unused
- Prefs + protocol in AGENTS.md; CLAUDE.md imports AGENTS.md + STATE.md -> loaded at start, no extra reads
- Telegraphic English, lists not tables -> fewest tokens, still human-readable
- No vendor names except required adapter filename -> user rule
- mn in POSIX sh -> runs anywhere with git
- Hosted on GitHub (public repo, raw files, tags pin versions) -> no server; publish = push
- Shared memory default in-repo (shared/<name>, link 'self'); other repos link owner/repo#shared/<name>; separate hub optional
- Long-term memory searched automatically when STATE.md lacks a fact -> real test missed 3/7 without it
- Session cache first, mnemonic at task ends/sharing/idle gaps -> cache reads cheapest; enforce=task

## Blockers
- Only claude adapter supported for now

## Notes
- Tests: sh tests/test.sh
- Old mirror <own-domain> retired from web01; user removes its DNS record
