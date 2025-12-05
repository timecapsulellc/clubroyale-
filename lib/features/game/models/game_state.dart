import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:myapp/features/game/models/card.dart';

part 'game_state.freezed.dart';
part 'game_state.g.dart';

/// Phase of the game
enum GamePhase {
  bidding,
  playing,
  roundEnd,
  gameFinished;
}

/// Player's bid for a round
@freezed
class Bid with _$Bid {
  const factory Bid({
    required String playerId,
    required int amount, // 1-13
  }) = _Bid;

  factory Bid.fromJson(Map<String, dynamic> json) => _$BidFromJson(json);
}

/// A single played card in a trick
@freezed
class PlayedCard with _$PlayedCard {
  const factory PlayedCard({
    required String playerId,
    required PlayingCard card,
  }) = _PlayedCard;

  factory PlayedCard.fromJson(Map<String, dynamic> json) =>
      _$PlayedCardFromJson(json);
}

/// A trick in progress or completed
@freezed
class Trick with _$Trick {
  const Trick._();

  const factory Trick({
    required CardSuit ledSuit,
    required List<PlayedCard> cards,
    String? winnerId,
  }) = _Trick;

  factory Trick.fromJson(Map<String, dynamic> json) => _$TrickFromJson(json);

  /// Check if trick is complete (4 cards played)
  bool get isComplete => cards.length == 4;

  /// Get the next player who needs to play
  String? getNextPlayer(List<String> playerOrder, String? currentPlayerId) {
    if (isComplete) return null;

    if (cards.isEmpty && currentPlayerId != null) {
      return currentPlayerId;
    }

    if (cards.isEmpty) {
      return playerOrder.first;
    }

    final lastPlayer = cards.last.playerId;
    final lastIndex = playerOrder.indexOf(lastPlayer);
    return playerOrder[(lastIndex + 1) % 4];
  }
}

/// Player's tricks won in current round
@freezed
class PlayerTricks with _$PlayerTricks {
  const factory PlayerTricks({
    required String playerId,
    @Default(0) int tricksWon,
  }) = _PlayerTricks;

  factory PlayerTricks.fromJson(Map<String, dynamic> json) =>
      _$PlayerTricksFromJson(json);
}
