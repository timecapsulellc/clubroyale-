/// Marriage Service - Firebase sync for multiplayer Marriage game
/// 
/// Handles real-time game state synchronization via Firestore

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:taasclub/core/card_engine/pile.dart';
import 'package:taasclub/core/card_engine/deck.dart';
import 'package:taasclub/core/card_engine/meld.dart';
import 'package:taasclub/features/game/game_room.dart';

/// Provider for MarriageService
final marriageServiceProvider = Provider((ref) => MarriageService());

/// Marriage-specific game state stored in Firestore
class MarriageGameState {
  final String tipluCardId;  // The wild card for this round
  final Map<String, List<String>> playerHands;  // playerId -> card IDs
  final List<String> deckCards;  // Remaining deck cards
  final List<String> discardPile;  // Discard pile cards
  final String currentPlayerId;
  final int currentRound;
  final String phase;  // 'dealing', 'playing', 'scoring'
  
  MarriageGameState({
    required this.tipluCardId,
    required this.playerHands,
    required this.deckCards,
    required this.discardPile,
    required this.currentPlayerId,
    required this.currentRound,
    required this.phase,
  });
  
  factory MarriageGameState.fromJson(Map<String, dynamic> json) {
    return MarriageGameState(
      tipluCardId: json['tipluCardId'] ?? '',
      playerHands: (json['playerHands'] as Map<String, dynamic>?)?.map(
        (k, v) => MapEntry(k, List<String>.from(v as List)),
      ) ?? {},
      deckCards: List<String>.from(json['deckCards'] ?? []),
      discardPile: List<String>.from(json['discardPile'] ?? []),
      currentPlayerId: json['currentPlayerId'] ?? '',
      currentRound: json['currentRound'] ?? 1,
      phase: json['phase'] ?? 'waiting',
    );
  }
  
  Map<String, dynamic> toJson() => {
    'tipluCardId': tipluCardId,
    'playerHands': playerHands,
    'deckCards': deckCards,
    'discardPile': discardPile,
    'currentPlayerId': currentPlayerId,
    'currentRound': currentRound,
    'phase': phase,
  };
}

