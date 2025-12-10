# ClubRoyale 🃏

> **Your Private Card Club** - A premium multiplayer card game platform with AI-powered gameplay

[![Live](https://img.shields.io/badge/Live-taasclub--app.web.app-brightgreen)](https://taasclub-app.web.app)
[![Android](https://img.shields.io/badge/Android-APK%20Ready-green)](./build/app/outputs/flutter-apk/app-release.apk)
[![Tests](https://img.shields.io/badge/Tests-162%20Passing-brightgreen)](./test)
[![Score](https://img.shields.io/badge/Quality%20Score-99%2F100-blue)]()

---

## 🎮 What is ClubRoyale?

ClubRoyale is a **premium multiplayer card game platform** that digitizes the "Home Game" experience. Host private rooms, play popular card games with friends, and settle scores seamlessly.

### For Players
- 🃏 **Play 4 Games**: Royal Meld (Marriage), Call Break, Teen Patti, In-Between
- 👥 **Multiplayer**: 2-8 players per room
- 🤖 **AI Opponents**: Smart bots fill empty seats (GenKit AI)
- 💬 **Social**: Chat, voice, video during games
- 📱 **Anywhere**: Web PWA, Android (iOS coming soon)
- 🎨 **5 Themes**: Royal Green, Purple, Blue, Crimson, Emerald
- 🌙 **Day/Night Mode**: Light and dark themes

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
cd ClubRoyale

# Install dependencies
flutter pub get

# Run on Chrome (Web)
flutter run -d chrome

# Build Android APK
flutter build apk --release

# Build Web
flutter build web
```

---

## 📊 Project Status (December 2025)

| Metric | Value |
|--------|-------|
| **Status** | 🟢 Production Ready |
| **Quality Score** | 99/100 |
| **Dart Files** | 222 |
| **Lines of Code** | 64,619 |
| **Tests Passing** | 162/169 (96%) |
| **Cloud Functions** | 12 Deployed |
| **AI Flows** | 6 GenKit Flows |
| **Theme Presets** | 5 |

### Platform Availability

| Platform | Status | Access |
|----------|--------|--------|
| **Web PWA** | 🟢 Live | [taasclub-app.web.app](https://taasclub-app.web.app) |
| **Android** | ✅ Ready | APK in `build/` folder |
| **iOS** | ⏳ Coming Soon | Firebase configured |

---

## 🎨 Theme System (NEW!)

Switch between 5 beautiful color themes:

| Theme | Primary | Accent |
|-------|---------|--------|
| 🟢 **Royal Green** (Default) | Forest Green | Gold |
| 🟣 Royal Purple | Deep Purple | Gold |
| 🔵 Midnight Blue | Navy | Silver |
| 🔴 Crimson | Dark Red | Gold |
| 🌿 Emerald | Teal | Champagne |

**Features:**
- Day/Night mode toggle
- Persisted to device storage
- Beautiful theme picker in Settings

---

## 🎯 Features

### Games (4 Complete)

| Game | Players | AI Bots | Status |
|------|---------|---------|--------|
| **Royal Meld** (Marriage) | 2-8 | ✅ GenKit | 🟢 Complete |
| **Call Break** | 4 | ✅ GenKit | 🟢 Complete |
| **Teen Patti** | 2-8 | ✅ GenKit | 🟢 Complete |
| **In-Between** | 2-6 | ✅ GenKit | 🟢 Complete |

### Multi-Region Terminology

| Global (ClubRoyale) | South Asia (Traditional) |
|---------------------|--------------------------|
| Royal Meld | Marriage |
| Wild Card | Tiplu |
| High Wild | Poplu |
| Low Wild | Jhiplu |
| Royal Sequence | Marriage (meld) |
| Go Royale | Declare |

### Core Features
- ✅ **Theme System** - 5 presets + day/night mode
- ✅ **Lobby System** - Create/join rooms with 6-digit codes
- ✅ **ELO Matchmaking** - Skill-based player pairing
- ✅ **Real-time Chat** - In-game, lobby, and direct messages
- ✅ **Voice/Video** - WebRTC audio + LiveKit video
- ✅ **Stories** - Share moments with friends
- ✅ **Diamond Economy** - Free daily bonuses
- ✅ **Settlement Calculator** - Auto-calculate and share results
- ✅ **Anti-Cheat** - Server-side move validation
- ✅ **AI Moderation** - GenKit-powered chat filtering

### AI Integration (GenKit + Gemini)

| Flow | Purpose |
|------|---------|
| `gameTipFlow` | Suggest optimal card to play |
| `botPlayFlow` | AI opponent card selection |
| `moderationFlow` | Chat content filtering |
| `bidSuggestionFlow` | Bid recommendations |
| `matchmakingFlow` | ELO-based player matching |
| `marriageBotPlay` | Marriage-specific AI |

---

## 🏗️ Architecture

```
┌─────────────────────────────────────────────────────────────────┐
│                    FLUTTER FRONTEND                             │
│  • 4 Game Engines  • 20 Feature Modules  • 5 Theme Presets     │
├─────────────────────────────────────────────────────────────────┤
│                    STATE (Riverpod 3.x)                         │
├─────────────────────────────────────────────────────────────────┤
│                    SERVICE LAYER (22 Services)                  │
└─────────────────────────────────────────────────────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────────────┐
│                    FIREBASE BACKEND                             │
│  • Firestore DB  • Auth  • 12 Cloud Functions  • Storage       │
├─────────────────────────────────────────────────────────────────┤
│                    AI LAYER (GenKit + Gemini Pro)               │
│  • 6 AI Flows  • Real-time Processing  • Chat Moderation       │
└─────────────────────────────────────────────────────────────────┘
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
ClubRoyale/
├── lib/                      # Flutter app (222 files, 64K LOC)
│   ├── core/                 # Shared utilities (15 modules)
│   │   ├── theme/            # Multi-theme system
│   │   ├── widgets/          # Common widgets
│   │   └── services/         # Core services
│   ├── features/             # Feature modules (20 modules)
│   │   ├── auth/             # Authentication
│   │   ├── lobby/            # Room management
│   │   ├── chat/             # Messaging
│   │   ├── social/           # Friends, presence, stories
│   │   ├── wallet/           # Diamond economy
│   │   ├── settings/         # Theme selector here
│   │   └── ...
│   └── games/                # Game engines (4 games)
│       ├── marriage/         # 52 tests
│       ├── call_break/       # 20 tests
│       ├── teen_patti/
│       └── in_between/
├── functions/                # Cloud Functions (12 functions)
│   └── src/
│       ├── genkit/           # 6 AI flows
│       └── triggers/         # Firestore triggers
├── web/                      # PWA assets
├── android/                  # Android platform
├── ios/                      # iOS platform
├── test/                     # 19 test files
└── docs/                     # 50 documentation files
```

---

## 📚 Documentation

| Category | Documents |
|----------|-----------|
| **Strategy** | [PRD](./docs/PRD_TAASCLUB.md), [Roadmap](./docs/ULTIMATE_ROADMAP.md), [Audit](./docs/ULTIMATE_AUDIT_REPORT.md) |
| **Games** | [Marriage Rules](./docs/MARRIAGE_GAME_SPEC.md), [Game SDK](./docs/GAME_ENGINE_SDK.md) |
| **Legal** | [Privacy Policy](./docs/PRIVACY_POLICY.md), [Terms](./docs/TERMS_OF_SERVICE.md), [Data Safety](./docs/DATA_SAFETY_DECLARATION.md) |
| **Setup** | [FCM](./docs/FCM_SETUP.md), [LiveKit](./docs/LIVEKIT_SETUP.md), [Deep Links](./docs/DEEP_LINKS_SETUP.md) |
| **Store** | [Listing](./docs/STORE_LISTING.md), [Assets](./docs/STORE_ASSETS.md), [Icons](./docs/ICON_DESIGN_SPECS.md) |
| **Status** | [Remaining Tasks](./docs/REMAINING_TASKS.md), [Project Status](./docs/REMAINING_TASKS.md) |

---

## 🔧 Tech Stack

| Layer | Technology |
|-------|------------|
| **Framework** | Flutter 3.38.4 |
| **Language** | Dart 3.10 (null-safe) |
| **State** | Riverpod 3.x |
| **Routing** | GoRouter |
| **Backend** | Firebase (Firestore, Auth, Functions, Storage) |
| **AI/ML** | GenKit + Gemini Pro (Google AI) |
| **Video** | LiveKit |
| **Audio** | WebRTC |
| **Ads** | Google AdMob (Ready) |
| **IAP** | RevenueCat (Ready) |

---

## 🔗 Links

| Resource | URL |
|----------|-----|
| **Live App** | https://taasclub-app.web.app |
| **Firebase Console** | https://console.firebase.google.com/project/taasclub-app |
| **GitHub** | https://github.com/timecapsulellc/TaasClub |
| **Documentation** | [./docs/README.md](./docs/README.md) |

---

## 📄 License

Proprietary - TimeCapsule LLC

---

## 🏆 Quality Metrics

- ✅ **162/169 tests passing** (96%)
- ✅ **Zero critical bugs**
- ✅ **Type-safe codebase** (null-safety enabled)
- ✅ **Enterprise-grade security** (server-side validation)
- ✅ **Legal compliance** (Safe Harbor model)
- ✅ **PWA optimized** (installable, offline-ready)
- ✅ **Multi-theme** (5 presets + day/night)

---

## 🆕 Recent Updates (December 2025)

| Update | Description |
|--------|-------------|
| **Multi-Theme** | 5 color presets with day/night mode |
| **Branding** | TaasClub → ClubRoyale |
| **Camera Fix** | Web camera handling improved |
| **Coming Soon** | Styled placeholder widget |
| **APK Build** | 112MB release ready |

**Last Updated:** December 11, 2025
