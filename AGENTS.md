# AGENTS.md

<!-- mnemonic:begin -->
## Preferences
- chat_lang: es
- work_lang: en (files, code, commits, docs)
- commits: one per major change, minor changes grouped, simple messages
- brand_refs: no AI tool or vendor names in git history, code or docs (required adapter filenames excepted); no co-author trailers
- code: write or change code only when the user asks; otherwise discuss and design
- priority: minimize tokens; read only what is needed, short answers, no re-exploration
- docs: document every mechanism; concise but complete
- tone: direct, clear summaries, light humor welcome, say so when a question is trivial
- state_updates: rewrite STATE.md when a task ends; hooks block after 3 commits without it

## Memory protocol
Files:
- STATE.md: live project state. Loaded every session. Budget ~1500 tokens.
- memory/INDEX.md + memory/<topic>.md: long-term memory. Never read it whole. When you need a fact that STATE.md does not have (or the user asks), run `.mnemonic/mn mem find <words>` and open only the matching topic, before answering "unknown" or re-exploring code.
- .mnemonic/mn: helper CLI (`.mnemonic/mn help`). Guide: .mnemonic/README.md.

Session start:
1. If STATE.md is not already in context, read it. Nothing else by default.
2. If it may be outdated, run `.mnemonic/mn check` (reports commits since the last STATE.md update).
3. Do not re-explore what STATE.md or a memory topic answers. Do not reopen recorded decisions without new facts.

Before the final commit of a task or session:
1. Rewrite STATE.md; never append. Drop finished items: git log is the history.
2. Caps (lines): Goal 3, Current 5, Next 7, Decisions 10, Blockers 5, Notes 5. Prune the least relevant.
3. Pruned but valuable knowledge: `.mnemonic/mn mem add <topic> "<keywords>" "<summary>"`, then write memory/<topic>.md.
4. Run `.mnemonic/mn check`, fix warnings, commit STATE.md together with the work.
Automation: hooks enforce state_updates (see Preferences) and reject STATE.md commits that fail mn check. Comply, do not bypass.

## Session economy
- Work in this session while the task lasts: its prompt cache is the cheapest context. No new sessions for subtasks.
- Do not re-read files already in context; delegate heavy reading to subagents.
- Compact only at a task boundary, right after updating STATE.md.
- Record facts other sessions will need in shared memory as soon as you learn them.
- After an idle gap over 1 h in a long conversation the prompt hook reports it: offer the user a fresh session from STATE.md.

Deliverables you generate (reports, charts, PDFs, page sources) go in artifacts/<topic>/.

Style for STATE.md and memory: telegraphic, one line per item, `what -> why`, lists not tables, paths instead of descriptions, no emojis.
<!-- mnemonic:end -->
