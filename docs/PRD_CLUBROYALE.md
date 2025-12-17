# ClubRoyale PRD (Product Requirements Document)
## The Agentic Social Gaming Platform

**Version:** 1.4
**Date:** December 17, 2025
**Strategy:** Strategy B - Agentic Social Ecosystem

---

## 1. Executive Summary

ClubRoyale is a next-generation **Play & Connect** platform that combines classic card games with a deeply integrated social network, powered by **Agentic AI**. Unlike traditional game apps, ClubRoyale uses autonomous AI agents to manage content, moderate safety, recommend interactions, and enhance the gameplay experience in real-time.

> **One-Liner:** A social gaming ecosystem where AI agents facilitate meaningful connections and premium gameplay.

---

## 2. Key Pillars

### 2.1 Premium Social Gaming
- **Games**: Royal Meld (Marriage), Call Break, Teen Patti, In-Between.
- **Social Hub**: Activity feeds, stories, voice rooms, and clubs.
- **Identity**: Customizable profiles, achievement badges, and stats.

### 2.2 Agentic AI Layer (NEW)
Twelve autonomous agents work in the background to optimize the platform:
- **Director Agent**: Orchestrates the overall user experience.
- **Safety Agent**: Moderators content and behavior using **Tree of Thoughts (ToT)** reasoning.
- **Recommendation Agent**: Suggests games, friends, and content based on 4D analysis.
- **Analytics Agent**: Predicts engagement and churn risks.
- **Content Agent**: Generates daily stories, reels, and celebration content.

### 2.3 Diamond Economy V5
A sustainable, engagement-driven economy:
- **Earn**: Play games, host voice rooms, view stories, invite friends.
- **Spend**: Tips, gifts, game entry, club customization.

---

## 3. User Roles

### The Player (Social Gamer)
- Plays games for fun and competition.
- Connects with friends in voice rooms.
- Shares highlights to stories.
- Earns badges and climbs leaderboards.

### The Host (Community Leader)
- Creates private rooms and clubs.
- Organizes tournaments.
- Hosts voice sessions.
- Settles offline scores using the "Settlement Bill" feature.

### The AI Agents (System Actors)
- **Moderator**: Enforces safety rules.
- **Coach**: Provides game tips.
- **Concierge**: Suggests relevant activities.

---

## 4. Key Features & Flow

### 4.1 Onboarding ("Play & Connect")
- **Social First**: Users are introduced to the community before games.
- **Quick Connect**: Sync contacts, find online friends immediately.

### 4.2 The Lobby & Social Hub
- **Activity Feed**: Real-time updates of friend wins, new clubs, and events.
- **Online Bar**: One-tap invites to online friends.
- **Voice Rooms**: Drop-in audio spaces for casual hangouts.

### 4.3 Gameplay Experience
- **In-Game Social Overlay**: Chat, voice, and spectator controls without leaving the table.
- **Spectator Mode**: Friends can watch and react to live games.
- **Smart Settlements**: Auto-calculated debts for offline settlement.

### 4.4 Agentic Capabilities
| Agent | Role | Capability |
|-------|------|------------|
| **Director** | Orchestrator | Manages agent coordination |
| **Safety** | Moderator | ToT-based context analysis |
| **Recommendation** | Curator | 4D personalization (Time, Mood, Social, Skill) |
| **Analytics** | Analyst | Churn prediction & retention triggers |
| **Content** | Creator | Generates engaging stories/reels |

---

## 5. Technical Stack

| Layer | Technology |
|-------|------------|
| **Frontend** | Flutter 3.x (Web, Android, iOS) |
| **State** | Riverpod |
| **Backend** | Firebase (Firestore, Functions V2) |
| **AI/ML** | Google GenKit + Gemini Pro + Tree of Thoughts |
| **Real-time** | WebSocket (Canvas), WebRTC (Voice), LiveKit (Video) |
| **Economy** | RevenueCat (IAP) + Ledger System |

---

## 6. Success Metrics (KPIs)

| Metric | Target | Status |
|--------|--------|--------|
| **DAU/MAU** | > 35% | 📈 |
| **Avg Session** | > 45 mins | ✅ |
| **Retention D30** | > 40% | 📈 |
| **Agent Actions** | > 1000/day | ✅ |
| **Crash Free** | > 99.9% | ✅ |

---

## 7. Roadmap Notes

- **v1.0 (Dec 1)**: Core Games + Basic Social.
- **v1.2 (Dec 12)**: Social Expansion (Feed, Clubs, Tournaments).
- **v1.3 (Dec 16)**: Diamond Economy V5 + Onboarding.
- **v1.4 (Dec 17)**: Agentic AI Layer + Production Hardening. (CURRENT)
- **v2.0 (Q1 2026)**: iOS Launch + Creator Tools.
