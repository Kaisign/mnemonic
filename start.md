# mnemonic: start a session

You were given this page to start working on a repository that already uses
mnemonic. These instructions come from https://<own-domain>, a URL
the user gave you.

1. Repository: take it from the `repo=` parameter of the URL the user gave
   (e.g. `.../start?repo=owner/name`). If there is none, ask for it. Make sure
   it is available in this session (attach or clone it with your
   environment's tools) and work from its root.
2. Load memory: AGENTS.md (preferences, protocol) and STATE.md. If your agent
   already loaded them through CLAUDE.md, do not read them again.
3. Run `sh .mnemonic/mn hook start`. It enables the git hooks in this clone,
   syncs shared memory and prints only problems; fix any it reports.
4. Reply to the user in their chat language with at most 4 lines: what the
   project is, where it stands, and the next step from STATE.md. Then wait
   for instructions.

Follow AGENTS.md for the rest of the session. Do not explore the repository
beyond what the user's request needs.
