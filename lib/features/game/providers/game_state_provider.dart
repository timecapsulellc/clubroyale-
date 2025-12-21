import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:clubroyale/features/game/game_room.dart';
import 'package:clubroyale/features/game/game_service.dart';
import 'package:clubroyale/core/models/playing_card.dart';
import 'package:clubroyale/features/game/models/game_state.dart';
import 'package:clubroyale/features/game/call_break_service.dart';
import 'package:clubroyale/features/game/services/card_validation_service.dart';
import 'package:clubroyale/features/auth/auth_service.dart';

// Re-export the callBreakServiceProvider from call_break_service.dart
export 'package:clubroyale/features/game/call_break_service.dart' show callBreakServiceProvider;

/// Stream provider for the current game room
final currentGameProvider = StreamProvider.family<GameRoom?, String>((ref, gameId) {
  final gameService = ref.watch(gameServiceProvider);
  return gameService.getGameStream(gameId);
});

/// Provider for the current user's ID
final currentUserIdProvider = Provider<String?>((ref) {
  final authService = ref.watch(authServiceProvider);
  return authService.currentUser?.uid;
});

/// Provider for the current player's hand
final playerHandProvider = Provider.family<List<PlayingCard>, String>((ref, gameId) {
  final game = ref.watch(currentGameProvider(gameId)).value;
  final userId = ref.watch(currentUserIdProvider);
  
  if (game == null || userId == null) return [];
  return game.playerHands[userId] ?? [];
});

/// Provider to check if it's the current user's turn
final isMyTurnProvider = Provider.family<bool, String>((ref, gameId) {
  final game = ref.watch(currentGameProvider(gameId)).value;
  final userId = ref.watch(currentUserIdProvider);
  
  if (game == null || userId == null) return false;
  return game.currentTurn == userId;
});

/// Provider for cards the current player can legally play
final playableCardsProvider = Provider.family<List<PlayingCard>, String>((ref, gameId) {
  final game = ref.watch(currentGameProvider(gameId)).value;
  final userId = ref.watch(currentUserIdProvider);
  
  if (game == null || userId == null) return [];
  if (game.gamePhase != GamePhase.playing) return [];
  if (game.currentTurn != userId) return [];
  
  final hand = game.playerHands[userId] ?? [];
  if (hand.isEmpty) return [];
  
  return CardValidationService.getValidCards(
    hand,
    game.currentTrick,
  );
});

/// Provider for the current game phase
final gamePhaseProvider = Provider.family<GamePhase?, String>((ref, gameId) {
  final game = ref.watch(currentGameProvider(gameId)).value;
  return game?.gamePhase;
});

/// Provider for checking if game is in Call Break mode
final isCallBreakModeProvider = Provider.family<bool, String>((ref, gameId) {
  final game = ref.watch(currentGameProvider(gameId)).value;
  if (game == null) return false;
  // Game is in Call Break mode if there are player hands or game phase is set
  return game.playerHands.isNotEmpty || game.gamePhase != null;
});

/// Provider for current round info
final currentRoundProvider = Provider.family<RoundInfo, String>((ref, gameId) {
  final game = ref.watch(currentGameProvider(gameId)).value;
  
  return RoundInfo(
    currentRound: game?.currentRound ?? 1,
    totalRounds: game?.config.totalRounds ?? 5,
    tricksPlayed: game?.trickHistory.length ?? 0,
  );
});

/// Provider for player bids in current round
final playerBidsProvider = Provider.family<Map<String, int>, String>((ref, gameId) {
  final game = ref.watch(currentGameProvider(gameId)).value;
  if (game == null) return {};
  
  return game.bids.map((key, bid) => MapEntry(key, bid.amount));
});

/// Provider for tricks won in current round
final tricksWonProvider = Provider.family<Map<String, int>, String>((ref, gameId) {
  final game = ref.watch(currentGameProvider(gameId)).value;
  return game?.tricksWon ?? {};
});

/// Action provider for game actions
class GameActionsNotifier extends Notifier<AsyncValue<void>> {
  @override
  AsyncValue<void> build() {
    return const AsyncValue.data(null);
  }
  
  /// Submit a bid
  Future<void> submitBid(String gameId, String playerId, int bidAmount) async {
    state = const AsyncValue.loading();
    try {
      final service = ref.read(callBreakServiceProvider);
      await service.placeBid(gameId, playerId, bidAmount);
      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }
  
  /// Play a card
  Future<void> playCard(String gameId, String playerId, PlayingCard card) async {
    state = const AsyncValue.loading();
    try {
      final service = ref.read(callBreakServiceProvider);
      await service.playCard(gameId, playerId, card);
      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }
  
  /// Start next round
  Future<void> startNextRound(String gameId, List<String> playerIds) async {
    state = const AsyncValue.loading();
    try {
      final service = ref.read(callBreakServiceProvider);
      await service.startNewRound(gameId, playerIds);
      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }
}

final gameActionsProvider = NotifierProvider<GameActionsNotifier, AsyncValue<void>>(
  GameActionsNotifier.new,
);

/// Helper class for round info
class RoundInfo {
  final int currentRound;
  final int totalRounds;
  final int tricksPlayed;
  
  const RoundInfo({
    required this.currentRound,
    required this.totalRounds,
    required this.tricksPlayed,
  });
  
  int get totalTricks => 13;
  int get tricksRemaining => totalTricks - tricksPlayed;
  bool get isRoundComplete => tricksPlayed >= totalTricks;
  bool get isGameComplete => currentRound > totalRounds;
}
