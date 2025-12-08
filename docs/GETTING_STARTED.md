# 🚀 TaasClub - Getting Started Guide

**Welcome to TaasClub!** This guide will help you get started with development.

> **Project Status:** 98% Production Ready ✅  
> **Live URL:** https://taasclub-app.web.app  
> **Last Updated:** December 8, 2025

---

## 🎯 Quick Start (5 minutes)

### 1. Clone & Run

```bash
# Clone repository
git clone https://github.com/timecapsulellc/TaasClub.git
cd TaasClub

# Install dependencies
flutter pub get

# Generate Freezed files
dart run build_runner build --delete-conflicting-outputs

# Run the app
flutter run -d chrome
```

### 2. Key Documentation

| Document | Description |
|----------|-------------|
| [README.md](../README.md) | Project overview |
| [ARCHITECTURE_AUDIT.md](ARCHITECTURE_AUDIT.md) | Technical audit & features |
| [REMAINING_TASKS.md](REMAINING_TASKS.md) | Outstanding work |

---

## 🎮 What is TaasClub?

A multiplayer card game platform with **4 games**, **social features**, **AI matchmaking**, and **real-time communication**.

### Games
- 🎴 **Marriage** (2-8 players)
- ♠️ **Call Break** (4 players)
- 🃏 **Teen Patti** (2-8 players)
- 🎰 **In-Between** (2-8 players)

### Key Features
- 💎 Diamond wallet with daily bonuses
- 👥 Friends, presence, game invites
- 🤖 GenKit AI (bot play, moderation, matchmaking)
- 🎤 Voice & video chat (WebRTC/LiveKit)
- 🏆 ELO ranking system

---

## 🏗️ Project Architecture

```
lib/
├── core/card_engine/     # Card assets & logic
├── features/
│   ├── auth/             # Firebase Auth
│   ├── chat/             # In-game chat
│   ├── lobby/            # Room management
│   ├── wallet/           # Diamond economy
│   ├── social/           # Friends, invites, matchmaking
│   ├── ai/               # GenKit integration
│   └── game/             # Game engine
└── games/
    ├── marriage/
    ├── call_break/
    ├── teen_patti/
    └── in_between/

functions/src/genkit/flows/
    ├── gameTipFlow.ts
    ├── botPlayFlow.ts
    ├── moderationFlow.ts
    ├── bidSuggestionFlow.ts
    └── matchmakingFlow.ts
```

---

## 🛠️ Development Commands

```bash
# Install dependencies
flutter pub get

# Generate Freezed models
dart run build_runner build --delete-conflicting-outputs

# Run tests
flutter test

# Analyze code
flutter analyze

# Build web
flutter build web --release

# Deploy web
npx firebase deploy --only hosting

# Deploy functions
cd functions && npm run build && firebase deploy --only functions
```

---

## 🧪 Testing

```bash
# Run all 169 tests
flutter test

# Run specific game tests
flutter test test/games/marriage/
flutter test test/games/call_break/
```

---

## 📊 Current Status

| Category | Status |
|----------|--------|
| Games | ✅ 4 Complete |
| Social | ✅ Complete |
| AI/GenKit | ✅ 5 Flows |
| Communication | ✅ Chat/Audio/Video |
| Economy | ✅ Diamonds + Bonuses |
| Tests | ✅ 169 Passing |

---

## 🚀 Deployment

### Web (Already Deployed)
```bash
flutter build web --release
npx firebase deploy --only hosting
```

### Android
```bash
flutter build appbundle --release
# Upload to Play Console
```

### Cloud Functions
```bash
cd functions
npm run build
firebase deploy --only functions
```

---

## 📚 Further Reading

- [Architecture Audit](ARCHITECTURE_AUDIT.md) - Full technical details
- [LiveKit Setup](LIVEKIT_SETUP.md) - Video/audio configuration
- [RevenueCat Setup](REVENUECAT_SETUP.md) - IAP configuration

---

**Live App:** https://taasclub-app.web.app 🎮
