# Marriage Game Technical Specification
## P2P Gameplay, GenKit AI & Anti-Cheat Architecture

**Version:** 2.0  
**Date:** December 8, 2025  
**Game:** Marriage (South Asian Card Game)  
**Platform:** TaasClub

---

## Game Rules Overview

**Players:** 2-8 (common: 3-4)  
**Deck:** 52 cards (no jokers)  
**Objective:** Win tricks via marriages (K+Q same suit)

**Phases:**
1. **Bidding:** Players bid tricks to win (1-13)
2. **Trump Selection:** Highest bidder chooses trump
3. **Marriage Declaration:** K+Q pairs = bonus points
4. **Trick-Taking:** Follow suit, highest/trump wins
5. **Scoring:** Marriage points + trick points

---

## Architecture

```
┌─────────────────────────────────────────┐
│           Flutter Client                │
│  Riverpod State │ UI Components │ Cache │
└─────────────────────────────────────────┘
                    ↕
┌─────────────────────────────────────────┐
│            Firebase Layer               │
│  Firestore │ Cloud Functions │ Rules   │
└─────────────────────────────────────────┘
                    ↕
┌─────────────────────────────────────────┐
│           GenKit AI Services            │
│  Bot Play │ Bid Suggest │ Cheat Detect │
└─────────────────────────────────────────┘
```

---

## Data Model

### Firestore: `matches/{matchId}`

```typescript
interface MarriageMatch {
  id: string;
  gameType: 'marriage';
  roomCode: string;
  status: 'waiting' | 'inProgress' | 'completed';
  
  players: {
    [userId: string]: {
      displayName: string;
      seat: number;
      isHost: boolean;
      isAI: boolean;
      aiDifficulty?: 'easy' | 'medium' | 'hard' | 'expert';
    }
  };
  
  gameState: {
    phase: 'bidding' | 'trumpSelection' | 'playing' | 'scoring';
    currentTurn: string;
    trumpSuit?: string;
    bids: Record<string, number>;
    hands: Record<string, string[]>; // Private
    tricks: Record<string, number>;
    currentTrick: { userId: string; card: string }[];
  };
  
  settings: {
    minPlayers: number;
    maxPlayers: number;
    pointsToWin: number;
    timePerTurn: number;
    entryFee: number;
  };
  
  auditLog: AuditEntry[];
  suspiciousActivity: SuspiciousEntry[];
}
```

---

## P2P Gameplay Flow

### 1. Room Creation
```dart
Future<String> createMarriageRoom() async {
  final roomCode = generateRoomCode();
  await firestore.collection('matches').doc(roomCode).set({
    'gameType': 'marriage',
    'status': 'waiting',
    'players': { currentUserId: { isHost: true, seat: 0 } },
  });
  return roomCode;
}
```

### 2. Game Start (Cloud Function)
```typescript
// Server shuffles deck, deals hands
export const startMarriageMatch = functions.firestore
  .document('matches/{matchId}')
  .onUpdate(async (change) => {
    const deck = shuffleDeck();
    const hands = dealCards(deck, playerCount);
    
    await change.after.ref.update({
      status: 'inProgress',
      'gameState.phase': 'bidding',
      'gameState.hands': hands,
    });
  });
```

### 3. Bidding
```dart
Future<void> placeBid(int amount) async {
  await firestore.doc(matchId).update({
    'gameState.bids.$currentUserId': amount,
  });
}
```

---

## GenKit AI Integration

### Bot Play Flow
```typescript
export const marriageBotPlayFlow = defineDotpromptFlow({
  name: 'marriageBotPlay',
  model: geminiFlash,
}, async (input: BotPlayInput) => {
  const prompt = `
    You are ${input.difficulty} AI in Marriage card game.
    Hand: ${input.hand.join(', ')}
    Phase: ${input.gameState.phase}
    
    Return JSON: {"action": "bid"|"playCard", "value": <number|card>}
  `;
  
  return JSON.parse(await prompt.generate());
});
```

### Difficulty Levels

| Level | Strategy |
|-------|----------|
| Easy | Random play, no strategy |
| Medium | Basic follow suit, play high on wins |
| Hard | Card counting, probability calculation |
| Expert | Opponent modeling, optimal bidding |

---

## Anti-Cheat System

