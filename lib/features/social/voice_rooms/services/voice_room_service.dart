import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:clubroyale/features/social/voice_rooms/models/voice_room.dart';
import 'package:clubroyale/features/auth/auth_service.dart';
import 'package:clubroyale/features/rtc/audio_service.dart';

/// Voice room service provider
final voiceRoomServiceProvider = Provider<VoiceRoomService>((ref) {
  return VoiceRoomService(
    firestore: FirebaseFirestore.instance,
    ref: ref,
  );
});

/// Stream of active voice rooms
final activeVoiceRoomsProvider = StreamProvider<List<VoiceRoom>>((ref) {
  return ref.watch(voiceRoomServiceProvider).getActiveRooms();
});

/// Stream of current user's voice room (if any)
final currentVoiceRoomProvider = StreamProvider<VoiceRoom?>((ref) {
  final userId = ref.watch(currentUserIdProvider);
  if (userId == null) return Stream.value(null);
  return ref.watch(voiceRoomServiceProvider).getCurrentRoom(userId);
});

/// Service for managing voice rooms
class VoiceRoomService {
  final FirebaseFirestore firestore;
  final Ref ref;

  VoiceRoomService({
    required this.firestore,
    required this.ref,
  });

  CollectionReference<Map<String, dynamic>> get _roomsRef =>
      firestore.collection('voice_rooms');

  /// Create a new voice room
  Future<VoiceRoom> createRoom({
    required String name,
    String? description,
    int maxParticipants = 8,
    bool isPrivate = false,
    String? linkedGameId,
    String? linkedLobbyId,
  }) async {
    final userId = ref.read(currentUserIdProvider);
    final userProfile = ref.read(authStateProvider).value;

    if (userId == null) {
      throw Exception('User not authenticated');
    }

    final roomDoc = _roomsRef.doc();
    final now = DateTime.now();

    final room = VoiceRoom(
      id: roomDoc.id,
      name: name,
      description: description,
      hostId: userId,
      hostName: userProfile?.displayName ?? 'Host',
      participants: {
        userId: VoiceParticipant(
          id: userId,
          name: userProfile?.displayName ?? 'Host',
          photoUrl: userProfile?.photoURL,
          joinedAt: now,
        ),
      },
      maxParticipants: maxParticipants,
      createdAt: now,
      isActive: true,
      isPrivate: isPrivate,
      linkedGameId: linkedGameId,
      linkedLobbyId: linkedLobbyId,
    );

    await roomDoc.set(_roomToFirestore(room));

    return room;
  }

  /// Join an existing voice room
  Future<void> joinRoom(String roomId) async {
    final userId = ref.read(currentUserIdProvider);
    final userProfile = ref.read(authStateProvider).value;

    if (userId == null) {
      throw Exception('User not authenticated');
    }

    // Leave any current room first
    await leaveCurrentRoom();

    final participant = VoiceParticipant(
      id: userId,
      name: userProfile?.displayName ?? 'User',
      photoUrl: userProfile?.photoURL,
      joinedAt: DateTime.now(),
    );

    await _roomsRef.doc(roomId).update({
      'participants.$userId': {
        'id': userId,
        'name': participant.name,
        'photoUrl': participant.photoUrl,
        'isMuted': false,
        'isSpeaking': false,
        'isDeafened': false,
        'joinedAt': FieldValue.serverTimestamp(),
      },
    });

    // Connect to audio using existing RTC infrastructure
    // This would integrate with the existing audio_service.dart
  }

  /// Leave the current voice room
  Future<void> leaveCurrentRoom() async {
    final userId = ref.read(currentUserIdProvider);
    if (userId == null) return;

    // Find current room
    final snapshot = await _roomsRef
        .where('participants.$userId', isNull: false)
        .limit(1)
        .get();

    if (snapshot.docs.isEmpty) return;

    final roomDoc = snapshot.docs.first;
    final roomData = roomDoc.data();

    // Check if user is host
    final isHost = roomData['hostId'] == userId;

    if (isHost) {
      // If host leaves, close the room
      await closeRoom(roomDoc.id);
    } else {
      // Remove participant
      await _roomsRef.doc(roomDoc.id).update({
        'participants.$userId': FieldValue.delete(),
      });
    }
  }

  /// Close a voice room (host only)
  Future<void> closeRoom(String roomId) async {
    await _roomsRef.doc(roomId).update({
      'isActive': false,
    });
  }

  /// Toggle mute for current user
  Future<void> toggleMute(String roomId) async {
    final userId = ref.read(currentUserIdProvider);
    if (userId == null) return;

    final doc = await _roomsRef.doc(roomId).get();
    if (!doc.exists) return;

    final data = doc.data()!;
    final participants = data['participants'] as Map<String, dynamic>?;
    if (participants == null) return;

    final currentParticipant = participants[userId] as Map<String, dynamic>?;
    if (currentParticipant == null) return;

    final isMuted = currentParticipant['isMuted'] as bool? ?? false;

    await _roomsRef.doc(roomId).update({
      'participants.$userId.isMuted': !isMuted,
    });
  }

