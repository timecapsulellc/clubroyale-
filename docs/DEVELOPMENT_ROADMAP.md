# TaasClub Development Roadmap 🗺️

> **Philosophy:** Clone & Develop Faster — Don't reinvent the wheel, build on proven foundations.

## 🎯 Project Vision

TaasClub is a multiplayer Call Break card game with a unique focus on **settlement tracking** and **financial transparency** in gaming sessions. The app enables players to:

- Create and join game lobbies
- Play Call Break with real-time updates
- Track settlements and financial ledgers
- View game history and statistics

---

## 🏗️ Development Phases

### Phase 1: Foundation (✅ Completed)

**Goal:** Establish the core infrastructure

- [x] Firebase project setup
- [x] Flutter project initialization
- [x] Anonymous authentication
- [x] Basic navigation with go_router
- [x] State management with Riverpod
- [x] User profile management
- [x] Real-time score updates
- [x] Ledger screen for game results

**Status:** ✅ Core infrastructure is operational

---

### Phase 2: In-App Purchases (✅ Completed)

**Goal:** Implement diamond currency system via RevenueCat

- [x] RevenueCat SDK integration
- [x] Diamond purchase packages
- [x] Transaction verification
- [x] User balance tracking

**Status:** ✅ IAP infrastructure ready (requires store configuration)

