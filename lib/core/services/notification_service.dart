import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final notificationServiceProvider = Provider((ref) => NotificationService());

class NotificationService {
  final FirebaseMessaging _fcm = FirebaseMessaging.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> init(BuildContext context) async {
    // 1. Request Permission
    NotificationSettings settings = await _fcm.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      debugPrint('🔔 Notification permission granted');
      
      // 2. Get Token
      String? token = await _fcm.getToken();
      if (token != null) {
        await _saveToken(token);
      }

      // 3. Listen for Token Refresh
      _fcm.onTokenRefresh.listen(_saveToken);

      // 4. Foreground Messages
      FirebaseMessaging.onMessage.listen((RemoteMessage message) {
        debugPrint('🔔 Foreground Message: ${message.notification?.title}');
        if (message.notification != null && context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                   Text(message.notification!.title ?? 'New Notification', style: const TextStyle(fontWeight: FontWeight.bold)),
                   Text(message.notification!.body ?? ''),
                ],
              ),
              backgroundColor: const Color(0xFF2d1b4e),
              behavior: SnackBarBehavior.floating,
              action: SnackBarAction(label: 'VIEW', onPressed: () {}),
            ),
          );
        }
      });
    } else {
      debugPrint('🔕 Notification permission denied');
    }
  }

  Future<void> _saveToken(String token) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      // Use FieldValue.arrayUnion to allow multiple devices
      await _firestore.collection('users').doc(user.uid).set({
        'fcmTokens': FieldValue.arrayUnion([token]),
        'lastFcmUpdate': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
      debugPrint('🔔 FCM Token saved');
    }
  }
}
