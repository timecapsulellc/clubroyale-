# FCM Push Notifications Setup Guide

> **Last Updated:** December 8, 2025

## Overview

TaasClub uses Firebase Cloud Messaging (FCM) for push notifications when:
- A user receives a game invite
- A user receives a friend request

## Architecture

```
Flutter App                     Cloud Functions
┌─────────────────┐            ┌─────────────────────────┐
│ AuthService     │───────────▶│ Store FCM Token         │
│ - getFCMToken() │            │ in /users/{uid}/fcmToken│
└─────────────────┘            └─────────────────────────┘
                                          │
         Firestore Trigger                │
         ┌────────────────────────────────▼─┐
         │ onInviteCreated                  │
         │ onFriendRequestCreated           │
         │          │                       │
         │          ▼                       │
         │   Get FCM Token from /users      │
         │          │                       │
         │          ▼                       │
         │   messaging.send({...})          │
         └──────────────────────────────────┘
```

## Setup Steps

### 1. Enable Required APIs

Visit these URLs to enable the necessary APIs:

1. **Firestore API:** https://console.developers.google.com/apis/api/firestore.googleapis.com/overview?project=taasclub-app

2. **Cloud Functions API:** https://console.cloud.google.com/apis/api/cloudfunctions.googleapis.com/overview?project=taasclub-app

3. **Firebase Cloud Messaging API:** https://console.cloud.google.com/apis/api/fcm.googleapis.com/overview?project=taasclub-app

### 2. Configure Web Push Certificate (For Web)

1. Go to Firebase Console → Project Settings → Cloud Messaging
2. Under "Web configuration", click "Generate key pair"
3. Copy the generated VAPID key
4. Add to `lib/firebase_options.dart`:
   ```dart
   // Add VAPID key for web push
   static const String webPushCertificate = 'YOUR_VAPID_KEY';
   ```

### 3. Deploy Cloud Functions

```bash
cd functions
npm run build
firebase deploy --only functions
```

### 4. Register FCM Token in Flutter

Add this to `AuthService` after sign-in:

```dart
import 'package:firebase_messaging/firebase_messaging.dart';

Future<void> registerFCMToken() async {
  final messaging = FirebaseMessaging.instance;
  
  // Request permission
  await messaging.requestPermission(
    alert: true,
    badge: true,
    sound: true,
  );
  
  // Get token
  final token = await messaging.getToken();
  if (token != null && currentUser != null) {
    await FirebaseFirestore.instance
        .collection('users')
        .doc(currentUser!.uid)
        .set({'fcmToken': token}, SetOptions(merge: true));
  }
  
  // Listen for token refresh
  messaging.onTokenRefresh.listen((newToken) {
    if (currentUser != null) {
      FirebaseFirestore.instance
          .collection('users')
          .doc(currentUser!.uid)
          .update({'fcmToken': newToken});
    }
  });
}
```

### 5. Handle Incoming Notifications in Flutter

```dart
// In main.dart
FirebaseMessaging.onMessage.listen((message) {
  // Show in-app notification
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text(message.notification?.body ?? '')),
  );
});

FirebaseMessaging.onMessageOpenedApp.listen((message) {
  // Handle notification tap
  final type = message.data['type'];
  if (type == 'game_invite') {
    context.go('/lobby/${message.data['roomId']}');
  }
});
```

## Cloud Functions Deployed

| Function | Trigger | Purpose |
|----------|---------|---------|
| `onInviteCreated` | Firestore: `/invites/{id}` | Send invite notification |
| `onFriendRequestCreated` | Firestore: `/friendRequests/{id}` | Send friend request notification |
| `getMatchSuggestions` | HTTPS Callable | AI matchmaking |

## Notification Payload

### Game Invite
```json
{
  "notification": {
    "title": "Game Invitation! 🎮",
    "body": "{name} invited you to play {gameType}"
  },
  "data": {
    "type": "game_invite",
    "inviteId": "...",
    "roomId": "...",
    "gameType": "marriage"
  }
}
```

### Friend Request
```json
{
  "notification": {
    "title": "Friend Request! 👋",
    "body": "{name} wants to be your friend"
  },
  "data": {
    "type": "friend_request",
    "requestId": "..."
  }
}
```

## Troubleshooting

### "Firestore API not enabled"
Enable at: https://console.developers.google.com/apis/api/firestore.googleapis.com/overview?project=taasclub-app

### "FCM token not found"
Ensure `registerFCMToken()` is called after sign-in.

### Notifications not showing on web
1. Check VAPID key is configured
2. Ensure service worker is registered
3. Check browser notification permissions
