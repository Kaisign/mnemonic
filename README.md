# mnemonic

> Agents: to install, follow [install.md](install.md)
> (raw: https://raw.githubusercontent.com/<owner>/mnemonic/main/install.md).
> To start a session on a repository that already uses mnemonic, follow
> [start.md](start.md).

Git-based, token-cheap memory for coding agents.

A session resumes work by reading two small files that load automatically:
preferences plus protocol (`AGENTS.md`) and the live state (`STATE.md`).
Long-term knowledge sits in `memory/` and is read only on request, through
an index. Optional shared memory (submonics) lets sessions in different
repositories share knowledge through a common git repository. History is `git log`. Estimated savings: ~40% tokens and ~28% cost
per month of typical work ([docs/savings.md](docs/savings.md)).

## Install
In an agent session, say:
```
Read https://github.com/<owner>/mnemonic and install it in owner/name
```
The agent asks for the target repository and your preferences, installs the
files, fills the initial state, commits and pushes, and hands you a start
link for later sessions on that repository:
```
Read https://github.com/<owner>/mnemonic/blob/main/start.md and work on owner/name
```

Manual install from a repository root:
```
curl -fsSL https://raw.githubusercontent.com/<owner>/mnemonic/main/mn -o /tmp/mn
sh /tmp/mn init --chat-lang es
```

## What gets installed
```
AGENTS.md          preferences + memory protocol (marked block)
CLAUDE.md          adapter: @AGENTS.md @STATE.md
STATE.md           live state, ~1500 token budget
memory/INDEX.md    long-term memory index (on demand)
memory/<topic>.md  long-term topics (on demand)
.mnemonic/mn       CLI
.mnemonic/README.md user guide
.mnemonic/config   saved preferences
.mnemonic/links    linked shared memories (optional)
```

## How it works
1. Session start: AGENTS.md and STATE.md are already in context; no
   exploration of what the state answers.
2. Work as usual; recorded decisions are not reopened without new facts.
3. Before the final commit: STATE.md is rewritten (not appended) within
   per-section caps, valuable pruned knowledge goes to `memory/`, `mn check`
   validates, STATE.md is committed with the work.

## CLI
```
mn init [options]      install or change preferences
mn check               size, caps, staleness, index integrity
mn mem list|find|show|add
mn sub link|find|show|add|save|sync|list|unlink   shared memory
mn archive <topic>     move a memory topic out of the index
mn status              one-screen summary
mn update              fetch the latest mn
```

## Test results (0.0.6)
Measured on 2026-11-14 with small-model and mid-size-model subagents
(details: [tests/bench/RESULTS.md](tests/bench/RESULTS.md)).

Resume benchmark (22 runs; same questions, automatic grading):
| Previous history | Tokens without | Tokens with | Saving | Correct without | Correct with |
|---|---|---|---|---|---|
| ~0.7K tokens | 66,049 | 65,671 | 1% | 16/16 | 16/16 |
| ~5K tokens | 72,686 | 65,175 | 10% | 16/16 | 16/16 |
| ~15K tokens | 88,759 | 66,118 | 26% | 16/16 | 16/16 |
| ~24K tokens (real session) | 106,603 | 68,163 | 36% | 14/14 | 14/14 |

End to end:
- Install from GitHub into an empty repository: succeeded first time
  (configured author enforced over a foreign git identity, first commit and
  push without prompts).
- Work session with five user messages and changing decisions: five commits,
  STATE.md and a memory topic kept current; the hooks blocked twice (3
  commits without a state update, missing sections) and the agent complied.
- Resuming in a fresh session, with vs without mnemonic (same code and git
  history): 5/5 vs 3/5 questions answered; without memory no agent knew the
  rejected alternative or the planned task. Tokens were equal (~69K) on this
  ~150-line project; one agent without rules added an AI co-author trailer.
- Real development session replay: resuming after the prompt cache expired
  cost about 80% less with STATE.md; inside a live session the money saving
  was negligible (cache reads are already cheap).

Conclusion: the main value is keeping what code does not record (decisions,
reasons, plans) and enforcing discipline automatically; token savings grow
with history length and matter most when resuming long projects.

## Documentation
- [How it works](docs/how-it-works.md): plain-language overview with diagram
- [Architecture](docs/architecture.md): files, loading, design decisions
- [STATE.md](docs/state.md): format, caps, lifecycle, staleness
- [Long-term memory](docs/memory.md): index, access rule, filling
- [Shared memory](docs/shared.md): submonics, hub, concurrent writes
- [Automation](docs/automation.md): hooks that keep memory current without user action
- [CLI](docs/cli.md): commands, options, environment, tests
- [Installer and hosting](docs/installer.md): bootstrap flow, server
- [Savings](docs/savings.md): estimates and assumptions
- [Changelog](CHANGELOG.md): versions
- [CONTINUE.md](CONTINUE.md): how to resume this project
- [Benchmark](tests/bench/README.md): measured results in [tests/bench/RESULTS.md](tests/bench/RESULTS.md)

## Repository layout
```
install.md   installer prompt
start.md     session start prompt
mn           CLI (downloaded from raw.githubusercontent.com)
tests/       test suite (sh tests/test.sh)
docs/        documentation
```
This repository uses mnemonic itself; see [.mnemonic/README.md](.mnemonic/README.md).
