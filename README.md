# TaasClub

> **The Private Club Ledger** - A multiplayer card game platform with AI-powered gameplay

[![Live](https://img.shields.io/badge/Live-taasclub--app.web.app-brightgreen)](https://taasclub-app.web.app)
[![Android](https://img.shields.io/badge/Android-APK%20Ready-green)](https://taasclub-app.web.app/download.html)
[![Tests](https://img.shields.io/badge/Tests-169%20Passing-brightgreen)](./test)
[![Score](https://img.shields.io/badge/Quality%20Score-99%2F100-blue)]()

---

## 🎮 What is TaasClub?

TaasClub is a **multiplayer card game platform** that digitizes the "Home Game" experience. Host private rooms, play popular card games with friends, and settle scores seamlessly.

### For Players
- 🃏 **Play 4 Games**: Marriage, Call Break, Teen Patti, In-Between
- 👥 **Multiplayer**: 2-8 players per room
- 🤖 **AI Opponents**: Smart bots fill empty seats
- 💬 **Social**: Chat, voice, video during games
- 📱 **Anywhere**: Web, Android, iOS (coming soon)

### For Hosts
- 🏠 **Private Rooms**: Share 6-digit code with friends
- 💎 **Diamond Economy**: Earn free diamonds daily
- 📊 **Settlement**: Auto-calculate "who owes whom"
- 📤 **Share**: Export settlement to WhatsApp

---

## 🚀 Quick Start

```bash
# Clone the repository
git clone https://github.com/timecapsulellc/TaasClub.git
cd TaasClub

# Install dependencies
flutter pub get

# Run on Chrome (Web)
flutter run -d chrome

# Build Android APK
flutter build apk --release
```

---

## 📊 Project Status

| Metric | Value |
|--------|-------|
| **Status** | 🟢 Production Ready |
| **Quality Score** | 99/100 |
| **Dart Files** | 188 |
| **Lines of Code** | 50,825 |
| **Tests Passing** | 169/169 (100%) |
| **Cloud Functions** | 12 Deployed |
| **AI Flows** | 6 GenKit Flows |

### Platform Availability

| Platform | Status | Access |
|----------|--------|--------|
| **Web PWA** | 🟢 Live | [taasclub-app.web.app](https://taasclub-app.web.app) |
| **Android** | ✅ Ready | [Download APK](https://taasclub-app.web.app/download.html) |
| **iOS** | ⏳ Coming Soon | Firebase configured |

---

## 🎯 Features

### Games (4 Complete)
| Game | Players | AI Bots | Tests |
|------|---------|---------|-------|
| **Marriage** | 2-8 | ✅ | 52 |
| **Call Break** | 4 | ✅ | 20 |
| **Teen Patti** | 2-8 | ✅ | ✅ |
| **In-Between** | 2-8 | ✅ | ✅ |

### Core Features
- ✅ **Lobby System** - Create/join rooms with 6-digit codes
- ✅ **ELO Matchmaking** - Skill-based player pairing
- ✅ **Real-time Chat** - In-game, lobby, and direct messages
- ✅ **Voice/Video** - WebRTC audio + LiveKit video
- ✅ **Diamond Economy** - Free daily bonuses, room creation costs
- ✅ **Settlement Calculator** - Auto-calculate and share results
- ✅ **Anti-Cheat** - Server-side move validation
- ✅ **AI Moderation** - GenKit-powered chat filtering

### AI Integration (GenKit)
| Flow | Purpose |
|------|---------|
| `gameTipFlow` | Suggest optimal card to play |
| `botPlayFlow` | AI opponent card selection |
| `moderationFlow` | Chat content filtering |
| `bidSuggestionFlow` | Bid recommendations |
| `matchmakingFlow` | ELO-based player matching |

---

## 🏗️ Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                    FLUTTER FRONTEND                          │
│  • 4 Game Engines  • 16 Feature Modules  • PWA Optimized    │
├─────────────────────────────────────────────────────────────┤
│                    STATE (Riverpod)                          │
├─────────────────────────────────────────────────────────────┤
│                    SERVICE LAYER (21 Services)               │
└─────────────────────────────────────────────────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────────┐
│                    FIREBASE BACKEND                          │
│  • Firestore DB  • Auth  • 12 Cloud Functions  • Storage    │
├─────────────────────────────────────────────────────────────┤
│                    AI LAYER (GenKit)                         │
│  • Gemini Pro  • 6 AI Flows  • Real-time Processing         │
└─────────────────────────────────────────────────────────────┘
```

---

## 💎 Revenue Model (Safe Harbor)

> **The app is a CALCULATOR, not a BANK.**

| Earn Diamonds | Amount |
|---------------|--------|
| Welcome Bonus | 100 💎 |
| Daily Login | 10 💎 |
| Watch Ad | 20 💎 (6x/day) |
| Complete Game | 5 💎 |
| Referral | 50 💎 |

| Spend Diamonds | Cost |
|----------------|------|
| Create Room | 10 💎 |
| Ad-Free Game | 5 💎 |

**No real money transactions.** Settlement is for offline use only.

---

## 📁 Project Structure

```
TaasClub/
├── lib/                      # Flutter app (188 files, 50K LOC)
│   ├── core/                 # Shared utilities (17 modules)
│   ├── features/             # Feature modules (16 modules)
│   │   ├── auth/             # Authentication
│   │   ├── lobby/            # Room management
│   │   ├── chat/             # Messaging
│   │   ├── social/           # Friends, presence
│   │   ├── wallet/           # Diamond economy
│   │   └── ...
│   └── games/                # Game engines
│       ├── marriage/         # 52 tests
│       ├── call_break/       # 20 tests
│       ├── teen_patti/
│       └── in_between/
├── functions/                # Cloud Functions (12 functions)
│   └── src/
│       ├── genkit/           # 6 AI flows
│       ├── admin/            # Diamond management
│       └── triggers/         # Firestore triggers
├── web/                      # PWA assets
├── android/                  # Android platform
├── ios/                      # iOS platform
├── test/                     # 169 tests
└── docs/                     # 36 documentation files
```

---

## 📚 Documentation

| Category | Documents |
|----------|-----------|
| **Strategy** | [PRD](./docs/PRD_TAASCLUB.md), [Roadmap](./docs/ULTIMATE_ROADMAP.md), [Architecture](./docs/ARCHITECTURE_AUDIT.md) |
| **Games** | [Marriage Rules](./docs/MARRIAGE_GAME_SPEC.md), [Game SDK](./docs/GAME_ENGINE_SDK.md) |
| **Legal** | [Privacy Policy](./docs/PRIVACY_POLICY.md), [Terms](./docs/TERMS_OF_SERVICE.md), [Data Safety](./docs/DATA_SAFETY_DECLARATION.md) |
| **Setup** | [FCM](./docs/FCM_SETUP.md), [LiveKit](./docs/LIVEKIT_SETUP.md), [Deep Links](./docs/DEEP_LINKS_SETUP.md) |
| **Store** | [Listing](./docs/STORE_LISTING.md), [Assets](./docs/STORE_ASSETS.md), [Icons](./docs/ICON_DESIGN_SPECS.md) |

---

## 🔧 Tech Stack

| Layer | Technology |
|-------|------------|
| **Framework** | Flutter 3.38.4 |
| **Language** | Dart 3.10.3 (null-safe) |
| **State** | Riverpod |
| **Routing** | GoRouter |
| **Backend** | Firebase (Firestore, Auth, Functions, Storage) |
| **AI/ML** | GenKit + Gemini Pro |
| **Video** | LiveKit |
| **Audio** | WebRTC |
| **Ads** | Google AdMob |

---

## 🔗 Links

| Resource | URL |
|----------|-----|
| **Live App** | https://taasclub-app.web.app |
| **Download** | https://taasclub-app.web.app/download.html |
| **Firebase Console** | https://console.firebase.google.com/project/taasclub-app |
| **Documentation** | [./docs/README.md](./docs/README.md) |

---

## 📄 License

Proprietary - TimeCapsule LLC

---

## 🏆 Quality Metrics

- ✅ **169/169 tests passing** (100%)
- ✅ **Zero critical bugs**
- ✅ **Type-safe codebase** (null-safety enabled)
- ✅ **Enterprise-grade security** (server-side validation)
- ✅ **Legal compliance** (Safe Harbor model)
- ✅ **PWA optimized** (installable, offline-ready)

**Last Updated:** December 10, 2025