### Server Validation
```typescript
export const validateMove = functions.https.onCall(async (data, context) => {
  const { matchId, move } = data;
  const userId = context.auth.uid;
  const match = await getMatch(matchId);
  
  // Check 1: Is it your turn?
  if (match.gameState.currentTurn !== userId) {
    logSuspicious(matchId, userId, 'Out of turn');
    throw new Error('Not your turn');
  }
  
  // Check 2: Do you own this card?
  if (!match.gameState.hands[userId].includes(move.card)) {
    logSuspicious(matchId, userId, 'Card not in hand');
    throw new Error('Invalid card');
  }
  
  // Check 3: Follow suit rule
  const leadSuit = match.gameState.currentTrick[0]?.card.slice(-1);
  if (leadSuit) {
    const hasLeadSuit = match.gameState.hands[userId].some(c => c.endsWith(leadSuit));
    if (hasLeadSuit && !move.card.endsWith(leadSuit)) {
      logSuspicious(matchId, userId, 'Not following suit');
      throw new Error('Must follow suit');
    }
  }
  
  return { valid: true };
});
```

### Client Optimistic Updates
```dart
Future<void> playCard(String card) async {
  // Optimistic UI update
  gameState.playCardOptimistically(card);
  
  try {
    await functions.httpsCallable('validateMove').call({
      'matchId': matchId,
      'move': {'card': card},
    });
    // Confirmed, update Firestore
    await updateFirestore(card);
  } catch (e) {
    // Rollback on rejection
    gameState.rollbackLastMove();
  }
}
```

---

## UI/UX Specifications

### Layout
```
┌────────────────────────────────────────┐
│  [Room: ABC123]  [⚙️]  [❌ Leave]     │
├────────────────────────────────────────┤
│      Opponent 2      Opponent 3        │
│                                        │
│  Opp 1  ┌──────────────┐  Opp 4       │
│         │ Current Trick │              │
│         │  [4 cards]   │              │
│         └──────────────┘              │
│                                        │
│    [Your Hand: 13 cards in fan]       │
├────────────────────────────────────────┤
│  Bid: 5 │ Trump: ♥️ │ Tricks: 3/5     │
└────────────────────────────────────────┘
```

### Animations

| Action | Duration | Effect |
|--------|----------|--------|
| Card Deal | 300ms | Fly from deck |
| Card Play | 200ms | Slide to center |
| Trick Win | 500ms | Glow + slide |
| Marriage | 400ms | Flip + sparkle |

---

## Testing Strategy

### Unit Tests (95% Coverage)
```dart
test('Deal cards evenly', () {
  final hands = engine.dealCards(playerCount: 4);
  expect(hands.values.every((h) => h.length == 13), true);
});

test('Follow suit enforced', () {
  engine.startTrick(leadCard: 'KH');
  expect(() => engine.playCard('player2', '3C'), throwsException);
});

test('Marriage scoring', () {
  expect(engine.calculateMarriagePoints('KH', 'QH', trumpSuit: 'hearts'), 40);
  expect(engine.calculateMarriagePoints('KC', 'QC', trumpSuit: 'hearts'), 20);
});
```

### Integration Tests
```dart
testWidgets('Full 2-player match', (tester) async {
  final host = await createTestUser('Alice');
  final guest = await createTestUser('Bob');
  
  await host.createRoom();
  await guest.joinRoom();
  await host.startGame();
  
  // Play all tricks
  for (int i = 0; i < 13; i++) {
    await host.playCard();
    await guest.playCard();
  }
  
  expect(find.text('Game Over'), findsOneWidget);
});
```

---

## Deployment Checklist

### Pre-Launch
- [ ] All tests passing
- [ ] No critical Sentry errors
- [ ] Game loads < 3s on 4G
- [ ] 60 FPS on mid-range devices
- [ ] Firestore rules tested
- [ ] Tutorial completed by beta testers

### Post-Launch
- Day 1: Monitor costs, error rates
- Week 1: User feedback, retention analysis
- Month 1: A/B test AI difficulty, rewards

---

## Future Enhancements

### Short-Term (3-6 months)
- Spectator mode
- Replay system
- Custom rules
- Voice chat

### Long-Term (6-12 months)
- AI Coach (post-game analysis)
- Tournaments
- Ranked seasons
- Cross-game progression
