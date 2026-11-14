# Architecture

## Goal
Let any session resume work on a repository by reading a few small, bounded
files instead of re-exploring code or replaying conversations. Every design
choice is judged by tokens read per session.

## Files installed in a target repository
| File | When it is read | Owner | Purpose |
|---|---|---|---|
| `AGENTS.md` | every session (auto) | mnemonic block + user | Preferences and memory protocol inside `<!-- mnemonic:begin/end -->`. Everything outside the markers belongs to the user. |
| `CLAUDE.md` | every session (auto) | user + mnemonic lines | Adapter: `@AGENTS.md` and `@STATE.md` imports. |
| `STATE.md` | every session (auto) | agent | Live state. See [state.md](state.md). |
| `memory/INDEX.md` | on request only | agent | Long-term memory index. See [memory.md](memory.md). |
| `memory/<topic>.md` | on request only | agent | Long-term knowledge, one topic per file. |
| `.mnemonic/mn` | executed, not read | mnemonic | CLI. See [cli.md](cli.md). |
| `.mnemonic/config` | by `mn` | mnemonic | Saved preference choices; `mn init` starts from them. |
| `.mnemonic/links` | by `mn` | mnemonic | Linked shared memories. See [shared.md](shared.md). |
| `.mnemonic/cache/` | on request only | mnemonic (git-ignored) | Clones of external shared memory, and `last-turn` (time of the last turn, for the cache-expiry advisor). |
| `.mnemonic/hooks/pre-commit` | by git | mnemonic | Enforces STATE.md updates. See [automation.md](automation.md). |
| `.claude/settings.json` | by the agent | user + mnemonic hooks | Adapter hooks: session start, turn end. |
| `memory/archive/` | never | agent | Archived topics, out of the index. |
| `shared/<name>/` | when needed | all linked sessions | In-repo shared memory (submonics linked as `self`). See [shared.md](shared.md). |
| `artifacts/` | never | agent | Generated deliverables (reports, charts, PDFs, page sources). |
| `.mnemonic/README.md` | by humans | mnemonic | User guide, regenerated on every `mn init`. |
| `README.md` | by humans | user | Gets a short "Memory system" section linking the guide. |

## Loading mechanism
- `AGENTS.md` is the cross-agent convention for repository instructions.
- Agents that do not read it natively get a one-file adapter. The only
  adapter today is `CLAUDE.md`, which uses `@path` imports. Imports are
  expanded when the session starts, so AGENTS.md and STATE.md are in context
  from the first turn with no tool call. Without imports, the protocol tells
  the agent to read STATE.md itself (one extra read).
- Long-term and shared memory are never imported. They are searched
  automatically only when a needed fact is missing from STATE.md (index
  first, then one topic), so their cost is zero until used; only one line per
  linked submonic appears in AGENTS.md.

## Why one STATE.md and no history file
- Everything loaded every session must have a fixed size, or its cost grows
  with project age.
- History already exists, exact and free until queried: `git log`.
- What git does not explain well (why something was decided, what failed)
  goes to the Decisions section while relevant, then to long-term memory.

## Why plain, telegraphic English
- Tokenizers favour common words; abbreviations and custom codes split into
  more tokens and are easier to misread.
- JSON/YAML add quotes, braces and repeated keys.
- English uses roughly 20-30% fewer tokens than Spanish for the same content.
- Humans can read and correct the state, which catches drift early.
- Lists instead of tables: pipes cost tokens.

## Brand neutrality
Generated content names no AI tool or vendor. The only exception is the
adapter filename required by the agent (`CLAUDE.md`), whose content is just
two neutral import lines.

## Idempotency
`mn init` can run any number of times:
- AGENTS.md: the marked block is replaced; content outside is untouched.
- CLAUDE.md: import lines are added only if missing.
- STATE.md, memory/INDEX.md: created only if missing.
- README.md: the memory section is appended only once.
- `.mnemonic/README.md` and `.mnemonic/mn`: overwritten (owned by mnemonic).
