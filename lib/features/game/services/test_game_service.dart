import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:clubroyale/features/game/game_room.dart';
import 'package:clubroyale/features/game/game_config.dart';
import 'package:clubroyale/core/models/playing_card.dart';
import 'package:clubroyale/features/game/models/game_state.dart';
import 'package:clubroyale/features/game/logic/call_break_logic.dart';
import 'package:clubroyale/features/game/engine/models/deck.dart';
import 'dart:async';

final testGameServiceProvider = Provider<TestGameService>(
  (ref) => TestGameService(),
);

/// In-memory game service for Test Mode - bypasses Firestore entirely
class TestGameService {
  /// Static storage for current test game
  static GameRoom? _currentGame;
  static final StreamController<GameRoom?> _gameController =
      StreamController<GameRoom?>.broadcast();

  /// Get the current test game ID
  static const String testGameId = 'test_quick_game';

  /// Stream of game state updates
  Stream<GameRoom?> watchGame() {
    // Emit current state for new listeners
    Future.microtask(() => _gameController.add(_currentGame));
    return _gameController.stream;
  }

  /// Get current game
  GameRoom? get currentGame => _currentGame;

  /// Create a quick test game with 1 human + 3 bots
  GameRoom createQuickGame(String humanPlayerId, String humanPlayerName) {
    final botIds = [
      'bot_1_${DateTime.now().millisecondsSinceEpoch}',
      'bot_2_${DateTime.now().millisecondsSinceEpoch + 1}',
      'bot_3_${DateTime.now().millisecondsSinceEpoch + 2}',
    ];

    final players = [
      Player(id: humanPlayerId, name: humanPlayerName, isReady: true),
      Player(id: botIds[0], name: 'Bot Alpha', isReady: true),
      Player(id: botIds[1], name: 'Bot Beta', isReady: true),
      Player(id: botIds[2], name: 'Bot Gamma', isReady: true),
    ];

    final playerIds = players.map((p) => p.id).toList();

    // Deal hands
    final hands = Deck.dealHands(playerIds);

    _currentGame = GameRoom(
      id: testGameId,
      name: 'Quick Test Game',
      hostId: humanPlayerId,
      roomCode: '000000',
      status: GameStatus.playing,
      config: const GameConfig(totalRounds: 5, pointValue: 10.0),
      players: players,
      scores: {for (var p in players) p.id: 0},
      createdAt: DateTime.now(),
      gamePhase: GamePhase.bidding,
      currentRound: 1,
      currentTurn: playerIds.first,
      playerHands: hands,
      bids: <String, Bid>{},
      tricksWon: {for (var p in players) p.id: 0},
      currentTrick: null,
      trickHistory: [],
    );

    debugPrint('🧪 Quick Test Game Created with ${players.length} players');
    _notify();
    return _currentGame!;
  }

  /// Place a bid
  Future<void> placeBid(String playerId, int bidAmount) async {
    if (_currentGame == null) return;

    final bids = Map<String, Bid>.from(_currentGame!.bids);
    bids[playerId] = Bid(playerId: playerId, amount: bidAmount);

    final playerIds = _currentGame!.players.map((p) => p.id).toList();
    final allBid = playerIds.every((id) => bids.containsKey(id));

    _currentGame = _currentGame!.copyWith(
      bids: bids,
      gamePhase: allBid ? GamePhase.playing : GamePhase.bidding,
      currentTurn: allBid
          ? playerIds.first
          : CallBreakLogic.getNextPlayer(playerIds, playerId),
    );

    debugPrint('🧪 Bid placed: $playerId -> $bidAmount (All bid: $allBid)');
    _notify();

    // Auto-bid for bots after human bids
    if (!allBid && _currentGame!.currentTurn!.startsWith('bot_')) {
      await Future.delayed(const Duration(milliseconds: 500));
      await _autoBotBid();
    }
  }

  /// Auto-bid for bots
  Future<void> _autoBotBid() async {
    if (_currentGame == null) return;

    while (_currentGame!.gamePhase == GamePhase.bidding &&
        _currentGame!.currentTurn != null &&
        _currentGame!.currentTurn!.startsWith('bot_')) {
      final botId = _currentGame!.currentTurn!;
      final botHand = _currentGame!.playerHands[botId] ?? [];
      final spadeCount = botHand.where((c) => c.suit == CardSuit.spades).length;
      final bid = (2 + spadeCount ~/ 2).clamp(1, 5); // Simple bot logic

      await placeBid(botId, bid);
      await Future.delayed(const Duration(milliseconds: 300));
    }
  }

