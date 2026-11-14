# Changelog

## 0.0.5
- Session start pulls other sessions' pushes (`git pull --rebase`) when the
  tree is clean and has an upstream; reports pulled commits and asks to
  re-read STATE.md when it changed; warns instead of pulling with local
  changes, and aborts a failed rebase.

## 0.0.4
- Git author for all commits: asked by the installer, saved in
  `.mnemonic/config` (`--author-name`, `--author-email`), applied to the
  clone and shared memory clones, re-applied at session start, enforced by
  the pre-commit hook.
- `mn publish`: commits the mnemonic files and pushes without prompts; the
  installer runs it for the first commit (no confirmation).

## 0.0.3
- The installer pushes the first commit instead of asking.
- Start link for new sessions on an installed repository:
  `<own-domain>/start?repo=owner/name` (served `start.md`; the
  repository comes from the link). Printed by `mn status` and handed over at
  the end of the installation.

## 0.0.2
- Enforcement modes for STATE.md updates: `task` (default; blocks after 3
  work commits without an update), `strict`, `off` (`mn init --enforce`).
- Cache-expiry advisor: after an idle gap over the cache TTL in a long
  conversation, the agent offers a fresh session from STATE.md
  (`mn hook prompt`, UserPromptSubmit).
- Session economy rules in the protocol: stay in one session per task, no
  re-reads, compact at task boundaries, share facts when learned.
- Agent hook installation adds only missing events (safe upgrades).
- In-repo shared memory changes no longer count as work for the hook.

## 0.0.1
- STATE.md protocol, long-term memory with index and automatic lookup.
- Shared memory (submonics): in-repo (`shared/`), separate hub or one repo
  per submonic; concurrent writes with rebase.
- `artifacts/` for generated deliverables.
- Automation: git pre-commit hook, agent session hooks, `mn archive`,
  `mn status`; persistent preferences in `.mnemonic/config`.
- Installer prompt served at <own-domain>; benchmark suite with
  charts and PDF report.
