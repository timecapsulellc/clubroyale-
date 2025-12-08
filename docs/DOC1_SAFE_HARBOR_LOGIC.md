# Doc 1: Safe Harbor Logic
## Legal Safety Framework

**Version:** 1.0  
**Date:** December 8, 2025  
**Strategy:** Private Club Ledger (Strategy A)

---

## Core Principle

> **The app is a CALCULATOR, not a BANK.**

---

## The Firewall Rule

There is a **strict separation** between:

| Inside App | Outside App |
|------------|-------------|
| Points | Cash |
| Chips | UPI |
| Scores | Bank Transfers |
| "Bill Images" | Real Money |
| Units | Rupees/Dollars |

---

## Critical Code Constraints

### ❌ NEVER Use These Terms in Code Logic:
- "Currency"
- "Rupee" / "₹"
- "Dollar" / "$"
- "Money"
- "Payment"
- "Wallet" (for real money)

### ✅ ALWAYS Use Instead:
- "Units"
- "Points"
- "Chips"
- "Score"
- "Diamonds" (virtual only)

---

## User Mental Model

The user decides mentally:
```
1 Unit = ₹10 (or any value they choose)
```

**The app NEVER knows or stores this conversion.**  
It only displays: "Player A owes Player B: 50 Units"

---

## Settlement Output Rules

### What We DO:
- Calculate score differences
- Generate text: "Amit owes Ravi: 500"
- Create shareable image/screenshot
- Display UPI ID (user-provided, NOT processed)

### What We DON'T DO:
- Process any payments
- Store bank/UPI details in our database
- Link to payment gateways for settlements
- Transfer any real money

---

## Monetization (Safe Revenue)

| Item | Cost | Purpose |
|------|------|---------|
| Diamonds | ₹100 = 100 | Virtual currency via IAP |
| Room Creation | 10 Diamonds | Host pays to create room |
| Ad-Free | 5 Diamonds/game | Disable ads for room |
| Guest Play | FREE | Friends join free |

**RevenueCat handles IAP** - Standard Apple/Google in-app purchase flow.

---

## Legal Positioning

| We Are | We Are NOT |
|--------|------------|
| Social card game | Gambling app |
| Digital scorekeeper | Payment processor |
| Bill generator | Money transfer service |
| Recreation app | Casino |

---

## Code Implementation Example

```dart
// ✅ CORRECT: Safe terminology
class SettlementService {
  List<String> calculateDebts(
    Map<String, int> playerScores,
    double unitValue, // NOT "rupeeValue"
  ) {
    // Returns: ["Player B pays A: 200 units"]
  }
}

// ❌ WRONG: Avoid this
class PaymentService {
  void transferMoney(double rupees) {
    // NEVER implement this
  }
}
```

---

## Compliance Checklist

- [ ] No real-money wallet in app
- [ ] No payment gateway integration for settlements
- [ ] "Units" terminology throughout codebase
- [ ] Settlement is text/image only
- [ ] Users settle offline (UPI/Cash/Bank)
- [ ] App Store category: "Games > Card"
- [ ] No "gambling" keywords in metadata

---

**Remember:** We are a digital scorekeeper. Users decide what "points" mean to them.
