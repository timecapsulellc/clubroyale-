# Nepali Marriage Card Game: Comprehensive Rules & Implementation Guide

This is a comprehensive guide to the Nepali variant of the Marriage Card Game, specifically tailored for game development.
The Nepali variant is significantly more complex than the Indian or International versions due to its "two-phase" gameplay and the intricate "Maal" (Value Card) system. Below is the full ruleset, including terminology, logic, and custom rules (house rules).

---

## 1. Core Game Configuration

- **Decks**: 3 standard 52-card decks mixed together (Total: 156 cards).
- **Players**: 2 to 5 players.
- **Deal**: 21 cards per player.
- **Objective**: To organize all 21 cards into valid sets (Sequences, Trials, Tunnels) and be the first to "Close" the game.

---

## 2. Card Terminology (The "Maal" System)

In the Nepali variant, "Jokers" are not just wildcards; they are point multipliers called **Maal**. The identity of the Maal is hidden at the start and revealed only during gameplay.

### A. The Determining Card (Tiplu)
Once a player meets the "Primary Requirement" (see Section 3), they pick a random card from the deck. This card determines the Maal.
*   *Example*: If the card pulled is the **8 of Hearts (8♥)**.

### B. The Maal Cards (Point Cards)
Based on the example **8♥**:

| Term | Meaning | Cards (Example) | Value |
|------|---------|-----------------|-------|
| **Tiplu** | Main Maal | **8♥** | **3 Points** |
| **Poplu** | Upper Maal (Rank +1) | **9♥** | **2 Points** |
| **Jhiplu** | Lower Maal (Rank -1) | **7♥** | **2 Points** |
| **Alter** | Cross Maal (Same Rank & Color, Diff Suit) | **8♦** | **5 Points** |
| **Man** | Universal/Printed Joker | **Joker** | **2-5 Points** (Configurable) |

*   **Alter Note**: If Tiplu is 8♥ (Red), the Alter is 8♦ (Red). It is often treated as a high-value wildcard.
*   **Man Note**: In digital/custom versions, a specific card (like the printed Joker) is designated as "Man". It acts as a wildcard before and after the Tiplu is seen.

---

## 3. The Two-Phase Gameplay

The most distinct feature of the Nepali variant is that players cannot use Jokers/Maal or see the Tiplu until they prove they have a good hand.

### Phase 1: The "Pure" Grind (Primary Sets)
A player must form **3 Pure Sequences** (or Tunnels) to unlock the game.

-   **Pure Sequence**: 3+ consecutive cards of the same suit (e.g., `5♠-6♠-7♠`). **No wildcards allowed.**
-   **Tunnel (Tunnella)**: Three identical cards (e.g., `K♣-K♣-K♣`). This is the highest valued set.
-   **Restriction**: You **cannot** look at the hidden Tiplu or use any wildcards until you display these 3 sets on the table.

### Phase 2: The "Dirty" Game (Secondary Sets)
Once a player displays their 3 Pure sets:
1.  They **look** at the hidden Tiplu card.
2.  They now **know** what the wildcards are (Tiplu, Poplu, Jhiplu, Alter).
3.  They can now use these wildcards to finish arranging their remaining 12 cards into "Dirty" sets (Impure sequences or Trials).

---

## 4. Custom Rules & Variations (Development Toggles)

These are the specific logic toggles implemented to allow players to customize their lobby.

### A. "Kidnap" (The High Stakes Rule)
-   **Logic**: If Player A finishes the game (closes) while Player B is still in Phase 1 (has not shown their pure sets), Player B is "Kidnapped."
-   **Penalty**: Player B gets **0 points** for any Maal cards they hold. Their Maal points are transferred (kidnapped) to the Winner.
-   **Dev Note**: Boolean toggle `isKidnapEnabled`.

### B. "Murder" (The Hardcore Rule)
-   **Logic**: Similar to Kidnap, but instead of transferring points, the points are simply destroyed.
-   **Penalty**: Any player who hasn't entered Phase 2 gets -100 (or a set penalty) and their Maal cards are ignored completely during scoring.

### C. "Tunnel Pachaunu" (Tunnel Validation)
-   **Logic**: In standard rules, a Tunnel (e.g., `7♠-7♠-7♠`) is worth 5 points immediately. In this variation, a player must successfully enter Phase 2 (show 3 pure sets) to claim their Tunnel points.
-   **Scenario**: If you have a Tunnel but lose the game before showing your pure sets, your Tunnel is worth **0 points**.

