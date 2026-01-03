import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:clubroyale/core/models/playing_card.dart';
import 'package:clubroyale/features/game/models/game_state.dart';
import 'package:clubroyale/features/game/logic/call_break_logic.dart';
import 'package:clubroyale/features/game/engine/models/deck.dart';

import 'package:clubroyale/features/game/services/sound_service.dart';

final callBreakServiceProvider = Provider<CallBreakService>((ref) {
  final soundService = ref.read(soundServiceProvider);
  return CallBreakService(soundService);
});

/// Service for Call Break game logic
class CallBreakService {
  final SoundService _soundService;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  CallBreakService(this._soundService);

  /// Start a new round - deal cards and set bidding phase
  Future<void> startNewRound(String gameId, List<String> playerIds) async {
    // Deal hands
    final hands = Deck.dealHands(playerIds);

    // Update game room
    await _db.collection('games').doc(gameId).update({
      'gamePhase': GamePhase.bidding.name,
      'playerHands': _serializeHands(hands),
      'bids': {},
      'currentTrick': null,
      'trickHistory': [],
      'tricksWon': {for (var playerId in playerIds) playerId: 0},
      'currentTurn': playerIds.first, // First player bids
    });
  }

  /// Place a bid for the current round
  Future<void> placeBid(String gameId, String playerId, int bidAmount) async {
    if (bidAmount < 1 || bidAmount > 13) {
      throw Exception('Bid must be between 1 and 13');
    }

    final gameDoc = await _db.collection('games').doc(gameId).get();
    final gameData = gameDoc.data()!;
    final bids = Map<String, dynamic>.from(gameData['bids'] ?? {});
    final playerIds = (gameData['players'] as List)
        .map((p) => p['id'] as String)
        .toList();

    // Add bid
    bids[playerId] = {'playerId': playerId, 'amount': bidAmount};

    // Check if all players have bid
    final allBid = playerIds.every((id) => bids.containsKey(id));

    await _db.collection('games').doc(gameId).update({
      'bids': bids,
      'gamePhase': allBid ? GamePhase.playing.name : GamePhase.bidding.name,
      'currentTurn': allBid
          ? playerIds.first
          : _getNextPlayer(playerIds, playerId),
    });
  }

  /// Validate a move before playing
  Future<void> validateMove(
    String gameId,
    String playerId,
    PlayingCard card,
  ) async {
    final gameDoc = await _db.collection('games').doc(gameId).get();
    final gameData = gameDoc.data()!;

    // 1. Check if it's player's turn
    if (gameData['currentTurn'] != playerId) {
      throw Exception('Not your turn');
    }

    // 2. Check if player has the card
    final hands = _deserializeHands(
      gameData['playerHands'] as Map<String, dynamic>,
    );
    final playerHand = hands[playerId]!;
    if (!playerHand.any((c) => c.suit == card.suit && c.rank == card.rank)) {
      throw Exception('You do not have this card');
    }

    // 3. Check rules if trick is in progress
    if (gameData['currentTrick'] != null) {
      final currentTrick = Trick.fromJson(
        gameData['currentTrick'] as Map<String, dynamic>,
      );
      final ledSuit = currentTrick.ledSuit;

      // Rule: Must follow suit if possible
      final hasLedSuit = playerHand.any((c) => c.suit == ledSuit);
      if (hasLedSuit && card.suit != ledSuit) {
        throw Exception('Must follow suit (${ledSuit.name})');
      }

      // Rule: If playing led suit, try to win
      if (card.suit == ledSuit) {
        final highestInSuit = currentTrick.cards
            .where((c) => c.card.suit == ledSuit)
            .map((c) => c.card.rank.value)
            .fold(0, (max, val) => val > max ? val : max);

        final hasHigher = playerHand.any(
          (c) => c.suit == ledSuit && c.rank.value > highestInSuit,
        );

        if (hasHigher && card.rank.value <= highestInSuit) {
          // Note: Some variations allow playing any card of suit.
          // Enforcing "must win if possible" is stricter.
          // We'll leave this as a warning or strict rule depending on config.
          // For now, let's be lenient on "must win" but strict on "must follow suit".
        }
      }

      // Rule: If cannot follow suit, must play trump (Spade) if possible
      if (!hasLedSuit) {
        final hasSpade = playerHand.any((c) => c.suit == CardSuit.spades);
        if (hasSpade && card.suit != CardSuit.spades) {
          // Exception: If another player already played a Spade,
          // you only HAVE to play a Spade if you can beat it?
          // Standard rule: Must play trump if you can't follow suit.
          throw Exception('Must play Spade if you cannot follow suit');
        }
      }
    }
  }

