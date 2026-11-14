# Automation

Goal: after installation the user does nothing. Memory stays current because
git and the agent's hooks require it, not because someone remembers. The
session's own prompt cache stays the main working memory; mnemonic steps in
at task ends, when a fact is worth sharing, and after long idle gaps.

## Enforcement modes
`mn init --enforce <mode>`, saved as `enforce=` in `.mnemonic/config`:
| Mode | Pre-commit hook | Turn-end hook |
|---|---|---|
| `task` (default) | Blocks once `MN_TASK_COMMITS` (3) work commits pile up without a STATE.md update | Asks for a STATE.md update at the same limit |
| `strict` | Every work commit must include STATE.md | Asks after any unreflected commit |
| `off` | Never requires STATE.md | Never asks |
In every mode a commit that stages STATE.md must pass `mn check`.

## 1. Git pre-commit hook (any agent)
File: `.mnemonic/hooks/pre-commit`, enabled with
`git config core.hooksPath .mnemonic/hooks` by `mn init` (and again at
session start, since fresh clones do not keep local git config).

On every commit:
1. Work files are anything except STATE.md, memory/, shared/, .mnemonic/,
   AGENTS.md, CLAUDE.md, .claude/ and .gitignore. If they are staged without
   STATE.md, the mode decides (table above).
2. If STATE.md is staged it runs `mn check --pre-commit` (size, caps,
   sections, memory index); any warning rejects the commit.
3. A pre-existing `.git/hooks/pre-commit` still runs first.

Bypass once: `MN_SKIP=1 git commit ...`. If `core.hooksPath` already points
elsewhere, init warns instead of overriding it.

## 2. Agent hooks (adapter)
File: `.claude/settings.json` (merged into an existing file; needs python3
for merging, otherwise a warning and `mn hook settings` prints the block).

| Event | Command | Effect |
|---|---|---|
| Session start | `mn hook start` | Re-enables the git hook, syncs shared memory, prints only problems (WARN/FAIL) into the agent's context. Silent when clean. |
| Each user prompt | `mn hook prompt` | Cache-expiry advisor (below). Silent unless it applies. |
| End of each turn | `mn hook stop` | Records the time, saves pending external shared memory edits (commit + push), and asks for a STATE.md update when unreflected commits reach the mode's limit. Never blocks twice in a row (`stop_hook_active`). |

Uncommitted work does not trigger the turn-end hook; the pre-commit hook
covers it at commit time. Compaction needs no hook: AGENTS.md and STATE.md
are imports, reloaded after compaction.

## Cache-expiry advisor
The prompt cache expires after about an hour. Resuming a long conversation
after that re-writes its whole context to cache (in the real-data test, 112K
to 143K tokens per resume, about $1 each), while a new session starts from
STATE.md. When the gap since the last turn exceeds `MN_CACHE_TTL` (3600 s)
and the transcript is over `MN_RESUME_WARN` (50,000 estimated tokens), the
prompt hook tells the agent to report it in one line and ask the user:
continue here, or update STATE.md and open a new session. Once per gap.

## Session economy rules
Written into AGENTS.md so every session follows them:
- Stay in one session while the task lasts; its prompt cache is the cheapest context.
- Do not re-read files already in context; delegate heavy reading to subagents.
- Compact only at a task boundary, right after updating STATE.md.
- Record facts other sessions need in shared memory as soon as they are learned.
- After a long idle gap in a long conversation, offer a fresh session from STATE.md.

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
mnemonic 0.0.2 in my-project
preferences: chat es, work en, commits grouped, ...
state:       STATE.md ~310/1500 tokens, loaded every session
memory:      2 topic(s), read on demand; 1 archived
shared:      infra profile (on demand, all sessions write)
automation:  git pre-commit on (task mode), agent session hooks on
commands:    .mnemonic/mn help    guide: .mnemonic/README.md
```

## Cost
Hooks run locally and print nothing when everything is in order, so they
add no tokens to a healthy session. A blocked commit or stop costs one short
message and one STATE.md rewrite, which the protocol requires anyway.
