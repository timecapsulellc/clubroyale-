# Doc 3: Monetization Flow
## Revenue Model for TaasClub

**Version:** 1.0  
**Date:** December 8, 2025  
**Strategy:** Private Club Ledger (Strategy A)

---

## Revenue Streams

```
┌─────────────────────────────────────────────────┐
│                  REVENUE MODEL                  │
├─────────────────────────────────────────────────┤
│  1. Diamond Sales (Primary)     ~80% revenue   │
│  2. Ads (Secondary)             ~20% revenue   │
│  3. Premium Features (Future)                   │
└─────────────────────────────────────────────────┘
```

---

## 1. Diamond Economy

### Pricing Table

| Package | Diamonds | Price | Per Diamond |
|---------|----------|-------|-------------|
| Starter | 100 | ₹99 | ₹0.99 |
| Popular | 500 | ₹399 | ₹0.80 |
| Value | 1000 | ₹699 | ₹0.70 |
| Mega | 2500 | ₹1499 | ₹0.60 |

### Diamond Sinks (Usage)

| Action | Cost | Who Pays |
|--------|------|----------|
| Create Room | 10 💎 | Host |
| Ad-Free Game | 5 💎 | Host |
| Extended Time | 5 💎 | Host |
| Premium Tables | 20 💎 | Host |

---

## 2. User Roles & Economics

### The Host ("The Whale")
```
Actions:
- Buys Diamonds (IAP)
- Creates Rooms (spends Diamonds)
- Sets Rules (point value, rounds)
- Controls room settings

Cost: ₹10+ per session
Value: Creates the game, attracts friends
```

### The Guest ("The Player")
```
Actions:
- Joins via 6-digit code
- Plays for FREE
- Views Settlement Bill
- May see ads

Cost: FREE
Value: Grows user base, social proof
```

---

## 3. Ad Model

### Ad Placement Strategy

| Placement | Frequency | Type |
|-----------|-----------|------|
| Between rounds | Every 2 rounds | Interstitial |
| Room waiting | While waiting | Banner |
| Post-game | Game end | Rewarded (optional) |
| Settings screen | Always | Banner |

### Ad-Free Option
- **Cost:** 5 Diamonds per game
- **Effect:** Disables ALL ads for everyone in room
- **Benefit:** Host can offer premium experience

```dart
// Ad display logic
bool shouldShowAd(GameRoom room) {
  if (room.config.adsDisabled) return false;
  if (room.currentRound % 2 != 0) return false;
  return true;
}
```

---

## 4. Revenue Projections

### Per User Economics

| User Type | % of Users | Monthly Revenue |
|-----------|------------|-----------------|
| Host (Whale) | 10% | ₹200-500 |
| Active Guest | 60% | ₹0 (ads) |
| Casual | 30% | ₹0 |

### Platform Projections

| MAU | Hosts (10%) | Avg Spend | Monthly Rev |
|-----|-------------|-----------|-------------|
| 10K | 1,000 | ₹150 | ₹1.5 Lakh |
| 50K | 5,000 | ₹150 | ₹7.5 Lakh |
| 100K | 10,000 | ₹150 | ₹15 Lakh |
| 500K | 50,000 | ₹150 | ₹75 Lakh |

---

## 5. Implementation (RevenueCat)

### Setup
```dart
// lib/features/wallet/diamond_service.dart
class DiamondService {
  static const packages = {
    'diamonds_100': 100,
    'diamonds_500': 500,
    'diamonds_1000': 1000,
    'diamonds_2500': 2500,
  };
  
  Future<void> purchaseDiamonds(String packageId) async {
    final offerings = await Purchases.getOfferings();
    final package = offerings.current?.getPackage(packageId);
    
    if (package != null) {
      final result = await Purchases.purchasePackage(package);
      await _addDiamonds(packages[packageId]!);
    }
  }
  
  Future<void> spendDiamonds(int amount, String reason) async {
    final current = await getDiamondBalance();
    if (current < amount) throw InsufficientDiamondsException();
    
    await _deductDiamonds(amount);
    await _logTransaction(amount, reason);
  }
}
```

### Firestore Model
```typescript
// User document
{
  id: "user123",
  diamonds: 150,
  totalPurchased: 500,
  totalSpent: 350,
  transactions: [
    {type: "purchase", amount: 500, timestamp: ...},
    {type: "spend", amount: 10, reason: "room_create"},
  ]
}
```

---

## 6. Growth Strategy

### Free-to-Play Funnel
```
Download (Free)
    ↓
Play as Guest (Free)
    ↓
Host First Game (Get 20 free Diamonds)
    ↓
Run out of Diamonds
    ↓
Purchase to continue hosting
```

### Retention Mechanics
- **Daily Login:** +5 Diamonds
- **Invite Friend:** +10 Diamonds (both)
- **Win Streak:** +2 Diamonds per 3 wins
- **Watch Ad:** +1 Diamond

---

## 7. Future Premium Features

| Feature | Cost | Description |
|---------|------|-------------|
| Custom Room Themes | 50 💎 | Festive, Neon, Classic |
| Extended History | 100 💎/mo | View 1-year history |
| Tournament Mode | 200 💎 | Bracket competition |
| Private League | 500 💎/mo | Season leaderboards |

---

## Key Principle

> **The Host is the customer. The Guest is the product.**
> 
> Hosts pay for the privilege of hosting games.  
> Guests play free to create the social proof that keeps Hosts paying.
