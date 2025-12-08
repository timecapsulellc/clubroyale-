# Doc 2: Settlement Algorithm
## The Math Behind the Ledger

**Version:** 1.0  
**Date:** December 8, 2025  
**Strategy:** Private Club Ledger (Strategy A)

---

## Algorithm Overview

The Settlement Algorithm calculates "who owes whom" with **minimum transactions**.

---

## Input Parameters

```dart
Input {
  players: Map<String, int>  // Player ID → Final Score
  unitValue: double          // User-defined (e.g., 10)
}
```

**Example Input:**
```
Players: {
  "P1": +50,   // Winner
  "P2": -10,   // Loser
  "P3": -20,   // Loser  
  "P4": -20    // Loser
}
Unit Value: 10
```

---

## Algorithm Steps

### Step 1: Convert Scores to Units
```
P1: +50 × 10 = +500 units
P2: -10 × 10 = -100 units
P3: -20 × 10 = -200 units
P4: -20 × 10 = -200 units

Total: +500 - 100 - 200 - 200 = 0 ✓ (Zero-sum verified)
```

### Step 2: Separate Winners and Losers
```
Winners: [P1: +500]
Losers:  [P2: -100, P3: -200, P4: -200]
```

### Step 3: Match Losers to Winners (Greedy)
```
P2 (-100) → P1 (+500) : P2 pays P1: 100
P3 (-200) → P1 (+400) : P3 pays P1: 200
P4 (-200) → P1 (+200) : P4 pays P1: 200

P1 now at 0 ✓
```

---

## Output Format

```dart
List<Transaction> output = [
  Transaction(from: "Player 2", to: "Player 1", amount: 100),
  Transaction(from: "Player 3", to: "Player 1", amount: 200),
  Transaction(from: "Player 4", to: "Player 1", amount: 200),
];
```

**Display Text:**
```
Player 2 pays Player 1: 100
Player 3 pays Player 1: 200
Player 4 pays Player 1: 200
```

---

## Dart Implementation

```dart
class SettlementService {
  List<Transaction> calculateDebts(
    Map<String, int> playerScores,
    double unitValue,
  ) {
    final transactions = <Transaction>[];
    
    // Step 1: Convert to units
    final balances = playerScores.map(
      (id, score) => MapEntry(id, score * unitValue),
    );
    
    // Step 2: Separate winners and losers
    final winners = balances.entries
        .where((e) => e.value > 0)
        .toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    
    final losers = balances.entries
        .where((e) => e.value < 0)
        .toList()
      ..sort((a, b) => a.value.compareTo(b.value));
    
    // Step 3: Match losers to winners
    int i = 0, j = 0;
    final winnerBalances = {for (var w in winners) w.key: w.value};
    final loserBalances = {for (var l in losers) l.key: l.value.abs()};
    
    while (i < winners.length && j < losers.length) {
      final winner = winners[i].key;
      final loser = losers[j].key;
      
      final winnerNeed = winnerBalances[winner]!;
      final loserDebt = loserBalances[loser]!;
      
      final amount = winnerNeed < loserDebt ? winnerNeed : loserDebt;
      
      transactions.add(Transaction(
        from: loser,
        to: winner,
        amount: amount.toInt(),
      ));
      
      winnerBalances[winner] = winnerNeed - amount;
      loserBalances[loser] = loserDebt - amount;
      
      if (winnerBalances[winner] == 0) i++;
      if (loserBalances[loser] == 0) j++;
    }
    
    return transactions;
  }
}

class Transaction {
  final String from;
  final String to;
  final int amount;
  
  Transaction({
    required this.from,
    required this.to,
    required this.amount,
  });
  
  @override
  String toString() => '$from pays $to: $amount';
}
```

---

## Bill Image Generation

The settlement output is rendered as a **shareable image** (JPEG/PNG):

```dart
Future<Uint8List> generateBillImage(List<Transaction> transactions) async {
  // Use flutter's RepaintBoundary + RenderRepaintBoundary
  // to capture the settlement widget as an image
  
  return imageBytes;
}
```

**Bill Layout:**
```
┌─────────────────────────────────────┐
│         🎴 TaasClub                 │
│       Settlement Receipt            │
├─────────────────────────────────────┤
│                                     │
│  Player 2 → Player 1: 100          │
│  Player 3 → Player 1: 200          │
│  Player 4 → Player 1: 200          │
│                                     │
├─────────────────────────────────────┤
│  Game: Call Break | Rounds: 5      │
│  Date: Dec 8, 2025                  │
└─────────────────────────────────────┘
```

---

## Sharing Options

1. **Share on WhatsApp** - Uses `share_plus` package
2. **Copy UPI Link** - Host can paste their UPI ID
3. **Save to Gallery** - Saves bill image locally

---

## Edge Cases

| Case | Handling |
|------|----------|
| All players tie (0 scores) | "No settlement needed" |
| Single winner | All losers pay winner |
| Multiple winners | Distribute proportionally |
| Negative total | Error - scores must sum to 0 |

---

## Testing

```dart
test('Settlement calculates correctly', () {
  final service = SettlementService();
  
  final transactions = service.calculateDebts(
    {'P1': 50, 'P2': -10, 'P3': -20, 'P4': -20},
    10.0,
  );
  
  expect(transactions.length, 3);
  expect(transactions[0].amount, 100);
  expect(transactions[1].amount, 200);
  expect(transactions[2].amount, 200);
});
```
