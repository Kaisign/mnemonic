# Long-term memory

Knowledge worth keeping that is not needed every session: architecture notes,
old decisions and their reasons, approaches that failed, domain context.
It is not an activity log; that is `git log`.

## Layout
```
memory/
  INDEX.md        one line per topic
  auth.md         one file per topic
  deploy.md
```
Index line format:
```
- <topic>: <keywords> - <one-line summary>
```
`<topic>` matches `[A-Za-z0-9._-]+` and equals the file name without `.md`.

Topic file header (written by `mn mem add`):
```
# auth
keywords: login jwt sessions
summary: Auth design and rejected options
updated: 2026-11-14
```
The body follows the same telegraphic style as STATE.md.

## Access rule
Never loaded at session start and never read whole. The agent looks it up
automatically when it needs a fact that STATE.md does not have, and also when
the user asks ("check memory about X"):
1. `mn mem find <words>` (or read INDEX.md) to pick a topic. Opening topic
   files to search them is not allowed.
2. Open only the matching topic file.
3. Only then answer "unknown" or explore the code.

Cost when unused: zero. Cost when used: a few index lines + one file.
Why automatic: in the real-data benchmark a run that did not consult memory
answered "unknown" to 3 of 7 questions whose answers were in a topic file.

## How it fills up
At the end of a task, items pruned from STATE.md that still have value are
moved here:
```
.mnemonic/mn mem add auth "login jwt sessions" "Auth design and rejected options"
```
then the agent writes the details into `memory/auth.md`. Existing topics are
edited in place and their `updated:` line refreshed.

## Integrity
`mn check` reports index entries without a file and topic files missing from
the index.