### D. The "Dublee" Mode (Pairs)
-   **Logic**: Instead of making sequences, the player attempts to make 7 pairs (Dublee).
-   **Dublee**: Two identical cards (e.g., `9♦-9♦`).
-   **Gameplay**: If a player has 7 Dublees, they can show them to "see the Tiplu." They must then make one final Dublee (8 total) to win the game.

### E. "Visisting the Pile" (Strict Discard Rule)
-   **Standard Rule**: You can pick the discarded card only if you use it immediately to form a set.
-   **Strict Visiting Rule**: You **cannot** pick from the discard pile at all until you have "Visited" (Opened your game). You are forced to draw from the deck until you unlock.

---

## 5. Scoring Algorithm (The "Maal" Calculation)

Scoring in Nepali Marriage is not just about who wins; it is a **Net-Sum** calculation of the "Maal" cards held by every player.

### Step 1: Game Points (Win/Loss)
-   **Winner**: Receives +10 points from every player.
-   **Phase 1 Losers**: Pay **10 points** to the winner.
-   **Phase 2 Losers**: Pay **3 points** to the winner.

### Step 2: Maal Points (The Economy)
Every player counts the value of the Maal cards in their hand.
-   Tiplu: 3 pts
-   Poplu: 2 pts
-   Jhiplu: 2 pts
-   Tunnel: 5 pts
-   Alter: 5 pts

### Step 3: The Net Calculation
Each player settles the difference with every other player.
**Formula**:
`NetScore[i] = (GameWinPoints) + SUM(MaalPoints[i] - MaalPoints[j])` for all `j != i`.

### Summary for Developers
| Term | Meaning | Point Value (Standard) |
|------|---------|------------------------|
| **Tiplu** | The Main Joker | 3 |
| **Poplu** | Rank +1 of Tiplu | 2 |
| **Jhiplu** | Rank -1 of Tiplu | 2 |
| **Alter** | Tiplu Rank + Same Color + Diff Suit | 5 |
| **Tunnel** | Three Identical Cards | 5 |
| **Marriage** | Holding Tiplu + Poplu + Jhiplu | +10 Bonus |

---

## 6. Implementation Architecture

### Game Config JSON Structure
For development, the game rules object is structured as follows:

```json
{
  "gameVariant": "NEPALI_MARRIAGE",
  "visitingRules": {
    "sequencesRequired": 3,
    "allowDubleeVisit": true,
    "dubleeCountRequired": 7,
    "tunnelAsSequence": true
  },
  "maalRules": {
    "tipluValue": 3,
    "popluValue": 2,
    "jhipluValue": 2,
    "alterValue": 5,
    "isManEnabled": true
  },
  "penalties": {
    "enableKidnap": true,
    "enableMurder": false,
    "unvisitedPenalty": 10,
    "visitedPenalty": 3
  }
}
```

### Visiting Logic (Gatekeeper)
-   **Sequence Visit**: Requires `3 Pure Sequences`.
-   **Dublee Visit**: Requires `7 Pairs`.
-   **Tunnel Visit**: `3 Tunnels` is often an instant win.

### Maal Calculation Logic
The Maal value of a hand is dynamic and calculated *after* the Tiplu is revealed.
1.  Identify Tiplu (Rank/Suit).
2.  Calculate Identities of Poplu, Jhiplu, Alter.
3.  Scan Hand for these identities and sum their values.
4.  Apply Kidnap/Murder logic if applicable (set points to 0 if unvisited).

---

## 7. Verified Implementation Status (Jan 5, 2026)
 
 The following logic has been audited and confirmed in `lib/games/`:
 
 ### Marriage (Royal Meld)
 - [x] **Vesting / Strict Discard**: Implemented in `drawFromDiscard`.
 - [x] **Joker Block**: Implemented in `drawFromDiscard`.
 - [x] **Kidnap Logic**: Verified in `MarriageScorer`. Points transfer correctly from unvisited losers.
 - [x] **Tunnel Win**: Validated. 3 Tunnels triggers immediate win.
 - [x] **Maal System**: Tiplu, Poplu, Jhiplu, Alter, Man verified.
 - [x] **Dublee**: Logic for 7+1 pairs verified.
 
 ### Other Games
 - [x] **Call Break**: Scoring (underbid penalty, overtrick bonus) verified.
 - [x] **Teen Patti**: Hand integrity (Trail > Pure > Sequence...) verified.
 - [x] **In-Between**: Edge cases (A-A boundary, Post rule) verified.
