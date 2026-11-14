# Token savings

Estimates from a simulation, not measurements. Prices: input $4, output $20,
cache read $0.20, cache write (1 h) $8 per million tokens. Fixed per-session
overhead (agent system prompt and tools) assumed at ~35K tokens.

## Where the savings come from
1. Orientation: without memory the agent re-explores files and the user
   re-explains context; with memory the state is in context from turn one.
2. Smaller context for the whole session: every turn re-reads the
   accumulated context, so exploration noise is paid again on every
   later turn.
3. Fewer turns: no re-discussion of decided topics; `mn` outputs replace
   multi-file reads.

## Scenarios
| Scenario | Without | With | Tokens | Cost |
|---|---|---|---|---|
| Continue yesterday's task | 27 turns, 1.78M, $1.30 | 19 turns, 1.11M, $0.98 | -38% | -25% |
| Resume after a month | 37 turns, 2.89M, $1.76 | 21 turns, 1.24M, $1.04 | -57% | -41% |
| "Why did we choose X?" | 8 turns, 367K, $0.53 | 3 turns, 114K, $0.34 | -69% | -35% |
| Check the state is current | 6 turns, 243K, $0.42 | 2 turns, 75K, $0.32 | -69% | -25% |

Typical month (15 continue, 2 resume, 3 lookups): ~42% fewer tokens, ~28%
lower cost, ~200 fewer turns.

## Why cost drops less than tokens
- The fixed per-session overhead (~$0.30) cannot be reduced.
- Most saved tokens are cache reads, the cheapest kind.
- For lookups inside an already open session the cost saving approaches 60%.

## When it does not pay off
- One-off, single-session tasks: the closing STATE.md rewrite is not recovered.
- A STATE.md that grows past its budget: savings disappear above ~10K tokens.

## Measuring for real
Run the same task with and without the system and compare the session token
usage reported by the agent (e.g. its cost or context command).
