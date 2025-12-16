/// Club Service
/// 
/// Manages gaming clubs/groups

import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:clubroyale/features/clubs/club_model.dart';
import 'package:clubroyale/features/social/models/social_chat_model.dart';

/// Club Service
class ClubService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  CollectionReference<Map<String, dynamic>> get _clubsRef =>
      _firestore.collection('clubs');

  DocumentReference<Map<String, dynamic>> _clubDoc(String id) =>
      _clubsRef.doc(id);

  /// Upload Club Avatar
  Future<String> uploadClubAvatar(File file) async {
    final ref = _storage.ref().child('clubs/${DateTime.now().millisecondsSinceEpoch}.jpg');
    await ref.putFile(file);
    return await ref.getDownloadURL();
  }

  /// Create a new club
  Future<String> createClub({
    required String ownerId,
    required String ownerName,
    required String name,
    required String description,
    ClubPrivacy privacy = ClubPrivacy.public,
    List<String> gameTypes = const [],
    String? avatarUrl,
  }) async {
    final doc = _clubsRef.doc();
    
    // 1. Create Linked Chat
    final chatRef = _firestore.collection('chats').doc();
    await chatRef.set({
      'id': chatRef.id,
      'type': 'club',
      'participants': [ownerId],
      'admins': [ownerId],
      'name': name,
      'description': description,
      'avatarUrl': avatarUrl,
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
      'unreadCounts': {},
      'metadata': {'clubId': doc.id},
    });

    // 2. Create Club
    await doc.set({
      'id': doc.id,
      'name': name,
      'description': description,
      'ownerId': ownerId,
      'ownerName': ownerName,
      'avatarUrl': avatarUrl,
      'chatId': chatRef.id, // Save Chat ID
      'privacy': privacy.name,
      'memberIds': [ownerId],
      'memberCount': 1,
      'gameTypes': gameTypes,
      'createdAt': FieldValue.serverTimestamp(),
      'totalGamesPlayed': 0,
      'weeklyActiveMembers': 0,
    });

    // Add owner as first member
    await _clubDoc(doc.id).collection('members').doc(ownerId).set({
      'oderId': ownerId,
      'userName': ownerName,
      'role': ClubRole.owner.name,
      'joinedAt': FieldValue.serverTimestamp(),
      'gamesPlayedInClub': 0,
      'winsInClub': 0,
      'totalPoints': 0,
    });

    debugPrint('🏠 Club created: ${doc.id}');
    return doc.id;
  }

  /// Join a public club
  Future<bool> joinClub({
    required String clubId,
    required String oderId,
    required String userName,
    String? avatarUrl,
  }) async {
    try {
      final doc = await _clubDoc(clubId).get();
      if (!doc.exists) return false;

      final privacy = ClubPrivacy.values.firstWhere(
        (p) => p.name == doc.data()!['privacy'],
        orElse: () => ClubPrivacy.public,
      );

      if (privacy != ClubPrivacy.public) {
        debugPrint('Club requires invite');
        return false;
      }

      final memberIds = List<String>.from(doc.data()!['memberIds'] ?? []);
      if (memberIds.contains(oderId)) {
        debugPrint('Already a member');
        return false;
      }

      final chatId = doc.data()!['chatId'] as String?;

      await _clubDoc(clubId).update({
        'memberIds': FieldValue.arrayUnion([oderId]),
        'memberCount': FieldValue.increment(1),
      });

      await _clubDoc(clubId).collection('members').doc(oderId).set({
        'oderId': oderId,
        'userName': userName,
        'avatarUrl': avatarUrl,
        'role': ClubRole.member.name,
        'joinedAt': FieldValue.serverTimestamp(),
        'gamesPlayedInClub': 0,
        'winsInClub': 0,
        'totalPoints': 0,
      });
      
      // Add to Chat
      if (chatId != null) {
        await _firestore.collection('chats').doc(chatId).update({
          'participants': FieldValue.arrayUnion([oderId])
        });
      }

      // Post activity
      await _postActivity(
        clubId: clubId,
        oderId: oderId,
        userName: userName,
        type: ClubActivityType.memberJoined,
        content: '$userName joined the club!',
      );

      debugPrint('✅ Joined club: $clubId');
      return true;
    } catch (e) {
      debugPrint('Error joining club: $e');
      return false;
    }
  }

  /// Leave a club
  Future<bool> leaveClub({
    required String clubId,
    required String oderId,
  }) async {
    try {
      final doc = await _clubDoc(clubId).get();
      if (!doc.exists) return false;

      // Owner can't leave (must transfer ownership or delete)
      if (doc.data()!['ownerId'] == oderId) {
        debugPrint('Owner cannot leave. Transfer ownership first.');
        return false;
      }
      
      final chatId = doc.data()!['chatId'] as String?;

      await _clubDoc(clubId).update({
        'memberIds': FieldValue.arrayRemove([oderId]),
        'memberCount': FieldValue.increment(-1),
      });

      await _clubDoc(clubId).collection('members').doc(oderId).delete();
      
      // Remove from Chat
      if (chatId != null) {
        await _firestore.collection('chats').doc(chatId).update({
          'participants': FieldValue.arrayRemove([oderId])
        });
      }

      return true;
    } catch (e) {
      debugPrint('Error leaving club: $e');
      return false;
    }
  }

  /// Send club invite
  Future<String> sendInvite({
    required String clubId,
    required String clubName,
    required String inviterId,
    required String inviterName,
    required String inviteeId,
    String? message,
  }) async {
    final inviteRef = _firestore.collection('club_invites').doc();
    
    await inviteRef.set({
      'id': inviteRef.id,
      'clubId': clubId,
      'clubName': clubName,
      'inviterId': inviterId,
      'inviterName': inviterName,
      'inviteeId': inviteeId,
      'message': message,
      'createdAt': FieldValue.serverTimestamp(),
      'expiresAt': DateTime.now().add(const Duration(days: 7)),
      'isAccepted': false,
      'isDeclined': false,
    });

    return inviteRef.id;
  }

  /// Accept club invite
  Future<bool> acceptInvite({
    required String inviteId,
    required String oderId,
    required String userName,
    String? avatarUrl,
  }) async {
    try {
      final inviteDoc = await _firestore.collection('club_invites').doc(inviteId).get();
      if (!inviteDoc.exists) return false;

      final data = inviteDoc.data()!;
      if (data['inviteeId'] != oderId) return false;

      final clubId = data['clubId'] as String;

      // Update invite
      await inviteDoc.reference.update({'isAccepted': true});

      // Add to club (bypass privacy check)
      await _clubDoc(clubId).update({
        'memberIds': FieldValue.arrayUnion([oderId]),
        'memberCount': FieldValue.increment(1),
      });

      await _clubDoc(clubId).collection('members').doc(oderId).set({
        'oderId': oderId,
        'userName': userName,
        'avatarUrl': avatarUrl,
        'role': ClubRole.member.name,
        'joinedAt': FieldValue.serverTimestamp(),
        'gamesPlayedInClub': 0,
        'winsInClub': 0,
        'totalPoints': 0,
      });

      return true;
    } catch (e) {
      debugPrint('Error accepting invite: $e');
      return false;
    }
  }

  /// Get club leaderboard
  Future<List<ClubLeaderboardEntry>> getLeaderboard(String clubId) async {
    final snapshot = await _clubDoc(clubId)
        .collection('members')
        .orderBy('totalPoints', descending: true)
        .limit(50)
        .get();

    return snapshot.docs.asMap().entries.map((entry) {
      final data = entry.value.data();
      final games = data['gamesPlayedInClub'] as int? ?? 0;
      final wins = data['winsInClub'] as int? ?? 0;
      
      return ClubLeaderboardEntry(
        rank: entry.key + 1,
        oderId: data['oderId'] as String,
        userName: data['userName'] as String,
        avatarUrl: data['avatarUrl'] as String?,
        games: games,
        wins: wins,
        points: data['totalPoints'] as int? ?? 0,
        winRate: games > 0 ? wins / games : 0,
      );
    }).toList();
  }

  /// Post activity to club feed
  Future<void> _postActivity({
    required String clubId,
    required String oderId,
    required String userName,
    required ClubActivityType type,
    required String content,
    String? userAvatarUrl,
    String? gameId,
    String? gameType,
  }) async {
    await _clubDoc(clubId).collection('activity').add({
      'clubId': clubId,
      'oderId': oderId,
      'userName': userName,
      'userAvatarUrl': userAvatarUrl,
      'type': type.name,
      'content': content,
      'gameId': gameId,
      'gameType': gameType,
      'createdAt': FieldValue.serverTimestamp(),
      'likedBy': [],
      'likesCount': 0,
    });
  }

  /// Watch a club
  Stream<Club?> watchClub(String id) {
    return _clubDoc(id).snapshots().map((doc) {
      if (!doc.exists) return null;
      return Club.fromJson(doc.data()!);
    });
  }

  /// Watch user's clubs
  Stream<List<Club>> watchUserClubs(String oderId) {
    return _clubsRef
        .where('memberIds', arrayContains: oderId)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs.map((doc) => Club.fromJson(doc.data())).toList();
        });
  }

  /// Search clubs
  Future<List<Club>> searchClubs(String query) async {
    final snapshot = await _clubsRef
        .where('privacy', isEqualTo: ClubPrivacy.public.name)
        .limit(20)
        .get();

    return snapshot.docs
        .map((doc) => Club.fromJson(doc.data()))
        .where((club) => 
            club.name.toLowerCase().contains(query.toLowerCase()) ||
            club.description.toLowerCase().contains(query.toLowerCase()))
        .toList();
  }

  /// Get pending invites for user
  Stream<List<ClubInvite>> watchPendingInvites(String oderId) {
    return _firestore
        .collection('club_invites')
        .where('inviteeId', isEqualTo: oderId)
        .where('isAccepted', isEqualTo: false)
        .where('isDeclined', isEqualTo: false)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs
              .map((doc) => ClubInvite.fromJson(doc.data()))
              .where((invite) => !invite.isExpired)
              .toList();
        });
  }
}

/// Provider
final clubServiceProvider = Provider<ClubService>((ref) => ClubService());

/// Watch specific club
final clubProvider = StreamProvider.family<Club?, String>((ref, id) {
  return ref.watch(clubServiceProvider).watchClub(id);
});

/// Watch user's clubs
final userClubsProvider = StreamProvider.family<List<Club>, String>((ref, oderId) {
  return ref.watch(clubServiceProvider).watchUserClubs(oderId);
});

/// Watch pending invites
final pendingClubInvitesProvider = StreamProvider.family<List<ClubInvite>, String>((ref, oderId) {
  return ref.watch(clubServiceProvider).watchPendingInvites(oderId);
});
