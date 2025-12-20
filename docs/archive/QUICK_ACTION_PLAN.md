# TaasClub - Quick Action Plan 🚀

**Date:** December 9, 2025 17:48 IST  
**Current Status:** 98/100 (A+ Grade) - Beta Ready  
**Goal:** Complete final 2% and launch beta

---

## ⚡ TODAY'S PRIORITY (90 minutes total)

### 1. FCM Push Notifications Setup (50 mins) ⭐ HIGH PRIORITY

**Why:** Enable game invites and friend request notifications

**Steps:**
```bash
# Step 1: Firebase Console (5 mins)
1. Go to https://console.firebase.google.com/project/taasclub-app
2. Navigate to Project Settings → Cloud Messaging
3. Click "Generate Key Pair" under Web Push certificates
4. Copy the VAPID key

# Step 2: Add to Environment (5 mins)
5. Open `lib/core/constants/firebase_config.dart`
6. Add: static const vapidKey = 'YOUR_VAPID_KEY';

# Step 3: Update Auth Service (10 mins)
7. Already implemented in `lib/features/auth/auth_service.dart`
8. Verify FCM token registration on login

# Step 4: Test Notifications (30 mins)
9. Deploy functions: firebase deploy --only functions
10. Create test invite from User A
11. Verify User B receives notification
12. Test on web, Android (if available)
```

**📋 Detailed Guide:** [docs/FCM_SETUP.md](./docs/FCM_SETUP.md)

---

### 2. Deploy Latest Cloud Functions (10 mins) ⭐ REQUIRED

```bash
cd /Users/dadou/TaasClub
firebase deploy --only functions

# Expected output:
# ✓ functions[getGameTip] deployed
# ✓ functions[getBotPlay] deployed
# ✓ functions[marriageBotPlay] deployed
# ✓ functions[moderateChat] deployed
# ✓ functions[getBidSuggestion] deployed
# ✓ functions[getMatchSuggestions] deployed
# ✓ functions[onInviteCreated] deployed
# ✓ functions[onFriendRequestCreated] deployed
# ✓ functions[validateBid] deployed
# ✓ functions[validateMove] deployed
# ✓ functions[processSettlement] deployed
# ✓ functions[generateLiveKitToken] deployed
```

---

### 3. End-to-End Testing (30 mins) ⭐ VALIDATION

**Test Flow:**
1. **Open App** → https://taasclub-app.web.app
2. **Login** → Google sign-in as User A
3. **Create Room** → Marriage game, 4 players
4. **Copy Room Code** → Share with User B (different device/browser)
5. **Join Room** → User B enters code
6. **Start Game** → Host starts, cards dealt
7. **Play Cards** → Complete at least 3 rounds
8. **Test Chat** → Send messages (check moderation)
9. **Test Invite** → Send game invite (check FCM notification)
10. **Verify Settlement** → Check score calculation
11. **Monitor Logs** → Check Firebase Console for errors

**Expected Results:**
- ✅ Room created successfully
- ✅ Player joins without errors
- ✅ Cards dealt correctly
- ✅ Chat messages appear
- ✅ Game logic works
- ✅ No crashes in Crashlytics

---

## 📅 THIS WEEK (Days 2-7)

### Day 2: RevenueCat Setup (85 mins)

**Why:** Enable in-app purchases for diamond packs

**Steps:**
1. **Create RevenueCat Account** (15 mins)
   - Go to https://www.revenuecat.com
   - Sign up with Google account
   - Verify email

2. **Add App** (20 mins)
   - Create new project: "TaasClub"
   - Add Android app (bundle: `com.timecapsule.taasclub`)
   - Add iOS app (bundle: `com.timecapsule.taasclub`)
   - Link Play Store (requires app to be created first)

3. **Create Products** (30 mins)
   - Product 1: `diamond_pack_100` - ₹100 = 100 💎
   - Product 2: `diamond_pack_500` - ₹450 = 500 💎
   - Product 3: `diamond_pack_1000` - ₹800 = 1000 💎
   - Product 4: `diamond_pack_2000` - ₹1500 = 2000 💎
   - Product 5: `diamond_pack_5000` - ₹3500 = 5000 💎

4. **Get API Keys** (5 mins)
   - Copy Public SDK Key for Android
   - Copy Public SDK Key for iOS
   - Copy Secret API Key (for backend)

5. **Update Code** (5 mins)
   ```dart
   // lib/config/revenuecat_config.dart
   class RevenueCatConfig {
     static const String androidKey = 'YOUR_ANDROID_KEY';
     static const String iosKey = 'YOUR_IOS_KEY';
   }
   ```

6. **Test Purchase Flow** (25 mins)
   - Test on Android device (sandbox mode)
   - Verify purchase succeeds
   - Check diamond balance updates
   - Confirm transaction logged

