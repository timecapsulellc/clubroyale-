# UI/UX Reference Analysis
**Source:** User uploaded screenshots (Teen Patti / Taas app).
**Goal:** Adapt TaasClub UI to match this "Premium Nepali Card Game" aesthetic.

## 1. Core Visual Identity
*   **Theme:** Casino/Tabletop Green.
*   **Background:** Deep forest green felt texture (#2E8B57 approx) with lighter green geometric/curved vector overlays for table edges.
*   **Accent Colors:**
    *   **Gold/Yellow:** (#FFD700) Used for buttons, borders, and high-priority text.
    *   **Orange:** (#FF6B00 approx) Used for "BLIND" status, "Resume Game" button background.
    *   **Teal/Green:** (#006400) Darker shades for button backgrounds.
    *   **White:** Text and icons.

## 2. Layout & Structure

### A. Game Screen (Table View)
*   **Header (Top Left):** 
    *   Floating Action Buttons (FABs) for Menu, Sound, Info.
    *   **Style:** Circular, semi-transparent dark teal fill with **orange/gold border**. White icons.
*   **Players (Top & Sides):**
    *   **Avatar:** Circular image with a white/silver border.
    *   **Status Badge:** Rectangular tag next to avatar (e.g., "SEEN" in green, "BLIND" in orange).
    *   **Name:** White text, simple sans-serif.
*   **Game Log (Left Sidebar):**
    *   Vertical list of events ("Bot 1 has made a chaal...").
    *   **Style:** Translucent dark teal box with **dashed orange border**. White text.
*   **Center Area:**
    *   **Pot/Chips:** Stack of gold coins icons + numeric value.
    *   **Watermark:** "Teen Patti" / "Taas" logo faded in background.
*   **Player Controls (Bottom):**
    *   **Hand:** Cards fanned out.
    *   **Action Buttons:** Large, circular or oval. 
        *   "Pack", "See Cards", "Chaal".
        *   Solid fill (teal or orange) with **double gold borders**.
    *   **Betting Controls:** `+` / `-` circular buttons with amount display.

### B. Home Screen (Menu)
*   **Structure:**
    *   **Top Bar:** User profile (Avatar + Level + Coins), Language Toggle (UK/Nepal flag).
    *   **Title:** "Taas : Nepali Card Games" in a stylized modal header.
    *   **Game Grid:** Horizontal scroll or grid of games (Marriage, Call Break, Dhumbal, Flash).
        *   **Card:** Rectangular, glass-morphism or dark modal style.
        *   **Icon:** Realistic playing cards illustration.
        *   **Label:** Cursive/Script font for game names (e.g., "Marriage").
    *   **Bottom Navigation:** Large icons with labels (Solo Games, Account, Settings, Store, Go Back).

### C. Scoreboard
*   **Style:** Full-screen modal overlay.
*   **Colors:** Green background, yellow text for headers ("Scores List", "Round 1").
*   **Grid:** Simple table layout. white text for scores.
*   **Footer:** Long horizontal line separator. "Resume Game" button (Gradient Orange/Gold).

## 3. Typography
*   **Headings:** Serif or Script font (likely "Lobster" or similar) for Game Titles ("Marriage", "Teen Patti").
*   **UI Text:** Clean Sans-Serif (Roboto or Open Sans) for readability. Bold weights for statuses.

## 4. Implementation Plan (Adaptation)
1.  **Global Theme:** Update `ThemeData` in `main.dart` to match the Green/Gold palette.
2.  **Game Screen Refactor:**
    *   Implement `TableLayout` widget with the curved green background.
    *   Build `PlayerAvatarWidget` with the specific status badge style.
    *   Build `GameLogOverlay` with the dashed border style.
3.  **Controls:** Create `CasinoButton` widget (Gold border, gradient fill).
4.  **Home Screen:** Redesign `MainMenuScreen` to use the "Card Grid" layout.

---

## 5. Competitive Analysis: Taas by 3 Colors Interactive
**Play Store:** [Taas: Nepali Card Games](https://play.google.com/store/apps/details?id=com.sabytes.games.marriage)

### Features to IMPROVE UPON:

| Feature | Competitor Implementation | TaasClub Strategy (Better) |
|---|---|---|
| **Theme Store** | Basic list view, toggle switches. | **Premium Modal/Bottom Sheet** with animated carousel previews. Card-based selection. |
| **Card Skins** | Simple list, static previews. | **Interactive Preview** - show cards on a mini-table before purchase/selection.|
| **Level Gating** | High levels for themes (Level 85+). | **Fairer Progression** - unlock themes via achievements and challenges, not just level. |
| **Coin Cost** | Exorbitant prices (99999 for some). | **Achievable Pricing** with clear earning paths. Provide bundles. |
| **UI/UX** | Functional, but dated. Cluttered list. | **Modern, Premium Feel.** Use glassmorphism, micro-animations. Minimal clutter. |
| **Architecture** | Unclear. Likely monolithic. | **Clean Architecture (Flutter/Riverpod/Bloc)** with clear separation. |

### New Feature Requirements from Screenshots:

1.  **Game Store / Theme Selection:**
    *   Allow users to select table themes (Green, Dark, Blue, SkyBlue, Extra Dark, Light).
    *   Persist selection per user.
    *   Show preview of theme before applying.
    *   **TaasClub Twist:** Each theme can have a unique gameboard shader/animation.

2.  **Card Skins:**
    *   Classic Cards, Poker Style, Default Standard Cards (Big).
    *   Card Back customization.
    *   **TaasClub Twist:** Offer culturally relevant card designs (e.g., Nepali art).

3.  **User Profile in Header:**
    *   Coins/Diamonds display.
    *   Level/XP progress bar.
    *   Avatar.

