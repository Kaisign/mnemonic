# mn CLI

Single POSIX `sh` script. Needs git, awk, sed and grep; `curl` or `wget` only
for `update`. Installed at `.mnemonic/mn`. Its purpose is to replace file
reads with short outputs: checking the state through `mn check` costs a few
lines instead of reading and comparing several files.

The repository root is `git rev-parse --show-toplevel`, or the current
directory, or `MN_DIR` / `--dir`.

## Commands
### `mn init [options]`
Installs or updates the system. Options and defaults:
| Option | Values | Default |
|---|---|---|
| `--chat-lang` | any | en |
| `--work-lang` | any | en |
| `--commits` | grouped, atomic, manual | grouped |
| `--brand-refs` | none, allowed | none |
| `--code` | on-request, proactive | on-request |
| `--priority` | savings, balanced, quality | savings |
| `--docs` | full, minimal, none | full |
| `--tone` | direct-humor, direct, formal | direct-humor |
| `--agents` | comma list: claude | claude |
| `--dir` | path | repo root |

Options are validated before anything is written. Choices are saved in
`.mnemonic/config`; a later `mn init` starts from them, so pass only what
changes. Behaviour on existing
files is described in [architecture.md](architecture.md#idempotency).

### `mn check`
Exit 0 when clean, 1 with warnings. Checks:
- STATE.md exists; size estimate `bytes / 4` within `MN_MAX_TOKENS` (1500).
- Section caps (Goal 3, Current 5, Next 7, Decisions 10, Blockers 5, Notes 5).
- All six sections present.
- Staleness: commits since the last commit touching STATE.md.
- Uncommitted STATE.md changes (info only).
- Memory index consistency in both directions.

### `mn mem list | find <words> | show <topic> | add <topic> "<keywords>" "<summary>"`
- `list`: index entries.
- `find`: case-insensitive search of the index; several words match any
  (OR). Exit 1 when nothing matches. Never opens topic files.
- `show`: prints one topic file.
- `add`: appends the index line and creates the topic file with a header.
  Rejects duplicates, invalid names and the reserved name `INDEX`.

### `mn sub ...` (shared memory)
| Command | Effect |
|---|---|
| `sub link <name> <repo>[#folder] ["desc"]` | Add to `.mnemonic/links`, clone, create submonic if missing, push, re-render AGENTS.md |
| `sub unlink <name>` | Remove the link, re-render AGENTS.md |
| `sub list` | Links with topic counts |
| `sub sync [name]` | Clone or pull caches |
| `sub find <words>` | Search all linked indexes (OR, case-insensitive); exit 1 when no match |
| `sub show <name>/<topic>` | Print one topic |
| `sub add <name> <topic> "<kw>" "<summary>"` | Create topic, commit, push |
| `sub path <name>` | Local folder to edit topic files |
| `sub save <name> ["msg"]` | Commit that folder and push, rebasing on concurrent writes |

Details: [shared.md](shared.md).

### `mn update`
Downloads `$MN_URL/mn` (default `https://<own-domain>/mn`),
verifies the shebang and replaces `.mnemonic/mn`.

### `mn version`, `mn help`

## Environment
| Variable | Default | Use |
|---|---|---|
| `MN_MAX_TOKENS` | 1500 | STATE.md budget for `check` |
| `MN_URL` | https://<own-domain> | Source for `update` |
| `MN_DIR` | repo root | Target directory |

## Tests
`sh tests/test.sh` runs the suite in temporary repositories: fresh install,
idempotent re-init, preference persistence, merging with existing files,
option validation, every `check` rule, every memory command, and shared
memory with two repositories writing concurrently to one hub.
