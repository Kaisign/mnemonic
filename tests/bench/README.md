# Benchmark: resuming work with and without mnemonic

Measures how much context an agent needs to resume a project and whether it
still answers correctly. Small on purpose: 6 short runs, a few thousand
tokens each.

## Design
Each scenario is a finished previous session. Facts are spread across the
conversation and several are corrected later (renames, changed numbers,
reordered steps), so answering requires the latest value, not the first one.

| Scenario | Thinking | Content | Traps |
|---|---|---|---|
| s1-linear | sequential | release pipeline steps | step reordered, port changed, retention 3 -> 5, decision stated late |
| s2-abstract | rule application | invented card game | term renamed, scoring rule added later, restriction added, rejected card |
| s3-analytical | arithmetic | hosting cost comparison | two corrected inputs, derived totals, what-if scenario |

Conditions:
- `without`: only `transcript.md` (the previous conversation). The agent must
  re-read it, as a session without memory would.
- `with`: mnemonic files distilled from the same conversation: `STATE.md`,
  `memory/INDEX.md` and topic files. Some answers live only in long-term
  memory, so the on-demand index lookup is exercised too.

Both conditions contain the same facts. `expected.txt` holds grading
patterns (`pattern && pattern`, case-insensitive regex, all must match); it is
never copied into workspaces.

## Run
Automatic, with subagents: see [PROMPT.md](PROMPT.md).

Manual:
```
sh tests/bench/prepare.sh /tmp/bench      # builds 6 workspaces, prints prompts
# run each prompt in a fresh session (or subagent)
sh tests/bench/grade.sh /tmp/bench        # scores + context size
```
Optionally write each run's reported token usage to
`<workspace>/usage.txt` to get the `agent_tokens` column and summary.

## Output
```
scenario        memory    correct   ctx_tok agent_tokens  failed
s1-linear       without       5/5      ~906        21000  -
s1-linear       with          5/5      ~335        18500  -
```
- `correct`: answers matching all patterns.
- `ctx_tok`: memory files offered to the run (bytes / 4).
- `agent_tokens`: total tokens reported for the run, including the agent's
  fixed overhead (system prompt, tools), which is the same in both conditions.

## Reading the results
- The sample transcripts are short (~600-900 tokens). Real conversations are
  tens of thousands of tokens and grow with the project; STATE.md does not.
  The context ratio here is therefore a lower bound on real savings.
- The fixed per-agent overhead dominates `agent_tokens` in such a small
  sample; compare `ctx_tok` for the memory effect itself.
- Accuracy matters as much as size: a smaller context that loses facts is
  not a saving.

## Adding a scenario
Create `tests/bench/sN-name/` with `without/transcript.md`, `with/STATE.md`,
`with/memory/INDEX.md` (+ topics), `questions.md` and `expected.txt`.
prepare.sh and grade.sh pick it up automatically.
