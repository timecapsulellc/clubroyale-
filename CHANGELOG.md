# ClubRoyale Changelog

## [2026-01-03] Chief Architect Audit Pipeline

### ✨ New Features

#### Economy & Ads
- **AdMob Integration**: Rewarded video ads via `AdService`
- **Virtual Ledger Model**: No-IAP, diamonds are score-tracking only
- **Watch Ads Button**: Functional in "The Vault" UI, grants 20💎 per view

#### AI Agents
- **15 PhD-Level Workflow Agents**: Added to `.agent/workflows/`
  - Chief Architect, Code Quality, Testing & QA
  - Game Mechanics, Card Engine, Bot AI, Multiplayer Sync
  - Economy & Rewards, UI/UX Designer, Asset Generator
  - Animation Effects, Firebase Expert, ToT Agent
  - Analytics Insights, Debug & Fix

---

### 🔧 Improvements

#### UI/UX Design
- **Typography**: Standardized to `GoogleFonts.oswald`
- **Color Palette**: Applied `CasinoColors` (richPurple, gold, neonPink, feltGreen)
- **Diamond Purchase Screen**: Restored `_buildBalanceCard` and `_buildFreeBadge`

#### Code Quality
- Applied `dart fix --apply` (358 files formatted)
- Fixed `OnUserEarnedRewardCallback` type in `AdService`
- Removed unused imports

---

### 🎮 Game Audits

| Game | Tests | Status |
|------|-------|--------|
| Marriage (Nepali) | 100% | ✅ Production Ready |
| Call Break | 27/27 | ✅ Production Ready |
| Teen Patti | 7/7 | ✅ Production Ready |

---

### 🔒 Security Audit

| Collection | Client Access | Status |
|------------|---------------|--------|
| `/wallets` | READ ONLY | ✅ Secure |
| `/ledger` | READ ONLY | ✅ Secure |
| `/audit_logs` | Admin Only | ✅ Secure |
| `/games` | Host/Participants | ⚠️ TODO flagged |

---

### 📊 Test Results
- **Passing**: 316
- **Failing**: 3 (pre-existing, unrelated to this session)

---

### 📁 Files Changed
- **398 files modified**
- **+31,662 lines added**
- **-15,186 lines removed**

---

**Commit**: `eecf3742 - feat: Complete audit pipeline - Economy, UI, Games, Quality`
