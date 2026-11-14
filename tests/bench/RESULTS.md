# Results

## 2026-11-14 - mn 0.1.0, small model subagents, 6 runs
| Scenario | Memory | Correct | Memory context | Agent tokens | Tool uses |
|---|---|---|---|---|---|
| s1-linear | without | 5/5 | ~906 | 65,499 | 5 |
| s1-linear | with | 5/5 | ~335 | 65,234 | 7 |
| s2-abstract | without | 6/6 | ~625 | 66,115 | 6 |
| s2-abstract | with | 6/6 | ~283 | 65,104 | 7 |
| s3-analytical | without | 5/5 | ~511 | 65,207 | 5 |
| s3-analytical | with | 5/5 | ~199 | 64,657 | 5 |

Totals: memory context ~2,042 -> ~817 tokens (-60%); agent tokens
196,821 -> 194,995 (-1%); accuracy 16/16 in both conditions.

Findings:
- No accuracy loss: distilled state answered every question, including
  corrected values and the on-demand memory lookups (s1 Q4, s2 Q5).
- Memory context shrinks 60% even on very short transcripts.
- Agent-level saving is ~1% here because each subagent carries ~64K tokens of
  fixed overhead and the sample transcripts are under 1K tokens. The saving
  per run is the context difference (~200-600 tokens) multiplied by the
  turns that re-read it.
- Long-term memory lookups cost 2 extra tool calls (index + topic); worth it
  only when the topic file replaces a much larger read.
- The baseline is generous: a real session without memory has no transcript
  at all and must re-explore code or ask the user.
