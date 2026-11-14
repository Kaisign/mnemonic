# Changelog

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
