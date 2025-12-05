# Card Game Engine

This directory contains the card game engine for TaasClub, built on top of the `playing_cards` package.

## Overview

Instead of cloning a repository and extracting card assets, we're using the [`playing_cards`](https://pub.dev/packages/playing_cards) package from pub.dev. This approach provides:

- ✅ Production-ready card rendering
- ✅ Automatic maintenance and updates
- ✅ Clean, tested code
- ✅ MIT licensed
- ✅ No need to manage card image assets

## Components

### DeckService (`deck_service.dart`)

A utility service that wraps the `playing_cards` package with Call Break-specific functionality.

**Key Methods:**

```dart
final deckService = DeckService();

// Create and shuffle a deck
final deck = deckService.createShuffledDeck();

// Deal cards for Call Break (4 players, 13 cards each)
final hands = deckService.dealCallBreakHands();
// Returns: Map<int, List<PlayingCard>> where key is player index

// Sort a hand by suit and rank
final sortedHand = deckService.sortHand(myHand);

// Count cards of a specific suit
final spadeCount = deckService.countSuit(myHand, Suit.spades);

// Get all cards of a suit
final spades = deckService.getCardsOfSuit(myHand, Suit.spades);

// Remove a card from hand
deckService.removeCard(myHand, playedCard);

// Get card description
final desc = deckService.getCardDescription(card);
// Returns: "Ace of Spades ♠"
```

## Usage Example

### Basic Card Rendering

```dart
import 'package:playing_cards/playing_cards.dart';

// Render a single card
PlayingCardView(
  card: PlayingCard(Suit.spades, CardValue.ace),
)

// With customization
PlayingCardView(
  card: PlayingCard(Suit.hearts, CardValue.king),
  showBack: false,  // Show card face
  elevation: 2.0,
  shape: RoundedRectangleBorder(
    borderRadius: BorderRadius.circular(8),
  ),
)
```

### Dealing Cards for Call Break

```dart
import 'package:taas_club/features/game/engine/deck_service.dart';

final deckService = DeckService();

// Deal hands for a Call Break game
final hands = deckService.dealCallBreakHands();

// hands[0] contains player 0's 13 cards
// hands[1] contains player 1's 13 cards
// hands[2] contains player 2's 13 cards
// hands[3] contains player 3's 13 cards

// Sort each hand
final sortedHand = deckService.sortHand(hands[0]!);
```

### Full Game Setup

```dart
import 'package:playing_cards/playing_cards.dart';
import 'package:taas_club/features/game/engine/deck_service.dart';

class GameSetup {
  final DeckService _deckService = DeckService();
  
  void startGame() {
    // Deal cards to 4 players
    final hands = _deckService.dealCallBreakHands();
    
    // Process each player's hand
    for (int playerIndex = 0; playerIndex < 4; playerIndex++) {
      final hand = hands[playerIndex]!;
      final sortedHand = _deckService.sortHand(hand);
      
      // Show hand statistics
      print('Player $playerIndex:');
      print('  Total cards:${hand.length}');
      print('  Spades: ${_deckService.countSuit(hand, Suit.spades)}');
      print('  Hearts: ${_deckService.countSuit(hand, Suit.hearts)}');
      print('  Diamonds: ${_deckService.countSuit(hand, Suit.diamonds)}');
      print('  Clubs: ${_deckService.countSuit(hand, Suit.clubs)}');
    }
  }
}
```

## Testing

A test screen is available at `/test-cards` route to verify the card engine integration.

**To access:**
1. Run the app
2. Navigate to the test screen:
   ```dart
   context.go('/test-cards');
   ```
3. Verify:
   - Cards render correctly
   - All 4 suits display properly
   - Shuffle/deal functionality works
   - Card backs toggle correctly

## Package Information

**Package:** `playing_cards` v0.1.6  
**License:** MIT  
**Pub.dev:** https://pub.dev/packages/playing_cards  
**GitHub:** https://github.com/bedardjo/playing_cards

## Next Steps

With the card engine in place, you can now:

1. **Build the Lobby System** (Phase 4)
   - Create/join game rooms
   - Player ready-check
   - Real-time synchronization

2. **Implement Game Logic** (Phase 6)
   - Bidding phase
   - Card play validation
   - Trick winner determination
   - Scoring

3. **Add Settlement Calculator** (Phase 5)
   - Calculate who owes whom
   - Process diamond transfers
   - Record transaction history

## Credits

This engine uses the `playing_cards` package by Joseph Bedard.  
Original package: https://pub.dev/packages/playing_cards  
License: MIT
