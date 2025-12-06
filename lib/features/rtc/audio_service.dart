import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'signaling_service.dart';

/// Configuration for WebRTC connections
class WebRTCConfig {
  /// ICE servers for STUN/TURN
  /// Replace TURN server URL with your own Coturn server
  static const List<Map<String, dynamic>> iceServers = [
    // Free Google STUN server
    {'urls': 'stun:stun.l.google.com:19302'},
    {'urls': 'stun:stun1.l.google.com:19302'},
    // Add your TURN server here for NAT traversal
    // {
    //   'urls': 'turn:your-turn-server.com:3478',
    //   'username': 'your-username',
    //   'credential': 'your-password',
    // },
  ];

  static const Map<String, dynamic> offerSdpConstraints = {
    'mandatory': {
      'OfferToReceiveAudio': true,
      'OfferToReceiveVideo': false,
    },
    'optional': [],
  };

  static const Map<String, dynamic> mediaConstraints = {
    'audio': true,
    'video': false,
  };
}

/// Audio connection state
enum AudioConnectionState {
  disconnected,
  connecting,
  connected,
  failed,
}

/// Represents a peer connection with another user
class PeerConnection {
  final String peerId;
  final RTCPeerConnection connection;
  MediaStream? remoteStream;
  bool isMuted = false;

  PeerConnection({
    required this.peerId,
    required this.connection,
  });
}

/// Audio service managing WebRTC peer connections for voice chat
class AudioService extends ChangeNotifier {
  final SignalingService _signaling;
  final Map<String, PeerConnection> _peerConnections = {};
  
  MediaStream? _localStream;
  bool _isMuted = false;
  bool _isEnabled = false;
  AudioConnectionState _state = AudioConnectionState.disconnected;

  AudioService({required SignalingService signaling}) : _signaling = signaling {
    _setupSignalingCallbacks();
  }

  // Getters
  bool get isMuted => _isMuted;
  bool get isEnabled => _isEnabled;
  AudioConnectionState get state => _state;
  List<String> get connectedPeers => _peerConnections.keys.toList();
  MediaStream? get localStream => _localStream;

  /// Setup signaling callbacks
  void _setupSignalingCallbacks() {
    _signaling.onOfferReceived = _handleOffer;
    _signaling.onAnswerReceived = _handleAnswer;
    _signaling.onCandidateReceived = _handleCandidate;
  }

  /// Initialize audio and join voice chat
  Future<void> joinAudioRoom() async {
    if (_isEnabled) return;

    _state = AudioConnectionState.connecting;
    notifyListeners();

    try {
      // Get local audio stream
      _localStream = await navigator.mediaDevices.getUserMedia(
        WebRTCConfig.mediaConstraints,
      );

      // Initialize signaling
      await _signaling.initialize();

      // Get existing participants and create offers
      final participants = await _signaling.getParticipants();
      for (final peerId in participants) {
        if (peerId != _signaling.localUserId) {
          await _createPeerConnection(peerId, isInitiator: true);
        }
      }

      _isEnabled = true;
      _state = AudioConnectionState.connected;
      notifyListeners();
    } catch (e) {
      _state = AudioConnectionState.failed;
      notifyListeners();
      rethrow;
    }
  }

  /// Leave voice chat
  Future<void> leaveAudioRoom() async {
    if (!_isEnabled) return;

    // Close all peer connections
    for (final peer in _peerConnections.values) {
      await peer.connection.close();
    }
    _peerConnections.clear();

    // Stop local stream
    _localStream?.getTracks().forEach((track) => track.stop());
    _localStream = null;

    // Leave signaling
    await _signaling.leave();

    _isEnabled = false;
    _state = AudioConnectionState.disconnected;
    notifyListeners();
  }

  /// Toggle local mute
  void toggleMute() {
    _isMuted = !_isMuted;
    
    _localStream?.getAudioTracks().forEach((track) {
      track.enabled = !_isMuted;
    });

    notifyListeners();
  }

  /// Mute/unmute a specific peer
  void togglePeerMute(String peerId) {
    final peer = _peerConnections[peerId];
    if (peer != null) {
      peer.isMuted = !peer.isMuted;
      peer.remoteStream?.getAudioTracks().forEach((track) {
        track.enabled = !peer.isMuted;
      });
      notifyListeners();
    }
  }

