# ClubRoyale Blueprint

## Overview

ClubRoyale (v2.1) is a **Play & Connect** social gaming platform built with Flutter and Firebase. It features 4 premium card games, a complete social network (stories, feed, clubs), and an **AI Gaming Platform** with cognitive bot personalities.

**Live URL:** https://clubroyale-app.web.app

## Core Architecture

```
┌─────────────────────────────────────────────────────────────────┐
│                     FLUTTER FRONTEND (70K+ LOC)                  │
│  • 4 Game Engines  • 35+ Feature Modules  • 5 Theme Presets     │
├─────────────────────────────────────────────────────────────────┤
│                     STATE (Riverpod 3.x)                         │
├─────────────────────────────────────────────────────────────────┤
│                     SERVICE LAYER (30+ Services)                 │
└─────────────────────────────────────────────────────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────────────┐
│                     FIREBASE BACKEND                             │
│  • Firestore  • Auth  • 30+ Cloud Functions  • FCM  • Storage   │
├─────────────────────────────────────────────────────────────────┤
│                     AI LAYER (Agentic AI + ToT)                  │
│  • 12 Autonomous Agents  • 5 Bot Personalities  • Instant Play  │
└─────────────────────────────────────────────────────────────────┘
```

## Key Features

### Games (4 Complete)
- **Royal Meld (Marriage)**: 2-8 players, 52 tests passing
- **Call Break**: 4 players, trick-taking
- **Teen Patti**: 2-8 players, three-card poker
- **In-Between**: 2-8 players, hi-lo betting

### AI Gaming Platform (NEW - December 2025)
- **Cognitive Bot Personalities**: TrickMaster, CardShark, LuckyDice, DeepThink, RoyalAce
- **Instant Play**: Pre-seeded bot rooms for zero-wait gaming
- **Tree of Thoughts**: Human-like decision making
- **Play Now Button**: One-tap join to available AI games
- **Bot Room Seeder**: Automated hourly room population

### Social Features
- Activity Feed, Stories, Online Friends Bar
- Voice Rooms, Clubs, Spectator Mode
- Diamond Economy V5, Tournaments, Replays

## Project Structure

```
ClubRoyale/
├── lib/                     # Flutter app (250+ files)
│   ├── features/            # 35+ feature modules
│   └── games/               # 4 game engines
├── functions/               # Cloud Functions (30+)
│   └── src/
│       ├── agents/          # 12 AI Agents + Cognitive Play
│       ├── scheduled/       # Bot Room Seeder
│       └── triggers/        # Firestore triggers
└── docs/                    # 50+ documentation files
```

## Development Phases

| Phase | Description | Status |
|-------|-------------|--------|
| 1-19 | Core Platform + Social | ✅ Complete |
| 20 | AI Gaming Platform | ✅ Complete |
| 21 | Documentation Update | ✅ Complete |

**Last Updated:** December 20, 2025
