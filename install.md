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

## 4. Initial state
Fill STATE.md (telegraphic, in the work language, caps from AGENTS.md):
- Repository with content: read only the README and the top-level file list.
  Do not explore further. Write Goal and what you can infer; leave the rest
  for the user.
- Empty repository: ask the user for the project goal in one question.

## 5. Verify and commit
- Run `.mnemonic/mn check` and fix any warning.
- Commit all generated files with a simple message such as
  `Add mnemonic memory system`. If brand-refs is none, the message, author and
  trailers must not name any AI tool or vendor.
- Ask before pushing.

## 6. Explain to the user
In `chat_lang`, briefly explain:
- AGENTS.md (preferences + protocol) and STATE.md load at every session start.
- STATE.md is rewritten at the end of each task, never appended; history is git log.
- Long-term memory (memory/) is only read when they ask, e.g.
  "check memory about <topic>"; only the index and one topic are opened.
- Change preferences by editing AGENTS.md or re-running `.mnemonic/mn init`.
- Full guide: `.mnemonic/README.md`. Commands: `.mnemonic/mn help`.
