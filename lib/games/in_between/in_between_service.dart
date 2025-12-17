/// In Between Service - Firebase sync for multiplayer In Between game
/// 
/// Handles real-time game state synchronization via Firestore
library;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:clubroyale/core/card_engine/deck.dart';
import 'package:clubroyale/core/card_engine/pile.dart';

/// Provider for InBetweenService
final inBetweenServiceProvider = Provider((ref) => InBetweenService());

/// In Between game state stored in Firestore
class InBetweenGameState {
  final String lowCardId;
  final String highCardId;
  final String? middleCardId;
  final int pot;
  final int currentBet;
  final String currentPlayerId;
  final Map<String, int> playerChips;
  final String phase;  // 'betting', 'revealing', 'result', 'finished'
  final List<String> deckCards;
  
  InBetweenGameState({
    required this.lowCardId,
    required this.highCardId,
    this.middleCardId,
    required this.pot,
    required this.currentBet,
    required this.currentPlayerId,
    required this.playerChips,
    required this.phase,
    required this.deckCards,
  });
  
  factory InBetweenGameState.fromJson(Map<String, dynamic> json) {
    return InBetweenGameState(
      lowCardId: json['lowCardId'] ?? '',
      highCardId: json['highCardId'] ?? '',
      middleCardId: json['middleCardId'],
      pot: json['pot'] ?? 0,
      currentBet: json['currentBet'] ?? 0,
      currentPlayerId: json['currentPlayerId'] ?? '',
      playerChips: (json['playerChips'] as Map<String, dynamic>?)?.map(
        (k, v) => MapEntry(k, v as int),
      ) ?? {},
      phase: json['phase'] ?? 'betting',
      deckCards: List<String>.from(json['deckCards'] ?? []),
    );
  }
  
  Map<String, dynamic> toJson() => {
    'lowCardId': lowCardId,
    'highCardId': highCardId,
    'middleCardId': middleCardId,
    'pot': pot,
    'currentBet': currentBet,
    'currentPlayerId': currentPlayerId,
    'playerChips': playerChips,
    'phase': phase,
    'deckCards': deckCards,
  };
}

