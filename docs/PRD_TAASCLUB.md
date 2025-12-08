# TaasClub PRD (Product Requirements Document)
## The Private Ledger Strategy

**Version:** 1.0  
**Date:** December 8, 2025  
**Strategy:** Strategy A - Private Club Ledger

---

## 1. Executive Summary

TaasClub is a multiplayer card game platform that digitizes the "Home Game" experience. It allows a **Host** to create a private room for friends to play **Call Break** or **Marriage**. The app tracks scores and, at the end of the session, generates a **"Settlement Bill"** image that users can use to settle offline via UPI/Cash.

> **One-Liner:** A digital scorekeeper for private card games that settles debts automatically via a generated screenshot.

---

## 2. User Roles

### The Host ("The Whale")
- **Who:** The organizer of the game
- **Actions:**
  - Buys Diamonds (In-App Purchase)
  - Creates Private Rooms
  - Sets Rules (Point Value, Rounds)
  - Shares room code with friends
- **Cost:** Spends Diamonds to host

### The Guest ("The Player")
- **Who:** Friends who join the game
- **Actions:**
  - Joins via 6-digit PIN code
  - Plays cards
  - Views the Settlement Bill
- **Cost:** FREE to play

---

## 3. Key Features & Flow

### 3.1 The Lobby (The Marketplace)

#### Create Room
```
Inputs:
- Game Type: (Call Break / Marriage)
- Rounds: (5 / 10 / 13)
- Point Value: (Hidden metadata, user's mental model)
- Boot Amount: (Entry in chips - display only)

Cost: Deducts 10 Diamonds from Host
Output: 6-digit PIN code
```

#### Join Room
```
Input: 6-digit PIN Code
Restriction: Room must have < 4 players
Cost: FREE (0 Diamonds required)
```

---

### 3.2 Gameplay (The Engine)

#### Call Break Rules
- 5 Rounds standard
- Spades is always trump
- Bid 1-13 tricks before each round
- Must follow suit if possible

#### Marriage Rules  
- 2-8 players
- K+Q of same suit = Marriage (bonus points)
- Trump marriage = 40 points
- Non-trump marriage = 20 points

#### Anti-Cheat Features
| Feature | Description |
|---------|-------------|
| GPS Check | Warn if 2 players within 5 meters |
| IP Check | Warn if players on same Wi-Fi |
| Server-Authoritative | All moves validated server-side |
| Rate Limiting | Prevent bot/script usage |

---

### 3.3 The Settlement (The USP)

#### Trigger
Game ends (final round complete)

#### Process
1. App calculates "Net Plus/Minus" per player
2. Matches losers to winners
3. Generates settlement text

#### Display
```
┌─────────────────────────────────────┐
│         🎴 TaasClub                 │
│       Settlement Receipt            │
├─────────────────────────────────────┤
│  Amit owes Ravi: 500               │
│  Priya owes Ravi: 200              │
│  Deepak owes Ravi: 300             │
├─────────────────────────────────────┤
│  [Share on WhatsApp]               │
│  [Copy UPI Link]                    │
└─────────────────────────────────────┘
```

#### Actions
- **Share Receipt:** Generate image, share via WhatsApp
- **Copy UPI Link:** Host can paste their UPI ID (NOT processed by app)

---

## 4. User Flows

### Flow A: Host Creates Game
```
1. Host opens app → Lobby
2. Taps "Create Private Room"
3. Selects game type, rounds
4. Pays 10 Diamonds
5. Gets 6-digit code: "ABC123"
6. Shares code on WhatsApp group
```

### Flow B: Guest Joins Game
```
1. Guest receives code via WhatsApp
2. Opens app → Taps "Join Room"
3. Enters code: "ABC123"
4. Waits in lobby for game to start
```

### Flow C: Game & Settlement
```
1. Host starts game (4 players ready)
2. 5 rounds of Call Break played
3. Game ends → Settlement screen appears
4. All players see "who owes whom"
5. Host shares receipt via WhatsApp
6. Players settle offline via UPI/Cash
```

---

## 5. Technical Stack

| Layer | Technology |
|-------|------------|
| Frontend | Flutter (Mobile + Web) |
| Backend | Firebase (Firestore, Functions) |
| Auth | Phone Number (Firebase Auth) |
| Payments | RevenueCat (Diamonds IAP) |
| State | Riverpod |
| Navigation | GoRouter |
| AI | GenKit + Gemini (Bot play) |

---

## 6. Firestore Data Model

```typescript
// Collection: gameRooms
{
  roomId: "ABC123",
  hostId: "user_123",
  status: "waiting" | "playing" | "settled",
  gameType: "call_break" | "marriage",
  
  players: [
    {id: "user_123", name: "Ravi", score: 50},
    {id: "user_456", name: "Amit", score: -20},
    {id: "user_789", name: "Priya", score: -15},
    {id: "user_012", name: "Deepak", score: -15}
  ],
  
  config: {
    rounds: 5,
    pointValue: 10,  // Hidden from UI, user's mental model
    adsDisabled: false
  },
  
  gameState: {
    currentRound: 3,
    currentTurn: "user_456",
    // ... game-specific state
  },
  
  createdAt: Timestamp,
  endedAt: Timestamp
}
```

---

## 7. Critical Constraints

### ✅ DO
- Track scores and game state
- Generate settlement as text/image
- Allow users to share via WhatsApp
- Display Host's UPI ID (if provided)
- Use "Units" terminology

### ❌ DON'T
- Process any payments
- Store bank/credit card info
- Use "Rupee/Dollar/Currency" in code
- Link to payment gateways
- Auto-transfer money

---

## 8. Success Metrics

| Metric | Target |
|--------|--------|
| DAU | 30% of MAU |
| Session Length | 30+ minutes |
| Games per Session | 3+ |
| Host Conversion | 10% of users |
| Diamond Purchase | ₹150/host/month |

---

## 9. MVP Scope (2-Week Sprint)

### Week 1
- [ ] Login & Lobby (Create/Join Room)
- [ ] Card Deck Logic (Deal, Play, Turns)
- [ ] Firebase Connection

### Week 2
- [ ] Settlement Screen (Calculate & Display)
- [ ] Bill Image Generation
- [ ] RevenueCat Integration (Diamonds)
- [ ] App Store Submission
