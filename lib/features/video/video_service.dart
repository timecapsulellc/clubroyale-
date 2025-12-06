import 'dart:async';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:livekit_client/livekit_client.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

/// Configuration for LiveKit connection
class LiveKitConfig {
  /// Your LiveKit server URL (replace with your self-hosted server)
  static const String serverUrl = 'wss://your-livekit-server.com';
  
  /// Room options for video calls
  static RoomOptions get roomOptions => const RoomOptions(
    adaptiveStream: true,
    dynacast: true,
    defaultAudioPublishOptions: AudioPublishOptions(
      dtx: true, // Discontinuous transmission for bandwidth saving
    ),
    defaultVideoPublishOptions: VideoPublishOptions(
      simulcast: true, // Enable simulcast for adaptive quality
    ),
  );
}

/// Video connection state
enum VideoConnectionState {
  disconnected,
  connecting,
  connected,
  reconnecting,
  failed,
}

/// Participant role in video room
enum ParticipantRole {
  player,    // Can publish video/audio
  spectator, // Can only subscribe
  pendingApproval, // Waiting for admin approval
}

/// Video room participant info
class VideoParticipant {
  final String odentity;
  final String? name;
  final ParticipantRole role;
  final bool isSpeaking;
  final bool isCameraEnabled;
  final bool isMicEnabled;
  final VideoTrack? videoTrack;
  final AudioTrack? audioTrack;

  VideoParticipant({
    required this.identity,
    this.name,
    required this.role,
    this.isSpeaking = false,
    this.isCameraEnabled = false,
    this.isMicEnabled = false,
    this.videoTrack,
    this.audioTrack,
  });
}

/// Service for managing LiveKit video rooms
class VideoService extends ChangeNotifier {
  final FirebaseFunctions _functions;
  final FirebaseFirestore _firestore;
  final String roomId;
  final String localUserId;
  final String localUserName;
  
  Room? _room;
  LocalParticipant? _localParticipant;
  final Map<String, RemoteParticipant> _remoteParticipants = {};
  
  VideoConnectionState _state = VideoConnectionState.disconnected;
  bool _isCameraEnabled = false;
  bool _isMicEnabled = false;
  bool _isScreenSharing = false;
  ParticipantRole _localRole = ParticipantRole.player;

  VideoService({
    required this.roomId,
    required this.localUserId,
    required this.localUserName,
    FirebaseFunctions? functions,
    FirebaseFirestore? firestore,
  }) : _functions = functions ?? FirebaseFunctions.instance,
       _firestore = firestore ?? FirebaseFirestore.instance;

  // Getters
  VideoConnectionState get state => _state;
  bool get isCameraEnabled => _isCameraEnabled;
  bool get isMicEnabled => _isMicEnabled;
  bool get isScreenSharing => _isScreenSharing;
  bool get isConnected => _state == VideoConnectionState.connected;
  ParticipantRole get localRole => _localRole;
  Room? get room => _room;
  LocalParticipant? get localParticipant => _localParticipant;
  List<RemoteParticipant> get remoteParticipants => _remoteParticipants.values.toList();

  /// Join the video room
  Future<void> joinRoom({bool asSpectator = false}) async {
    if (_state == VideoConnectionState.connecting || 
        _state == VideoConnectionState.connected) {
      return;
    }

    _state = VideoConnectionState.connecting;
    _localRole = asSpectator ? ParticipantRole.spectator : ParticipantRole.player;
    notifyListeners();

    try {
      // Get token from Cloud Function
      final token = await _getToken(isSpectator: asSpectator);
      
      // Create and connect to room
      _room = Room();
      
      // Set up event listeners
      _setupRoomListeners();
      
      // Connect to LiveKit server
      await _room!.connect(
        LiveKitConfig.serverUrl,
        token,
        roomOptions: LiveKitConfig.roomOptions,
      );

      _localParticipant = _room!.localParticipant;
      _state = VideoConnectionState.connected;
      
      // Auto-enable camera and mic for players
      if (!asSpectator) {
        await enableCamera();
        await enableMicrophone();
      }
      
      notifyListeners();
    } catch (e) {
      debugPrint('Failed to join video room: $e');
      _state = VideoConnectionState.failed;
      notifyListeners();
      rethrow;
    }
  }

