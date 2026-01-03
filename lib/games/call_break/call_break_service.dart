/// Call Break Service - Firebase sync for multiplayer Call Break game
///
/// Handles real-time game state synchronization via Firestore
library;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:clubroyale/core/card_engine/pile.dart';
import 'package:clubroyale/core/card_engine/deck.dart';

/// Provider for CallBreakService
final callBreakServiceProvider = Provider((ref) => CallBreakService());

/// Call Break game state stored in Firestore
class CallBreakGameState {
  final String roomId;
  final List<String> playerIds;
  final String? currentPlayerId;
  final String phase; // 'bidding', 'playing', 'scoring', 'finished'
  final int currentRound;
  final Map<String, int> bids;
  final Map<String, int> tricksWon;
  final Map<String, int> scores;
  final Map<String, List<String>> hands; // Player ID -> card IDs
  final List<String> currentTrickCards;
  final String? ledSuit;
  final int cardsRemaining;
  final DateTime? updatedAt;

  CallBreakGameState({
    required this.roomId,
    required this.playerIds,
    this.currentPlayerId,
    required this.phase,
    required this.currentRound,
    required this.bids,
    required this.tricksWon,
    required this.scores,
    required this.hands,
    required this.currentTrickCards,
    this.ledSuit,
    required this.cardsRemaining,
    this.updatedAt,
  });

  factory CallBreakGameState.fromJson(Map<String, dynamic> json) {
    return CallBreakGameState(
      roomId: json['roomId'] ?? '',
      playerIds: List<String>.from(json['playerIds'] ?? []),
      currentPlayerId: json['currentPlayerId'],
      phase: json['phase'] ?? 'bidding',
      currentRound: json['currentRound'] ?? 1,
      bids: Map<String, int>.from(json['bids'] ?? {}),
      tricksWon: Map<String, int>.from(json['tricksWon'] ?? {}),
      scores: Map<String, int>.from(json['scores'] ?? {}),
      hands:
          (json['hands'] as Map<String, dynamic>?)?.map(
            (k, v) => MapEntry(k, List<String>.from(v)),
          ) ??
          {},
      currentTrickCards: List<String>.from(json['currentTrickCards'] ?? []),
      ledSuit: json['ledSuit'],
      cardsRemaining: json['cardsRemaining'] ?? 0,
      updatedAt: (json['updatedAt'] as Timestamp?)?.toDate(),
    );
  }

  Map<String, dynamic> toJson() => {
    'roomId': roomId,
    'playerIds': playerIds,
    'currentPlayerId': currentPlayerId,
    'phase': phase,
    'currentRound': currentRound,
    'bids': bids,
    'tricksWon': tricksWon,
    'scores': scores,
    'hands': hands,
    'currentTrickCards': currentTrickCards,
    'ledSuit': ledSuit,
    'cardsRemaining': cardsRemaining,
    'updatedAt': FieldValue.serverTimestamp(),
  };
}

