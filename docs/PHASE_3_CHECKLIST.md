# Phase 3 Implementation Checklist ✓

**Goal:** Integrate a cloned card game engine into TaasClub

**Estimated Time:** 2-4 hours  
**Status:** 🔜 Not Started

---

## 🔍 Step 1: Repository Research (30 min)

### Search for Repositories

- [ ] Search GitHub: `flutter call break`
- [ ] Search GitHub: `flutter card game`
- [ ] Search GitHub: `flutter playing cards`
- [ ] Check pub.dev for card game packages
- [ ] Create a shortlist of 2-3 candidates

### Evaluate Each Candidate

For each repository, check:

- [ ] Has MIT or Apache 2.0 license
- [ ] Contains all 52 card assets (PNG or SVG)
- [ ] Has card back design
- [ ] Includes shuffling and dealing logic
- [ ] Has card rendering widget
- [ ] Last updated within 12 months (preferred)
- [ ] Builds without major errors
- [ ] Code is relatively clean and readable

**Use this evaluation form:** [CARD_ENGINE_SELECTION.md](file:///Users/priyamagoswami/TassClub/TaasClub/docs/CARD_ENGINE_SELECTION.md)

### Document Your Selection

- [ ] Record selected repository URL: `___________________________`
- [ ] Record repository license: `___________________________`
- [ ] Take screenshots of card assets for reference
- [ ] Note any特殊 requirements or dependencies

---

## 📦 Step 2: Clone & Verify (15 min)

### Clone to Temporary Location

```bash
# Clone outside your project directory
cd ~/temp
git clone <selected-repository-url> card-engine-source
cd card-engine-source
```

- [ ] Repository cloned successfully

### Verify It Builds

```bash
# Install dependencies
flutter pub get

# Check for errors
flutter analyze

# Try to build (choose one based on your platform)
flutter build apk --debug    # For Android
# OR
flutter build web            # For Web
```

- [ ] Dependencies installed without errors
- [ ] No critical analysis errors
- [ ] Builds successfully (or minor fixable issues only)

### Explore the Structure

```bash
# Find card assets
find . -name "*.png" | grep -i card
find . -name "*.svg" | grep -i card

# Find key code files
find lib -name "*card*.dart"
find lib -name "*deck*.dart"
find lib -name "*game*.dart"
```

- [ ] Located card asset directory: `___________________________`
- [ ] Located card model file: `___________________________`
- [ ] Located deck service file: `___________________________`
- [ ] Located card widget file: `___________________________`

---

## 🎨 Step 3: Extract Card Assets (10 min)

### Create Assets Directory

```bash
cd /Users/priyamagoswami/TassClub/TaasClub
mkdir -p assets/cards
```

- [ ] Assets directory created

### Copy Card Images

```bash
# Replace <source-path> with the actual path from Step 2
cp ~/temp/card-engine-source/<source-path>/*.png assets/cards/
# OR for SVG
cp ~/temp/card-engine-source/<source-path>/*.svg assets/cards/
```

- [ ] Card images copied to `assets/cards/`

### Verify All 52 Cards + Back

```bash
ls -1 assets/cards/ | wc -l   # Should be 53 (52 cards + 1 back)
ls assets/cards/
```

- [ ] Total files: `_____` (should be 53 or more)
- [ ] Has all ranks: Ace, 2-10, Jack, Queen, King
- [ ] Has all suits: Spades, Hearts, Diamonds, Clubs
- [ ] Has card back image

### Update pubspec.yaml

Add to `pubspec.yaml`:

```yaml
flutter:
  assets:
    - assets/cards/
```

- [ ] Updated `pubspec.yaml`

### Install Assets

```bash
flutter pub get
```

- [ ] Assets registered with Flutter

---

## 🔧 Step 4: Extract Code Components (30-60 min)

### Create Engine Directory

```bash
mkdir -p lib/features/game/engine
```

- [ ] Engine directory created

### Copy Card Model

```bash
# Adjust source path based on your repository structure
cp ~/temp/card-engine-source/lib/models/card.dart \
   lib/features/game/engine/card_model.dart
```

- [ ] `card_model.dart` copied

### Copy Deck Service

```bash
cp ~/temp/card-engine-source/lib/services/deck*.dart \
   lib/features/game/engine/deck_service.dart
```

- [ ] `deck_service.dart` copied

### Copy Card Widget

```bash
cp ~/temp/card-engine-source/lib/widgets/card*.dart \
   lib/features/game/engine/card_widget.dart
```

- [ ] `card_widget.dart` copied

### Fix Import Paths

Open each copied file and update imports:

**Files to edit:**
1. `lib/features/game/engine/card_model.dart`
2. `lib/features/game/engine/deck_service.dart`
3. `lib/features/game/engine/card_widget.dart`

**Change:**
```dart
import '../models/card.dart';
import 'package:original_package/...';
```

**To:**
```dart
import 'card_model.dart';
import 'package:taas_club/features/game/engine/card_model.dart';
```

- [ ] Fixed imports in `card_model.dart`
- [ ] Fixed imports in `deck_service.dart`
- [ ] Fixed imports in `card_widget.dart`

### Add Missing Dependencies

Check if any packages are needed:

```bash
# Look at the original pubspec.yaml
cat ~/temp/card-engine-source/pubspec.yaml
```

Add any required packages:

```bash
flutter pub add <package_name>
```

- [ ] Added required dependencies (list): `___________________________`

---

## ✅ Step 5: Verify Integration (30 min)

### Run Flutter Analyze

```bash
flutter analyze
```

- [ ] Zero errors in engine files
- [ ] Warnings addressed or documented

### Create Test Screen

Create `lib/features/game/test_card_engine_screen.dart`:

```dart
import 'package:flutter/material.dart';
import 'engine/card_model.dart';
import 'engine/card_widget.dart';
import 'engine/deck_service.dart';

class TestCardEngineScreen extends StatefulWidget {
  const TestCardEngineScreen({super.key});

  @override
  State<TestCardEngineScreen> createState() => _TestCardEngineScreenState();
}

class _TestCardEngineScreenState extends State<TestCardEngineScreen> {
  late DeckService _deckService;
  List<PlayingCard> _hand = [];

  @override
  void initState() {
    super.initState();
    _deckService = DeckService();
    _shuffleAndDeal();
  }

  void _shuffleAndDeal() {
    setState(() {
      _hand = _deckService.dealCards(5);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Card Engine Test'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _shuffleAndDeal,
            tooltip: 'Deal New Hand',
          ),
        ],
      ),
      body: _hand.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : Center(
              child: Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _hand
                    .map((card) => SizedBox(
                          width: 100,
                          height: 140,
                          child: CardWidget(card: card),
                        ))
                    .toList(),
              ),
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: _shuffleAndDeal,
        child: const Icon(Icons.shuffle),
      ),
    );
  }
}
```

- [ ] Test screen created

### Add Route

In `lib/main.dart`, add a route to the test screen:

```dart
GoRoute(
  path: '/test-cards',
  builder: (context, state) => const TestCardEngineScreen(),
),
```

- [ ] Route added to router

### Run the App

```bash
flutter run
```

Navigate to the test screen (e.g., by adding a button or manually navigating to `/test-cards`).

- [ ] App builds and runs
- [ ] Test screen loads without errors
- [ ] Cards render visually
- [ ] All 5 cards display correctly
- [ ] Refresh button deals new random cards
- [ ] Different suits and ranks appear

### Test Card Variety

Click refresh multiple times and verify:

- [ ] Spades (♠️) render correctly
- [ ] Hearts (♥️) render correctly
- [ ] Diamonds (♦️) render correctly
- [ ] Clubs (♣️) render correctly
- [ ] Face cards (J, Q, K) render correctly
- [ ] Number cards (A, 2-10) render correctly
- [ ] Card back (if shown) renders correctly

---

## 📝 Step 6: Documentation (15 min)

### Create Engine README

Create `lib/features/game/engine/README.md`:

```markdown
# Card Game Engine

**Source:** [Repository URL]  
**License:** [License Name]  
**Cloned Date:** [Date]

## Components

### Models
- `card_model.dart` - Playing card data structure (Suit, Rank, PlayingCard)

### Services
- `deck_service.dart` - Deck shuffling and dealing logic

### Widgets
- `card_widget.dart` - Visual rendering of playing cards

## Usage

```dart
import 'package:taas_club/features/game/engine/deck_service.dart';
import 'package:taas_club/features/game/engine/card_model.dart';

final deckService = DeckService();
final hand = deckService.dealCards(13); // Deal 13 cards
```

## Assets

Card images are located in `assets/cards/` and registered in `pubspec.yaml`.

## Credits

Based on [Original Repository Name] by [Author].  
Original license: [License]
```

- [ ] Engine README created

### Add License Attribution

Create `lib/features/game/engine/LICENSE`:

```
This code is derived from [Repository Name] ([URL])

[Copy the original license text here]
```

- [ ] License file created

### Update Project Documentation

Add a note in `docs/DEVELOPMENT_ROADMAP.md`:

```markdown
### Phase 3: The Base Engine (✅ Completed)

**Cloned Repository:** [URL]  
**Integration Date:** [Date]  
**Components Extracted:**
- 52 card assets + card back
- Card model
- Deck service (shuffle/deal)
- Card rendering widget
```

- [ ] Updated development roadmap

---

## 🧹 Step 7: Clean Up (10 min)

### Remove Temporary Clone

```bash
rm -rf ~/temp/card-engine-source
```

- [ ] Temporary directory removed

### Remove Unused Code

Review the extracted files and remove:

- [ ] Any unused imports
- [ ] Commented-out code from the original repo
- [ ] Debug print statements
- [ ] Unused classes or functions

### Run Final Quality Checks

```bash
# Format code
flutter format lib/features/game/engine/

# Analyze
flutter analyze

# Clean build
flutter clean
flutter pub get
flutter run
```

- [ ] Code formatted
- [ ] No analysis errors
- [ ] App builds cleanly
- [ ] Test screen still works

---

## 🎉 Step 8: Completion Verification

### Final Checklist

Phase 3 is complete when ALL of these are true:

- [ ] ✅ Cloned a suitable open-source card game repository
- [ ] ✅ Extracted all 52 card assets to `assets/cards/`
- [ ] ✅ Copied core engine files to `lib/features/game/engine/`
- [ ] ✅ `CardWidget` renders any card correctly
- [ ] ✅ `DeckService` shuffles and deals cards without errors
- [ ] ✅ Created test screen showing 5 random cards
- [ ] ✅ App builds with zero errors
- [ ] ✅ All assets load on first launch
- [ ] ✅ Code is documented (README + LICENSE)
- [ ] ✅ Integration is verified with visual testing

### Sign-Off

**Completed by:** `___________________________`  
**Date:** `___________________________`  
**Repository used:** `___________________________`  
**Time spent:** `_____` hours

**Notes/Issues encountered:**
```
(Describe any issues and how they were resolved)
```

---

## 🚀 Next Steps

Once Phase 3 is complete, proceed to:

### Phase 4: Lobby System

- [ ] Design lobby UI mockups
- [ ] Create Firestore `game_rooms` collection schema
- [ ] Implement create/join game flow
- [ ] Build real-time player synchronization
- [ ] Add ready-check mechanism

**See:** [DEVELOPMENT_ROADMAP.md - Phase 4](file:///Users/priyamagoswami/TassClub/TaasClub/docs/DEVELOPMENT_ROADMAP.md)

---

**Last Updated:** December 5, 2025  
**Status:** Ready to execute  
**Estimated Time:** 2-4 hours
