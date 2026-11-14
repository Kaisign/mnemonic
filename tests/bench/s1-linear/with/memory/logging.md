# logging
keywords: logging library winston pino benchmark
summary: Logging library choice and rejected option
updated: 2026-11-14

- Chosen: pino -> ~1 ms/request at peak vs ~9 ms for winston; performance decided
- Rejected: winston
- Smoke test parses pino JSON lines