**📋 Code Ready:** `lib/features/store/diamond_store.dart` (410 lines)

---

### Day 3-4: Beta User Testing

**Goal:** 10-20 real users

**Steps:**
1. **Recruit Testers**
   - Friends & family (5 users)
   - Social media post (5 users)
   - Game communities (5-10 users)

2. **Provide Access**
   - Share link: https://taasclub-app.web.app
   - Provide test room codes
   - Create support channel (WhatsApp group)

3. **Monitor**
   - Crashlytics dashboard (daily)
   - Firebase Analytics (user behavior)
   - Feedback collection (Google Form)

4. **Iterate**
   - Fix critical bugs immediately
   - Note feature requests
   - Improve UX based on feedback

---

### Day 5: Lighthouse PWA Audit (15 mins)

**Goal:** Achieve 90+ PWA score

```bash
# In Chrome DevTools
1. Open https://taasclub-app.web.app
2. F12 → Lighthouse tab
3. Select "Progressive Web App"
4. Click "Generate Report"

# Expected Scores:
# - PWA: 90+ ✓
# - Performance: 80+ ✓
# - Accessibility: 85+ ✓
# - Best Practices: 90+ ✓
# - SEO: 90+ ✓
```

**If score < 90:**
- Check manifest.json
- Verify service worker
- Test offline functionality
- Validate icon sizes

---

### Day 6-7: Play Store Prep (Optional)

**If ready to submit:**

1. **Create Play Console Account** (30 mins)
   - Pay $25 one-time fee
   - Complete developer profile

2. **Create App Listing** (2 hours)
   - App name: TaasClub
   - Short description (80 chars)
   - Full description (4000 chars)
   - Screenshots: 4x phone, 4x tablet
   - Feature graphic: 1024x500
   - App icon: 512x512

3. **Upload APK** (1 hour)
   ```bash
   flutter build apk --release
   # Upload to Internal Testing track
   ```

4. **Fill Forms** (1 hour)
   - Content rating (IARC)
   - Target audience (18+)
   - Privacy policy URL
   - Data safety declaration

**📋 Reference:** [docs/STORE_LISTING.md](./docs/STORE_LISTING.md)

---

## 📊 SUCCESS METRICS

### Week 1 Targets:
- ✅ FCM notifications working
- ✅ 10+ beta testers recruited
- ✅ 50+ total games played
- ✅ < 5 crashes per day
- ✅ Lighthouse score > 90

### Week 2 Targets:
- ✅ RevenueCat integrated
- ✅ 1+ successful test purchase
- ✅ Play Store listing ready
- ✅ Privacy policy live
- ✅ Terms of service live

---

## 🚨 BLOCKERS & SOLUTIONS

### Potential Issues:

| Issue | Solution |
|-------|----------|
| FCM not working on iOS | Use APNs certificate (iOS setup required) |
| RevenueCat sandbox issues | Use real Google account for testing |
| Slow Firestore queries | Add indexes in Firebase Console |
| High Cloud Function costs | Monitor usage, optimize cold starts |
| Low PWA score | Check manifest, service worker, icons |

---

## 📞 QUICK REFERENCE

| Resource | URL/Command |
|----------|-------------|
| **Live App** | https://taasclub-app.web.app |
| **Firebase Console** | https://console.firebase.google.com/project/taasclub-app |
| **Crashlytics** | Firebase Console → Crashlytics |
| **Analytics** | Firebase Console → Analytics |
| **Deploy Functions** | `firebase deploy --only functions` |
| **Deploy Hosting** | `firebase deploy --only hosting` |
| **Full Audit** | [docs/ULTIMATE_AUDIT_REPORT.md](./docs/ULTIMATE_AUDIT_REPORT.md) |

---

## ✅ DAILY CHECKLIST

### Every Morning:
- [ ] Check Crashlytics for new crashes
- [ ] Review Analytics for user activity
- [ ] Monitor Firestore usage/costs
- [ ] Check GitHub for any issues
- [ ] Test app on live URL

### Every Evening:
- [ ] Commit any code changes
- [ ] Update task list if needed
- [ ] Respond to tester feedback
- [ ] Plan next day's work

---

## 🎯 FINAL GOAL

**Launch to Beta:** December 16, 2025 (7 days from now)  
**Public Launch:** January 1, 2026 (3 weeks from now)

**Path to Success:**
1. ✅ Complete FCM setup (Today)
2. ✅ Beta testing (This week)
3. ✅ RevenueCat integration (This week)
4. ✅ Play Store submission (Next week)
5. ✅ Public launch (Week 3)

---

**You've built something amazing. Now let's share it with the world! 🚀**

---

**Last Updated:** December 9, 2025 17:48 IST  
**Next Update:** After FCM setup complete
