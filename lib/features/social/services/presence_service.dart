import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/social_user_model.dart';

final presenceServiceProvider = Provider<PresenceService>((ref) {
  return PresenceService(FirebaseAuth.instance);
});

class PresenceService {
  final FirebaseAuth _auth;
  FirebaseDatabase? _db;
  bool _isInitialized = false;
  bool _isAvailable = false;
  
  StreamSubscription? _connectionSubscription;
  DatabaseReference? _userStatusRef;

  PresenceService(this._auth);
  
  /// Initialize the database lazily to catch errors
  void _initDatabase() {
    if (_isInitialized) return;
    _isInitialized = true;
    
    // Skip Realtime Database on web - it requires databaseURL in firebase_options.dart
    // which is not configured for this project
    if (kIsWeb) {
      debugPrint('ℹ️ Realtime Database skipped on web - using Firestore for presence');
      _isAvailable = false;
      return;
    }
    
    try {
      _db = FirebaseDatabase.instance;
      _isAvailable = true;
      debugPrint('✅ Realtime Database initialized');
    } catch (e) {
      debugPrint('⚠️ Realtime Database not available: $e');
      _isAvailable = false;
    }
  }

  /// Initialize presence system (call on app start)
  void initialize() {
    _initDatabase();
    
    if (!_isAvailable || _db == null) {
      debugPrint('ℹ️ Presence system disabled - Realtime Database not available');
      return;
    }
    
    _auth.authStateChanges().listen((user) {
      if (user != null) {
        _connectUser(user.uid);
      } else {
        _disconnectUser();
      }
    });
  }

  void _connectUser(String uid) {
    if (_db == null) return;
    
    // Reference to this user's status in RTDB
    _userStatusRef = _db!.ref('/status/$uid');

    // Monitor connection state
    final infoConnected = _db!.ref('.info/connected');
    
    _connectionSubscription?.cancel();
    _connectionSubscription = infoConnected.onValue.listen((event) {
      final connected = event.snapshot.value as bool? ?? false;
      
      if (connected) {
        // We are connected!
        
        // 1. Set up onDisconnect hook: ensure we go 'offline' if connection drops
        _userStatusRef!.onDisconnect().update({
          'state': UserStatus.offline.name,
          'last_changed': ServerValue.timestamp,
        });

        // 2. Set current status to 'online'
        setUserStatus(UserStatus.online);
      }
    });
  }

  void _disconnectUser() {
    _connectionSubscription?.cancel();
    // We can explicitly set offline if we want, but usually onDisconnect handles it.
    // However, if we are logging out, we should set it explicitly.
    _userStatusRef?.update({
      'state': UserStatus.offline.name,
      'last_changed': ServerValue.timestamp,
    });
    _userStatusRef = null;
  }

  /// Manually update status (e.g. entering game, away)
  Future<void> setUserStatus(UserStatus status, {String? activityId}) async {
    if (_userStatusRef == null) return;

    await _userStatusRef!.update({
      'state': status.name, // online, away, inGame
      'last_changed': ServerValue.timestamp,
      if (activityId != null) 'activity_id': activityId,
      if (activityId == null) 'activity_id': null,
    });
  }

  /// Stream of a specific user/friend's status
  Stream<SocialUserStatus> watchUserStatus(String uid) {
    if (_db == null) {
      // Return a stream that immediately emits offline status
      return Stream.value(SocialUserStatus.offline());
    }
    
    return _db!.ref('/status/$uid').onValue.map((event) {
      if (event.snapshot.value == null) return SocialUserStatus.offline();
      
      final data = Map<String, dynamic>.from(event.snapshot.value as Map);
      final stateStr = data['state'] as String? ?? 'offline';
      
      return SocialUserStatus(
        uid: uid,
        status: UserStatus.values.firstWhere(
          (e) => e.name == stateStr, 
          orElse: () => UserStatus.offline
        ),
        lastSeen: DateTime.fromMillisecondsSinceEpoch(data['last_changed'] as int? ?? 0),
        activityId: data['activity_id'] as String?,
      );
    });
  }
}

class SocialUserStatus {
  final String uid;
  final UserStatus status;
  final DateTime? lastSeen;
  final String? activityId;

  SocialUserStatus({
    required this.uid,
    required this.status,
    this.lastSeen,
    this.activityId,
  });
  
  factory SocialUserStatus.offline() => SocialUserStatus(
    uid: '', 
    status: UserStatus.offline, 
    lastSeen: DateTime.now()
  );
}