  /// Play a card in the current trick
  Future<void> playCard(
    String gameId,
    String playerId,
    PlayingCard card,
  ) async {
    // Validate move first
    await validateMove(gameId, playerId, card);

    final gameDoc = await _db.collection('games').doc(gameId).get();
    final gameData = gameDoc.data()!;
    final playerIds = (gameData['players'] as List)
        .map((p) => p['id'] as String)
        .toList();

    // Get current trick or create new one
    Trick currentTrick;
    if (gameData['currentTrick'] == null) {
      // First card of trick - establishes led suit
      currentTrick = Trick(
        ledSuit: card.suit,
        cards: [PlayedCard(playerId: playerId, card: card)],
      );
    } else {
      currentTrick = Trick.fromJson(
        gameData['currentTrick'] as Map<String, dynamic>,
      );
      currentTrick = currentTrick.copyWith(
        cards: [
          ...currentTrick.cards,
          PlayedCard(playerId: playerId, card: card),
        ],
      );
    }

    // Remove card from player's hand
    final hands = _deserializeHands(
      gameData['playerHands'] as Map<String, dynamic>,
    );
    hands[playerId]!.removeWhere(
      (c) => c.suit == card.suit && c.rank == card.rank,
    );

    // Play sound
    _soundService.playCardSlide();

    // Check if trick is complete
    if (currentTrick.isComplete) {
      // Determine winner using Logic class
      final winnerId = CallBreakLogic.determineTrickWinner(currentTrick);

      // Play win sound
      _soundService.playTrickWin();

      // Update tricks won
      final tricksWon = Map<String, int>.from(gameData['tricksWon'] ?? {});
      tricksWon[winnerId] = (tricksWon[winnerId] ?? 0) + 1;

      // Add to history
      final trickHistory = List<Map<String, dynamic>>.from(
        gameData['trickHistory'] ?? [],
      );
      trickHistory.add(currentTrick.copyWith(winnerId: winnerId).toJson());

      // Check if round is complete (13 tricks)
      final roundComplete = trickHistory.length == 13;

      if (roundComplete) {
        await _completeRound(gameId, tricksWon, gameData);
      } else {
        // Next trick starts with winner
        await _db.collection('games').doc(gameId).update({
          'playerHands': _serializeHands(hands),
          'currentTrick': null,
          'trickHistory': trickHistory,
          'tricksWon': tricksWon,
          'currentTurn': winnerId,
        });
      }
    } else {
      // Continue current trick
      await _db.collection('games').doc(gameId).update({
        'playerHands': _serializeHands(hands),
        'currentTrick': currentTrick.toJson(),
        'currentTurn': CallBreakLogic.getNextPlayer(playerIds, playerId),
      });
    }
  }

  /// Complete the round and calculate scores
  Future<void> _completeRound(
    String gameId,
    Map<String, int> tricksWon,
    Map<String, dynamic> gameData,
  ) async {
    final bidsData = Map<String, dynamic>.from(gameData['bids'] ?? {});
    final bids = bidsData.map((k, v) => MapEntry(k, v['amount'] as int));

    final currentRound = gameData['currentRound'] as int? ?? 1;
    final totalRounds = gameData['config']['totalRounds'] as int? ?? 5;
    final pointValue =
        (gameData['config']['pointValue'] as num?)?.toDouble() ?? 10.0;

    // Calculate round scores using Logic class
    final roundScores = CallBreakLogic.calculateRoundScores(
      bids: bids,
      tricksWon: tricksWon,
      pointValue: pointValue,
    );

    // Update cumulative scores
    final currentScores = Map<String, int>.from(gameData['scores'] ?? {});
    roundScores.forEach((playerId, roundScore) {
      currentScores[playerId] =
          (currentScores[playerId] ?? 0) + roundScore.toInt();
    });

    // Save round scores history
    final allRoundScores = Map<String, List<double>>.from(
      (gameData['roundScores'] as Map<String, dynamic>?)?.map(
            (k, v) => MapEntry(k, (v as List).cast<double>()),
          ) ??
          {},
    );
    roundScores.forEach((playerId, score) {
      allRoundScores.putIfAbsent(playerId, () => []);
      allRoundScores[playerId]!.add(score);
    });

    // Check if game is finished
    final gameFinished = currentRound >= totalRounds;

    await _db.collection('games').doc(gameId).update({
      'currentRound': currentRound + 1,
      'scores': currentScores,
      'roundScores': allRoundScores,
      'gamePhase': gameFinished
          ? GamePhase.gameFinished.name
          : GamePhase.roundEnd.name,
      'status': gameFinished ? 'settled' : 'playing',
      'finishedAt': gameFinished ? FieldValue.serverTimestamp() : null,
    });
  }

  /// Get next player in rotation
  String _getNextPlayer(List<String> playerIds, String currentPlayerId) {
    return CallBreakLogic.getNextPlayer(playerIds, currentPlayerId);
  }

  /// Serialize hands to JSON
  Map<String, dynamic> _serializeHands(Map<String, List<PlayingCard>> hands) {
    return hands.map(
      (playerId, cards) => MapEntry(playerId, Deck.serializeHand(cards)),
    );
  }

  /// Deserialize hands from JSON
  Map<String, List<PlayingCard>> _deserializeHands(Map<String, dynamic> json) {
    return json.map(
      (playerId, cardsJson) =>
          MapEntry(playerId, Deck.deserializeHand(cardsJson as List)),
    );
  }
}
