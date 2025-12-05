# Card Game Engine

This directory contains the core card game engine for TaasClub. It is a custom implementation designed specifically for Call Break mechanics.

## Overview

The engine provides a complete set of tools for managing card game logic and rendering. It is self-contained within `lib/features/game/engine` and does not rely on external card packages.

## Components

### Models (`models/`)

- **`card.dart`**: Defines `PlayingCard`, `CardSuit`, and `CardRank`. Includes logic for card comparison and display strings.
- **`deck.dart`**: Represents a standard 52-card deck with shuffling capabilities.

### Widgets (`widgets/`)

- **`playing_card_widget.dart`**: A highly customizable widget for rendering playing cards. Supports face-up/face-down states, selection highlighting, and animations.
- **`card_hand_widget.dart`**: Displays a player's hand in a fanned layout, handling card selection and interaction.

## Usage

### Creating a Deck

```dart
import 'package:myapp/features/game/engine/models/deck.dart';

final deck = Deck();
deck.shuffle();
final hand = deck.deal(13);
```

### Rendering a Card

```dart
import 'package:myapp/features/game/engine/widgets/playing_card_widget.dart';
import 'package:myapp/features/game/engine/models/card.dart';

PlayingCardWidget(
  card: PlayingCard(suit: CardSuit.spades, rank: CardRank.ace),
  width: 60,
  height: 90,
  onTap: () => print('Card tapped!'),
)
```

### Displaying a Hand

```dart
import 'package:myapp/features/game/engine/widgets/card_hand_widget.dart';

CardHandWidget(
  cards: myHand,
  onCardSelected: (card) => setState(() => selectedCard = card),
)
```

## Key Features

- **Custom Rendering**: Cards are drawn using Flutter widgets (Text, Icon, Container), ensuring crisp scaling on all devices without needing image assets.
- **Call Break Logic**: The `PlayingCard` model includes specific comparison logic (`compareTo`) that handles trump suits and leading suits, essential for trick-taking games.
- **Null Safety**: Fully compliant with modern Dart null safety standards.

## Testing

To verify the engine integration, you can use the test screen at `/test-cards` (if implemented) or run the unit tests in `test/features/game/engine_test.dart`.
