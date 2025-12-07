# TaasClub 🎮

A Flutter multiplayer card game platform featuring popular South Asian card games with real-time gameplay, in-app purchases, and social features.

## 🎴 Games Available

| Game | Players | Status |
|------|---------|--------|
| **Marriage** | 2-8 | ✅ Full Multiplayer |
| **Call Break** | 4 | ✅ With AI Opponents |
| **Teen Patti** | 2-8 | ✅ With AI Bots |
| **In-Between** | 2-8 | ✅ With AI Bots |

## ✨ Features

- 🔐 **Firebase Authentication** - Anonymous sign-in for quick start
- 🎲 **Game Rooms** - Create and join multiplayer rooms with room codes
- ⚡ **Real-time Gameplay** - Live game state sync using Firestore
- 💎 **Diamond Wallet** - In-app currency with RevenueCat integration
- 📊 **Game History** - View past games and results
- 🏆 **Leaderboard** - See top players ranked by score
- 👤 **User Profiles** - Customize display name and avatar
- 📤 **Share Results** - Share game results with friends

## 🃏 Card Engine

The app includes a complete card engine (`lib/core/card_engine/`) with:
- 56 card assets (52 cards + jokers + card backs)
- Deck management (1-4 decks with shuffling/dealing)
- Meld detection (Sets, Runs, Tunnels, Marriage)
- Hand validation with backtracking algorithm

## 🛠 Tech Stack

- **Flutter** 3.9+ - Cross-platform UI framework
- **Firebase** - Backend services
  - Firestore (real-time database)
  - Authentication
  - Storage (avatars)
  - Cloud Functions (GenKit AI)
  - Crashlytics
- **Riverpod** - State management
- **go_router** - Navigation
- **Freezed** - Immutable data classes
- **RevenueCat** - In-app purchases
- **LiveKit** - Real-time video/audio

## 🚀 Getting Started

### Prerequisites

- Flutter SDK ^3.9.0
- Firebase CLI
- A Firebase project

### Installation

1. Clone the repository:
   ```bash
   git clone https://github.com/timecapsulellc/TaasClub.git
   cd TaasClub
   ```

2. Install dependencies:
   ```bash
   flutter pub get
   ```

3. Configure Firebase:
   ```bash
   flutterfire configure
   ```

4. Run the app:
   ```bash
   flutter run -d chrome  # Web
   flutter run -d android # Android
   flutter run -d ios     # iOS
   ```

## 📁 Project Structure

```
lib/
├── core/
│   └── card_engine/      # Card, Deck, Meld logic
├── features/
│   ├── auth/             # Authentication
│   ├── lobby/            # Room creation/joining
│   ├── wallet/           # Diamond purchases
│   ├── ledger/           # Game history
│   ├── profile/          # User profiles
│   └── game/             # General game screens
├── games/
│   ├── call_break/       # Call Break game
│   ├── marriage/         # Marriage game
│   ├── teen_patti/       # Teen Patti game
│   └── in_between/       # In-Between game
└── main.dart
```

## 🧪 Testing

```bash
# Run all tests
flutter test

# Run game tests only (89 tests)
flutter test test/games/

# Run specific game tests
flutter test test/games/marriage/
flutter test test/games/call_break/
```

**Test Coverage:**
- Marriage: 52 tests (integration + unit)
- Call Break: 20 tests
- General: 17 tests

## 🎯 Game Routes

| Route | Game |
|-------|------|
| `/call-break` | Call Break (solo with AI) |
| `/marriage` | Marriage (solo practice) |
| `/marriage/:roomId` | Marriage (multiplayer) |
| `/teen_patti/:roomId` | Teen Patti |
| `/in_between/:roomId` | In-Between |

## 📚 Documentation

| Document | Description |
|----------|-------------|
| [PROJECT_AUDIT_DEC7.md](docs/PROJECT_AUDIT_DEC7.md) | Latest project status |
| [REMAINING_TASKS.md](docs/REMAINING_TASKS.md) | Task list and progress |
| [GETTING_STARTED.md](docs/GETTING_STARTED.md) | Developer onboarding |
| [REVENUECAT_SETUP.md](docs/REVENUECAT_SETUP.md) | IAP configuration |
| [LIVEKIT_SETUP.md](docs/LIVEKIT_SETUP.md) | Video/audio setup |

## 🔧 Development Commands

```bash
# Generate Freezed files
dart run build_runner build --delete-conflicting-outputs

# Analyze code
flutter analyze

# Deploy Firestore rules
firebase deploy --only firestore:rules

# Deploy Cloud Functions
cd functions && npm run build && firebase deploy --only functions
```

## 📊 Current Status

- **Project Completion:** 94%
- **Tests Passing:** 156
- **Games:** 4 fully implemented
- **Last Updated:** December 7, 2025

## 🚧 Remaining Work

1. Settlement preview screen
2. Matchmaking queue
3. Move validation Cloud Functions

See [REMAINING_TASKS.md](docs/REMAINING_TASKS.md) for details.

## License

This project is private and proprietary.

## Contact

For questions or support, please contact the development team.
