import 'dart:async';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:livekit_client/livekit_client.dart';

import 'package:clubroyale/features/auth/auth_service.dart';

class VoiceRoomConfig {
  /// LiveKit server URL - set via --dart-define=LIVEKIT_URL=wss://your-server.com
  /// If not configured, voice rooms will be disabled
  static const String serverUrl = String.fromEnvironment(
    'LIVEKIT_URL',
    defaultValue: '',
  );
  
  /// Check if LiveKit is properly configured
  static bool get isEnabled => serverUrl.isNotEmpty && serverUrl.startsWith('wss://');
  
  static RoomOptions get roomOptions => const RoomOptions(
    adaptiveStream: true,
    dynacast: true,
    defaultAudioPublishOptions: AudioPublishOptions(
      dtx: true,
    ),
    defaultVideoPublishOptions: VideoPublishOptions(
      simulcast: false, 
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
  speaker,  
  listener, 
}

// Provider for the LiveKit Voice Room Service
final liveKitRoomServiceProvider = Provider.autoDispose.family<VoiceRoomService, String>((ref, roomId) {
  final user = ref.watch(authServiceProvider).currentUser;
  if (user == null) throw Exception('User must be logged in');
  
  final service = VoiceRoomService(
    roomId: roomId,
    userId: user.uid,
    userName: user.displayName ?? 'User',
    userAvatar: user.photoURL,
  );
  ref.onDispose(() => service.dispose());
  return service;
});

class VoiceRoomService extends ChangeNotifier {
  final FirebaseFunctions _functions = FirebaseFunctions.instance;
  final String roomId;
  final String userId;
  final String userName;
  final String? userAvatar; 

  Room? _room;
  LocalParticipant? _localParticipant;
  final Map<String, RemoteParticipant> _remoteParticipants = {};

  VoiceRoomState _state = VoiceRoomState.disconnected;
  bool _isMicEnabled = false;
  VoiceRole _role = VoiceRole.listener;
  
  // Stream to listen for unmute requests (for the UI)
  final _unmuteRequestController = StreamController<bool>.broadcast();
  Stream<bool> get onUnmuteRequested => _unmuteRequestController.stream;

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
    // Check if LiveKit is configured
    if (!VoiceRoomConfig.isEnabled) {
      debugPrint('VoiceRoom: LiveKit not configured. Set LIVEKIT_URL env var.');
      _state = VoiceRoomState.failed;
      notifyListeners();
      return;
    }
    
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
  
  /// Mute/Unmute a remote participant (Admin only)
  Future<void> muteRemoteParticipant(String participantId, bool muted) async {
    try {
      final callable = _functions.httpsCallable('muteParticipant');
      await callable.call({
        'roomId': roomId,
        'participantIdentity': participantId,
        'muted': muted,
      });
    } catch (e) {
      debugPrint('Error muting participant: $e');
      rethrow; 
    }
  }
  
  /// Mute ALL remote participants (Admin only)
  Future<void> muteAllRemoteParticipants() async {
    try {
      final callable = _functions.httpsCallable('muteAllParticipants');
      await callable.call({
        'roomId': roomId,
      });
    } catch (e) {
      debugPrint('Error muting all: $e');
      rethrow; 
    }
  }

  /// Request a user to unmute themselves (Admin only)
  Future<void> requestUnmute(String participantIdentity) async {
    if (_room == null || _localParticipant == null) return;
    
    try {
      final payload = 'REQUEST_UNMUTE'.codeUnits;
      
      await _localParticipant!.publishData(
         payload,
         reliable: true,
         destinationIdentities: [participantIdentity],
      );
    } catch (e) {
      debugPrint('Error requesting unmute: $e');
      rethrow;
    }
  }

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
      ..on<TrackUnmutedEvent>((event) => notifyListeners())
      ..on<DataReceivedEvent>((event) {
        try {
          // Decoding might be needed depending on how it's sent
          final dataString = String.fromCharCodes(event.data);
          if (dataString == 'REQUEST_UNMUTE') {
             _unmuteRequestController.add(true);
          }
        } catch (e) {
             // ignore
        }
      });
  }

  @override
  void dispose() {
    _unmuteRequestController.close();
    leaveRoom();
    super.dispose();
  }
}