class MarriageService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  /// Cards per player in Marriage
  static const int cardsPerPlayer = 21;
  
  /// Start a new Marriage game
  Future<void> startGame(String roomId, List<String> playerIds) async {
    // Use 4 decks for 6-8 players, 3 decks for 2-5 players
    final requiredDecks = playerIds.length > 5 ? 4 : 3;
    final deck = Deck.forMarriage(deckCount: requiredDecks);
    deck.shuffle();
    
    // Deal cards to each player
    final playerHands = <String, List<String>>{};
    for (final playerId in playerIds) {
      final hand = <String>[];
      for (int i = 0; i < cardsPerPlayer; i++) {
        final card = deck.drawCard();
        if (card != null) {
          hand.add(card.id);
        }
      }
      playerHands[playerId] = hand;
    }
    
    // Draw tiplu (wild card)
    final tiplu = deck.drawCard();
    
    // Put first card on discard pile
    final firstDiscard = deck.drawCard();
    
    // Remaining deck
    final deckCards = deck.cards.map((c) => c.id).toList();
    
    // Create game state
    final gameState = MarriageGameState(
      tipluCardId: tiplu?.id ?? '',
      playerHands: playerHands,
      deckCards: deckCards,
      discardPile: firstDiscard != null ? [firstDiscard.id] : [],
      currentPlayerId: playerIds.first,
      currentRound: 1,
      phase: 'playing',
    );
    
    // Save to Firestore
    await _firestore.collection('games').doc(roomId).update({
      'status': 'playing',
      'marriageState': gameState.toJson(),
    });
  }
  
  /// Watch Marriage game state
  Stream<MarriageGameState?> watchGameState(String roomId) {
    return _firestore
        .collection('games')
        .doc(roomId)
        .snapshots()
        .map((snap) {
          final data = snap.data();
          if (data == null || data['marriageState'] == null) return null;
          return MarriageGameState.fromJson(
            data['marriageState'] as Map<String, dynamic>,
          );
        });
  }
  
  /// Draw card from deck
  Future<String?> drawFromDeck(String roomId, String playerId) async {
    final doc = await _firestore.collection('games').doc(roomId).get();
    final data = doc.data();
    if (data == null || data['marriageState'] == null) return null;
    
    final state = MarriageGameState.fromJson(
      data['marriageState'] as Map<String, dynamic>,
    );
    
    if (state.currentPlayerId != playerId) return null;
    if (state.deckCards.isEmpty) return null;
    
    // Draw top card
    final drawnCardId = state.deckCards.last;
    final newDeck = List<String>.from(state.deckCards)..removeLast();
    
    // Add to player's hand
    final newHands = Map<String, List<String>>.from(state.playerHands);
    newHands[playerId] = [...(newHands[playerId] ?? []), drawnCardId];
    
    // Update Firestore
    await _firestore.collection('games').doc(roomId).update({
      'marriageState.deckCards': newDeck,
      'marriageState.playerHands.$playerId': newHands[playerId],
    });
    
    return drawnCardId;
  }
  
  /// Draw card from discard pile
  Future<String?> drawFromDiscard(String roomId, String playerId) async {
    final doc = await _firestore.collection('games').doc(roomId).get();
    final data = doc.data();
    if (data == null || data['marriageState'] == null) return null;
    
    final state = MarriageGameState.fromJson(
      data['marriageState'] as Map<String, dynamic>,
    );
    
    if (state.currentPlayerId != playerId) return null;
    if (state.discardPile.isEmpty) return null;
    
    // Draw top card from discard
    final drawnCardId = state.discardPile.last;
    final newDiscard = List<String>.from(state.discardPile)..removeLast();
    
    // Add to player's hand
    final newHands = Map<String, List<String>>.from(state.playerHands);
    newHands[playerId] = [...(newHands[playerId] ?? []), drawnCardId];
    
    // Update Firestore
    await _firestore.collection('games').doc(roomId).update({
      'marriageState.discardPile': newDiscard,
      'marriageState.playerHands.$playerId': newHands[playerId],
    });
    
    return drawnCardId;
  }
  
  /// Discard a card
  Future<void> discardCard(String roomId, String playerId, String cardId) async {
    final doc = await _firestore.collection('games').doc(roomId).get();
    final data = doc.data();
    if (data == null || data['marriageState'] == null) return;
    
    final state = MarriageGameState.fromJson(
      data['marriageState'] as Map<String, dynamic>,
    );
    
    if (state.currentPlayerId != playerId) return;
    
    // Remove from player's hand
    final newHands = Map<String, List<String>>.from(state.playerHands);
    newHands[playerId] = (newHands[playerId] ?? [])..remove(cardId);
    
    // Add to discard pile
    final newDiscard = [...state.discardPile, cardId];
    
    // Move to next player
    final playerIds = state.playerHands.keys.toList();
    final currentIndex = playerIds.indexOf(playerId);
    final nextIndex = (currentIndex + 1) % playerIds.length;
    final nextPlayerId = playerIds[nextIndex];
    
    // Update Firestore
    await _firestore.collection('games').doc(roomId).update({
      'marriageState.discardPile': newDiscard,
      'marriageState.playerHands.$playerId': newHands[playerId],
      'marriageState.currentPlayerId': nextPlayerId,
    });
  }
  
  /// Declare/show hand (attempt to win)
  Future<bool> declare(String roomId, String playerId) async {
    final doc = await _firestore.collection('games').doc(roomId).get();
    final data = doc.data();
    if (data == null || data['marriageState'] == null) return false;
    
    final state = MarriageGameState.fromJson(
      data['marriageState'] as Map<String, dynamic>,
    );
    
    if (state.currentPlayerId != playerId) return false;
    
    // TODO: Validate all cards are in valid melds
    // For now, allow declaration if player has 21 or fewer cards
    final hand = state.playerHands[playerId] ?? [];
    if (hand.length > 21) return false;
    
    // Update game state to scoring phase
    await _firestore.collection('games').doc(roomId).update({
      'marriageState.phase': 'scoring',
      'status': 'finished',
    });
    
    return true;
  }
}
