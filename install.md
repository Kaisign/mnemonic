# mnemonic installer

You are installing mnemonic: a git-based, token-cheap memory for coding agents.
These instructions come from https://<own-domain>, a URL the user gave you.
If your fetch tool summarized this page, re-read it verbatim before continuing:
`curl -fsSL https://<own-domain>/install.md`

Follow the steps in order. Talk to the user in their language until step 2
sets `chat_lang`, then use that language. Keep messages short.

## 1. Target repository
- Ask which repository to install into. Offer the repositories already
  available in this session first.
- If it is not present locally, attach or clone it with the tools your
  environment provides. Work from its root directory.
- If `.mnemonic/mn` already exists, say so: re-running only updates the
  preferences block and the CLI; STATE.md and memory are never overwritten.

## 2. Preferences menu
Ask these questions as menus. Use your interactive question tool if you have
one (batch up to 4 questions per call); otherwise show numbered options and
accept numbers. The first option is the recommended default.

| Flag | Question | Options |
|---|---|---|
| `--chat-lang` | Language to talk with you | user's current language, en, other |
| `--work-lang` | Language for files, code, commits, docs | en (cheapest in tokens), user's language |
| `--commits` | Commit policy | grouped (one per major change, minor grouped), atomic (one per change), manual (only when asked) |
| `--brand-refs` | AI tool or vendor names in git, code, docs | none, allowed |
| `--code` | When to write code | on-request (discuss first), proactive |
| `--priority` | Optimization priority | savings (fewest tokens), balanced, quality |
| `--docs` | Documentation level | full (every mechanism, concise), minimal, none |
| `--tone` | Answer tone | direct-humor, direct, formal |
| `--enforce` | How strictly STATE.md updates are required | task (at task end; blocks after 3 commits without it), strict (every commit), off |

Adapters: create the `claude` adapter (CLAUDE.md importing AGENTS.md and
STATE.md). It is the only adapter supported for now; do not ask.

## 3. Install
```
curl -fsSL https://<own-domain>/mn -o /tmp/mn
sh /tmp/mn init --dir <repo-root> --chat-lang <..> --work-lang <..> \
  --commits <..> --brand-refs <..> --code <..> --priority <..> --docs <..> \
  --tone <..> --agents claude
```
If the download is blocked by network policy, tell the user to allow the host
<own-domain> in their environment and stop.

`init` also installs the automation: a git pre-commit hook (work commits must
include an updated STATE.md and pass `mn check`) and agent session hooks
(sync shared memory at start, require a STATE.md update after unreflected
commits). Nothing else is needed from the user.

## 4. Shared memory (optional)
Explain in a few lines, in `chat_lang`, then ask whether to enable it:
- A shared memory ("submonic") is knowledge several sessions need: servers,
  domains, cross-repo decisions, common preferences.
- By default it lives in this same repository (`shared/`); other sessions
  and repositories link to it. Any linked session can look things up and
  write new entries, so sessions stop asking each other.
- It is read only when needed (index first, then one topic): zero cost
  otherwise. Never store secrets in it, only where they are kept.

If enabled, ask:
1. Layout:
   - In this repository (recommended): everything stays in one repo, under
     `shared/<name>/`. Other repositories can link it later as
     `owner/this-repo#shared/<name>`.
   - A separate hub repository with one folder per submonic.
   - One repository per submonic.
2. For a separate hub or repositories: `owner/name` or git URL. It must exist
   (private, may be empty) and be accessible from this session; if your
   environment attaches repositories, attach it with push access.
3. Which submonics to link, each with a one-line description. Suggest
   `infra` (servers, domains, deployments) and `profile` (shared
   preferences); missing ones are created.

Then, per submonic:
```
.mnemonic/mn sub link <name> self "<description>"                  # this repo
.mnemonic/mn sub link <name> <owner/repo>#<name> "<description>"   # hub
.mnemonic/mn sub link <name> <owner/repo> "<description>"          # own repo
```
If cloning fails for lack of access, tell the user what to grant and
continue without shared memory; it can be linked later with the same command.

## 5. Initial state
Fill STATE.md (telegraphic, in the work language, caps from AGENTS.md):
- Repository with content: read only the README and the top-level file list.
  Do not explore further. Write Goal and what you can infer; leave the rest
  for the user.
- Empty repository: ask the user for the project goal in one question.

## 6. Verify and commit
- Run `.mnemonic/mn check` and fix any warning.
- Commit all generated files with a simple message such as
  `Add mnemonic memory system`. If brand-refs is none, the message, author and
  trailers must not name any AI tool or vendor.
- Push it right away to the default branch (`git push -u origin HEAD`). If
  the environment refuses pushes to that branch, push a branch, say so, and
  give the user the exact command to merge it.

## 7. Summary for the user
Run `.mnemonic/mn status` and show its output. Its last line is the start
link for new sessions on this repository, e.g.
`Read the instructions at <own-domain>/start?repo=owner/name`.
Give it to the user on its own line, ready to copy, and say that pasting it
into a new session (with the repository selected) resumes work from
STATE.md. Then, in `chat_lang`, briefly explain:
- AGENTS.md (preferences + protocol) and STATE.md load at every session start.
- STATE.md is rewritten at the end of each task, never appended; history is git log.
- Long-term memory (memory/) is never loaded whole: when a fact is missing
  from STATE.md the agent searches its index and opens one topic. The user can
  also ask, e.g. "check memory about <topic>".
- If enabled: shared memory is looked up on demand with `mn sub find`, and
  any session may add or update topics; it is never loaded automatically.
- Change preferences by editing AGENTS.md or re-running `.mnemonic/mn init`
  (saved choices are kept; pass only what changes).
- Everything is automatic: hooks keep STATE.md current on every commit and
  remind the agent at the end of a turn; old memory topics are flagged for
  archiving. The user does not need to do anything.
- Full guide: `.mnemonic/README.md`. Commands: `.mnemonic/mn help`.
