# Shared memory (submonics)

Knowledge several sessions need, kept in a separate git repository that
every linked session can read and write. Typical content: infrastructure
(servers, domains, deployments), decisions that span several repositories,
common preferences. It replaces messages between sessions: instead of asking
another session, look it up.

## Layout
Default: inside the repository where mnemonic is installed, so everything
lives in one repo:
```
my-project/
  STATE.md  memory/      project memory
  shared/infra/          submonic linked as `self`
  shared/profile/
  artifacts/             generated deliverables
```
`.mnemonic/links`: `infra = self | servers, domains`. Writes are commits in
this repository (only the submonic folder), pushed with the normal work; the
pre-commit hook does not require STATE.md for `shared/` changes. Sessions on
other repositories link it as `owner/my-project#shared/infra`.

Alternative: a separate hub repository, one folder per submonic.
```
mnemonic-hub/
  README.md          generated on first use
  infra/
    INDEX.md         - web01: server ip nginx webroot - Main VPS and services
    web01.md
  profile/
    INDEX.md
```
Option: one repository per submonic, with INDEX.md at its root. Both styles
can be mixed. Topic files use the same header and telegraphic style as local
long-term memory ([memory.md](memory.md)).

## Linking
`.mnemonic/links` (committed), one line per submonic:
```
infra   = owner/hub#infra | servers, domains, deployments
profile = owner/hub#profile | shared preferences
other   = git@host:team/other-memory.git | something else
```
- `owner/name` means a GitHub repository; any git URL or local path works.
- `#folder` selects a folder inside the repository; omitted means the root.
- The description after `|` is rendered into the AGENTS.md block (one line
  per submonic), so the agent knows what exists without reading anything.

`mn sub link` writes the line, clones the repository, creates the folder and
its INDEX.md if missing (plus the hub README), pushes, and re-renders
AGENTS.md. `mn sub unlink` removes the line and re-renders.

## Local cache
Repositories are cloned into `.mnemonic/cache/<url-slug>/`, ignored by git
(`mn init` adds the rule). One clone per repository, however many
submonics it holds. Clones take the author name and email of the host
repository, so shared commits follow the same identity rules.

## Reading (when needed)
The agent searches shared memory when a fact is in neither STATE.md nor local
memory, or when the user asks.
- `mn sub find <words>`: searches the INDEX.md of every linked submonic,
  prints `name/topic: keywords - summary`. Clones missing caches; prints an
  info line when a cache is older than one day (`mn sub sync` refreshes).
- `mn sub show <name>/<topic>`: prints one topic.
Never loaded at session start; cost is zero until used.

## Writing (every session may write)
- New topic: `mn sub add <name> <topic> "<keywords>" "<summary>"` pulls,
  appends the index line, creates the file, commits and pushes.
- Edit: change the file in `$(mn sub path <name>)`, then
  `mn sub save <name> "<message>"` commits only that submonic's folder and
  pushes.
- Concurrency: before each push mn rebases on the latest remote state and
  retries up to three times. Different topics or different lines merge
  cleanly; one line per fact keeps that the common case. A conflict on the
  same line stops with a message instead of guessing.

## Rules
- Shared facts only; per-repository state stays in that repository's
  STATE.md.
- No secrets. Write where a secret is kept, never its value.
- Keep entries current: update the topic and its `updated:` line when a fact
  changes, instead of adding a contradicting line.

## Access
The hub should be private. Every session needs read and push access to it;
in cloud sessions the repository must be attached to the session.
