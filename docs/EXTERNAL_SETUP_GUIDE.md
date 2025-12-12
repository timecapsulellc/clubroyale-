# ClubRoyale - External Configuration Guide

> **Last Updated:** December 12, 2025  
> **Status:** Ready for external setup

---

## 🎯 Overview

This guide covers the **3 remaining external tasks** that require user action:

| Task | Time | Priority |
|------|------|----------|
| 1. RevenueCat API Keys | 60 mins | Optional (IAP) |
| 2. FCM Push Test | 30 mins | Recommended |
| 3. Play Store Listing | 2-3 hrs | Required for launch |

---

## 1️⃣ RevenueCat API Keys Setup (60 mins)

### What It Does
Enables in-app purchases for diamond bundles (optional - app works without it).

### Steps

#### A. Create RevenueCat Account
1. Go to https://app.revenuecat.com
2. Sign up with Google account
3. Create new project: "ClubRoyale"

#### B. Add Android App
1. Click **+ Add App** → Android
2. Package name: `com.example.myapp`
3. Connect to Google Play Console (see section 3)

#### C. Add iOS App (Optional)
1. Click **+ Add App** → iOS
2. Bundle ID: `com.example.myapp`
3. Connect to App Store Connect

#### D. Create Products
1. Go to **Products** tab
2. Add products:
   - `diamonds_100` - 100 Diamonds ($0.99)
   - `diamonds_500` - 500 Diamonds ($3.99)
   - `diamonds_1200` - 1200 Diamonds ($7.99)

#### E. Get API Keys
1. Go to **API Keys** in sidebar
2. Copy the **Public API Key** for each platform

#### F. Update Code
Edit `lib/config/revenuecat_config.dart`:

```dart
// Replace these with your actual keys
static const String _iosApiKey = 'appl_xxxxxxxxxxxx';
static const String _androidApiKey = 'goog_xxxxxxxxxxxx';
```

#### G. Test
```bash
flutter run -d android  # Test on Android device
```

---

## 2️⃣ FCM Push Notification Test (30 mins)

### What It Does
Sends push notifications for game invites and friend requests.

### Current Status
- ✅ Cloud Functions deployed
- ✅ Flutter code ready
- ⏳ Need to test on real device

### Steps

#### A. Enable FCM API
1. Go to: https://console.cloud.google.com/apis/api/fcm.googleapis.com
2. Select project: `taasclub-app`
3. Click **Enable**

#### B. Generate Web Push Certificate (VAPID Key)
1. Go to Firebase Console → Project Settings → Cloud Messaging
2. Under "Web configuration", click **Generate key pair**
3. Copy the VAPID key

#### C. Test on Android
1. Build and install APK:
   ```bash
   flutter build apk --release
   adb install build/app/outputs/flutter-apk/app-release.apk
   ```
2. Sign in to app
3. Have another user send you a friend request
4. Notification should appear

#### D. Verify in Firebase Console
1. Go to Firebase Console → Cloud Messaging
2. Click **Send your first message**
3. Target: Single device
4. Paste FCM token from logs
5. Send test notification

#### Troubleshooting
- **No notification?** Check device notification settings
- **FCM token missing?** Ensure `registerFCMToken()` is called after sign-in
- **Functions error?** Run `firebase functions:log`

---

## 3️⃣ Play Store Listing (2-3 hrs)

### What It Does
Publishes app to Google Play Store.

### Prerequisites
- [ ] Google Play Developer account ($25 one-time)
- [ ] APK ready: `build/app/outputs/flutter-apk/app-release.apk`
- [ ] Screenshots (see below)

### Steps

#### A. Create App in Play Console
1. Go to https://play.google.com/console
2. Click **Create app**
3. Fill in:
   - App name: `ClubRoyale - Royal Meld & Call Break`
   - Default language: English
   - App type: App (not Game)
   - Free or Paid: Free

#### B. Store Listing Content

**Short Description (80 chars):**
```
Play classic card games FREE with friends! Royal Meld, Call Break & more 🎴
```

**Full Description:**
```
🎴 ClubRoyale - Play Royal Meld & Call Break with Friends!

100% FREE card games with friends - no payments, no gambling, just fun!

🃏 GAMES

• Royal Meld (Marriage) - The beloved 21-card game for 2-8 players
• Call Break - The popular trick-taking game for 4 players
• Teen Patti - 3-card poker variant
• In-Between - Quick betting game

✨ FEATURES

✓ Create private rooms with 6-digit codes
✓ Invite friends via WhatsApp
✓ Play against smart AI bots
✓ Track scores and settlements
✓ 5 beautiful color themes
✓ Tournament mode & Clubs
✓ Achievement badges

💎 FREE DIAMONDS

Earn diamonds daily - no purchases required!

⚠️ This app is for entertainment only. No real-money gambling.
```

**Category:** Card Games  
**Content Rating:** Teen (simulated gambling)  
**Target Age:** 18+

#### C. Screenshots Required

| Type | Size | Count |
|------|------|-------|
| Phone | 1080x1920 | 4-8 |
| Tablet (7") | 1200x1920 | 4-8 |
| Tablet (10") | 1600x2560 | 4-8 |

**Screenshot content suggestions:**
1. Home screen with lobby
2. Game in progress (Marriage)
3. Tournament bracket view
4. Settings with themes
5. Profile with achievements

#### D. Upload APK
1. Go to **Release** → **Production**
2. Click **Create new release**
3. Upload APK from: `build/app/outputs/flutter-apk/app-release.apk`
4. Add release notes

#### E. Complete Data Safety Form
Answer based on [DATA_SAFETY_DECLARATION.md](./DATA_SAFETY_DECLARATION.md):
- Data collected: Name, email, game history
- Data shared: No
- Data encrypted: Yes (Firebase)

#### F. Submit for Review
1. Complete all required sections
2. Click **Submit for review**
3. Wait 1-7 days for approval

---

## ✅ Completion Checklist

### RevenueCat
- [ ] Account created
- [ ] Android/iOS apps added
- [ ] Products configured
- [ ] API keys copied
- [ ] Code updated
- [ ] Tested on device

### FCM Push
- [ ] FCM API enabled
- [ ] VAPID key generated (web)
- [ ] Tested on Android
- [ ] Notifications received

### Play Store
- [ ] Developer account created
- [ ] App created in Console
- [ ] Store listing filled
- [ ] Screenshots uploaded
- [ ] APK uploaded
- [ ] Data safety completed
- [ ] Submitted for review

---

## 🔗 Quick Links

| Resource | URL |
|----------|-----|
| RevenueCat Dashboard | https://app.revenuecat.com |
| Firebase Console | https://console.firebase.google.com/project/taasclub-app |
| Play Console | https://play.google.com/console |
| FCM API Enable | https://console.cloud.google.com/apis/api/fcm.googleapis.com |

---

**Note:** These tasks require external accounts and cannot be automated. Follow the steps above to complete setup.
