import 'dart:async';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:livekit_client/livekit_client.dart';
import 'package:firebase_auth/firebase_auth.dart';

// Reuse or duplicate config? For independency, duplicating relevant parts.
class VoiceRoomConfig {
  static const String serverUrl = 'wss://your-livekit-server.com'; // TODO: Move to Env
  
  static RoomOptions get roomOptions => const RoomOptions(
    adaptiveStream: true,
    dynacast: true,
    defaultAudioPublishOptions: AudioPublishOptions(
      dtx: true,
    ),
    defaultVideoPublishOptions: VideoPublishOptions(
      simulcast: false, // No video
    ),
  );
}

enum VoiceRoomState {
  disconnected,
  connecting,
  connected,
  reconnecting,
  failed,
}

enum VoiceRole {
  speaker,  // Can speak
  listener, // Can only listen
}

class VoiceRoomService extends ChangeNotifier {
  final FirebaseFunctions _functions = FirebaseFunctions.instance;
  final String roomId;
  final String userId;
  final String userName;
  final String? userAvatar; // For display in grid

  Room? _room;
  LocalParticipant? _localParticipant;
  final Map<String, RemoteParticipant> _remoteParticipants = {};

  VoiceRoomState _state = VoiceRoomState.disconnected;
  bool _isMicEnabled = false;
  VoiceRole _role = VoiceRole.listener;

  VoiceRoomService({
    required this.roomId,
    required this.userId,
    required this.userName,
    this.userAvatar,
  });

  // Getters
  VoiceRoomState get state => _state;
  bool get isMicEnabled => _isMicEnabled;
  bool get isConnected => _state == VoiceRoomState.connected;
  VoiceRole get role => _role;
  Room? get room => _room;
  List<Participant> get allParticipants {
    final list = <Participant>[];
    if (_localParticipant != null) list.add(_localParticipant!);
    list.addAll(_remoteParticipants.values);
    return list;
  }

  /// Join the voice room
  Future<void> joinRoom({bool asListener = true}) async {
    if (_state == VoiceRoomState.connecting || _state == VoiceRoomState.connected) return;

    _state = VoiceRoomState.connecting;
    _role = asListener ? VoiceRole.listener : VoiceRole.speaker;
    notifyListeners();

    try {
      final token = await _getToken(isListener: asListener);
      
      _room = Room();
      _setupRoomListeners();

      await _room!.connect(
        VoiceRoomConfig.serverUrl,
        token,
        roomOptions: VoiceRoomConfig.roomOptions,
      );

      _localParticipant = _room!.localParticipant;
      _state = VoiceRoomState.connected;

      if (!asListener) {
        await enableMicrophone();
      }
      
      notifyListeners();
    } catch (e) {
      debugPrint('VoiceRoom Join Error: $e');
      _state = VoiceRoomState.failed;
      notifyListeners();
      // For Demo/Dev: If server is unreachable, maybe mock connection? 
      // Nah, let's fail gracefully.
    }
  }

  Future<void> leaveRoom() async {
    await _room?.disconnect();
    _room = null;
    _localParticipant = null;
    _remoteParticipants.clear();
    _state = VoiceRoomState.disconnected;
    _isMicEnabled = false;
    notifyListeners();
  }

  Future<void> toggleMicrophone() async {
    if (_isMicEnabled) {
      await disableMicrophone();
    } else {
      await enableMicrophone();
    }
  }

  Future<void> enableMicrophone() async {
    if (_localParticipant == null || _role == VoiceRole.listener) return;
    try {
      await _localParticipant!.setMicrophoneEnabled(true);
      _isMicEnabled = true;
      notifyListeners();
    } catch (e) {
      debugPrint('Mic Error: $e');
    }
  }

  Future<void> disableMicrophone() async {
    if (_localParticipant == null) return;
    try {
      await _localParticipant!.setMicrophoneEnabled(false);
      _isMicEnabled = false;
      notifyListeners();
    } catch (e) {
      debugPrint('Mic Error: $e');
    }
  }
  
  // Hand raising logic would go here (metadata update)

  Future<String> _getToken({required bool isListener}) async {
    try {
      final callable = _functions.httpsCallable('generateLiveKitToken');
      final result = await callable.call<Map<String, dynamic>>({
        'roomName': roomId,
        'participantName': userName,
        'participantId': userId,
        'isSpectator': isListener, 
      });
      
      final data = result.data;
      if (data.containsKey('token')) {
        return data['token'] as String;
      } else {
        throw Exception('Token not found in response');
      }
    } catch (e) {
      debugPrint("VoiceRoom Token Error: $e");
      // In development, we might still want a fallback if the function fails
      // But for production, this should rethrow or handle the error gracefully
      rethrow; 
    }
  }

  void _setupRoomListeners() {
    if (_room == null) return;
    _room!.events
      ..on<RoomDisconnectedEvent>((event) {
        _state = VoiceRoomState.disconnected;
        _remoteParticipants.clear();
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
      ..on<ActiveSpeakersChangedEvent>((event) {
        notifyListeners();
      })
      ..on<TrackMutedEvent>((event) => notifyListeners())
      ..on<TrackUnmutedEvent>((event) => notifyListeners());
  }

  @override
  void dispose() {
    leaveRoom();
    super.dispose();
  }
}

// Provider
final voiceRoomServiceProvider = Provider.family.autoDispose<VoiceRoomService, String>((ref, roomId) {
  final user = FirebaseAuth.instance.currentUser;
  if (user == null) throw Exception("User must be logged in");
  
  final service = VoiceRoomService(
    roomId: roomId,
    userId: user.uid,
    userName: user.displayName ?? 'Guest',
    userAvatar: user.photoURL,
  );
  ref.onDispose(() => service.dispose());
  return service;
});
