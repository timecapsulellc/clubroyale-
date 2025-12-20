# Card Engine Selection Guide 🃏

This guide helps you identify and evaluate open-source card game repositories suitable for cloning into the TaasClub project.

---

## 🎯 What We Need

### Must-Have Requirements

1. **Complete Card Asset Library**
   - All 52 playing cards (Ace through King of all 4 suits)
   - Card back design
   - Format: PNG or SVG
   - Minimum resolution: 200x300px per card

2. **Core Game Mechanics**
   - Card shuffling algorithm
   - Card dealing logic
   - Turn-based state management
   - Card rendering widget

3. **License**
   - MIT, Apache 2.0, or other permissive license
   - Allows commercial use and modification

4. **Technology**
   - Built with Flutter/Dart
   - Compatible with null-safety (Dart ≥2.12)
   - Uses modern state management (Provider, Riverpod, BLoC, or basic setState)

### Nice-to-Have Features

- Card animations (dealing, playing, collecting)
- Multiplayer infrastructure (we'll replace with our own)
- Material 3 UI components
- Active maintenance (commits within last 12 months)

---

## 🔍 Search Strategy

### GitHub Search Queries

Use these search queries on GitHub:

```
language:dart "card game" OR "playing cards"
```

```
flutter "call break" OR "callbreak"
```

```
flutter "card game" stars:>5
```

```
flutter trump spades game
```

### Pub.dev Packages

Check these package categories:

- [Games & Entertainment](https://pub.dev/packages?q=topic%3Agames)
- Search for: `playing cards`, `card game`, `deck`

### Recommended Repositories (as of Dec 2025)

> **Note:** Always verify the current state and license before cloning

| Repository | Stars | Last Updated | License | Assets | Notes |
|------------|-------|--------------|---------|--------|-------|
| TBD | - | - | - | - | *Conduct research* |

---

## ✅ Evaluation Checklist

Use this checklist when evaluating a repository:

```markdown
## Repository Evaluation: [Repository Name]

**URL:** [GitHub URL]

### License & Legal
- [ ] Has an open-source license (MIT/Apache preferred)
- [ ] License allows commercial use
- [ ] License allows modification and distribution
- [ ] No copyright restrictions on assets

### Technical Compatibility
- [ ] Written in Flutter/Dart
- [ ] Null-safety enabled
- [ ] Minimum Flutter version ≤ 3.9.0 (our current version)
- [ ] No deprecated dependencies
- [ ] Builds without errors on `flutter build`

### Asset Quality
- [ ] Contains all 52 cards (13 ranks × 4 suits)
- [ ] Card back design included
- [ ] Assets are PNG or SVG format
- [ ] Resolution is at least 200x300px
- [ ] Visual quality is production-ready

### Code Quality
- [ ] Code is well-structured and readable
- [ ] Follows Flutter best practices
- [ ] Has documentation or README
- [ ] No obvious bugs or issues in GitHub Issues
- [ ] Reasonably modular (easy to extract components)

### Functionality
- [ ] Card shuffling works
- [ ] Card dealing works
- [ ] Card widget renders properly
- [ ] Turn-based logic is present
- [ ] Game state management exists

### Decision
- [ ] **APPROVED** - Ready to clone and integrate
- [ ] **REJECTED** - Reason: ___________________________
- [ ] **NEEDS MODIFICATION** - What needs fixing: _______
```

---

## 🛠️ Integration Process

Once you've selected a repository, follow these steps:

### Step 1: Clone to Temporary Location

```bash
# Clone outside your project directory
cd ~/temp
git clone <repository-url> card-engine-source

# Verify it builds
cd card-engine-source
flutter pub get
flutter analyze
flutter build apk --debug  # or flutter build web
```

### Step 2: Identify Key Components

Create a list of files to extract:

```markdown
## Files to Extract

### Assets
- [ ] assets/cards/*.png (or .svg)
- [ ] assets/card_back.png

### Models
- [ ] lib/models/card.dart
- [ ] lib/models/deck.dart
- [ ] lib/models/game_state.dart

### Services/Logic
- [ ] lib/services/deck_service.dart
- [ ] lib/services/game_logic.dart

### Widgets
- [ ] lib/widgets/card_widget.dart
- [ ] lib/widgets/hand_widget.dart

### Dependencies (from pubspec.yaml)
- [ ] <list any required packages>
```

### Step 3: Copy Assets

```bash
# Create assets directory in TaasClub
cd /Users/priyamagoswami/TassClub/TaasClub
mkdir -p assets/cards

# Copy card images
cp ~/temp/card-engine-source/assets/cards/* assets/cards/

# Verify assets were copied
ls -l assets/cards/
```

Update `pubspec.yaml`:

```yaml
flutter:
  assets:
    - assets/cards/
```

Run:
```bash
flutter pub get
```

### Step 4: Extract Code Components

Create the engine directory:

```bash
mkdir -p lib/features/game/engine
```

Copy and adapt the core files:

```bash
# Copy model files
cp ~/temp/card-engine-source/lib/models/card.dart lib/features/game/engine/card_model.dart

# Copy service files
cp ~/temp/card-engine-source/lib/services/deck_service.dart lib/features/game/engine/deck_service.dart

# Copy widget files
cp ~/temp/card-engine-source/lib/widgets/card_widget.dart lib/features/game/engine/card_widget.dart
```

### Step 5: Resolve Import Paths

Update all import statements in the copied files:

**Before:**
```dart
import '../models/card.dart';
import 'package:original_package_name/something.dart';
```

**After:**
```dart
import 'card_model.dart';
import 'package:taas_club/features/game/engine/card_model.dart';
```

### Step 6: Add Required Dependencies

Check the original `pubspec.yaml` and add any necessary dependencies:

```bash
# Example if they use a specific package
flutter pub add <package_name>
```

### Step 7: Run Flutter Analyze

```bash
flutter analyze
```

Fix any errors or warnings.

### Step 8: Create Integration Test

Create `lib/features/game/test_card_engine.dart`:

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
    _dealHand();
  }

  void _dealHand() {
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
            onPressed: _dealHand,
          ),
        ],
      ),
      body: Center(
        child: _hand.isEmpty
            ? const CircularProgressIndicator()
            : Wrap(
                spacing: 8,
                children: _hand.map((card) => CardWidget(card: card)).toList(),
              ),
      ),
    );
  }
}
```

Add a route in `lib/main.dart`:

```dart
GoRoute(
  path: '/test-cards',
  builder: (context, state) => const TestCardEngineScreen(),
),
```

Run the app and navigate to `/test-cards` to verify cards display correctly.

### Step 9: Clean Up

Remove any unused code from the cloned engine:

- Delete AI opponent logic (if present)
- Remove single-player modes
- Strip out their UI screens (lobby, settings, etc.)
- Keep only the core card mechanics

### Step 10: Documentation

Create `lib/features/game/engine/README.md`:

```markdown
# Card Game Engine

