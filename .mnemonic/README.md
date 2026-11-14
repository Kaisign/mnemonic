# Memory system (mnemonic)

This repository keeps its working memory in git so that any session can resume
work by reading a few small files instead of re-exploring the code or replaying
old conversations.

## Files
| File | Loaded | Purpose |
|---|---|---|
| AGENTS.md | every session | Preferences and the memory protocol, between `mnemonic:begin/end` markers. Content outside the markers is yours. |
| CLAUDE.md | every session | Adapter for agents that do not read AGENTS.md natively. It only imports `@AGENTS.md` and `@STATE.md`, so both load at start without extra reads. |
| STATE.md | every session | Live state: Goal, Current, Next, Decisions, Blockers, Notes. Rewritten, never appended. Budget ~1500 tokens. |
| memory/INDEX.md | on demand | One line per long-term topic: name, keywords, summary. |
| memory/<topic>.md | on demand | Long-term knowledge: architecture, old decisions, failed approaches, domain context. |
| .mnemonic/mn | never (run) | Helper CLI. |

## How a session works
1. Start: AGENTS.md and STATE.md are already in context. The agent works from
   STATE.md and does not re-explore what it already answers.
2. Work: as usual. Recorded decisions are not reopened without new facts.
3. Close: the agent rewrites STATE.md (finished items removed, caps respected),
   moves valuable pruned knowledge to long-term memory, runs `mn check` and
   commits STATE.md with the work.

History lives in `git log`; STATE.md only describes the present and the next
steps, so its size, and its cost per session, stays constant.

## Using long-term memory
It is never read automatically. Ask for it explicitly, e.g.
"check memory about authentication". The agent then reads only the index (or
runs `mn mem find`) and opens the single matching topic file.

## Commands
```
.mnemonic/mn check                  validate size, caps, staleness, index
.mnemonic/mn mem list               show the index
.mnemonic/mn mem find <words>       search the index
.mnemonic/mn mem show <topic>       print one topic
.mnemonic/mn mem add <topic> "<keywords>" "<summary>"
.mnemonic/mn init [options]         re-run to change preferences
.mnemonic/mn update                 fetch the latest mn
```

## Shared memory (optional)
Submonics are shared memories kept in another git repository (usually one
private hub with a folder per submonic). Every linked session can read and
write them; they are read only when needed. Linked submonics are listed in
`.mnemonic/links` and summarized in AGENTS.md.
```
.mnemonic/mn sub link infra owner/hub#infra "servers, domains"
.mnemonic/mn sub find <words>         search all linked indexes
.mnemonic/mn sub show infra/<topic>   read one topic
.mnemonic/mn sub add infra <topic> "<keywords>" "<summary>"
.mnemonic/mn sub save infra "<message>"   after editing in $(mn sub path infra)
```
Never store secrets in shared memory; only where they are kept.

## Automation
- Git pre-commit hook (`.mnemonic/hooks`, enabled through core.hooksPath):
  rejects commits that change work files without STATE.md, or that fail
  `mn check`. Bypass once with `MN_SKIP=1 git commit ...`.
- Agent hooks (`.claude/settings.json`): at session start they re-enable the
  git hook in fresh clones, sync shared memory and report problems; at the
  end of each turn they save shared memory edits and ask the agent to update
  STATE.md if commits were made without it.
- `mn check` flags memory topics not updated in 90 days; `mn archive <topic>`
  moves one out of the index (still in git).
- `mn status` prints a one-screen summary.

## Changing preferences
Edit the Preferences list in AGENTS.md, or re-run `mn init` with only the
options that change (`.mnemonic/mn help`); other choices are kept from
`.mnemonic/config`. Re-running only replaces the marked block; STATE.md and
memory are never overwritten.

## Uninstall
Delete `.mnemonic/`, `memory/`, `STATE.md`, the marked block in AGENTS.md,
the two import lines in CLAUDE.md and the `.mnemonic/cache/` line in
.gitignore. Shared memory repositories are not touched.
