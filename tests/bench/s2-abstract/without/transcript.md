# Previous session transcript: Tessel card game rules

USER: I want to design a small card game called Tessel. Cards have a color (red, blue or green) and a rank from 1 to 9.

ASSISTANT: Simple base. How do players score?

USER: Two cards of the same color whose ranks add up to 10 form a "pair". Players play cards in sequence and score when consecutive cards form a pair.

ASSISTANT: So red 3 followed by red 7 is a pair, red 3 followed by blue 7 is not. How many points per pair?

USER: 2 points per pair.

ASSISTANT: Noted: pair = same color, ranks sum to 10, consecutive, 2 points.

USER: What about the deck size?

ASSISTANT: Three colors times nine ranks gives 27 cards. Two copies of each would give 54, closer to a standard deck.

USER: Two copies, 54 cards. Hand size 6.

ASSISTANT: 54 cards, hands of 6. Players draw back to 6 at the end of their turn?

USER: Yes. Now a special card: "Mirror". When played, it reverses the play order and repeats the previous card's score.

ASSISTANT: That creates long back-and-forth loops. In a quick simulation games went from about 15 to about 40 minutes.

USER: That's too long. Drop Mirror. Rejected because it made games far too long.

ASSISTANT: Mirror removed: games too long.

USER: Another special card, "Echo". Echo takes the color of the previous card, and its rank becomes 10 minus the previous card's rank. So it always completes a pair with the card before it.

ASSISTANT: Interesting: blue 2 followed by Echo makes Echo a blue 8, so it forms a pair. How many Echo cards in the deck?

USER: Four Echo cards, so 58 cards total.

ASSISTANT: Deck is now 58 cards: 54 numbered plus 4 Echo.

USER: I don't like the word "pair", people think of poker. Rename it to "link". Same rule, new name.

ASSISTANT: Renamed: "pair" is now "link". Same color, ranks summing to 10, consecutive.

USER: Green should feel special. Links made of green cards score double.

ASSISTANT: Green link = 4 points, red and blue links = 2 points.

USER: Problem: if Echo is the first card of a round there is no previous card. Echo cannot be played as the first card of a round.

ASSISTANT: Rule added: Echo is illegal as the first card of a round.

USER: What ends the game?

ASSISTANT: Options: a fixed number of rounds, or first player to a target score.

USER: First to 30 points wins. Ties are broken by fewer cards left in hand.

ASSISTANT: Game ends at 30 points; ties go to the player with fewer cards in hand.

USER: Good. Next time we write the rulebook text.
