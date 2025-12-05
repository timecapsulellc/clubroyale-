import 'package:freezed_annotation/freezed_annotation.dart';

part 'card.freezed.dart';
part 'card.g.dart';

/// Card suits in a standard deck
enum CardSuit {
  hearts,
  diamonds,
  clubs,
  spades;

  /// Display symbol for the suit
  String get symbol {
    switch (this) {
      case CardSuit.hearts:
        return '♥';
      case CardSuit.diamonds:
        return '♦';
      case CardSuit.clubs:
        return '♣';
      case CardSuit.spades:
        return '♠';
    }
  }

  /// Color of the suit (red or black)
  bool get isRed => this == CardSuit.hearts || this == CardSuit.diamonds;
}

/// Card ranks from 2 to Ace
enum CardRank {
  two(2),
  three(3),
  four(4),
  five(5),
  six(6),
  seven(7),
  eight(8),
  nine(9),
  ten(10),
  jack(11),
  queen(12),
  king(13),
  ace(14);

  const CardRank(this.value);

  /// Numeric value for comparison (Ace = 14, King = 13, etc.)
  final int value;

  /// Display string for the rank
  String get displayString {
    switch (this) {
      case CardRank.ace:
        return 'A';
      case CardRank.king:
        return 'K';
      case CardRank.queen:
        return 'Q';
      case CardRank.jack:
        return 'J';
      default:
        return value.toString();
    }
  }
}

/// Represents a playing card in the deck
@freezed
class PlayingCard with _$PlayingCard {
  const PlayingCard._();

  const factory PlayingCard({
    required CardSuit suit,
    required CardRank rank,
  }) = _PlayingCard;

  factory PlayingCard.fromJson(Map<String, dynamic> json) =>
      _$PlayingCardFromJson(json);

  /// Get a unique string identifier for this card
  String get id => '${suit.name}_${rank.name}';

  /// Display string like "A♠" or "7♥"
  String get displayString => '${rank.displayString}${suit.symbol}';

  /// Compare two cards for trick-taking logic
  /// Returns 1 if this card wins, -1 if other card wins, 0 if equal
  int compareTo(PlayingCard other, CardSuit trumpSuit, CardSuit ledSuit) {
    // Both same suit
    if (suit == other.suit) {
      return rank.value.compareTo(other.rank.value);
    }

    // This card is trump
    if (suit == trumpSuit) {
      return 1;
    }

    // Other card is trump
    if (other.suit == trumpSuit) {
      return -1;
    }

    // This card follows led suit
    if (suit == ledSuit) {
      return 1;
    }

    // Other card follows led suit
    if (other.suit == ledSuit) {
      return -1;
    }

    // Neither card follows suit or is trump (shouldn't happen in valid game)
    return 0;
  }
}

/// Trump suit is always Spades in Call Break
const CardSuit trumpSuit = CardSuit.spades;
