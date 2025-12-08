# TaasClub Beta to Production Roadmap

**Last Updated:** December 8, 2025  
**Status:** ✅ Architecturally Complete - Ready for Beta

---

## 📊 Current Completion Status

| Category | Status |
|----------|--------|
| Core Game Logic | ✅ 100% |
| Compliance (Safe Harbor, Age Gate) | ✅ 100% |
| Monetization (Diamond Store) | ✅ Ready (needs RevenueCat key) |
| Anti-Cheat (Audit, Collusion Detection) | ✅ 100% |
| AI (Hybrid: 90% local, 10% GenKit) | ✅ 100% |
| UI/UX Features | ✅ 95% |

---

## 🚀 PHASE 1: IMMEDIATE (This Week)

### Manual Configuration Required

| Task | Action | Priority |
|------|--------|----------|
| **RevenueCat API Key** | Create account → Add apps → Get key → Add to `diamond_store.dart` | 🔴 Critical |
| **Deep Link Domain** | Create `assetlinks.json` → Host at `https://taasclub.app/.well-known/` | 🔴 Critical |
| **Signing Secret** | Generate 32+ char random string → Add to Firebase env config | 🔴 Critical |
| **Firebase Security Rules** | Review and lock down Firestore rules | 🔴 Critical |

### Beta Testing Checklist

#### Functional Tests
- [ ] Age Gate - Fresh install shows 18+ verification
- [ ] Room Creation (2-5 players) - Uses 3 decks
- [ ] Room Creation (6 players) - Uses 4 decks  
- [ ] Room Creation (7-8 players) - Uses 5 decks
- [ ] Diamond Purchase - Completes via Play Billing
- [ ] Host Leave - New host auto-assigned
- [ ] Player Disconnect - 60s countdown → Bot takes over
- [ ] Invite Link - Opens app → Joins correct room
- [ ] Marriage Full Round - Melds validate, scoring correct
- [ ] Call Break Full Round - Bidding works, penalties apply
- [ ] Bot AI - Reasonable moves, no crashes
- [ ] Settlement Share - Includes disclaimer, no banned terms

#### Edge Case Tests
- [ ] Offline during purchase - Fails gracefully
- [ ] All players disconnect - Room marked abandoned
- [ ] Rapid reconnect - No duplicate players
- [ ] Invalid invite link - Shows clear error
- [ ] Insufficient diamonds - Redirects to store

### Performance Targets

| Metric | Target |
|--------|--------|
| App cold start | < 3 seconds |
| Room creation | < 1 second |
| Card play latency | < 200ms |
| Bot move time | < 500ms |
| GenKit response | < 2 seconds |

---

## 🔧 PHASE 2: PRE-LAUNCH HARDENING (Weeks 2-3)

### Security Audit
- [ ] Firestore Rules - Users can only read/write their own data
- [ ] Cloud Functions - Rate limiting, input validation
- [ ] API Keys - All in environment config, not in code
- [ ] Auth - Test account deletion, token refresh
- [ ] Audit Logs - Sensitive data not logged

### Error Handling & Monitoring
- [ ] Firebase Crashlytics - Crash reporting
- [ ] Firebase Analytics - User behavior
- [ ] Error Boundaries - Prevent white screens
- [ ] Offline Mode - Clear "No connection" states

### UI/UX Polish
- [ ] Loading States - Skeletons/spinners
- [ ] Empty States - "No rooms" / "No games" screens
- [ ] Error Messages - User-friendly text
- [ ] Accessibility - TalkBack/VoiceOver, contrast
- [ ] Responsiveness - Small phones, tablets, landscape

---

## 📱 PHASE 3: STORE SUBMISSION (Weeks 3-4)

### Google Play Store Checklist

| Requirement | Status |
|-------------|--------|
| App Icon (512x512) | ⬜ |
| Feature Graphic (1024x500) | ⬜ |
| Screenshots (4+ phone, 4+ tablet) | ⬜ |
| Short Description (80 chars) | ⬜ |
| Full Description | ⬜ |
| Privacy Policy URL | ⬜ |
| Content Rating (IARC) | ⬜ |
| Target Audience (18+) | ⬜ |
| App Category (Card Games) | ⬜ |
| IAP Declaration | ⬜ |
| Data Safety Declaration | ⬜ |

### Store Description Template

```
🎴 TaasClub - Play Marriage & Call Break with Friends!

Play classic South Asian card games online with friends or practice 
against AI opponents.

GAMES:
• Marriage (Nepali Rummy) - 2-8 players
• Call Break - 4 players

FEATURES:
✓ Create private rooms with 6-digit codes
✓ Invite friends via shareable links
✓ Play against smart AI bots
✓ Track scores and settlements
✓ Voice chat during games

This app is a social scorekeeping utility for entertainment purposes only.
Virtual currency (Diamonds) is used for platform features and cannot be 
exchanged for real money. Players must be 18+ to use this app.

Not a gambling app. No real-money wagering or cash prizes.
```

---

## 📊 PHASE 4: POST-LAUNCH (Ongoing)

### Week 1 After Launch
- Monitor crash reports
- Watch user reviews
- Check audit logs
- Track IAP revenue

### First Month
- A/B test diamond prices
- Add more AI difficulty levels
- Implement tournaments
- Add friend lists

### Future Roadmap
- More Games (Teen Patti, Rummy, Spades)
- Leaderboards
- Achievements
- Custom Avatars
- Spectator Mode
- Replay System
- Clubs/Teams

---

## 🎯 Timeline Summary

| Phase | Timeline | Focus |
|-------|----------|-------|
| Phase 1 | This week | Configuration + Beta testing |
| Phase 2 | Weeks 2-3 | Security + Polish |
| Phase 3 | Weeks 3-4 | Store submission |
| Phase 4 | Ongoing | Monitor + Iterate |
