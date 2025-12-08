# Getting Started with TaasClub

> **Quick Start Guide for Developers**

---

## 📊 Project Status

| Component | Status |
|-----------|--------|
| 4 Games | ✅ Complete |
| Settlement Service | ✅ Complete |
| GenKit AI (5 flows) | ✅ Complete |
| 12 Cloud Functions | ✅ Deployed |
| 169 Tests | ✅ Passing |

**Live URL:** https://taasclub-app.web.app

---

## 🚀 Quick Start

### Prerequisites
- Flutter 3.x
- Node.js 18+ (for functions)
- Firebase CLI

### Installation

```bash
# Clone repository
git clone https://github.com/timecapsulellc/TaasClub.git
cd TaasClub

# Install Flutter dependencies
flutter pub get

# Run web version
flutter run -d chrome

# Run tests
flutter test
```

### Firebase Setup

```bash
# Install Firebase CLI
npm install -g firebase-tools

# Login
firebase login

# Deploy functions
cd functions && npm install && npm run build
firebase deploy --only functions

# Deploy hosting
flutter build web --release
firebase deploy --only hosting
```

---

## 🎯 Core Principle

> **The app is a CALCULATOR, not a BANK.**

```
INSIDE APP          │   OUTSIDE APP
─────────           │   ───────────
Points/Units        │   Cash/UPI
Diamonds (virtual)  │   Real Money
Bill Image          │   Actual Payments
```

---

## 📁 Project Structure

```
lib/
├── core/
│   ├── responsive/        # Screen breakpoints
│   ├── audio/             # Sound effects
│   └── ai/                # AI difficulty
├── features/
│   ├── auth/              # Phone login
│   ├── lobby/             # Room create/join
│   ├── wallet/            # Diamond balance
│   ├── game/              # Game screens
│   ├── social/            # Friends, chat
│   └── settlement/        # Bill generation
└── games/
    ├── core/              # GameEngine abstract
    ├── marriage/          # Marriage logic
    └── call_break/        # Call Break logic
```

---

## 📖 Key Documentation

| Doc | Purpose |
|-----|---------|
| [docs/README.md](./README.md) | Documentation Hub |
| [docs/PRD_TAASCLUB.md](./PRD_TAASCLUB.md) | Product Requirements |
| [docs/MASTER_ARCHITECT_PROMPT.md](./MASTER_ARCHITECT_PROMPT.md) | AI Dev Guide |
| [docs/DOC2_SETTLEMENT_ALGORITHM.md](./DOC2_SETTLEMENT_ALGORITHM.md) | Settlement Math |

---

## 🔧 Development Commands

```bash
# Run specific test file
flutter test test/games/marriage/marriage_game_test.dart

# Build web release
flutter build web --release

# Analyze code
flutter analyze

# Format code
dart format lib/
```

---

## 🚀 Roadmap

### Phase 1: Foundation (Current)
- [x] 4 Games complete
- [x] Settlement service
- [x] Cloud Functions deployed
- [ ] CI/CD Pipeline
- [ ] Sentry integration

### Phase 2: Platform
- [ ] Clubs/Guilds
- [ ] Tournaments
- [ ] Season Pass

### Phase 3: Scale
- [ ] Multi-region
- [ ] Esports
- [ ] 1M MAU
