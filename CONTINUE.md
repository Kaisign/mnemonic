# Continue this project

Status: paused after v0.0.6 (2026-11-14). The repository is private.

## Resume
1. Open a session with this repository selected. CLAUDE.md loads AGENTS.md
   (preferences, protocol) and STATE.md (current state and next steps); the
   session start hook pulls, applies the git author and reports problems.
2. Read STATE.md "Next" and continue from item 1.
3. Run `sh tests/test.sh` before and after changes (139 tests at v0.0.6).

## Pending work (from the 0.0.6 tests)
- `mn check`: "STATE.md never committed" should be info before the first commit.
- memory/INDEX.md template still says "read only when the user asks";
  align it with the automatic lookup.
- The pre-commit hook counts `git commit --amend` as a new work commit;
  document it or skip amends.
- Protocol: state that all six STATE.md sections are mandatory.
- `mn check`: do not report STATE.md as stale when it is staged.
- `mn status`: start prompt for remotes that are not on GitHub.
- Style rule: no counters in STATE.md (they go stale on the next commit).
- Validation still missing: a multi-day real project, parallel sessions on one
  repository, shared memory across repositories.
- Idea, not started: read-only project panel aggregating STATE.md of several
  repositories (Current, Next, Blockers, Decisions).

## Release process
- Bump MN_VERSION in `mn`, add a CHANGELOG entry, run the tests, commit.
- Tag `vX.Y.Z` and push the tag (tags must be pushed from a machine with
  direct GitHub access).

## Hosting note
Install and start prompts fetch `install.md`, `start.md` and `mn` from
raw.githubusercontent.com, which only works while the repository is public.
While it is private, install by cloning the repository with access and running
`sh mn init` from the target repository, or make it public again.
