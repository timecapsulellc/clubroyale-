/// Replay Service
/// 
/// Manages saving, loading, and playing back game replays

import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:clubroyale/features/replay/replay_model.dart';

/// Replay Service
class ReplayService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _replaysRef =>
      _firestore.collection('replays');

  /// Save a game replay
  Future<String> saveReplay({
    required String gameType,
    required String roomId,
    required List<String> playerIds,
    required List<String> playerNames,
    required List<ReplayEvent> events,
    required int durationMs,
    String? winnerId,
    String? winnerName,
    Map<String, int>? finalScores,
    required String savedBy,
    String? title,
    bool isPublic = false,
  }) async {
    final doc = _replaysRef.doc();
    
    await doc.set({
      'id': doc.id,
      'gameType': gameType,
      'roomId': roomId,
      'playerIds': playerIds,
      'playerNames': playerNames,
      'gameDate': FieldValue.serverTimestamp(),
      'durationMs': durationMs,
      'winnerId': winnerId,
      'winnerName': winnerName,
      'finalScores': finalScores,
      'events': events.map((e) => e.toJson()).toList(),
      'savedBy': savedBy,
      'title': title ?? 'Game Replay',
      'isPublic': isPublic,
      'views': 0,
      'likedBy': [],
    });

    debugPrint('📹 Replay saved: ${doc.id}');
    return doc.id;
  }

  /// Load a replay
  Future<GameReplay?> loadReplay(String replayId) async {
    final doc = await _replaysRef.doc(replayId).get();
    if (!doc.exists) return null;
    
    // Increment view count
    await doc.reference.update({'views': FieldValue.increment(1)});
    
    return GameReplay.fromJson(doc.data()!);
  }

  /// Delete a replay
  Future<void> deleteReplay(String replayId, String userId) async {
    final doc = await _replaysRef.doc(replayId).get();
    if (!doc.exists) return;
    
    // Only the saver can delete
    if (doc.data()!['savedBy'] != userId) {
      debugPrint('Unauthorized delete attempt');
      return;
    }
    
    await doc.reference.delete();
    debugPrint('🗑️ Replay deleted: $replayId');
  }

  /// Toggle like on a replay
  Future<void> toggleLike(String replayId, String userId) async {
    final doc = _replaysRef.doc(replayId);
    
    await _firestore.runTransaction((transaction) async {
      final snapshot = await transaction.get(doc);
      if (!snapshot.exists) return;
      
      final likedBy = List<String>.from(snapshot.data()!['likedBy'] ?? []);
      
      if (likedBy.contains(userId)) {
        likedBy.remove(userId);
      } else {
        likedBy.add(userId);
      }
      
      transaction.update(doc, {'likedBy': likedBy});
    });
  }

  /// Get user's saved replays
  Stream<List<GameReplay>> watchUserReplays(String userId) {
    return _replaysRef
        .where('savedBy', isEqualTo: userId)
        .orderBy('gameDate', descending: true)
        .limit(50)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs.map((doc) => GameReplay.fromJson(doc.data())).toList();
        });
  }

  /// Get public replays (for discovery)
  Stream<List<GameReplay>> watchPublicReplays({String? gameType}) {
    var query = _replaysRef
        .where('isPublic', isEqualTo: true)
        .orderBy('gameDate', descending: true)
        .limit(50);
    
    if (gameType != null) {
      query = query.where('gameType', isEqualTo: gameType);
    }
    
    return query.snapshots().map((snapshot) {
      return snapshot.docs.map((doc) => GameReplay.fromJson(doc.data())).toList();
    });
  }

  /// Get popular replays
  Stream<List<GameReplay>> watchPopularReplays() {
    return _replaysRef
        .where('isPublic', isEqualTo: true)
        .orderBy('views', descending: true)
        .limit(20)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs.map((doc) => GameReplay.fromJson(doc.data())).toList();
        });
  }

  /// Search replays by player name
  Future<List<GameReplay>> searchByPlayer(String playerName) async {
    final snapshot = await _replaysRef
        .where('isPublic', isEqualTo: true)
        .limit(50)
        .get();
    
    return snapshot.docs
        .map((doc) => GameReplay.fromJson(doc.data()))
        .where((replay) => replay.playerNames.any(
            (name) => name.toLowerCase().contains(playerName.toLowerCase())))
        .toList();
  }
}

