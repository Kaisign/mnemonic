# Installer

## Bootstrap
The repository is public, so GitHub is the only host. The user starts any
session with:
```
Read https://github.com/<owner>/mnemonic and install it in owner/name
```
The README tells agents to follow `install.md`, which tells the agent to:
1. Confirm the target repository (attach or clone it if needed).
2. Ask the preference menu, including the git author (interactive question
   tool if available, numbered options otherwise). The first option of each
   question is the default.
3. Download `mn` from raw.githubusercontent.com (or clone this repository)
   and run `mn init` with the chosen flags.
4. Optionally link shared memory.
5. Fill STATE.md from the README and top-level file list only, or ask for
   the goal if the repository is empty.
6. Run `mn check` and `mn publish` (first commit and push, no confirmation).
7. Show `mn status`, hand over the start prompt and explain the system in the
   user's chat language.

If the agent's fetch tool summarizes pages, `install.md` tells it to re-read
the raw file or clone the repository, so commands and flags are not altered.

## Start prompt for later sessions
`mn status` prints it for the installed repository:
```
Read https://github.com/<owner>/mnemonic/blob/main/start.md and work on owner/name
```
start.md makes the agent attach the repository, load AGENTS.md and STATE.md
(skipped when the adapter already did), run `mn hook start`, and answer with
a four-line status and the next step. With the adapter, a session opened on
the repository already loads memory; the prompt adds the status summary.

## Versions
Releases are git tags. A pinned installer or CLI is the same path under the
tag: `https://raw.githubusercontent.com/<owner>/mnemonic/v0.0.6/mn`.
`MN_URL` points `mn update` at any tag or mirror.

## Trust
Following instructions from a URL is a prompt-injection vector. Agents may
ask for confirmation before acting on it; that is expected. The content comes
from a public repository the user controls.

## Network
Sessions need github.com or raw.githubusercontent.com, usually allowed by
default. Cloning the public repository through git is the fallback.