**Documentation:** See [docs/REVENUECAT_SETUP.md](file:///Users/priyamagoswami/TassClub/TaasClub/docs/REVENUECAT_SETUP.md)

---

### Phase 3: The Base Engine (🔄 Next Priority)

> **CRITICAL: DO NOT BUILD FROM SCRATCH**

**Goal:** Clone and integrate an existing Call Break card game engine

#### 🎯 What to Clone

You need to find and clone a Flutter-based Call Break or generic card game repository that includes:

1. **Complete Card Asset Library** (52 cards + back design)
   - All suits: ♠️ Spades, ♥️ Hearts, ♦️ Diamonds, ♣️ Clubs
   - All ranks: Ace through King
   - Card back design
   - Format: PNG or SVG files

2. **Core Game Logic**
   - Card shuffling algorithm
   - Card dealing mechanism
   - Turn-based round logic
   - Basic game state management

3. **UI Components**
   - `Card` widget for rendering individual cards
   - Card animations (dealing, playing, collecting)
   - Hand/deck layout components

#### 📦 Recommended Sources

Search for these open-source repositories:

- **CallBreak-Flutter** (Check GitHub for active forks)
- **Flutter Card Game Toolkit**
- Generic Flutter card game templates on pub.dev

> **License Check:** Ensure the repository has an MIT, Apache 2.0, or similar permissive license before cloning.

#### 🛠️ Implementation Steps

**Step 1: Repository Selection & Cloning**

```bash
# Example (replace with actual repository URL)
git clone https://github.com/username/CallBreak-Flutter ~/temp/card-engine
cd ~/temp/card-engine
```

**Step 2: Extract Card Assets**

1. Locate the `assets/` directory in the cloned repo
2. Copy all card images to your project:
   ```bash
   cp -r ~/temp/card-engine/assets/cards TaasClub/assets/cards
   ```
3. Update `pubspec.yaml`:
   ```yaml
   flutter:
     assets:
       - assets/cards/
   ```

**Step 3: Extract Core Game Components**

Create a new directory structure:

```
lib/features/game/
├── engine/                  # Cloned engine code
│   ├── card_model.dart     # Card data structure
│   ├── deck_service.dart   # Shuffling & dealing
│   ├── game_logic.dart     # Round management
│   └── card_widget.dart    # Card rendering widget
├── lobby/                   # YOUR CUSTOM CODE
│   ├── lobby_screen.dart
│   └── lobby_service.dart
└── settlement/              # YOUR CUSTOM CODE
    ├── settlement_calculator.dart
    └── settlement_service.dart
```

**Step 4: Integration Test**

Create a simple test screen to verify the cloned engine works:

```dart
// lib/features/game/test_card_screen.dart
import 'package:flutter/material.dart';
import 'engine/card_widget.dart';
import 'engine/card_model.dart';

class TestCardScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Card Engine Test')),
      body: Center(
        child: CardWidget(
          card: PlayingCard(suit: Suit.spades, rank: Rank.ace),
        ),
      ),
    );
  }
}
```

Run the app and navigate to this screen to confirm the card renders correctly.

**Step 5: Clean Up & Strip Unnecessary Code**

- Remove any game modes you don't need (e.g., single-player vs AI)
- Strip out UI screens (lobby, menus) — you'll build your own
- Keep only:
  - Card assets
  - Card models and widgets
  - Deck shuffling/dealing logic
  - Basic game state management

#### 📋 Acceptance Criteria

- [ ] Card assets (52 cards + back) copied to `assets/cards/`
- [ ] `Card` widget successfully renders all suits and ranks
- [ ] Deck shuffling produces random, non-repeating sequences
- [ ] Card dealing distributes cards correctly (13 cards per player for 4 players)
- [ ] No compilation errors from cloned code
- [ ] Test screen shows Ace of Spades correctly

**Full Implementation Guide:** See [PHASE_3_CHECKLIST.md](file:///Users/priyamagoswami/TassClub/TaasClub/docs/PHASE_3_CHECKLIST.md) for detailed step-by-step instructions.

**Status:** 🔜 Not Started

---

### Phase 4: Lobby System (📝 Planned)

**Goal:** Build custom lobby management on top of the cloned engine

#### Features

- Create game room with configurable settings:
  - Number of rounds
  - Bet amount (in diamonds)
  - Private/public room toggle
- Real-time player list (4 players max)
- Ready check system
- Room code sharing

#### Technical Approach

```dart
// lib/features/game/lobby/models/game_room.dart
@freezed
class GameRoom with _$GameRoom {
  factory GameRoom({
    required String id,
    required String hostId,
    required List<String> playerIds,
    required int betAmount,        // in diamonds
    required int totalRounds,
    required GameRoomStatus status,
    DateTime? createdAt,
  }) = _GameRoom;
}
```

**Firestore Structure:**

```
/game_rooms/{roomId}
  - hostId: string
  - playerIds: array
  - betAmount: number
  - totalRounds: number
  - status: "waiting" | "ready" | "playing" | "completed"
  - createdAt: timestamp
```

**Status:** 📝 Design Phase

---

### Phase 5: Settlement Calculator (📝 Planned)

**Goal:** Build the unique value proposition — transparent settlement tracking

#### Core Logic

The settlement system calculates who owes whom after each game:

**Algorithm:**

1. Calculate net score for each player (actual score - bid)
2. Determine winners (positive net) and losers (negative net)
3. Use the **minimum transfer algorithm** to minimize number of transactions
4. Deduct diamonds from losers' accounts
5. Credit diamonds to winners' accounts
6. Record transaction in ledger with timestamp

**Example:**

```dart
// lib/features/game/settlement/settlement_calculator.dart

class SettlementCalculator {
  /// Calculates optimal transactions to settle debts
  /// Returns a list of transfers: (fromPlayerId, toPlayerId, amount)
  List<Settlement> calculateSettlements({
    required Map<String, int> playerScores,
    required int betPerPoint,
  }) {
    // 1. Calculate net positions
    final netPositions = playerScores.map(
      (playerId, score) => MapEntry(playerId, score * betPerPoint),
    );
    
    // 2. Split into creditors and debtors
    final creditors = netPositions.entries.where((e) => e.value > 0).toList();
    final debtors = netPositions.entries.where((e) => e.value < 0).toList();
    
    // 3. Use greedy algorithm to minimize transactions
    return _minimizeTransfers(creditors, debtors);
  }
  
  List<Settlement> _minimizeTransfers(
    List<MapEntry<String, int>> creditors,
    List<MapEntry<String, int>> debtors,
  ) {
    // Implementation of minimum transfer algorithm
    // ...
  }
}
```

#### UI Components

- **Settlement Preview Screen:** Shows who owes whom before confirmation
- **Transaction History:** Ledger view with all past settlements
- **Balance Overview:** Current diamond balance with withdrawal option

**Status:** 📝 Algorithm Design Phase

---

### Phase 6: Call Break Game Logic (📝 Planned)

**Goal:** Implement Call Break-specific rules on top of the cloned engine

> **Note:** The cloned engine provides card mechanics. You need to add Call Break game rules.

#### Game Flow

1. **Bidding Phase:** Each player bids how many hands they'll win (1-13)
2. **Playing Phase:** 13 rounds of card play
   - Follow suit rule
   - Trump suit (Spades) beats others
   - Highest card wins the trick
3. **Scoring Phase:** Calculate points based on bid vs actual wins

**Rules to Implement:**

```dart
// lib/features/game/engine/call_break_rules.dart

class CallBreakRules {
  /// Validates if a card can be played given the current trick
  bool canPlayCard({
    required PlayingCard card,
    required List<PlayingCard> currentTrick,
    required List<PlayingCard> playerHand,
  }) {
    if (currentTrick.isEmpty) return true; // First card, any is valid
    
    final ledSuit = currentTrick.first.suit;
    final hasSameSuit = playerHand.any((c) => c.suit == ledSuit);
    
    if (hasSameSuit && card.suit != ledSuit) {
      return false; // Must follow suit if possible
    }
    
    return true;
  }
  
  /// Determines which card wins the current trick
  PlayingCard findWinningCard(List<PlayingCard> trick) {
    final trumpCards = trick.where((c) => c.suit == Suit.spades).toList();
    
    if (trumpCards.isNotEmpty) {
      return trumpCards.reduce((a, b) => a.rank > b.rank ? a : b);
    }
    
    final ledSuit = trick.first.suit;
    final sameSuitCards = trick.where((c) => c.suit == ledSuit).toList();
    return sameSuitCards.reduce((a, b) => a.rank > b.rank ? a : b);
  }
}
```

**Status:** 📝 Design Phase

---

### Phase 7: Anti-Cheat & Validation (📝 Planned)

**Goal:** Prevent cheating and ensure fair gameplay

#### Security Measures

1. **Server-side game state validation** (Cloud Functions)
2. **Move verification** (validate each card play against rules)
3. **Timeout enforcement** (auto-play if player doesn't respond)
4. **Disconnection handling** (freeze game or replace with AI)

**Cloud Function Example:**

```typescript
// functions/src/validateMove.ts

export const validateMove = functions.https.onCall(async (data, context) => {
  const { gameId, playerId, cardPlayed } = data;
  
  // Verify player is in this game
  const gameDoc = await admin.firestore().doc(`games/${gameId}`).get();
  const game = gameDoc.data();
  
  if (!game.playerIds.includes(playerId)) {
    throw new functions.https.HttpsError('permission-denied', 'Not in game');
  }
  
  // Verify it's this player's turn
  if (game.currentTurn !== playerId) {
    throw new functions.https.HttpsError('failed-precondition', 'Not your turn');
  }
  
  // Verify card is valid according to rules
  const rules = new CallBreakRules();
  const isValid = rules.canPlayCard({
    card: cardPlayed,
    currentTrick: game.currentTrick,
    playerHand: game.hands[playerId],
  });
  
  if (!isValid) {
    throw new functions.https.HttpsError('invalid-argument', 'Invalid move');
  }
  
  return { success: true };
});
```

**Status:** 📝 Planning Phase

---

### Phase 8: Testing & Polish (📝 Planned)

**Goal:** Ensure production-ready quality

- [ ] Unit tests for settlement calculator
- [ ] Widget tests for game UI
- [ ] Integration tests for multiplayer flow
- [ ] Manual testing on physical devices
- [ ] Performance optimization
- [ ] Analytics integration (Firebase Analytics)
- [ ] Crash reporting (Firebase Crashlytics)

**Status:** 📝 Planned

---

## 📊 Current Status Summary

| Phase | Status | Completion |
|-------|--------|------------|
| Phase 1: Foundation | ✅ Complete | 100% |
| Phase 2: In-App Purchases | ✅ Complete | 100% |
| **Phase 3: Clone Card Engine** | **🔜 Next** | **0%** |
| Phase 4: Lobby System | 📝 Planned | 0% |
| Phase 5: Settlement Calculator | 📝 Planned | 0% |
| Phase 6: Call Break Logic | 📝 Planned | 0% |
| Phase 7: Anti-Cheat | 📝 Planned | 0% |
| Phase 8: Testing & Polish | 📝 Planned | 0% |

---

## 🚀 Immediate Next Steps

### Priority 1: Find & Clone Card Engine

1. **Research phase** (30 min):
   - Search GitHub for "CallBreak Flutter" or "Flutter card game"
   - Check licenses (MIT/Apache preferred)
   - Review code quality and asset completeness

2. **Clone & extract** (1-2 hours):
   - Clone the selected repository
   - Copy card assets to TaasClub project
   - Extract core game engine files
   - Remove unnecessary UI and features

3. **Verify integration** (30 min):
   - Create test screen to render cards
   - Test shuffling and dealing
   - Ensure no compilation errors

### Priority 2: Design Settlement Algorithm

- Design the minimum transfer algorithm
- Create Firestore data models for transactions
- Plan the settlement UI flow

### Priority 3: Lobby System Implementation

- Design lobby UI mockups
- Implement Firestore real-time listeners for room state
- Build player ready-check system

---

## 💡 Key Principles

### 1. Clone, Don't Create

**Don't build:**
- Card graphics (52 cards + back)
- Basic card shuffling algorithms
- Generic card game UI components

**Do build:**
- Lobby management system
- Settlement calculator (unique to TaasClub)
- Call Break-specific game rules
- Financial transaction tracking

### 2. Focus on Unique Value

Your USP is **settlement tracking**, not the card game itself. Invest development time in:

- Transparent settlement calculations
- User-friendly transaction history
- Diamond balance management
- Fair and secure multiplayer experience

### 3. Iterate Quickly

- Get the cloned engine working ASAP
- Build a minimal viable lobby
- Test with real users early
- Iterate based on feedback

---

## 📚 Additional Resources

- [Flutter Documentation](https://flutter.dev/docs)
- [Firebase Documentation](https://firebase.google.com/docs)
- [Riverpod Documentation](https://riverpod.dev)
- [Call Break Rules](https://en.wikipedia.org/wiki/Call_Bridge)

---

## 📝 Notes

- **Current Focus:** Phase 3 — finding and integrating a card game engine
- **Blocker:** Need to identify a suitable open-source card game repository
- **Timeline:** Aiming for MVP (Phases 1-6) within 3-4 weeks

---

**Last Updated:** December 5, 2025  
**Version:** 1.0  
**Status:** Ready to begin Phase 3 (Clone Card Engine)