  /// Play a card
  Future<void> playCard(String playerId, PlayingCard card) async {
    if (_currentGame == null) return;

    final hands = Map<String, List<PlayingCard>>.from(
      _currentGame!.playerHands,
    );
    final playerHand = List<PlayingCard>.from(hands[playerId] ?? []);
    playerHand.removeWhere((c) => c.suit == card.suit && c.rank == card.rank);
    hands[playerId] = playerHand;

    // Get or create current trick
    Trick currentTrick;
    if (_currentGame!.currentTrick == null) {
      currentTrick = Trick(
        ledSuit: card.suit,
        cards: [PlayedCard(playerId: playerId, card: card)],
      );
    } else {
      currentTrick = _currentGame!.currentTrick!.copyWith(
        cards: [
          ..._currentGame!.currentTrick!.cards,
          PlayedCard(playerId: playerId, card: card),
        ],
      );
    }

    final playerIds = _currentGame!.players.map((p) => p.id).toList();

    // Check if trick is complete
    if (currentTrick.isComplete) {
      final winnerId = CallBreakLogic.determineTrickWinner(currentTrick);
      final tricksWon = Map<String, int>.from(_currentGame!.tricksWon);
      tricksWon[winnerId] = (tricksWon[winnerId] ?? 0) + 1;

      final trickHistory = List<Trick>.from(_currentGame!.trickHistory);
      trickHistory.add(currentTrick.copyWith(winnerId: winnerId));

      final roundComplete = trickHistory.length == 13;

      if (roundComplete) {
        await _completeRound(tricksWon);
      } else {
        _currentGame = _currentGame!.copyWith(
          playerHands: hands,
          currentTrick: null,
          trickHistory: trickHistory,
          tricksWon: tricksWon,
          currentTurn: winnerId,
        );
        _notify();

        // Auto-play for bots
        if (winnerId.startsWith('bot_')) {
          await Future.delayed(const Duration(milliseconds: 500));
          await _autoBotPlay();
        }
      }
    } else {
      final nextPlayer = CallBreakLogic.getNextPlayer(playerIds, playerId);
      _currentGame = _currentGame!.copyWith(
        playerHands: hands,
        currentTrick: currentTrick,
        currentTurn: nextPlayer,
      );
      _notify();

      // Auto-play for bots
      if (nextPlayer.startsWith('bot_')) {
        await Future.delayed(const Duration(milliseconds: 500));
        await _autoBotPlay();
      }
    }
  }

  /// Auto-play for bots
  Future<void> _autoBotPlay() async {
    if (_currentGame == null) return;

    while (_currentGame!.gamePhase == GamePhase.playing &&
        _currentGame!.currentTurn != null &&
        _currentGame!.currentTurn!.startsWith('bot_')) {
      final botId = _currentGame!.currentTurn!;
      final botHand = List<PlayingCard>.from(
        _currentGame!.playerHands[botId] ?? [],
      );

      if (botHand.isEmpty) break;

      // Simple bot logic: play first valid card
      PlayingCard? cardToPlay;

      if (_currentGame!.currentTrick != null) {
        final ledSuit = _currentGame!.currentTrick!.ledSuit;
        // Try to follow suit
        final suitCards = botHand.where((c) => c.suit == ledSuit).toList();
        if (suitCards.isNotEmpty) {
          cardToPlay = suitCards.first;
        } else {
          // Play a spade if possible
          final spades = botHand
              .where((c) => c.suit == CardSuit.spades)
              .toList();
          cardToPlay = spades.isNotEmpty ? spades.first : botHand.first;
        }
      } else {
        // Leading - play any card (prefer non-spade)
        final nonSpades = botHand
            .where((c) => c.suit != CardSuit.spades)
            .toList();
        cardToPlay = nonSpades.isNotEmpty ? nonSpades.first : botHand.first;
      }

      await playCard(botId, cardToPlay);
      await Future.delayed(const Duration(milliseconds: 400));
    }
  }

  /// Complete round and calculate scores
  Future<void> _completeRound(Map<String, int> tricksWon) async {
    final bidsData = _currentGame!.bids;
    final bids = bidsData.map((k, v) => MapEntry(k, v.amount));

    final currentRound = _currentGame!.currentRound;
    final totalRounds = _currentGame!.config.totalRounds;
    final pointValue = _currentGame!.config.pointValue;

    final roundScores = CallBreakLogic.calculateRoundScores(
      bids: bids,
      tricksWon: tricksWon,
      pointValue: pointValue,
    );

    final currentScores = Map<String, int>.from(_currentGame!.scores);
    roundScores.forEach((playerId, roundScore) {
      currentScores[playerId] =
          (currentScores[playerId] ?? 0) + roundScore.toInt();
    });

    final gameFinished = currentRound >= totalRounds;

    if (gameFinished) {
      _currentGame = _currentGame!.copyWith(
        scores: currentScores,
        gamePhase: GamePhase.gameFinished,
        status: GameStatus.settled,
      );
    } else {
      // Start next round
      final playerIds = _currentGame!.players.map((p) => p.id).toList();
      final hands = Deck.dealHands(playerIds);

      _currentGame = _currentGame!.copyWith(
        currentRound: currentRound + 1,
        scores: currentScores,
        gamePhase: GamePhase.bidding,
        playerHands: hands,
        bids: <String, Bid>{},
        tricksWon: {for (var p in playerIds) p: 0},
        currentTrick: null,
        trickHistory: [],
        currentTurn: playerIds.first,
      );
    }

    _notify();
  }

  void _notify() {
    _gameController.add(_currentGame);
  }

  /// Reset test game
  void reset() {
    _currentGame = null;
    _notify();
  }
}
