# Nepali Marriage Card Game: Developer Ruleset

This document outlines the specific rules, logic, and variants for the Nepali style of Marriage Card Game implemented in ClubRoyale.

## 1. Core Configuration
- **Decks**: 3 Standard Decks (156 cards total).
- **Cards per Player**: 21.
- **Players**: 2-5 (Recommended).

## 2. The "Maal" System (Value Cards)
In Nepali Marriage, Jokers are point multipliers. The identity of the "Main Maal" (Tiplu) is hidden until a player "Opens" (Phase 2).

### Dynamic Maal Calculation
If Tiplu (Center Card) is **8 of Hearts (8♥)**:
1.  **Tiplu** (Main): 8♥ - **3 Points**
2.  **Poplu** (Upper): 9♥ (Rank + 1) - **2 Points**
3.  **Jhiplu** (Lower): 7♥ (Rank - 1) - **2 Points**
4.  **Alter** (Cross): 8♦ (Same Rank, Same Color, Diff Suit) - **5 Points**
5.  **Man** (Fixed): Printed Joker - **5 Points** (Configurable)

## 3. Two-Phase Gameplay
The game is strictly divided into two phases for each player.

### Phase 1: The "Pure" Grind (Locked)
- **State**: Player cannot see the Tiplu. Player cannot use any Wildcards (Maal) in sets.
- **Goal**: Form the "Gateway Collection" to unlock Phase 2.
- **Gateway Requirement**:
    - **3 Pure Sequences** (e.g., 2♥-3♥-4♥). No wilds.
    - OR **7 Dublees** (Pairs) if playing Dublee mode.
    - **Tunnels** (3 Identical cards) count as a Pure Sequence.

### Phase 2: The "Dirty" Game (Unlocked)
- **Trigger**: Player shows/declares their 3 Pure Sequences.
- **Effect**:
    - Player can now **See** the Tiplu.
    - Player knows which cards are wild.
    - Player can use wildcards to complete remaining sets.
    - Player is "Safe" from Kidnap penalty.

## 4. Scoring Logic (Zero-Sum Settlement)
Scoring is a matrix where every player pays/receives from every other player.

### A. Game Points (Win/Loss)
- **Winner**: Receives points from all losers.
- **Loser (Visited/Open)**: Pays **3 points** to Winner.
- **Loser (Locked/Closed)**: Pays **10 points** to Winner.

### B. Maal Exchange
Everyone compares Maal points with everyone else.
`NetScore = (MyTotalMaal - OpponentTotalMaal) * PointRate`

### C. Advanced Variants
1.  **Kidnap**: If Winner closes while Loser is "Locked" (Phase 1):
    - Loser's Maal points = 0.
    - Winner gets Loser's Maal points (Steal).
2.  **Murder**: Similar to Kidnap, but points are destroyed (Loser gets 0, Winner gets nothing extra from them).
3.  **Tunnel Pachaunu**: Tunnel (5 pts) typically valid only if Visited. If Locked, Tunnel = 0 pts.

### D. Interaction Rules
4.  **Vesting (Strict Visit)**: Player cannot pick from discard pile until Visited (Phase 2). Must draw from deck.
5.  **Joker Block**: If discard pile top card is a Joker/Maal, it cannot be picked up.

## 5. Development Implementation Checklist
- [x] **Game Phase Tracker**: Track `isVisited` (bool) for each player.
- [x] **Maal Visibility**: `Tiplu` is null/hidden for player until `isVisited == true`.
- [x] **Validation**: `isValidMove` prevents using Jokers in Phase 1.
- [x] **Scoring**: Implement Kidnap/Murder logic in `calculateFinalSettlement`.
- [x] **Vesting**: Enforce strict discard rules.
