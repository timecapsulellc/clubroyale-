# ClubRoyale 🃏

> **Play & Connect** - A premium social gaming platform with classic card games, voice rooms, stories, and community features

[![Live](https://img.shields.io/badge/Live-clubroyale--app.web.app-brightgreen)](https://clubroyale-app.web.app)
[![Android](https://img.shields.io/badge/Android-APK%20Ready-green)](./build/app/outputs/flutter-apk/app-release.apk)
[![Tests](https://img.shields.io/badge/Tests-168%20Passing-brightgreen)](./test)
[![Score](https://img.shields.io/badge/Quality%20Score-100%2F100-blue)]()

---

## 🎮 What is ClubRoyale?

ClubRoyale is a **Play & Connect** social gaming platform that combines classic card games with modern social features. It's not just about playing games—it's about connecting with friends, sharing moments, and being part of a gaming community.

### For Players
- 🃏 **4 Premium Games**: Royal Meld (Marriage), Call Break, Teen Patti, In-Between
- � **Social Hub**: Chat, Stories, Activity Feed, Online Friends Bar
- 🎙️ **Voice Rooms**: Live audio chat during games and hangouts
- 👥 **Clubs & Communities**: Join gaming clubs with leaderboards
- 👀 **Spectator Mode**: Watch live games with friends
- 🏆 **Tournaments**: Compete in bracket-style tournaments
- 📱 **Cross-Platform**: Web PWA, Android (iOS coming soon)
- 🎨 **5 Beautiful Themes**: Royal Green, Purple, Blue, Crimson, Emerald

### For Hosts
- 🏠 **Private Rooms**: Share 6-digit codes with friends
- 💎 **Diamond Economy**: Earn free diamonds through social activities
- 📊 **Auto Settlement**: Calculate "who owes whom" instantly
- 📤 **Share Results**: Export to WhatsApp or post to Story

---

## 🚀 Quick Start

```bash
# Clone the repository
git clone https://github.com/timecapsulellc/TaasClub.git
cd ClubRoyale

# Install dependencies
flutter pub get

# Run on Chrome (Web)
flutter run -d chrome --web-port 8081

# Build Android APK
flutter build apk --release

# Build Web (Production)
flutter build web
```

---

## 📊 Project Status (December 2025)

| Metric | Value |
|--------|-------|
| **Status** | 🟢 Production Ready |
| **Quality Score** | 100/100 |
| **Dart Files** | 240+ |
| **Lines of Code** | 68,000+ |
| **Tests Passing** | 168/169 (99.4%) |
| **Cloud Functions** | 25+ Deployed |
| **AI Flows** | 6 GenKit Flows |
| **Feature Modules** | 30+ |
| **Development Phases** | 19 Complete |

### Platform Availability

| Platform | Status | Access |
|----------|--------|--------|
| **Web PWA** | 🟢 Live | [clubroyale-app.web.app](https://clubroyale-app.web.app) |
| **Android** | ✅ Ready | APK in `build/` folder |
| **iOS** | ⏳ Coming Soon | Firebase configured |

---

## ✅ Completed Development Phases

### Phase 1-7: Core Foundation
| Phase | Feature | Status |
|-------|---------|--------|
| 1 | Read Receipts (Blue Ticks) | ✅ Complete |
| 2 | Diamond Gift Messages | ✅ Complete |
| 3 | Auto Game Result Stories | ✅ Complete |
| 4 | In-Game Social Overlay | ✅ Complete |
| 5 | Spectator Mode | ✅ Complete |
| 6 | Group Video Calls (1-8 players) | ✅ Complete |
| 7 | Cloud Function Triggers | ✅ Complete |

### Phase 15-17: Verification & Polish
| Phase | Feature | Status |
|-------|---------|--------|
| 15 | Firebase Cloud Functions Deployment | ✅ Complete |
| 16 | Admin Chat, Voice Room Token, Sound Effects | ✅ Complete |
| 17 | Final Audit, Analytics Integration | ✅ Complete |

### Phase 18: Diamond Revenue Model V5
| Component | Description | Status |
|-----------|-------------|--------|
| Core Config | `SocialDiamondRewards`, `VoiceRoomDiamondConfig`, `StoryDiamondConfig` | ✅ |
| Social Diamond Service | Voice room hosting, story views, game invites, tipping | ✅ |
| Cloud Functions | `grantSocialRewardFunction`, `processVoiceRoomTip`, scheduled rewards | ✅ |
| Earn Diamonds UI | Social tab with daily progress and activity cards | ✅ |

### Phase 19: In-Game Social Features
| Component | Description | Status |
|-----------|-------------|--------|
| Social Overlay | Chat/Voice/Spectator tabs during gameplay | ✅ |
| Voice Control Panel | Mic toggle, join/leave, participant display | ✅ |
| Spectator List Panel | Real-time count, viewer list, share link | ✅ |
| Game Result Story Sheet | Victory UI, "Post to Story" with captions | ✅ |

---

## 🎯 Complete Feature List

### 📱 Social-First Features (NEW!)
| Feature | Description |
|---------|-------------|
| **Onboarding ("Play & Connect")** | Social-first welcome flow highlighting community |
| **Activity Feed** | Social feed with game results, friend activities |
| **Stories** | Share game highlights, 24-hour expiring stories |
| **Online Friends Bar** | See who's online, quick invite to games |
| **Quick Social Actions** | One-tap access to Chat, Friends, Activity |
| **Voice Rooms** | Live audio during games and hangouts |
| **Clubs** | Gaming communities with leaderboards |
| **Spectator Mode** | Watch live games, spectator count badge |
| **Game Invites** | In-chat game invitations |
| **Diamond Gifts** | Send diamonds with animated messages |
| **Reply to Messages** | Quote and reply to chat messages |
| **Read Receipts** | Blue tick indicators (sent/delivered/read) |

### 🃏 Card Games (4 Complete)
| Game | Players | AI Bots | Status |
|------|---------|---------|--------|
| **Royal Meld** (Marriage) | 2-8 | ✅ GenKit | 🟢 Complete |
| **Call Break** | 4 | ✅ GenKit | 🟢 Complete |
| **Teen Patti** | 2-8 | ✅ GenKit | 🟢 Complete |
| **In-Between** | 2-6 | ✅ GenKit | 🟢 Complete |

### 💎 Diamond Economy V5
| Earn Method | Diamonds | Daily Cap |
|-------------|----------|-----------|
| Welcome Bonus | 100 💎 | Once |
| Daily Login | 10 💎 | 1x/day |
| Watch Ad | 20 💎 | 6x/day |
| Complete Game | 5 💎 | Unlimited |
| Voice Room Host (15 min) | 5 💎 | 30 💎/day |
| Story Views (10 views) | 2 💎 | 20 💎/day |
| Game Invite Accepted | 3 💎 | 15 💎/day |
| Weekly Engagement Tier | 10-100 💎 | Weekly |
| Monthly Milestone | 50-500 💎 | Monthly |

### 🎙️ Voice & Video
| Feature | Status |
|---------|--------|
| WebRTC Voice Chat | ✅ |
| LiveKit Video Calls | ✅ |
| 1-8 Player Video Grid | ✅ |
| Speaking Indicators | ✅ |
| Mute/Unmute Controls | ✅ |

### 🏗️ Core Infrastructure
| Feature | Status |
|---------|--------|
| Lobby System (6-digit codes) | ✅ |
| ELO Matchmaking | ✅ |
| Real-time Chat | ✅ |
| Settlement Calculator | ✅ |
| Anti-Cheat (Server-side) | ✅ |
| AI Moderation (GenKit) | ✅ |
| Tournaments (Bracket System) | ✅ |
| Replay System | ✅ |
| 21 Achievement Badges | ✅ |
| Push Notifications (FCM) | ✅ |
| PWA (Installable) | ✅ |

---

## 🏗️ Architecture

```
┌─────────────────────────────────────────────────────────────────┐
│                    FLUTTER FRONTEND                             │
│  • 4 Game Engines  • 30+ Feature Modules  • 5 Theme Presets     │
├─────────────────────────────────────────────────────────────────┤
│                    STATE (Riverpod 3.x)                         │
├─────────────────────────────────────────────────────────────────┤
│                    SERVICE LAYER (25+ Services)                 │
│  • AuthService  • SocialService  • DiamondService  • VoiceRoom  │
│  • StoryService • SpectatorService • PresenceService • Chat     │
└─────────────────────────────────────────────────────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────────────┐
│                    FIREBASE BACKEND                             │
│  • Firestore DB  • Auth  • 25+ Cloud Functions  • Storage      │
├─────────────────────────────────────────────────────────────────┤
│                    AI LAYER (GenKit + Gemini Pro)               │
│  • 6 AI Flows  • Real-time Bot Play  • Chat Moderation          │
├─────────────────────────────────────────────────────────────────┤
│                    CLOUD FUNCTIONS                              │
│  • Social Triggers  • Diamond Rewards  • Scheduled Jobs         │
└─────────────────────────────────────────────────────────────────┘
```

### Key Service Files

| Service | Purpose | Location |
|---------|---------|----------|
| `social_service.dart` | Chat, messages, social operations | `lib/features/social/services/` |
| `presence_service.dart` | Online status tracking | `lib/features/social/services/` |
| `social_diamond_service.dart` | Social diamond rewards | `lib/features/wallet/` |
| `story_service.dart` | Stories CRUD | `lib/features/stories/services/` |
| `spectator_service.dart` | Spectator mode | `lib/features/game/services/` |
| `voice_room_service.dart` | Voice chat rooms | `lib/features/social/services/` |

### Key Widget Files

| Widget | Purpose | Location |
|--------|---------|----------|
| `social_overlay.dart` | In-game social panel | `lib/features/game/widgets/` |
| `game_result_story_sheet.dart` | Post-game story creator | `lib/features/game/widgets/` |
| `spectator_badge.dart` | Spectator count display | `lib/features/game/widgets/` |
| `online_friends_bar.dart` | Friends online indicator | `lib/features/social/widgets/` |
| `quick_social_actions.dart` | Quick action buttons | `lib/features/social/widgets/` |
| `social_feed_widget.dart` | Activity feed | `lib/features/social/widgets/` |

---

## 🔮 Roadmap: What's Next

### Immediate (Q1 2025)
- [ ] iOS App Store Release
- [ ] Performance optimization for low-end devices
- [ ] Advanced club management features
- [ ] Tournament prizes and rewards

### Short-Term (Q2 2025)
- [ ] Seasonal events and limited-time games
- [ ] Profile customization (avatars, frames)
- [ ] Enhanced achievement system
- [ ] Community moderation tools

### Medium-Term (Q3-Q4 2025)
- [ ] Regional game variants (Nepali, Indian versions)
- [ ] Team tournaments
- [ ] Creator program for content creators
- [ ] API for third-party integrations

### Long-Term Vision
- [ ] More card games (Rummy, Poker variants)
- [ ] Cross-promotional features with other apps
- [ ] White-label solution for private clubs
- [ ] AI-powered game coaching

---

## 📁 Project Structure

```
ClubRoyale/
├── lib/                          # Flutter app (240+ files, 68K+ LOC)
│   ├── core/                     # Shared utilities
│   │   ├── theme/                # Multi-theme system
│   │   ├── config/               # Diamond config, game terminology
│   │   ├── widgets/              # Common widgets
│   │   ├── audio/                # Sound service
│   │   └── services/             # Analytics, share, deferred
│   ├── features/                 # Feature modules (30+ modules)
│   │   ├── auth/                 # Authentication
│   │   ├── lobby/                # Room management
│   │   ├── social/               # Chat, friends, presence, voice
│   │   ├── stories/              # Stories feature
│   │   ├── wallet/               # Diamond economy
│   │   ├── game/                 # Game screens, overlays, spectator
│   │   ├── clubs/                # Club system
│   │   ├── tournament/           # Tournament system
│   │   ├── replay/               # Game replay
│   │   ├── profile/              # User profiles
│   │   ├── onboarding/           # First-run experience
│   │   ├── settings/             # Settings & themes
│   │   └── admin/                # Admin panel
│   └── games/                    # Game engines (4 games)
│       ├── marriage/             # Royal Meld
│       ├── call_break/           # Call Break
│       ├── teen_patti/           # Teen Patti
│       └── in_between/           # In-Between
├── functions/                    # Cloud Functions (25+ functions)
│   └── src/
│       ├── genkit/               # 6 AI flows
│       ├── triggers/             # Firestore triggers
│       └── rewards/              # Social diamond rewards
├── web/                          # PWA assets
├── android/                      # Android platform
├── ios/                          # iOS platform
├── test/                         # Test files
└── docs/                         # 40+ documentation files
```

---

## 📚 Documentation

| Category | Documents |
|----------|-----------|
| **Strategy** | [PRD](./docs/PRD_TAASCLUB.md), [Roadmap](./docs/ULTIMATE_ROADMAP.md), [Audit](./docs/ULTIMATE_AUDIT_REPORT.md) |
| **Architecture** | [Architecture Audit](./docs/ARCHITECTURE_AUDIT.md), [Tech Summary](./docs/PROJECT_TECHNICAL_SUMMARY.md) |
| **Games** | [Marriage Rules](./docs/MARRIAGE_GAME_SPEC.md), [Game SDK](./docs/GAME_ENGINE_SDK.md) |
| **Legal** | [Privacy Policy](./docs/PRIVACY_POLICY.md), [Terms](./docs/TERMS_OF_SERVICE.md), [Data Safety](./docs/DATA_SAFETY_DECLARATION.md) |
| **Setup** | [FCM](./docs/FCM_SETUP.md), [LiveKit](./docs/LIVEKIT_SETUP.md), [Deep Links](./docs/DEEP_LINKS_SETUP.md) |
| **Store** | [Listing](./docs/STORE_LISTING.md), [Assets](./docs/STORE_ASSETS.md), [Brand](./docs/BRAND_STYLE_GUIDE.md) |

---

## 🔧 Tech Stack

| Layer | Technology |
|-------|------------|
| **Framework** | Flutter 3.38.4 |
| **Language** | Dart 3.10 (null-safe) |
| **State** | Riverpod 3.x |
| **Routing** | GoRouter |
| **Backend** | Firebase (Firestore, Auth, Functions, Storage, FCM) |
| **AI/ML** | GenKit + Gemini Pro (Google AI) |
| **Video** | LiveKit |
| **Audio** | WebRTC + audioplayers |
| **Ads** | Google AdMob (Ready) |
| **Analytics** | Firebase Analytics |

---

## 🏆 Quality Metrics

- ✅ **168/169 tests passing** (99.4%)
- ✅ **Zero critical bugs**
- ✅ **Type-safe codebase** (null-safety enabled)
- ✅ **Enterprise-grade security** (server-side validation)
- ✅ **Legal compliance** (Safe Harbor model)
- ✅ **PWA optimized** (installable, offline-ready)
- ✅ **19 development phases complete**
- ✅ **25+ Cloud Functions deployed**
- ✅ **Social-first architecture**

---

## 🆕 Recent Updates (December 2025)

| Update | Description |
|--------|-------------|
| **Play & Connect Onboarding** | Social-first welcome flow |
| **Diamond Revenue V5** | Social earning methods (voice, stories, invites) |
| **In-Game Social Overlay** | Chat/Voice/Spectator during gameplay |
| **Game Result Stories** | Post wins directly to Story |
| **Spectator Mode** | Watch live games with badge |
| **Voice Room Integration** | Mic controls, participant display |
| **Reply to Messages** | Quote and reply in chat |
| **Diamond Gifts** | Send animated diamond messages |
| **Read Receipts** | Blue tick indicators |
| **Firebase Config Fix** | Web platform RTDB handling |

**Last Updated:** December 16, 2025

---

## 📄 License

Proprietary - Metaweb Technologies

---

## 🔗 Links

| Resource | URL |
|----------|-----|
| **Live App** | https://clubroyale-app.web.app |
| **Firebase Console** | https://console.firebase.google.com/project/taasclub-app |
| **GitHub** | https://github.com/timecapsulellc/TaasClub |
| **Documentation** | [./docs/README.md](./docs/README.md) |
