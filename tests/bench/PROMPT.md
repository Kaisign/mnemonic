# Benchmark orchestration prompt

Paste this into an agent session that can run shell commands and launch
subagents, from the root of a clone of this repository:

```
Run the mnemonic benchmark:
1. Run: sh tests/bench/prepare.sh <scratch-dir>/bench
   It prints one prompt per run (3 scenarios x 2 conditions = 6 runs).
2. Launch the 6 runs as parallel subagents, each with its printed prompt
   verbatim, using the cheapest available model and no extra instructions.
3. For each run, write the subagent's reported total token usage (a single
   number) to <workspace>/usage.txt. If not reported, skip it.
4. Run: sh tests/bench/grade.sh <scratch-dir>/bench
5. Show the table and the summary lines. Do not open the answer files or the
   expected answers before step 4.
```

Without subagents, open each printed prompt in a fresh session, then run
step 4.