/// Call Break multiplayer service
class CallBreakService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Card cache for ID lookups
  final Map<String, Card> _cardCache = {};

  /// Start a new Call Break game
  Future<void> startGame(String roomId, List<String> playerIds) async {
    if (playerIds.length != 4) {
      throw ArgumentError('Call Break requires exactly 4 players');
    }

    // Create and shuffle deck
    final deck = Deck.standard();
    _buildCardCache();

    // Deal 13 cards to each player
    final hands = <String, List<String>>{};
    final dealt = deck.deal(4, 13);

    for (int i = 0; i < playerIds.length; i++) {
      hands[playerIds[i]] = dealt[i].map((c) => c.id).toList();
    }

    // Initialize game state
    final state = CallBreakGameState(
      roomId: roomId,
      playerIds: playerIds,
      currentPlayerId: playerIds[0], // First player bids first
      phase: 'bidding',
      currentRound: 1,
      bids: {},
      tricksWon: {for (final p in playerIds) p: 0},
      scores: {for (final p in playerIds) p: 0},
      hands: hands,
      currentTrickCards: [],
      cardsRemaining: 0,
    );

    await _firestore
        .collection('game_rooms')
        .doc(roomId)
        .collection('call_break')
        .doc('state')
        .set(state.toJson());
  }

  void _buildCardCache() {
    _cardCache.clear();
    for (final suit in Suit.values) {
      for (final rank in Rank.values) {
        final card = Card(suit: suit, rank: rank);
        _cardCache[card.id] = card;
      }
    }
  }

  Card? _getCard(String id) {
    if (_cardCache.isEmpty) _buildCardCache();
    return _cardCache[id];
  }

  /// Watch Call Break game state
  Stream<CallBreakGameState?> watchGameState(String roomId) {
    return _firestore
        .collection('game_rooms')
        .doc(roomId)
        .collection('call_break')
        .doc('state')
        .snapshots()
        .map((snap) {
          if (!snap.exists) return null;
          return CallBreakGameState.fromJson(snap.data()!);
        });
  }

  /// Submit a bid
  Future<bool> submitBid(String roomId, String playerId, int bid) async {
    if (bid < 1 || bid > 13) return false;

    final ref = _firestore
        .collection('game_rooms')
        .doc(roomId)
        .collection('call_break')
        .doc('state');

    return _firestore.runTransaction((txn) async {
      final snap = await txn.get(ref);
      if (!snap.exists) return false;

      final state = CallBreakGameState.fromJson(snap.data()!);

      // Validate it's this player's turn and bidding phase
      if (state.phase != 'bidding') return false;
      if (state.currentPlayerId != playerId) return false;
      if (state.bids.containsKey(playerId)) return false;

      // Add bid
      final newBids = Map<String, int>.from(state.bids);
      newBids[playerId] = bid;

      // Move to next player
      final currentIdx = state.playerIds.indexOf(playerId);
      final nextIdx = (currentIdx + 1) % 4;

      // Check if all bids are in
      final allBidsIn = newBids.length == 4;

      txn.update(ref, {
        'bids': newBids,
        'currentPlayerId': state.playerIds[nextIdx],
        'phase': allBidsIn ? 'playing' : 'bidding',
        'updatedAt': FieldValue.serverTimestamp(),
      });

      return true;
    });
  }

  /// Play a card
  Future<bool> playCard(String roomId, String playerId, String cardId) async {
    final ref = _firestore
        .collection('game_rooms')
        .doc(roomId)
        .collection('call_break')
        .doc('state');

    return _firestore.runTransaction((txn) async {
      final snap = await txn.get(ref);
      if (!snap.exists) return false;

      final state = CallBreakGameState.fromJson(snap.data()!);

      if (state.phase != 'playing') return false;
      if (state.currentPlayerId != playerId) return false;

      // Validate card is in hand
      final hand = state.hands[playerId] ?? [];
      if (!hand.contains(cardId)) return false;

      // Get the card
      final card = _getCard(cardId);
      if (card == null) return false;

      // Validate follow suit if required
      if (state.currentTrickCards.isNotEmpty && state.ledSuit != null) {
        final hasSuit = hand.any((cid) {
          final c = _getCard(cid);
          return c?.suit.name == state.ledSuit;
        });

        if (hasSuit && card.suit.name != state.ledSuit) {
          return false; // Must follow suit
        }
      }

      // Update hand
      final newHand = List<String>.from(hand);
      newHand.remove(cardId);

      final newHands = Map<String, List<String>>.from(state.hands);
      newHands[playerId] = newHand;

      // Update trick
      final newTrick = List<String>.from(state.currentTrickCards);
      newTrick.add('$playerId:$cardId');

      // Determine led suit
      String? newLedSuit = state.ledSuit;
      if (state.currentTrickCards.isEmpty) {
        newLedSuit = card.suit.name;
      }

      // Move to next player
      final currentIdx = state.playerIds.indexOf(playerId);
      final nextIdx = (currentIdx + 1) % 4;

      // Check if trick is complete
      if (newTrick.length == 4) {
        // Find winner
        final winnerId = _findTrickWinner(newTrick, newLedSuit!);

        // Update tricks won
        final newTricksWon = Map<String, int>.from(state.tricksWon);
        newTricksWon[winnerId] = (newTricksWon[winnerId] ?? 0) + 1;

        // Check if round is complete (13 tricks)
        final totalTricks = newTricksWon.values.fold(0, (a, b) => a + b);

        if (totalTricks >= 13) {
          // Calculate scores
          final newScores = Map<String, int>.from(state.scores);
          for (final pid in state.playerIds) {
            final bid = state.bids[pid] ?? 0;
            final won = newTricksWon[pid] ?? 0;

            if (won >= bid) {
              newScores[pid] = (newScores[pid] ?? 0) + bid;
            } else {
              newScores[pid] = (newScores[pid] ?? 0) - bid;
            }
          }

          txn.update(ref, {
            'hands': newHands,
            'currentTrickCards': [],
            'ledSuit': null,
            'tricksWon': newTricksWon,
            'scores': newScores,
            'phase': state.currentRound >= 5 ? 'finished' : 'scoring',
            'currentPlayerId': winnerId,
            'updatedAt': FieldValue.serverTimestamp(),
          });
        } else {
          // Winner leads next trick
          txn.update(ref, {
            'hands': newHands,
            'currentTrickCards': [],
            'ledSuit': null,
            'tricksWon': newTricksWon,
            'currentPlayerId': winnerId,
            'updatedAt': FieldValue.serverTimestamp(),
          });
        }
      } else {
        // Trick continues
        txn.update(ref, {
          'hands': newHands,
          'currentTrickCards': newTrick,
          'ledSuit': newLedSuit,
          'currentPlayerId': state.playerIds[nextIdx],
          'updatedAt': FieldValue.serverTimestamp(),
        });
      }

      return true;
    });
  }

  String _findTrickWinner(List<String> trickCards, String ledSuitName) {
    String? winnerId;
    Card? winningCard;

    for (final entry in trickCards) {
      final parts = entry.split(':');
      final playerId = parts[0];
      final cardId = parts[1];
      final card = _getCard(cardId);

      if (card == null) continue;

      if (winningCard == null) {
        winnerId = playerId;
        winningCard = card;
        continue;
      }

      // Spades (trump) beats non-trump
      if (card.suit == Suit.spades && winningCard.suit != Suit.spades) {
        winnerId = playerId;
        winningCard = card;
      }
      // Higher trump beats lower trump
      else if (card.suit == Suit.spades && winningCard.suit == Suit.spades) {
        if (card.rank.value > winningCard.rank.value) {
          winnerId = playerId;
          winningCard = card;
        }
      }
      // Following led suit - higher wins
      else if (card.suit.name == ledSuitName &&
          winningCard.suit.name == ledSuitName) {
        if (card.rank.value > winningCard.rank.value) {
          winnerId = playerId;
          winningCard = card;
        }
      }
    }

    return winnerId ?? trickCards[0].split(':')[0];
  }

  /// Start next round
  Future<void> startNextRound(String roomId) async {
    final ref = _firestore
        .collection('game_rooms')
        .doc(roomId)
        .collection('call_break')
        .doc('state');

    final snap = await ref.get();
    if (!snap.exists) return;

    final state = CallBreakGameState.fromJson(snap.data()!);
    if (state.phase != 'scoring') return;

    // Deal new cards
    final deck = Deck.standard();
    _buildCardCache();

    final hands = <String, List<String>>{};
    final dealt = deck.deal(4, 13);

    for (int i = 0; i < state.playerIds.length; i++) {
      hands[state.playerIds[i]] = dealt[i].map((c) => c.id).toList();
    }

    // Rotate first player
    final newRound = state.currentRound + 1;
    final firstPlayer = state.playerIds[newRound % 4];

    await ref.update({
      'currentRound': newRound,
      'phase': 'bidding',
      'bids': {},
      'tricksWon': {for (final p in state.playerIds) p: 0},
      'hands': hands,
      'currentTrickCards': [],
      'ledSuit': null,
      'currentPlayerId': firstPlayer,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }
}
