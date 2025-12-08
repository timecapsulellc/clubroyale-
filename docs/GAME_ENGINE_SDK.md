# Game Engine SDK Specification
## Pluggable Architecture for Multi-Game Platform

**Version:** 1.0  
**Date:** December 8, 2025  
**Platform:** TaasClub

---

## Overview

A modular game engine framework enabling rapid development of new card games while maintaining consistent quality, AI integration, and anti-cheat protection.

---

## Architecture

```
games/
├── core/
│   ├── game_engine.dart       # Abstract interface
│   ├── game_state.dart        # Base state class
│   └── move_validation.dart   # Validation result types
├── marriage/
│   ├── engine/
│   │   ├── marriage_engine.dart
│   │   └── marriage_rules.dart
│   └── ui/
│       └── marriage_screen.dart
├── call_break/
│   ├── engine/
│   │   └── callbreak_engine.dart
│   └── ui/
│       └── callbreak_screen.dart
└── teen_patti/
    └── ...
```

---

## Core Interface

```dart
/// Abstract game engine that all games must implement
abstract class GameEngine<TState extends GameState, TMove> {
  /// Game metadata
  String get gameId;
  String get gameName;
  int get minPlayers;
  int get maxPlayers;
  
  /// Initialize new game state
  TState createInitialState(List<String> playerIds);
  
  /// Validate if move is legal
  Future<MoveValidation> validateMove({
    required TState currentState,
    required String playerId,
    required TMove move,
  });
  
  /// Apply move and return new state
  TState applyMove(TState state, TMove move);
  
  /// Check if game is over
  GameResult? checkGameOver(TState state);
  
  /// Get AI suggestion (calls GenKit)
  Future<TMove> getAISuggestion({
    required TState state,
    required String playerId,
    required AIDifficulty difficulty,
  });
  
  /// Calculate scores
  Map<String, int> calculateScores(TState state);
}
```

---

## Implementation Example

```dart
class MarriageEngine extends GameEngine<MarriageState, MarriageMove> {
  @override
  String get gameId => 'marriage';
  
  @override
  String get gameName => 'Marriage';
  
  @override
  int get minPlayers => 2;
  
  @override
  int get maxPlayers => 8;
  
  @override
  MarriageState createInitialState(List<String> playerIds) {
    final deck = Deck.shuffled();
    final hands = _dealCards(deck, playerIds.length);
    
    return MarriageState(
      phase: GamePhase.bidding,
      playerIds: playerIds,
      hands: hands,
      bids: {},
      tricks: {},
    );
  }
  
  @override
  Future<MoveValidation> validateMove({
    required MarriageState currentState,
    required String playerId,
    required MarriageMove move,
  }) async {
    // Validate turn
    if (currentState.currentTurn != playerId) {
      return MoveValidation.invalid('Not your turn');
    }
    
    // Validate by move type
    switch (move.type) {
      case MoveType.bid:
        return _validateBid(currentState, playerId, move.bidAmount!);
      case MoveType.playCard:
        return _validatePlayCard(currentState, playerId, move.card!);
      case MoveType.declareMarriage:
        return _validateMarriage(currentState, playerId, move.cards!);
    }
  }
  
  @override
  Future<MarriageMove> getAISuggestion({
    required MarriageState state,
    required String playerId,
    required AIDifficulty difficulty,
  }) async {
    // Call GenKit flow
    final response = await marriageBotPlayFlow.call({
      'hand': state.hands[playerId],
      'phase': state.phase.name,
      'difficulty': difficulty.name,
      'trumpSuit': state.trumpSuit,
      'currentTrick': state.currentTrick,
    });
    
    return MarriageMove.fromJson(response);
  }
}
```

---

## State Management

```dart
/// Base class for all game states
abstract class GameState {
  String get currentTurn;
  GamePhase get phase;
  List<String> get playerIds;
  
  /// Convert to Firestore document
  Map<String, dynamic> toFirestore();
  
  /// Create from Firestore document
  factory GameState.fromFirestore(Map<String, dynamic> doc);
}

/// Marriage-specific state
class MarriageState extends GameState {
  final GamePhase phase;
  final List<String> playerIds;
  final Map<String, List<Card>> hands;
  final Map<String, int> bids;
  final Map<String, int> tricks;
  final String? trumpSuit;
  final List<TrickCard> currentTrick;
  final Map<String, List<Marriage>> declaredMarriages;
  
  // ... implementation
}
```

---

## Adding New Games

### Step 1: Create Engine
```dart
// games/call_break/engine/callbreak_engine.dart
class CallBreakEngine extends GameEngine<CallBreakState, CallBreakMove> {
  @override
  String get gameId => 'call_break';
  // ... implement all abstract methods
}
```

### Step 2: Register Game
```dart
// games/game_registry.dart
final gameRegistry = <String, GameEngine>{
  'marriage': MarriageEngine(),
  'call_break': CallBreakEngine(),
  'teen_patti': TeenPattiEngine(),
};
```

### Step 3: Create GenKit Flow
```typescript
// functions/src/genkit/callbreakBotPlay.ts
export const callBreakBotPlayFlow = defineDotpromptFlow({
  name: 'callBreakBotPlay',
  model: geminiFlash,
}, async (input) => {
  // Game-specific AI logic
});
```

### Step 4: Create UI
```dart
// games/call_break/ui/callbreak_screen.dart
class CallBreakScreen extends ConsumerWidget {
  // Use shared components: TaasCard, TaasButton, etc.
}
```

---

## Shared Components

```dart
/// Card widget used by all games
class TaasCard extends StatelessWidget {
  final Card card;
  final bool isSelected;
  final bool isPlayable;
  final VoidCallback? onTap;
  
  // Consistent styling, animations
}

/// Game table layout
class TaasGameTable extends StatelessWidget {
  final List<PlayerInfo> players;
  final Widget centerContent;
  final Widget bottomHand;
  
  // Positions players around table
}
```

---

## Testing Framework

```dart
/// Base test class for game engines
abstract class GameEngineTest<TEngine extends GameEngine> {
  late TEngine engine;
  
  void runStandardTests() {
    test('initializes with correct player count', () {
      final state = engine.createInitialState(['p1', 'p2']);
      expect(state.playerIds.length, 2);
    });
    
    test('rejects moves out of turn', () async {
      final state = engine.createInitialState(['p1', 'p2']);
      final result = await engine.validateMove(
        currentState: state,
        playerId: 'p2', // Not first turn
        move: createTestMove(),
      );
      expect(result.isValid, false);
    });
  }
}

/// Marriage-specific tests
class MarriageEngineTest extends GameEngineTest<MarriageEngine> {
  @override
  MarriageEngine engine = MarriageEngine();
  
  void runTests() {
    runStandardTests();
    
    test('validates follow suit rule', () async {
      // Marriage-specific test
    });
  }
}
```
