# STATE
updated: 2026-11-14

## Goal
- Design the Tessel card game; write the rulebook

## Current
- Rules settled; rulebook text not started

## Next
1. Write rulebook text

## Decisions
- Cards: red/blue/green, rank 1-9, two copies + 4 Echo = 58 cards; hand 6, draw back to 6
- "link" (renamed from "pair"): consecutive cards, same color, ranks sum to 10
- Link scores 2; green link scores 4
- Echo: takes previous card's color, rank = 10 - previous rank (always completes a link)
- Echo illegal as first card of a round
- Win: first to 30; tie -> fewer cards in hand

## Blockers
- (none)

## Notes
- Rejected special cards: see memory topic rejected-cards
