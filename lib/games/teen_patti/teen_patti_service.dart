/// Teen Patti Service - Firebase sync for multiplayer Teen Patti game
/// 
/// Handles real-time game state synchronization via Firestore
library;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:clubroyale/core/card_engine/deck.dart';

/// Provider for TeenPattiService
final teenPattiServiceProvider = Provider((ref) => TeenPattiService());

/// Teen Patti game state stored in Firestore
class TeenPattiGameState {
  final Map<String, List<String>> playerHands;  // playerId -> card IDs
  final Map<String, String> playerStatus;       // playerId -> 'blind'/'seen'/'folded'
  final Map<String, int> playerBets;            // playerId -> total bet
  final int pot;
  final int currentStake;
  final String currentPlayerId;
  final String phase;  // 'betting', 'sideShow', 'showdown', 'finished'
  final String? winnerId;
  
  TeenPattiGameState({
    required this.playerHands,
    required this.playerStatus,
    required this.playerBets,
    required this.pot,
    required this.currentStake,
    required this.currentPlayerId,
    required this.phase,
    this.winnerId,
  });
  
  factory TeenPattiGameState.fromJson(Map<String, dynamic> json) {
    return TeenPattiGameState(
      playerHands: (json['playerHands'] as Map<String, dynamic>?)?.map(
        (k, v) => MapEntry(k, List<String>.from(v as List)),
      ) ?? {},
      playerStatus: (json['playerStatus'] as Map<String, dynamic>?)?.map(
        (k, v) => MapEntry(k, v as String),
      ) ?? {},
      playerBets: (json['playerBets'] as Map<String, dynamic>?)?.map(
        (k, v) => MapEntry(k, v as int),
      ) ?? {},
      pot: json['pot'] ?? 0,
      currentStake: json['currentStake'] ?? 1,
      currentPlayerId: json['currentPlayerId'] ?? '',
      phase: json['phase'] ?? 'betting',
      winnerId: json['winnerId'],
    );
  }
  
  Map<String, dynamic> toJson() => {
    'playerHands': playerHands,
    'playerStatus': playerStatus,
    'playerBets': playerBets,
    'pot': pot,
    'currentStake': currentStake,
    'currentPlayerId': currentPlayerId,
    'phase': phase,
    'winnerId': winnerId,
  };
}

