// Picture-in-Picture Service
//
// Manages PiP state for video calls - allows floating video window
// while navigating to other screens during gameplay.

import 'dart:ui';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:livekit_client/livekit_client.dart';

/// PiP state model
class PipState {
  final bool isEnabled;
  final bool isMinimized;
  final Room? activeRoom;
  final List<RemoteParticipant> participants;
  final Offset position;
  final Size size;
  
  const PipState({
    this.isEnabled = false,
    this.isMinimized = false,
    this.activeRoom,
    this.participants = const [],
    this.position = const Offset(16, 100),
    this.size = const Size(150, 200),
  });
  
  bool get isPipShowing => isEnabled && isMinimized;
  
  PipState copyWith({
    bool? isEnabled,
    bool? isMinimized,
    Room? activeRoom,
    List<RemoteParticipant>? participants,
    Offset? position,
    Size? size,
  }) {
    return PipState(
      isEnabled: isEnabled ?? this.isEnabled,
      isMinimized: isMinimized ?? this.isMinimized,
      activeRoom: activeRoom ?? this.activeRoom,
      participants: participants ?? this.participants,
      position: position ?? this.position,
      size: size ?? this.size,
    );
  }
}

/// PiP Notifier using Riverpod 3.x Notifier pattern
class PipNotifier extends Notifier<PipState> {
  @override
  PipState build() => const PipState();
  
  /// Enable PiP mode with an active video room
  void enablePip(Room room) {
    final participants = room.remoteParticipants.values.toList();
    state = state.copyWith(
      isEnabled: true,
      isMinimized: true,
      activeRoom: room,
      participants: participants,
    );
    debugPrint('📺 PiP enabled with ${participants.length} participants');
  }
  
  /// Disable PiP mode
  void disablePip() {
    state = const PipState();
    debugPrint('📺 PiP disabled');
  }
  
  /// Minimize to floating window
  void minimize() {
    if (state.isEnabled) {
      state = state.copyWith(isMinimized: true);
      debugPrint('📺 PiP minimized');
    }
  }
  
  /// Maximize back to full screen
  void maximize() {
    if (state.isEnabled) {
      state = state.copyWith(isMinimized: false);
      debugPrint('📺 PiP maximized');
    }
  }
  
  /// Toggle between minimized and maximized
  void toggle() {
    if (state.isMinimized) {
      maximize();
    } else {
      minimize();
    }
  }
  
  /// Update floating window position
  void updatePosition(Offset newPosition) {
    state = state.copyWith(position: newPosition);
  }
  
  /// Snap to nearest corner
  void snapToCorner(Size screenSize) {
    final pos = state.position;
    final pipSize = state.size;
    const padding = 16.0;
    
    // Determine which side is closest
    final centerX = pos.dx + pipSize.width / 2;
    final screenCenterX = screenSize.width / 2;
    
    double newX, newY;
    
    // Horizontal snap
    if (centerX < screenCenterX) {
      newX = padding; // Left side
    } else {
      newX = screenSize.width - pipSize.width - padding; // Right side
    }
    
    // Vertical snap (keep within bounds)
    newY = pos.dy.clamp(padding, screenSize.height - pipSize.height - padding);
    
    state = state.copyWith(position: Offset(newX, newY));
  }
  
  /// Update participants list
  void updateParticipants(List<RemoteParticipant> participants) {
    state = state.copyWith(participants: participants);
  }
}

/// Provider for PiP state - using Riverpod 3.x NotifierProvider
final pipServiceProvider = NotifierProvider<PipNotifier, PipState>(
  PipNotifier.new,
);

/// Provider to check if PiP is currently showing
final isPipShowingProvider = Provider<bool>((ref) {
  final pipState = ref.watch(pipServiceProvider);
  return pipState.isPipShowing;
});