/// Replay Playback Controller using Riverpod Notifier
class ReplayPlaybackController extends Notifier<ReplayPlaybackState> {
  GameReplay? _replay;
  Timer? _playbackTimer;
  
  @override
  ReplayPlaybackState build() => const ReplayPlaybackState();

  /// Load replay for playback
  void loadReplay(GameReplay replay) {
    _replay = replay;
    state = ReplayPlaybackState(
      totalDuration: replay.durationMs,
      currentTime: 0,
      currentEventIndex: 0,
    );
  }

  /// Start/resume playback
  void play() {
    if (_replay == null) return;
    
    state = state.copyWith(isPlaying: true);
    
    _playbackTimer?.cancel();
    _playbackTimer = Timer.periodic(
      Duration(milliseconds: (100 / state.playbackSpeed).round()),
      (_) => _tick(),
    );
  }

  /// Pause playback
  void pause() {
    _playbackTimer?.cancel();
    state = state.copyWith(isPlaying: false);
  }

  /// Toggle play/pause
  void togglePlayPause() {
    if (state.isPlaying) {
      pause();
    } else {
      play();
    }
  }

  /// Seek to specific time
  void seekTo(int timeMs) {
    pause();
    
    // Find the event index at this time
    int eventIndex = 0;
    if (_replay != null) {
      for (int i = 0; i < _replay!.events.length; i++) {
        if (_replay!.events[i].timestamp <= timeMs) {
          eventIndex = i;
        } else {
          break;
        }
      }
    }
    
    state = state.copyWith(
      currentTime: timeMs,
      currentEventIndex: eventIndex,
    );
  }

  /// Set playback speed
  void setSpeed(double speed) {
    state = state.copyWith(playbackSpeed: speed);
    
    // Restart timer with new speed if playing
    if (state.isPlaying) {
      _playbackTimer?.cancel();
      _playbackTimer = Timer.periodic(
        Duration(milliseconds: (100 / speed).round()),
        (_) => _tick(),
      );
    }
  }

  /// Skip forward by seconds
  void skipForward(int seconds) {
    final newTime = (state.currentTime + seconds * 1000)
        .clamp(0, state.totalDuration);
    seekTo(newTime);
  }

  /// Skip backward by seconds
  void skipBackward(int seconds) {
    final newTime = (state.currentTime - seconds * 1000)
        .clamp(0, state.totalDuration);
    seekTo(newTime);
  }

  /// Go to start
  void restart() {
    seekTo(0);
  }

  void _tick() {
    if (_replay == null) return;
    
    final newTime = state.currentTime + 100;
    
    if (newTime >= state.totalDuration) {
      pause();
      state = state.copyWith(currentTime: state.totalDuration);
      return;
    }
    
    // Update event index
    int newEventIndex = state.currentEventIndex;
    while (newEventIndex < _replay!.events.length - 1 &&
           _replay!.events[newEventIndex + 1].timestamp <= newTime) {
      newEventIndex++;
    }
    
    state = state.copyWith(
      currentTime: newTime,
      currentEventIndex: newEventIndex,
    );
  }

  /// Get current event
  ReplayEvent? get currentEvent {
    if (_replay == null || _replay!.events.isEmpty) return null;
    if (state.currentEventIndex >= _replay!.events.length) return null;
    return _replay!.events[state.currentEventIndex];
  }

  /// Get events up to current time
  List<ReplayEvent> get eventsUpToNow {
    if (_replay == null) return [];
    return _replay!.events.sublist(0, state.currentEventIndex + 1);
  }

  void dispose() {
    _playbackTimer?.cancel();
  }
}

/// Providers
final replayServiceProvider = Provider<ReplayService>((ref) => ReplayService());

final userReplaysProvider = StreamProvider.family<List<GameReplay>, String>((ref, userId) {
  return ref.watch(replayServiceProvider).watchUserReplays(userId);
});

final publicReplaysProvider = StreamProvider<List<GameReplay>>((ref) {
  return ref.watch(replayServiceProvider).watchPublicReplays();
});

final replayPlaybackProvider =
    NotifierProvider<ReplayPlaybackController, ReplayPlaybackState>(
        ReplayPlaybackController.new);