  /// Toggle deafen for current user
  Future<void> toggleDeafen(String roomId) async {
    final userId = ref.read(currentUserIdProvider);
    if (userId == null) return;

    final doc = await _roomsRef.doc(roomId).get();
    if (!doc.exists) return;

    final data = doc.data()!;
    final participants = data['participants'] as Map<String, dynamic>?;
    if (participants == null) return;

    final currentParticipant = participants[userId] as Map<String, dynamic>?;
    if (currentParticipant == null) return;

    final isDeafened = currentParticipant['isDeafened'] as bool? ?? false;

    await _roomsRef.doc(roomId).update({
      'participants.$userId.isDeafened': !isDeafened,
    });
  }

  /// Update speaking status
  Future<void> setSpeaking(String roomId, bool isSpeaking) async {
    final userId = ref.read(currentUserIdProvider);
    if (userId == null) return;

    await _roomsRef.doc(roomId).update({
      'participants.$userId.isSpeaking': isSpeaking,
    });
  }

  /// Get active voice rooms
  Stream<List<VoiceRoom>> getActiveRooms() {
    return _roomsRef
        .where('isActive', isEqualTo: true)
        .where('isPrivate', isEqualTo: false)
        .orderBy('createdAt', descending: true)
        .limit(20)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => _roomFromFirestore(doc)).toList());
  }

  /// Get current user's voice room
  Stream<VoiceRoom?> getCurrentRoom(String userId) {
    return _roomsRef
        .where('isActive', isEqualTo: true)
        .snapshots()
        .map((snapshot) {
          for (final doc in snapshot.docs) {
            final data = doc.data();
            final participants = data['participants'] as Map<String, dynamic>?;
            if (participants != null && participants.containsKey(userId)) {
              return _roomFromFirestore(doc);
            }
          }
          return null;
        });
  }

  /// Get voice room by ID
  Stream<VoiceRoom?> getRoomStream(String roomId) {
    return _roomsRef.doc(roomId).snapshots().map((doc) {
      if (!doc.exists) return null;
      return _roomFromFirestore(doc);
    });
  }

  /// Convert Firestore doc to VoiceRoom
  VoiceRoom _roomFromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data()!;
    final participantsData = data['participants'] as Map<String, dynamic>? ?? {};

    final participants = <String, VoiceParticipant>{};
    participantsData.forEach((key, value) {
      if (value is Map<String, dynamic>) {
        participants[key] = VoiceParticipant(
          id: value['id'] as String? ?? key,
          name: value['name'] as String? ?? 'User',
          photoUrl: value['photoUrl'] as String?,
          isMuted: value['isMuted'] as bool? ?? false,
          isSpeaking: value['isSpeaking'] as bool? ?? false,
          isDeafened: value['isDeafened'] as bool? ?? false,
          joinedAt: (value['joinedAt'] as Timestamp?)?.toDate(),
        );
      }
    });

    return VoiceRoom(
      id: doc.id,
      name: data['name'] as String? ?? 'Voice Room',
      description: data['description'] as String?,
      hostId: data['hostId'] as String? ?? '',
      hostName: data['hostName'] as String? ?? 'Host',
      participants: participants,
      maxParticipants: data['maxParticipants'] as int? ?? 8,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      isActive: data['isActive'] as bool? ?? true,
      isPrivate: data['isPrivate'] as bool? ?? false,
      linkedGameId: data['linkedGameId'] as String?,
      linkedLobbyId: data['linkedLobbyId'] as String?,
    );
  }

  /// Convert VoiceRoom to Firestore map
  Map<String, dynamic> _roomToFirestore(VoiceRoom room) {
    final participantsMap = <String, dynamic>{};
    room.participants.forEach((key, participant) {
      participantsMap[key] = {
        'id': participant.id,
        'name': participant.name,
        'photoUrl': participant.photoUrl,
        'isMuted': participant.isMuted,
        'isSpeaking': participant.isSpeaking,
        'isDeafened': participant.isDeafened,
        'joinedAt': participant.joinedAt != null
            ? Timestamp.fromDate(participant.joinedAt!)
            : FieldValue.serverTimestamp(),
      };
    });

    return {
      'name': room.name,
      'description': room.description,
      'hostId': room.hostId,
      'hostName': room.hostName,
      'participants': participantsMap,
      'maxParticipants': room.maxParticipants,
      'createdAt': Timestamp.fromDate(room.createdAt),
      'isActive': room.isActive,
      'isPrivate': room.isPrivate,
      'linkedGameId': room.linkedGameId,
      'linkedLobbyId': room.linkedLobbyId,
    };
  }
}