class TeenPattiService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  static const int cardsPerPlayer = 3;
  static const int bootAmount = 10;
  
  /// Start a new Teen Patti game
  Future<void> startGame(String roomId, List<String> playerIds) async {
    // Create a single deck (52 cards)
    final deck = Deck.standard();
    deck.shuffle();
    
    // Deal 3 cards to each player
    final playerHands = <String, List<String>>{};
    final playerStatus = <String, String>{};
    final playerBets = <String, int>{};
    
    for (final playerId in playerIds) {
      final hand = <String>[];
      for (int i = 0; i < cardsPerPlayer; i++) {
        final card = deck.drawCard();
        if (card != null) {
          hand.add(card.id);
        }
      }
      playerHands[playerId] = hand;
      playerStatus[playerId] = 'blind';
      playerBets[playerId] = bootAmount;
    }
    
    // Create game state
    final gameState = TeenPattiGameState(
      playerHands: playerHands,
      playerStatus: playerStatus,
      playerBets: playerBets,
      pot: bootAmount * playerIds.length,
      currentStake: 1,
      currentPlayerId: playerIds.first,
      phase: 'betting',
    );
    
    // Save to Firestore
    await _firestore.collection('games').doc(roomId).update({
      'status': 'playing',
      'teenPattiState': gameState.toJson(),
    });
  }
  
  /// Watch Teen Patti game state
  Stream<TeenPattiGameState?> watchGameState(String roomId) {
    return _firestore
        .collection('games')
        .doc(roomId)
        .snapshots()
        .map((snap) {
          final data = snap.data();
          if (data == null || data['teenPattiState'] == null) return null;
          return TeenPattiGameState.fromJson(
            data['teenPattiState'] as Map<String, dynamic>,
          );
        });
  }
  
  /// See cards (blind -> seen)
  Future<void> seeCards(String roomId, String playerId) async {
    await _firestore.collection('games').doc(roomId).update({
      'teenPattiState.playerStatus.$playerId': 'seen',
    });
  }
  
  /// Place a bet
  Future<bool> bet(String roomId, String playerId, int amount) async {
    final doc = await _firestore.collection('games').doc(roomId).get();
    final data = doc.data();
    if (data == null || data['teenPattiState'] == null) return false;
    
    final state = TeenPattiGameState.fromJson(
      data['teenPattiState'] as Map<String, dynamic>,
    );
    
    if (state.currentPlayerId != playerId) return false;
    if (state.playerStatus[playerId] == 'folded') return false;
    
    // Update bet and pot
    final newBet = (state.playerBets[playerId] ?? 0) + amount;
    final newPot = state.pot + amount;
    
    // Calculate new stake
    final isSeen = state.playerStatus[playerId] == 'seen';
    final newStake = isSeen ? amount ~/ 2 : amount;
    
    // Move to next player
    final nextPlayerId = _getNextActivePlayer(state);
    
    await _firestore.collection('games').doc(roomId).update({
      'teenPattiState.playerBets.$playerId': newBet,
      'teenPattiState.pot': newPot,
      'teenPattiState.currentStake': newStake,
      'teenPattiState.currentPlayerId': nextPlayerId,
    });
    
    return true;
  }
  
  /// Fold (pack)
  Future<void> fold(String roomId, String playerId) async {
    final doc = await _firestore.collection('games').doc(roomId).get();
    final data = doc.data();
    if (data == null || data['teenPattiState'] == null) return;
    
    final state = TeenPattiGameState.fromJson(
      data['teenPattiState'] as Map<String, dynamic>,
    );
    
    // Count remaining active players
    final activePlayers = state.playerStatus.entries
        .where((e) => e.value != 'folded')
        .map((e) => e.key)
        .toList();
    
    final updateData = <String, dynamic>{
      'teenPattiState.playerStatus.$playerId': 'folded',
    };
    
    // Check if only one player left
    if (activePlayers.length <= 2) {
      final winnerList = activePlayers.where((id) => id != playerId).toList();
      if (winnerList.isNotEmpty) {
        updateData['teenPattiState.winnerId'] = winnerList.first;
        updateData['teenPattiState.phase'] = 'finished';
        updateData['status'] = 'finished';
      }
    } else {
      // Move to next active player
      final nextPlayerId = _getNextActivePlayerExcluding(state, playerId);
      updateData['teenPattiState.currentPlayerId'] = nextPlayerId;
    }
    
    await _firestore.collection('games').doc(roomId).update(updateData);
  }
  
  /// Request showdown (when 2 players left)
  Future<String?> showdown(String roomId, String playerId) async {
    final doc = await _firestore.collection('games').doc(roomId).get();
    final data = doc.data();
    if (data == null || data['teenPattiState'] == null) return null;
    
    final state = TeenPattiGameState.fromJson(
      data['teenPattiState'] as Map<String, dynamic>,
    );
    
    // Must be exactly 2 active players
    final activePlayers = state.playerStatus.entries
        .where((e) => e.value != 'folded')
        .map((e) => e.key)
        .toList();
    
    if (activePlayers.length != 2) return null;
    
    // Compare hands (simplified - in real implementation, decode cards and compare)
    // For now, just pick the first player as winner (will be replaced with actual logic)
    final winnerId = activePlayers.first;
    
    await _firestore.collection('games').doc(roomId).update({
      'teenPattiState.winnerId': winnerId,
      'teenPattiState.phase': 'finished',
      'status': 'finished',
    });
    
    return winnerId;
  }
  
  String _getNextActivePlayer(TeenPattiGameState state) {
    final players = state.playerHands.keys.toList();
    final currentIndex = players.indexOf(state.currentPlayerId);
    
    for (int i = 1; i <= players.length; i++) {
      final nextIndex = (currentIndex + i) % players.length;
      final nextPlayerId = players[nextIndex];
      if (state.playerStatus[nextPlayerId] != 'folded') {
        return nextPlayerId;
      }
    }
    
    return state.currentPlayerId;
  }
  
  String _getNextActivePlayerExcluding(TeenPattiGameState state, String excludeId) {
    final players = state.playerHands.keys.toList();
    final currentIndex = players.indexOf(state.currentPlayerId);
    
    for (int i = 1; i <= players.length; i++) {
      final nextIndex = (currentIndex + i) % players.length;
      final nextPlayerId = players[nextIndex];
      if (nextPlayerId != excludeId && state.playerStatus[nextPlayerId] != 'folded') {
        return nextPlayerId;
      }
    }
    
    return state.currentPlayerId;
  }
}
