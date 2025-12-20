# Marriage Card Game - Complete Rules Guide

> **Nepali Marriage (Mariage/Marriage)** is a popular South Asian rummy-style card game combining trick-taking, melding, and strategic wild cards. This guide covers both the **Nepali Standard** variant and the **Global/Casual** variant.

---

## Table of Contents

1. [Game Overview](#game-overview)
2. [Card Values and Terminology](#card-values-and-terminology)
3. [Game Setup](#game-setup)
4. [Gameplay Phases](#gameplay-phases)
5. [Visiting (Gatekeeper) System](#visiting-gatekeeper-system)
6. [Maal Cards and Scoring](#maal-cards-and-scoring)
7. [Winning the Game](#winning-the-game)
8. [Advanced Rules](#advanced-rules)
9. [Variant Comparison](#variant-comparison)
10. [FAQ](#faq)

---

## Game Overview

| Aspect | Details |
|--------|---------|
| **Players** | 2-6 (optimal: 3-4) |
| **Decks** | 3 standard decks (156 cards) including printed Jokers |
| **Cards per Player** | 21 cards |
| **Objective** | Form valid melds and declare before opponents |

### Core Concept

Marriage is a **draw-and-discard** game where players form **melds** (sets and sequences) from their hand. The unique twist is the **Tiplu** (wild card) system and the **Visiting** requirement that gates access to bonus Maal points.

---

## Card Values and Terminology

### Basic Card Values

| Card | Point Value |
|------|-------------|
| Ace (A) | 10 points |
| Face Cards (K, Q, J) | 10 points each |
| Number Cards (2-10) | Face value |
| Printed Joker | 0 points (but is Maal) |

### Key Terminology

| Term | Nepali | Global | Meaning |
|------|--------|--------|---------|
| **Tiplu** | टिप्लु | Wild Card | The center card that defines wild cards for the round |
| **Jhiplu** | झिप्लु | Low Wild | Card one rank BELOW Tiplu (same suit) |
| **Poplu** | पोप्लु | High Wild | Card one rank ABOVE Tiplu (same suit) |
| **Alter** | अल्टर | Color Match | Same rank + same color (different suit) as Tiplu |
| **Man** | मान | Joker | Printed Joker card |
| **Dublee** | डब्ली | Pair | Two cards of same rank and suit |
| **Tunnel** | टनेल | Triple | Three cards of same rank and suit |
| **Marriage** | म्यारेज | Royal Seq | Jhiplu + Tiplu + Poplu sequence |
| **Maal** | माल | Value Cards | Cards worth bonus points |
| **Visit** | भिजिट | Unlock | Showing 3 pure sequences to unlock Maal |

---

## Game Setup

### 1. Dealing
- Dealer shuffles 3 decks (156 cards)
- Each player receives **21 cards**
- One card is placed face-up in center → **Tiplu (Wild Card)**
- Remaining cards form the **Draw Pile**

### 2. Determining Tiplu/Wild Cards
Based on the center Tiplu card, the following become **Maal (Value) cards**:

```
Example: Tiplu = 7♠️

Tiplu:   7♠️ (3 points)
Jhiplu:  6♠️ (2 points) - one rank below
Poplu:   8♠️ (2 points) - one rank above
Alter:   7♣️ (5 points) - same rank, same color, different suit
Man:     🃏  (2 points) - printed Joker
```

---

## Gameplay Phases

### Turn Structure

Each turn has two phases:

```
┌─────────────────────────────────────────┐
│  DRAW PHASE                              │
│  ├─ Draw from Deck (always allowed)     │
│  └─ OR Pick from Discard (if allowed)   │
├─────────────────────────────────────────┤
│  DISCARD PHASE                           │
│  ├─ Discard one card face-up            │
│  ├─ OR Attempt to Visit                 │
│  └─ OR Declare (end game)               │
└─────────────────────────────────────────┘
```

### Meld Types

| Type | Cards | Example | Notes |
|------|-------|---------|-------|
| **Set/Trial** | 3+ same rank | K♠️ K♥️ K♦️ | Different suits |
| **Sequence/Run** | 3+ consecutive | 5♥️ 6♥️ 7♥️ | Same suit |
| **Pure Sequence** | Sequence without wilds | 5♥️ 6♥️ 7♥️ | Required for Visit |
| **Tunnel** | 3 identical cards | 7♠️ 7♠️ 7♠️ | Same rank AND suit |
| **Dublee** | 2 identical cards | 9♦️ 9♦️ | Same rank AND suit |

---

## Visiting (Gatekeeper) System

**Visiting** is a gatekeeper mechanic that **unlocks Maal bonus points**.

### How to Visit

You must show **3 Pure Sequences** (no wild cards) OR **7 Dublees** (pairs):

```
┌──────────────────────────────────────────┐
│  OPTION A: 3 Pure Sequences              │
│  ├─ 3♥️ 4♥️ 5♥️  (sequence 1)            │
│  ├─ J♠️ Q♠️ K♠️  (sequence 2)            │
│  └─ 8♣️ 9♣️ 10♣️ (sequence 3)            │
├──────────────────────────────────────────┤
│  OPTION B: 7 Dublees (Pairs)             │
│  └─ 7 pairs of identical cards           │
├──────────────────────────────────────────┤
│  OPTION C: 3 Tunnels (Instant Win)       │
│  └─ 3 sets of 3 identical cards = WIN    │
└──────────────────────────────────────────┘
```

### Before vs After Visiting

| Action | Before Visit (🔒) | After Visit (🔓) |
|--------|-------------------|------------------|
| Draw from Deck | ✅ Allowed | ✅ Allowed |
| Pick from Discard | ❌ Blocked* | ✅ Allowed |
| Use Maal in exchange | ❌ Worth 0 | ✅ Full value |
| Lose penalty | 10 points | 3 points |

> *Configurable rule: `mustVisitToPickDiscard`

---

## Maal Cards and Scoring

### Maal Point Values

| Maal Type | Default Points | Color | Badge |
|-----------|----------------|-------|-------|
| **Tiplu** | 3 | Purple | 👑 |
| **Poplu** | 2 | Blue | ⬆️ |
| **Jhiplu** | 2 | Cyan | ⬇️ |
| **Alter** | 5 | Orange | 💎 |
| **Man (Joker)** | 2 | Green | 🃏 |

### Marriage Bonus (100 points!)

The **Marriage** is when you have Jhiplu + Tiplu + Poplu in sequence:

```
If Tiplu = 7♠️:
Marriage = 6♠️ + 7♠️ + 8♠️ = 100 BONUS POINTS! 🎉
```

---

## Winning the Game

### Declaration

To **Declare** (win), you must have:
- **All 21 cards** arranged in valid melds
- **At least one pure sequence** (no wilds)
- **Zero deadwood** (unmelded cards)

### Scoring

When someone declares, scoring occurs:

#### Base Points (Zero-Sum)

| Player Status | Points |
|---------------|--------|
| **Winner** | +Points from all losers |
| **Loser (Visited)** | -3 points |
| **Loser (Unvisited)** | -10 points (Flat Penalty) |

#### Maal Exchange

Each player-pair exchanges Maal difference:

```
Player A (Visited): 8 Maal points
Player B (Visited): 5 Maal points
Player C (Not Visited): 12 Maal points → treated as 0!

A vs B: A gains +3 (8-5), B loses -3
A vs C: A gains +8 (8-0), C loses -8
B vs C: B gains +5 (5-0), C loses -5
```

---

## Advanced Rules

### Kidnap Rule (Default: Enabled)

If an opponent has **NOT Visited** when the game ends:
- Their Maal is treated as **0** for exchange
- They pay the **Flat Penalty** (10 points)
- The winner effectively "steals" the Maal advantage

### Murder Rule (Optional)

If enabled, unvisited players **lose all their held Maal** (it goes to the winner).

### Joker Block Rule

- **Printed Jokers cannot start the discard pile**
- Jokers drawn from deck can be discarded normally

### Turn Timer

- Default: **30 seconds** per turn
- On timeout: Auto-draw from deck, auto-discard first card

---

## Variant Comparison

| Feature | Nepali Standard | Global/Casual |
|---------|-----------------|---------------|
| Cards per player | 21 | 21 |
| Decks | 3 | 3 |
| Jokers included | ✅ Yes | ✅ Yes |
| Must Visit to pick discard | ✅ Yes | ❌ No |
| Kidnap rule | ✅ Enabled | ❌ Disabled |
| Murder rule | ❌ Disabled | ❌ Disabled |
| Dublee Win (7 pairs) | ✅ Allowed | ✅ Allowed |
| Tunnel counts as sequence | ✅ Yes | ✅ Yes |
| Turn timer | 30s | 45s |
| Maal point values | Standard | Standard |

---

## FAQ

### General Questions

**Q: How many cards do I start with?**
> A: 21 cards per player.

**Q: What is the Tiplu?**
> A: The center card that determines which cards are "wild" (can substitute any card in melds).

**Q: Can I use wild cards (Tiplu/Jhiplu/Poplu) in sequences?**
> A: Yes, but such sequences are NOT "pure" and cannot be used to Visit.

### Visiting Questions

**Q: What is "Visiting"?**
> A: Showing 3 pure sequences (no wilds) to unlock Maal bonus points.

**Q: Do I have to Visit to win?**
> A: No, but unvisited losers pay higher penalties and their Maal is worth 0.

**Q: Can I Visit with sequences that contain Jokers?**
> A: No, Visit requires **pure** sequences without any wild cards.

**Q: What happens if I have 7 pairs?**
> A: You can Visit with 7 Dublees (pairs) instead of 3 sequences.

### Maal Questions

**Q: What is Maal?**
> A: Bonus value cards (Tiplu, Jhiplu, Poplu, Alter, Man) worth extra points in scoring.

**Q: How do I know which cards are Maal?**
> A: In the app, Maal cards glow with colored borders and show emoji badges.

**Q: Do I gain Maal points if I haven't Visited?**
> A: No, unvisited players' Maal is treated as 0 during exchange.

### Scoring Questions

**Q: Is Marriage scoring zero-sum?**
> A: Yes, total points across all players always sum to zero.

**Q: What's the Flat Penalty?**
> A: Unvisited losers pay a fixed 10 points (instead of counting deadwood).

**Q: What is the Marriage bonus?**
> A: Having Jhiplu + Tiplu + Poplu (6♠️ + 7♠️ + 8♠️ if Tiplu is 7♠️) = 100 bonus points!

---

## Developer Notes

### Configuration Options

All rules are configurable via `MarriageGameConfig`:

```dart
MarriageGameConfig(
  cardsPerPlayer: 21,
  sequencesRequiredToVisit: 3,
  allowDubleeVisit: true,
  dubleeCountRequired: 7,
  mustVisitToPickDiscard: true,  // Nepali: true, Global: false
  enableKidnap: true,            // Nepali: true, Global: false
  enableMurder: false,
  tipluValue: 3,
  popluValue: 2,
  jhipluValue: 2,
  alterValue: 5,
  manValue: 2,
  unvisitedPenalty: 10,
  visitedPenalty: 3,
  turnTimeoutSeconds: 30,
)
```

### Adding New Rules

To add new rules:
1. Add config field to `MarriageGameConfig`
2. Implement logic check in `MarriageService` or `MarriageScorer`
3. Update UI to respect the config
4. Document in this guide

---

## Version History

| Version | Date | Changes |
|---------|------|---------|
| 1.0 | Dec 2025 | Initial rules implementation |
| 1.1 | Dec 2025 | Added Visiting Collections, Maal Glow UI |
| 1.2 | Dec 2025 | Added Dublee Sort, Flat Penalty confirmation |

---

*For technical implementation details, see [MARRIAGE_GAME_SPEC.md](./MARRIAGE_GAME_SPEC.md)*