class InBetweenService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  static const int startingChips = 100;
  static const int anteCost = 5;
  
  // Card lookup cache
  final Map<String, Card> _cardCache = {};
  
  InBetweenService() {
    _buildCardCache();
  }
  
  void _buildCardCache() {
    final deck = Deck.standard();
    for (final card in deck.cards) {
      _cardCache[card.id] = card;
    }
  }
  
  Card? _getCard(String id) => _cardCache[id];
  
  int _cardValue(Card card) {
    switch (card.rank) {
      case Rank.ace: return 14;
      case Rank.king: return 13;
      case Rank.queen: return 12;
      case Rank.jack: return 11;
      default: return card.rank.points;
    }
  }
  
  /// Start a new In Between game
  Future<void> startGame(String roomId, List<String> playerIds) async {
    final deck = Deck.standard();
    deck.shuffle();
    
    // Collect ante from all players
    final playerChips = <String, int>{};
    int pot = 0;
    
    for (final playerId in playerIds) {
      playerChips[playerId] = startingChips - anteCost;
      pot += anteCost;
    }
    
    // Draw two boundary cards
    final card1 = deck.drawCard()!;
    final card2 = deck.drawCard()!;
    
    // Ensure low < high
    String lowCardId, highCardId;
    final val1 = _cardValue(card1);
    final val2 = _cardValue(card2);
    
    if (val1 <= val2) {
      lowCardId = card1.id;
      highCardId = card2.id;
    } else {
      lowCardId = card2.id;
      highCardId = card1.id;
    }
    
    final gameState = InBetweenGameState(
      lowCardId: lowCardId,
      highCardId: highCardId,
      pot: pot,
      currentBet: 0,
      currentPlayerId: playerIds.first,
      playerChips: playerChips,
      phase: 'betting',
      deckCards: deck.cards.map((c) => c.id).toList(),
    );
    
    await _firestore.collection('games').doc(roomId).update({
      'status': 'playing',
      'inBetweenState': gameState.toJson(),
    });
  }
  
  /// Watch In Between game state
  Stream<InBetweenGameState?> watchGameState(String roomId) {
    return _firestore
        .collection('games')
        .doc(roomId)
        .snapshots()
        .map((snap) {
          final data = snap.data();
          if (data == null || data['inBetweenState'] == null) return null;
          return InBetweenGameState.fromJson(
            data['inBetweenState'] as Map<String, dynamic>,
          );
        });
  }
  
  /// Place a bet
  Future<bool> placeBet(String roomId, String playerId, int amount) async {
    final doc = await _firestore.collection('games').doc(roomId).get();
    final data = doc.data();
    if (data == null || data['inBetweenState'] == null) return false;
    
    final state = InBetweenGameState.fromJson(
      data['inBetweenState'] as Map<String, dynamic>,
    );
    
    if (state.currentPlayerId != playerId) return false;
    if (state.phase != 'betting') return false;
    
    final playerChips = state.playerChips[playerId] ?? 0;
    final maxBet = playerChips < state.pot ? playerChips : state.pot;
    
    if (amount < 0 || amount > maxBet) return false;
    
    await _firestore.collection('games').doc(roomId).update({
      'inBetweenState.currentBet': amount,
      'inBetweenState.phase': 'revealing',
    });
    
    return true;
  }
  
  /// Reveal middle card and calculate result
  Future<String> reveal(String roomId, String playerId) async {
    final doc = await _firestore.collection('games').doc(roomId).get();
    final data = doc.data();
    if (data == null || data['inBetweenState'] == null) return 'error';
    
    final state = InBetweenGameState.fromJson(
      data['inBetweenState'] as Map<String, dynamic>,
    );
    
    if (state.phase != 'revealing') return 'error';
    if (state.deckCards.isEmpty) return 'error';
    
    // Draw middle card
    final middleCardId = state.deckCards.first;
    final remainingDeck = state.deckCards.sublist(1);
    
    final lowCard = _getCard(state.lowCardId)!;
    final highCard = _getCard(state.highCardId)!;
    final middleCard = _getCard(middleCardId)!;
    
    final lowValue = _cardValue(lowCard);
    final highValue = _cardValue(highCard);
    final middleValue = _cardValue(middleCard);
    
    String result;
    int newPot = state.pot;
    final newChips = Map<String, int>.from(state.playerChips);
    final currentChips = newChips[playerId] ?? 0;
    
    if (middleValue == lowValue || middleValue == highValue) {
      // Post - lose double
      result = 'post';
      newChips[playerId] = currentChips - state.currentBet;
      newPot += state.currentBet * 2;
    } else if (middleValue > lowValue && middleValue < highValue) {
      // Win
      result = 'win';
      newChips[playerId] = currentChips + state.currentBet;
      newPot -= state.currentBet;
    } else {
      // Lose
      result = 'lose';
      newChips[playerId] = currentChips - state.currentBet;
      newPot += state.currentBet;
    }
    
    await _firestore.collection('games').doc(roomId).update({
      'inBetweenState.middleCardId': middleCardId,
      'inBetweenState.phase': 'result',
      'inBetweenState.pot': newPot,
      'inBetweenState.playerChips': newChips,
      'inBetweenState.deckCards': remainingDeck,
    });
    
    return result;
  }
  
  /// Next player's turn
  Future<void> nextTurn(String roomId) async {
    final doc = await _firestore.collection('games').doc(roomId).get();
    final data = doc.data();
    if (data == null || data['inBetweenState'] == null) return;
    
    final state = InBetweenGameState.fromJson(
      data['inBetweenState'] as Map<String, dynamic>,
    );
    
    final players = state.playerChips.keys.toList();
    final currentIndex = players.indexOf(state.currentPlayerId);
    final nextIndex = (currentIndex + 1) % players.length;
    final nextPlayerId = players[nextIndex];
    
    // Check if deck needs reshuffle
    var deckCards = List<String>.from(state.deckCards);
    if (deckCards.length < 5) {
      final deck = Deck.standard();
      deck.shuffle();
      deckCards = deck.cards.map((c) => c.id).toList();
    }
    
    // Draw new boundary cards
    final lowCardId = deckCards.removeAt(0);
    final highCardId = deckCards.removeAt(0);
    
    // Ensure low < high
    final lowCard = _getCard(lowCardId)!;
    final highCard = _getCard(highCardId)!;
    final lowValue = _cardValue(lowCard);
    final highValue = _cardValue(highCard);
    
    String finalLow, finalHigh;
    if (lowValue <= highValue) {
      finalLow = lowCardId;
      finalHigh = highCardId;
    } else {
      finalLow = highCardId;
      finalHigh = lowCardId;
    }
    
    await _firestore.collection('games').doc(roomId).update({
      'inBetweenState.lowCardId': finalLow,
      'inBetweenState.highCardId': finalHigh,
      'inBetweenState.middleCardId': null,
      'inBetweenState.currentBet': 0,
      'inBetweenState.currentPlayerId': nextPlayerId,
      'inBetweenState.phase': 'betting',
      'inBetweenState.deckCards': deckCards,
    });
  }
  
  /// Pass turn (bet 0)
  Future<void> pass(String roomId) async {
    await nextTurn(roomId);
  }
}
