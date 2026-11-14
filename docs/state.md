# STATE.md

The live state of the project. Loaded every session, so its size is the main
recurring cost of the system.

## Format
```
# STATE
updated: 2026-11-14

## Goal
- Persistent memory for coding agents, stored in git.

## Current
- Installer prompt: written, untested in a real session

## Next
1. Test install in mnemonic-test
2. Measure tokens vs a session without the system

## Decisions
- Single STATE.md, no history file -> fixed cost; git log is history
- English, telegraphic -> fewer tokens

## Blockers
- (none)

## Notes
- Server pulls main every 5 min
```

## Sections and caps
| Section | Max items | Content |
|---|---|---|
| Goal | 3 | What the project is for. Rarely changes. |
| Current | 5 | Work in progress and where it stands. |
| Next | 7 | Ordered next steps. |
| Decisions | 10 | `decision -> reason`, only while still relevant. |
| Blockers | 5 | Open questions, failures to avoid repeating. |
| Notes | 5 | Short facts that save a lookup. |

Total budget: ~1500 tokens (`MN_MAX_TOKENS`). Items are lines starting with
`-`, `*` or `N.` inside a section.

## Lifecycle
1. Start: already in context (adapter import) or read once.
2. During work: not touched.
3. Before the final commit of a task: rewritten from scratch.
   - Finished items are deleted; the commit records them.
   - Caps are enforced by pruning the least relevant items.
   - Pruned items that still matter go to long-term memory.
   - `updated:` set to today.
4. `mn check`, then STATE.md is committed together with the work.

## Rules
- Rewrite, never append. Appending turns the state into a log.
- One line per item, `what -> why`, no prose, no emojis, paths instead of
  descriptions.
- Do not reopen a recorded decision without new facts.

## Staleness
`mn check` finds the last commit that touched STATE.md and counts commits
after it. Any count above zero means work was committed without updating the
state; the agent should verify with `git log --oneline -N` before trusting it.
No hash needs to be stored in the file.
