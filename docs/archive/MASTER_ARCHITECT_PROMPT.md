# Master Architect Prompt
## AI Agent Development Instructions for TaasClub

**Version:** 1.0  
**Date:** December 8, 2025  
**Use With:** Cursor, Windsurf, ChatGPT, Claude

---

## The Prompt

Copy this entire prompt into your AI agent to build TaasClub:

---

```markdown
**Role:** Senior Flutter Architect & Game Developer.

**Project Name:** TaasClub (Private Ledger Strategy).

**Goal:** Build a multiplayer Call Break/Marriage game where the app acts as a Scorekeeper & Bill Generator.

---

## Critical Constraints (MUST FOLLOW)

1. **NO in-app gambling.**
2. **NO real-money wallet integration.**
3. The "Settlement" is purely a visual calculation (Text/Image) for users to handle offline.
4. Use "Units" terminology, NEVER "Rupees/Dollars/Currency".
5. The app is a CALCULATOR, not a BANK.

---

## Step 1: Project Structure (Feature-First)

Set up a Flutter project with Riverpod & GoRouter.
Create these specific directories:

```
lib/
├── core/
│   ├── responsive/      # Screen size utilities
│   ├── audio/           # Sound effects
│   └── ai/              # AI difficulty
├── features/
│   ├── auth/            # Phone login
│   ├── lobby/           # Room creation, join
│   ├── wallet/          # Diamond balance (virtual only)
│   └── game/
│       ├── call_break/  # Call Break game
│       ├── marriage/    # Marriage game
│       └── ledger/      # Settlement calculation
├── games/
│   ├── core/            # Abstract GameEngine
│   ├── call_break/      # Call Break engine
│   └── marriage/        # Marriage engine
└── config/
    └── theme/           # Casino theme
```

---

## Step 2: Define The "Ledger" Logic (The Brain)

Write a Dart class `SettlementService` with this method:

```dart
class SettlementService {
  List<Transaction> calculateDebts(
    Map<String, int> playerScores,
    double unitValue,
  ) {
    // Input: Player A (50), Player B (-20), Player C (-30). Unit Value: 10.
    // Logic: Find winners and losers. Match to minimize transactions.
    // Output: ["Player B pays A: 200 units", "Player C pays A: 300 units"]
  }
}

class Transaction {
  final String from;
  final String to;
  final int amount;
}
```

---

## Step 3: Define the Firestore Data Model

Write the specific Firestore Document structure for a `GameRoom`:

```typescript
{
  roomId: string,          // 6-digit code
  hostId: string,          // User who created
  status: 'waiting' | 'playing' | 'settled',
  gameType: 'call_break' | 'marriage',
  
  players: [{
    id: string,
    name: string,
    score: number,
    isReady: boolean
  }],
  
  config: {
    rounds: number,
    unitValue: number,
    adsDisabled: boolean
  },
  
  gameState: {
    currentRound: number,
    currentTurn: string,
    phase: 'bidding' | 'playing' | 'scoring'
  },
  
  createdAt: Timestamp,
  endedAt?: Timestamp
}
```

---

## Step 4: Room Service

```dart
// lib/features/lobby/room_service.dart
class RoomService {
  // Generate 6-digit code, create Firestore doc, deduct 10 Diamonds
  Future<String> createRoom(String hostId, GameType gameType);
  
  // Add user to player list if room < 4 players
  Future<void> joinRoom(String roomId, String userId);
  
  // Listen to room updates
  Stream<GameRoom> watchRoom(String roomId);
}
```

---

## Step 5: Settlement Screen

```dart
// lib/features/game/ledger/settlement_screen.dart
class SettlementScreen extends ConsumerWidget {
  // Display "who owes whom" list
  // Button: "Share on WhatsApp"
  // Button: "Copy UPI Link" (display only, no processing)
  // Generate shareable image
}
```

---

## Step 6: Diamond Wallet (Virtual Currency ONLY)

```dart
// lib/features/wallet/diamond_service.dart
class DiamondService {
  // Check balance
  Future<int> getBalance(String userId);
  
  // Deduct for room creation
  Future<void> spendDiamonds(String userId, int amount, String reason);
  
  // Add from IAP (RevenueCat handles actual payment)
  Future<void> addDiamonds(String userId, int amount);
}
```

---

## Action Items

1. Generate the folder structure
2. Create `SettlementService` with the debt calculation algorithm
3. Create Firestore data models
4. Create `RoomService` with create/join logic
5. Create `SettlementScreen` UI

**Remember:** The settlement output is TEXT/IMAGE only. No payment processing.
```

---

## Usage Instructions

### For Cursor/Windsurf:
1. Open your project
2. Open AI chat (Cmd+K or Ctrl+K)
3. Paste the prompt above
4. Ask: "Generate the folder structure and SettlementService"

### For ChatGPT/Claude:
1. Start a new conversation
2. Paste the prompt above
3. Ask specific questions like:
   - "Generate the SettlementService code"
   - "Create the Firestore security rules"
   - "Build the RoomService"

---

## Follow-Up Prompts

After initial setup, use these:

```
"Create the Call Break game engine with bidding and trick logic."
```

```
"Generate the Settlement Screen UI with WhatsApp sharing."
```

```
"Integrate RevenueCat for Diamond purchases."
```

```
"Add GenKit AI for bot opponents with 4 difficulty levels."
```

```
"Create anti-cheat validation for all moves."
```

---

## Critical Reminders for AI

Always remind the AI:

> "Remember: This app is a SCOREKEEPER, not a payment processor. 
> The Settlement is displayed as text/image for users to settle offline.
> Use 'Units' terminology, never 'Rupees' or 'Dollars'."