  /// Leave the video room
  Future<void> leaveRoom() async {
    await _room?.disconnect();
    _room = null;
    _localParticipant = null;
    _remoteParticipants.clear();
    _state = VideoConnectionState.disconnected;
    _isCameraEnabled = false;
    _isMicEnabled = false;
    notifyListeners();
  }

  /// Enable/disable camera
  Future<void> toggleCamera() async {
    if (_isCameraEnabled) {
      await disableCamera();
    } else {
      await enableCamera();
    }
  }

  Future<void> enableCamera() async {
    if (_localParticipant == null || _localRole == ParticipantRole.spectator) return;
    
    try {
      await _localParticipant!.setCameraEnabled(true);
      _isCameraEnabled = true;
      notifyListeners();
    } catch (e) {
      debugPrint('Failed to enable camera: $e');
    }
  }

  Future<void> disableCamera() async {
    if (_localParticipant == null) return;
    
    try {
      await _localParticipant!.setCameraEnabled(false);
      _isCameraEnabled = false;
      notifyListeners();
    } catch (e) {
      debugPrint('Failed to disable camera: $e');
    }
  }

  /// Enable/disable microphone
  Future<void> toggleMicrophone() async {
    if (_isMicEnabled) {
      await disableMicrophone();
    } else {
      await enableMicrophone();
    }
  }

  Future<void> enableMicrophone() async {
    if (_localParticipant == null || _localRole == ParticipantRole.spectator) return;
    
    try {
      await _localParticipant!.setMicrophoneEnabled(true);
      _isMicEnabled = true;
      notifyListeners();
    } catch (e) {
      debugPrint('Failed to enable microphone: $e');
    }
  }

  Future<void> disableMicrophone() async {
    if (_localParticipant == null) return;
    
    try {
      await _localParticipant!.setMicrophoneEnabled(false);
      _isMicEnabled = false;
      notifyListeners();
    } catch (e) {
      debugPrint('Failed to disable microphone: $e');
    }
  }

  /// Switch camera (front/back)
  Future<void> switchCamera() async {
    if (_localParticipant == null) return;
    
    final videoTrack = _localParticipant!.videoTrackPublications.firstOrNull?.track;
    if (videoTrack is LocalVideoTrack) {
      try {
        await videoTrack.switchCamera();
      } catch (e) {
        debugPrint('Failed to switch camera: $e');
      }
    }
  }

  /// Get token from Cloud Function
  Future<String> _getToken({required bool isSpectator}) async {
    final callable = _functions.httpsCallable('generateLiveKitToken');
    final result = await callable.call<Map<String, dynamic>>({
      'roomName': roomId,
      'participantName': localUserName,
      'participantId': localUserId,
      'isSpectator': isSpectator,
    });
    
    return result.data['token'] as String;
  }

  /// Setup room event listeners
  void _setupRoomListeners() {
    if (_room == null) return;

    _room!
      ..on<RoomDisconnectedEvent>((event) {
        _state = VideoConnectionState.disconnected;
        _remoteParticipants.clear();
        notifyListeners();
      })
      ..on<RoomReconnectingEvent>((event) {
        _state = VideoConnectionState.reconnecting;
        notifyListeners();
      })
      ..on<RoomReconnectedEvent>((event) {
        _state = VideoConnectionState.connected;
        notifyListeners();
      })
      ..on<ParticipantConnectedEvent>((event) {
        _remoteParticipants[event.participant.identity] = event.participant;
        notifyListeners();
      })
      ..on<ParticipantDisconnectedEvent>((event) {
        _remoteParticipants.remove(event.participant.identity);
        notifyListeners();
      })
      ..on<TrackSubscribedEvent>((event) {
        notifyListeners();
      })
      ..on<TrackUnsubscribedEvent>((event) {
        notifyListeners();
      })
      ..on<ActiveSpeakersChangedEvent>((event) {
        notifyListeners();
      });
  }