  /// Check if a peer is muted
  bool isPeerMuted(String peerId) {
    return _peerConnections[peerId]?.isMuted ?? false;
  }

  /// Create a new peer connection
  Future<RTCPeerConnection> _createPeerConnection(
    String peerId, {
    required bool isInitiator,
  }) async {
    final config = {
      'iceServers': WebRTCConfig.iceServers,
      'sdpSemantics': 'unified-plan',
    };

    final pc = await createPeerConnection(config);

    // Add local stream tracks
    if (_localStream != null) {
      for (final track in _localStream!.getTracks()) {
        await pc.addTrack(track, _localStream!);
      }
    }

    // Handle ICE candidates
    pc.onIceCandidate = (candidate) {
      if (candidate.candidate != null) {
        _signaling.sendCandidate(
          toPeerId: peerId,
          candidate: candidate.toMap(),
        );
      }
    };

    // Handle remote stream
    pc.onTrack = (event) {
      if (event.streams.isNotEmpty) {
        _peerConnections[peerId]?.remoteStream = event.streams[0];
        notifyListeners();
      }
    };

    // Handle connection state
    pc.onConnectionState = (state) {
      debugPrint('Peer $peerId connection state: $state');
      if (state == RTCPeerConnectionState.RTCPeerConnectionStateFailed ||
          state == RTCPeerConnectionState.RTCPeerConnectionStateDisconnected) {
        _removePeer(peerId);
      }
    };

    // Store peer connection
    _peerConnections[peerId] = PeerConnection(
      peerId: peerId,
      connection: pc,
    );

    // If initiator, create and send offer
    if (isInitiator) {
      final offer = await pc.createOffer(WebRTCConfig.offerSdpConstraints);
      await pc.setLocalDescription(offer);
      await _signaling.sendOffer(
        toPeerId: peerId,
        offer: offer.toMap(),
      );
    }

    return pc;
  }

  /// Handle incoming offer
  Future<void> _handleOffer(Map<String, dynamic> offer, String fromUserId) async {
    debugPrint('Received offer from $fromUserId');

    // Create peer connection as non-initiator
    final pc = await _createPeerConnection(fromUserId, isInitiator: false);

    // Set remote description
    await pc.setRemoteDescription(
      RTCSessionDescription(offer['sdp'], offer['type']),
    );

    // Create and send answer
    final answer = await pc.createAnswer();
    await pc.setLocalDescription(answer);
    await _signaling.sendAnswer(
      toPeerId: fromUserId,
      answer: answer.toMap(),
    );
  }

  /// Handle incoming answer
  Future<void> _handleAnswer(Map<String, dynamic> answer, String fromUserId) async {
    debugPrint('Received answer from $fromUserId');

    final peer = _peerConnections[fromUserId];
    if (peer != null) {
      await peer.connection.setRemoteDescription(
        RTCSessionDescription(answer['sdp'], answer['type']),
      );
    }
  }

  /// Handle incoming ICE candidate
  Future<void> _handleCandidate(Map<String, dynamic> candidate, String fromUserId) async {
    final peer = _peerConnections[fromUserId];
    if (peer != null) {
      await peer.connection.addCandidate(
        RTCIceCandidate(
          candidate['candidate'],
          candidate['sdpMid'],
          candidate['sdpMLineIndex'],
        ),
      );
    }
  }

  /// Remove a peer connection
  void _removePeer(String peerId) {
    final peer = _peerConnections.remove(peerId);
    peer?.connection.close();
    notifyListeners();
  }

  @override
  void dispose() {
    leaveAudioRoom();
    _signaling.dispose();
    super.dispose();
  }
}

/// Provider for audio service state
final audioServiceProvider = Provider.family.autoDispose<AudioService, SignalingParams>(
  (ref, params) {
    final signaling = ref.watch(signalingServiceProvider(params));
    final service = AudioService(signaling: signaling);
    ref.onDispose(() => service.dispose());
    return service;
  },
);

/// Provider for audio connection state
final audioConnectionStateProvider = Provider.family<AudioConnectionState, SignalingParams>(
  (ref, params) {
    final audioService = ref.watch(audioServiceProvider(params));
    return audioService.state;
  },
);

/// Provider for mute state
final audioMuteStateProvider = Provider.family<bool, SignalingParams>(
  (ref, params) {
    final audioService = ref.watch(audioServiceProvider(params));
    return audioService.isMuted;
  },
);
