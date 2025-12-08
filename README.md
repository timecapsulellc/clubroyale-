# TaasClub 🎮

A Flutter multiplayer card game platform featuring popular South Asian card games with real-time gameplay, social features, AI-powered matchmaking, and in-app purchases.

## 🎴 Games Available

| Game | Players | Status |
|------|---------|--------|
| **Marriage** | 2-8 | ✅ Full Multiplayer |
| **Call Break** | 4 | ✅ With AI Opponents |
| **Teen Patti** | 2-8 | ✅ With AI Bots |
| **In-Between** | 2-8 | ✅ With AI Bots |

## ✨ Features

### Core Gameplay
- 🔐 **Firebase Authentication** - Anonymous sign-in for quick start
- 🎲 **Game Rooms** - Create and join multiplayer rooms with room codes
- ⚡ **Real-time Gameplay** - Live game state sync using Firestore
- 💎 **Diamond Wallet** - In-app currency with RevenueCat integration
- 🎁 **Daily Bonus** - 100 diamonds per day + 1000 welcome diamonds

### Social Features (NEW)
- 👥 **Online Players** - See who's online in the lobby
- 🤝 **Friends System** - Send/accept friend requests
- 📨 **Game Invites** - Invite friends to your game room
- 💬 **Global Chat** - Chat in lobby with GenKit AI moderation
- 📩 **Direct Messages** - 1:1 private messaging

### AI & Matchmaking (NEW)
- 🏆 **ELO Rating System** - Skill-based ranking (Bronze → Diamond)
- ⚡ **Quick Match** - Instant matchmaking with similar-skill players
- 🤖 **GenKit AI Flows** - Bot play, bid suggestions, game tips, moderation

### Communication
- 🎤 **Voice Chat** - WebRTC-based audio during games
- 📹 **Video Chat** - LiveKit video grid in game rooms
- 💬 **In-Game Chat** - Text messaging with AI moderation

## 🛠 Tech Stack

| Category | Technologies |
|----------|--------------|
| **Frontend** | Flutter 3.9+, Riverpod, go_router, Freezed |
| **Backend** | Firebase (Firestore, Auth, Functions, Storage) |
| **AI** | GenKit + Gemini Flash for game AI & moderation |
| **Real-time** | WebRTC (audio), LiveKit (video), Firestore (chat) |
| **Monetization** | RevenueCat (IAP), Diamond wallet system |

## 🚀 Getting Started

### Prerequisites
- Flutter SDK ^3.9.0
- Firebase CLI
- Node.js 18+ (for Cloud Functions)

### Installation

```bash
# Clone repository
git clone https://github.com/timecapsulellc/TaasClub.git
cd TaasClub

# Install Flutter dependencies
flutter pub get

# Generate Freezed files
dart run build_runner build --delete-conflicting-outputs

# Configure Firebase
flutterfire configure

# Run the app
flutter run -d chrome  # Web
flutter run -d android # Android
```

## 📁 Project Structure

```
lib/
├── core/
│   └── card_engine/          # Card, Deck, Meld logic
├── features/
│   ├── auth/                 # Authentication
│   ├── lobby/                # Room creation/joining
│   ├── wallet/               # Diamond purchases & bonuses
│   ├── chat/                 # In-game chat with moderation
│   ├── profile/              # User profiles
│   ├── social/               # NEW: Friends, Presence, Invites
│   │   ├── presence_service.dart
│   │   ├── friends_service.dart
│   │   ├── invite_service.dart
│   │   ├── dm_service.dart
│   │   ├── matchmaking_service.dart
│   │   └── widgets/
│   ├── ai/                   # GenKit AI integration
│   └── game/                 # Game engine & screens
├── games/
│   ├── call_break/
│   ├── marriage/
│   ├── teen_patti/
│   └── in_between/
└── main.dart

functions/
└── src/
    └── genkit/
        └── flows/
            ├── gameTipFlow.ts
            ├── botPlayFlow.ts
            ├── moderationFlow.ts
            ├── bidSuggestionFlow.ts
            └── matchmakingFlow.ts   # NEW
```

## 🧪 Testing

```bash
# Run all tests
flutter test

# Current test count: 169 passing
```

## 📊 Current Status

| Metric | Value |
|--------|-------|
| **Project Completion** | 98% |
| **Tests Passing** | 169 |
| **Games** | 4 fully implemented |
| **Social Features** | Fully implemented |
| **AI Flows** | 5 GenKit flows |
| **Last Updated** | December 8, 2025 |

## 🔧 Development Commands

```bash
# Generate Freezed files
dart run build_runner build --delete-conflicting-outputs

# Analyze code
flutter analyze

# Deploy web app
flutter build web --release
firebase deploy --only hosting

# Deploy Cloud Functions
cd functions && npm run build && firebase deploy --only functions
```

## 📚 Documentation

| Document | Description |
|----------|-------------|
| [ARCHITECTURE_AUDIT.md](docs/ARCHITECTURE_AUDIT.md) | Latest architecture & audit |
| [REMAINING_TASKS.md](docs/REMAINING_TASKS.md) | Outstanding work |
| [GETTING_STARTED.md](docs/GETTING_STARTED.md) | Developer onboarding |
| [LIVEKIT_SETUP.md](docs/LIVEKIT_SETUP.md) | Video/audio setup |

## 🌐 Deployment

**Live URL:** https://taasclub-app.web.app

## License

This project is private and proprietary.

## Contact

For questions or support, please contact the development team.
