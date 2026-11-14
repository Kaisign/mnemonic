# Automation

Goal: after installation the user does nothing. Memory stays current because
git and the agent's hooks require it, not because someone remembers.

## 1. Git pre-commit hook (any agent)
File: `.mnemonic/hooks/pre-commit`, enabled with
`git config core.hooksPath .mnemonic/hooks` by `mn init` (and again at
session start, since fresh clones do not keep local git config).

On every commit:
1. If the commit stages work files (anything except STATE.md, memory/,
   .mnemonic/, AGENTS.md, CLAUDE.md, .claude/, .gitignore) but not
   STATE.md, it is rejected with instructions to rewrite and stage STATE.md.
2. Otherwise it runs `mn check --pre-commit` (size, caps, sections, memory
   index); any warning rejects the commit.
3. A pre-existing `.git/hooks/pre-commit` still runs first.

Bypass once: `MN_SKIP=1 git commit ...`. If `core.hooksPath` already points
elsewhere, init warns instead of overriding it.

## 2. Agent hooks (adapter)
File: `.claude/settings.json` (merged into an existing file; needs python3
for merging, otherwise a warning and `mn hook settings` prints the block).

| Event | Command | Effect |
|---|---|---|
| Session start | `mn hook start` | Re-enables the git hook, syncs shared memory, prints only problems (WARN/FAIL) into the agent's context. Silent when clean. |
| End of each turn | `mn hook stop` | Saves pending shared memory edits (commit + push). If commits exist after the last STATE.md commit, blocks the stop with an instruction to rewrite and commit STATE.md. Never blocks twice in a row (`stop_hook_active`). |

Uncommitted work does not trigger the turn-end hook; the pre-commit hook
covers it at commit time. Compaction needs no hook: AGENTS.md and STATE.md
are imports, reloaded after compaction.

## 3. Pruning
- `mn check` prints an info line for memory topics whose `updated:` date is
  older than `MN_STALE_DAYS` (default 90).
- `mn archive <topic>` moves the file to `memory/archive/` and removes its
  index line. History and content stay in git; reading cost drops to zero.
- STATE.md pruning is enforced by the caps in `mn check`, which the
  pre-commit hook runs.

## 4. Summary
`mn status`, printed at the end of `mn init` and shown by the installer:
```
mnemonic 0.3.0 in my-project
preferences: chat es, work en, commits grouped, ...
state:       STATE.md ~310/1500 tokens, loaded every session
memory:      2 topic(s), read on demand; 1 archived
shared:      infra profile (on demand, all sessions write)
automation:  git pre-commit on, agent session hooks on
commands:    .mnemonic/mn help    guide: .mnemonic/README.md
```

## Cost
Hooks run locally and print nothing when everything is in order, so they
add no tokens to a healthy session. A blocked commit or stop costs one short
message and one STATE.md rewrite, which the protocol requires anyway.
