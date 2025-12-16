import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:clubroyale/features/auth/auth_service.dart';

/// Spectator service provider
final spectatorServiceProvider = Provider<SpectatorService>((ref) {
  return SpectatorService(
    firestore: FirebaseFirestore.instance,
    ref: ref,
  );
});

/// Stream of spectators for a game
final spectatorCountProvider = StreamProvider.family<int, String>((ref, gameId) {
  return ref.watch(spectatorServiceProvider).watchSpectatorCount(gameId);
});

/// Stream of spectator list for a game
final spectatorListProvider = StreamProvider.family<List<SpectatorInfo>, String>((ref, gameId) {
  return ref.watch(spectatorServiceProvider).watchSpectators(gameId);
});

/// Spectator info model
class SpectatorInfo {
  final String id;
  final String name;
  final String? photoUrl;
  final DateTime joinedAt;

  SpectatorInfo({
    required this.id,
    required this.name,
    this.photoUrl,
    required this.joinedAt,
  });

  factory SpectatorInfo.fromJson(Map<String, dynamic> json) {
    return SpectatorInfo(
      id: json['id'] as String,
      name: json['name'] as String,
      photoUrl: json['photoUrl'] as String?,
      joinedAt: (json['joinedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'photoUrl': photoUrl,
    'joinedAt': FieldValue.serverTimestamp(),
  };
}

/// Service for managing game spectators
class SpectatorService {
  final FirebaseFirestore firestore;
  final Ref ref;

  SpectatorService({
    required this.firestore,
    required this.ref,
  });

  /// Join as a spectator
  Future<void> joinAsSpectator(String gameId) async {
    final userId = ref.read(currentUserIdProvider);
    final userProfile = ref.read(authStateProvider).value;
    
    if (userId == null) {
      throw Exception('User not authenticated');
    }

    final spectatorInfo = SpectatorInfo(
      id: userId,
      name: userProfile?.displayName ?? 'Spectator',
      photoUrl: userProfile?.photoURL,
      joinedAt: DateTime.now(),
    );

    await firestore
        .collection('games')
        .doc(gameId)
        .collection('spectators')
        .doc(userId)
        .set(spectatorInfo.toJson());
  }

  /// Leave spectator mode
  Future<void> leaveSpectator(String gameId) async {
    final userId = ref.read(currentUserIdProvider);
    if (userId == null) return;

    await firestore
        .collection('games')
        .doc(gameId)
        .collection('spectators')
        .doc(userId)
        .delete();
  }

  /// Check if current user is spectating
  Future<bool> isSpectating(String gameId) async {
    final userId = ref.read(currentUserIdProvider);
    if (userId == null) return false;

    final doc = await firestore
        .collection('games')
        .doc(gameId)
        .collection('spectators')
        .doc(userId)
        .get();

    return doc.exists;
  }

  /// Watch spectator count
  Stream<int> watchSpectatorCount(String gameId) {
    return firestore
        .collection('games')
        .doc(gameId)
        .collection('spectators')
        .snapshots()
        .map((snapshot) => snapshot.docs.length);
  }

  /// Watch spectator list
  Stream<List<SpectatorInfo>> watchSpectators(String gameId) {
    return firestore
        .collection('games')
        .doc(gameId)
        .collection('spectators')
        .orderBy('joinedAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => SpectatorInfo.fromJson({
                  'id': doc.id,
                  ...doc.data(),
                }))
            .toList());
  }

  /// Get shareable spectator link
  String getSpectatorLink(String gameId) {
    // TODO: Implement deep linking with Firebase Dynamic Links
    return 'https://clubroyale.app/watch/$gameId';
  }
}
