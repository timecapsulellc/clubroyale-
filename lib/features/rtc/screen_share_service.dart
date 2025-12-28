import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:clubroyale/core/services/app_logger.dart';
import 'package:livekit_client/livekit_client.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:clubroyale/features/auth/auth_service.dart';

/// Screen sharing service provider
final screenShareServiceProvider = Provider<ScreenShareService>((ref) {
  return ScreenShareService(ref);
});

/// Screen share state
final isScreenSharingProvider = NotifierProvider<ScreenShareNotifier, bool>(() => ScreenShareNotifier());

class ScreenShareNotifier extends Notifier<bool> {
  @override
  bool build() => false;
  
  void setSharing(bool value) {
    state = value;
  }
}

/// Screen sharing service using LiveKit
class ScreenShareService {
  final Ref ref;
  final FirebaseFunctions _functions = FirebaseFunctions.instance;
  
  Room? _room;
  LocalVideoTrack? _screenTrack;

  ScreenShareService(this.ref);

  /// Start screen sharing in a room
  Future<bool> startScreenShare({
    required String roomId,
    bool audio = true,
  }) async {
    try {
      // Get LiveKit token from backend
      final token = await _getScreenShareToken(roomId);
      if (token == null) return false;

      // Connect to LiveKit room
      _room = Room();
      await _room!.connect(
        'wss://your-livekit-server.com', // Configure via env
        token,
      );

      // Capture screen
      final source = await LocalVideoTrack.createScreenShareTrack(
        ScreenShareCaptureOptions(
          captureScreenAudio: audio,
          preferCurrentTab: true,
        ),
      );

      _screenTrack = source;
      await _room!.localParticipant?.publishVideoTrack(_screenTrack!);

      ref.read(isScreenSharingProvider.notifier).setSharing(true);
      return true;
    } catch (e) {
      AppLogger.error('Screen share error', error: e, tag: 'RTC');
      return false;
    }
  }

  /// Stop screen sharing
  Future<void> stopScreenShare() async {
    try {
      if (_screenTrack != null) {
        // await _room?.localParticipant?.unpublishTrack(_screenTrack!.sid);
        await _screenTrack?.stop();
        _screenTrack = null;
      }

      await _room?.disconnect();
      _room = null;

      ref.read(isScreenSharingProvider.notifier).setSharing(false);
    } catch (e) {
      AppLogger.error('Stop screen share error', error: e, tag: 'RTC');
    }
  }

  /// Get screen share token from backend
  Future<String?> _getScreenShareToken(String roomId) async {
    try {
      final userId = ref.read(currentUserIdProvider);
      if (userId == null) return null;

      final callable = _functions.httpsCallable('getScreenShareToken');
      final result = await callable.call<Map<String, dynamic>>({
        'roomId': roomId,
        'userId': userId,
      });

      return result.data['token'] as String?;
    } catch (e) {
      AppLogger.error('Error getting token', error: e, tag: 'RTC');
      return null;
    }
  }

  /// Check if screen sharing is supported
  static bool get isSupported {
    // Screen sharing is supported on web and desktop
    return true; // Platform check would go here
  }
}

/// Screen share button widget
// Usage example:
/*
IconButton(
  icon: Icon(isSharing ? Icons.stop_screen_share : Icons.screen_share),
  onPressed: () async {
    final service = ref.read(screenShareServiceProvider);
    if (isSharing) {
      await service.stopScreenShare();
    } else {
      await service.startScreenShare(roomId: 'game-123');
    }
  },
)
*/