  @override
  void dispose() {
    leaveRoom();
    super.dispose();
  }
}

// =====================================================
// ADMIN FUNCTIONS FOR SPECTATOR APPROVAL
// =====================================================

/// Service for managing spectator approvals (admin only)
class SpectatorApprovalService {
  final FirebaseFirestore _firestore;
  final String roomId;

  SpectatorApprovalService({
    required this.roomId,
    FirebaseFirestore? firestore,
  }) : _firestore = firestore ?? FirebaseFirestore.instance;

  /// Get stream of pending approvals
  Stream<List<SpectatorRequest>> get pendingApprovals {
    return _firestore
        .collection('game_rooms')
        .doc(roomId)
        .collection('pending_spectators')
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => SpectatorRequest.fromFirestore(doc))
            .toList());
  }

  /// Request to join as spectator
  Future<void> requestToJoin({
    required String userId,
    required String displayName,
  }) async {
    await _firestore
        .collection('game_rooms')
        .doc(roomId)
        .collection('pending_spectators')
        .doc(userId)
        .set({
      'userId': userId,
      'displayName': displayName,
      'requestedAt': FieldValue.serverTimestamp(),
    });
  }

  /// Approve a spectator request (admin only)
  Future<void> approveRequest(String userId) async {
    final batch = _firestore.batch();
    
    // Remove from pending
    batch.delete(_firestore
        .collection('game_rooms')
        .doc(roomId)
        .collection('pending_spectators')
        .doc(userId));
    
    // Add to approved spectators
    batch.set(
      _firestore
          .collection('game_rooms')
          .doc(roomId)
          .collection('approved_spectators')
          .doc(userId),
      {
        'approvedAt': FieldValue.serverTimestamp(),
      },
    );
    
    await batch.commit();
  }

  /// Reject a spectator request (admin only)
  Future<void> rejectRequest(String userId) async {
    await _firestore
        .collection('game_rooms')
        .doc(roomId)
        .collection('pending_spectators')
        .doc(userId)
        .delete();
  }

  /// Check if user is approved as spectator
  Future<bool> isApproved(String userId) async {
    final doc = await _firestore
        .collection('game_rooms')
        .doc(roomId)
        .collection('approved_spectators')
        .doc(userId)
        .get();
    return doc.exists;
  }
}

/// Spectator request model
class SpectatorRequest {
  final String userId;
  final String displayName;
  final DateTime? requestedAt;

  SpectatorRequest({
    required this.userId,
    required this.displayName,
    this.requestedAt,
  });

  factory SpectatorRequest.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return SpectatorRequest(
      userId: data['userId'] ?? doc.id,
      displayName: data['displayName'] ?? 'Unknown',
      requestedAt: (data['requestedAt'] as Timestamp?)?.toDate(),
    );
  }
}

// =====================================================
// RIVERPOD PROVIDERS
// =====================================================

/// Parameters for video service
class VideoServiceParams {
  final String roomId;
  final String userId;
  final String userName;

  VideoServiceParams({
    required this.roomId,
    required this.userId,
    required this.userName,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is VideoServiceParams &&
          roomId == other.roomId &&
          userId == other.userId;

  @override
  int get hashCode => roomId.hashCode ^ userId.hashCode;
}

/// Provider for video service
final videoServiceProvider = ChangeNotifierProvider.family<VideoService, VideoServiceParams>(
  (ref, params) => VideoService(
    roomId: params.roomId,
    localUserId: params.userId,
    localUserName: params.userName,
  ),
);

/// Provider for spectator approval service
final spectatorApprovalProvider = Provider.family<SpectatorApprovalService, String>(
  (ref, roomId) => SpectatorApprovalService(roomId: roomId),
);