This directory contains the core card game engine cloned from [Original Repository](link).

## License
Original code licensed under [License Name]. See LICENSE file.

## Components

### Models
- `card_model.dart` - Playing card data structure
- `deck_model.dart` - Deck representation

### Services
- `deck_service.dart` - Shuffling and dealing logic
- `game_logic.dart` - Turn management

### Widgets
- `card_widget.dart` - Visual card rendering
- `hand_widget.dart` - Player hand display

## Usage

```dart
final deckService = DeckService();
final hand = deckService.dealCards(13);
```

## Credits
Based on [Original Repository Name] by [Author].
```

---

## ⚠️ Common Issues & Solutions

### Issue 1: Import Errors

**Error:**
```
Error: Can't find file 'package:old_package_name/...'
```

**Solution:**
Update all imports to use your package name (`taas_club`) and correct relative paths.

---

### Issue 2: Null Safety Errors

**Error:**
```
Error: The parameter 'card' can't have a value of 'null'...
```

**Solution:**
Add null checks or update the code to use non-nullable types:

```dart
// Before
PlayingCard? card;

// After
late PlayingCard card;
```

---

### Issue 3: Missing Assets

**Error:**
```
Unable to load asset: assets/cards/ace_spades.png
```

**Solution:**
1. Verify assets were copied correctly
2. Check `pubspec.yaml` has the correct path
3. Run `flutter clean` and `flutter pub get`
4. Restart the app

---

### Issue 4: Incompatible State Management

**Error:**
```
Error: The method 'Provider.of' isn't defined...
```

**Solution:**
If the cloned code uses a different state management library (Provider, BLoC, etc.), either:
1. Add that dependency: `flutter pub add provider`
2. OR refactor the code to use Riverpod (your current state management)

---

### Issue 5: Deprecated Flutter APIs

**Error:**
```
Warning: 'FlatButton' is deprecated...
```

**Solution:**
Update deprecated widgets:

```dart
// Old
FlatButton(...)

// New
TextButton(...)
```

---

## 📋 Post-Integration Checklist

After integrating the cloned engine, verify:

- [ ] App builds without errors (`flutter build apk`)
- [ ] All 52 cards render correctly
- [ ] Card shuffling produces random results
- [ ] Card dealing distributes correctly (13 cards × 4 players)
- [ ] No console warnings or errors
- [ ] Card animations work (if included)
- [ ] Assets load on both Android and iOS
- [ ] Test screen shows cards properly
- [ ] Code follows your project's style guide
- [ ] Engine is documented in README

---

## 🎯 Success Criteria

You've successfully integrated the card engine when:

1. ✅ You can display any playing card on screen
2. ✅ You can shuffle a deck and get random order
3. ✅ You can deal 13 cards to 4 players
4. ✅ All assets load without errors
5. ✅ Code compiles with zero errors
6. ✅ Engine components are isolated in `lib/features/game/engine/`

---

## 🚀 Next Steps

Once the engine is integrated:

1. **Move to Phase 4:** Build the lobby system on top of this engine
2. **Design game flow:** Plan how players will interact with cards
3. **Implement Call Break rules:** Add game-specific logic
4. **Build settlement calculator:** Connect game results to financial tracking

---

**Last Updated:** December 5, 2025  
**Status:** Ready for repository research and selection
