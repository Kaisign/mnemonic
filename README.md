# mnemonic

Git-based, token-cheap memory for coding agents.

A session resumes work by reading two small files that load automatically:
preferences plus protocol (`AGENTS.md`) and the live state (`STATE.md`).
Long-term knowledge sits in `memory/` and is read only on request, through
an index. History is `git log`. Estimated savings: ~40% tokens and ~28% cost
per month of typical work ([docs/savings.md](docs/savings.md)).

## Install
In an agent session, say:
```
Read the instructions at <own-domain>
```
The agent asks for the target repository and your preferences, installs the
files, fills the initial state, commits and explains how to use it.

Manual install from a repository root:
```
curl -fsSL https://<own-domain>/mn -o /tmp/mn
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
mn update              fetch the latest mn
```

## Documentation
- [Architecture](docs/architecture.md): files, loading, design decisions
- [STATE.md](docs/state.md): format, caps, lifecycle, staleness
- [Long-term memory](docs/memory.md): index, access rule, filling
- [CLI](docs/cli.md): commands, options, environment, tests
- [Installer and hosting](docs/installer.md): bootstrap flow, server
- [Savings](docs/savings.md): estimates and assumptions
- [Benchmark](tests/bench/README.md): measured results in [tests/bench/RESULTS.md](tests/bench/RESULTS.md)

## Repository layout
```
install.md   installer prompt, served at the domain root
mn           CLI, served at /mn
tests/       test suite (sh tests/test.sh)
docs/        documentation
```
This repository uses mnemonic itself; see [.mnemonic/README.md](.mnemonic/README.md).
