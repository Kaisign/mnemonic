# Benchmark orchestration prompt

Paste this into an agent session that can run shell commands and launch
subagents, from the root of a clone of this repository:

```
Run the mnemonic benchmark:
1. For each length L in (none, 5000, 15000) run
     sh tests/bench/prepare.sh <scratch>/bL [--pad L]
   (no --pad for "none"). Each prints 6 prompts (3 scenarios x 2 conditions).
2. Launch all 18 runs as parallel subagents, each with its printed prompt
   verbatim, using the cheapest available model and no extra instructions.
3. For each run write the subagent's reported total tokens to
   <workspace>/usage.txt and its tool call count to <workspace>/tools.txt.
4. Build the CSV:
     echo label,scenario,memory,correct,total,ctx_tokens,agent_tokens,tool_uses > tests/bench/results/results.csv
     sh tests/bench/grade.sh <scratch>/bnone --csv 1k >> tests/bench/results/results.csv
     sh tests/bench/grade.sh <scratch>/b5000 --csv 5k >> tests/bench/results/results.csv
     sh tests/bench/grade.sh <scratch>/b15000 --csv 15k >> tests/bench/results/results.csv
5. Render: python3 tests/bench/chart.py   (optional PDF: node tests/bench/pdf.js)
6. Show the savings line and any failed answers. Do not open answer files or
   expected answers before step 4.
```

Without subagents, open each printed prompt in a fresh session, then run
steps 3-5.
