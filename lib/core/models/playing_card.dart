import 'package:freezed_annotation/freezed_annotation.dart';

part 'playing_card.freezed.dart';
part 'playing_card.g.dart';

/// Card suits in a standard deck
enum CardSuit {
  hearts('♥', true),
  diamonds('♦', true),
  clubs('♣', false),
  spades('♠', false);

  final String symbol;
  final bool isRed;

  const CardSuit(this.symbol, this.isRed);
}

/// Card ranks from 2 to Ace
enum CardRank {
  two(2, '2'),
  three(3, '3'),
  four(4, '4'),
  five(5, '5'),
  six(6, '6'),
  seven(7, '7'),
  eight(8, '8'),
  nine(9, '9'),
  ten(10, '10'),
  jack(11, 'J'),
  queen(12, 'Q'),
  king(13, 'K'),
  ace(14, 'A');

  final int value;
  final String symbol;

  const CardRank(this.value, this.symbol);

  /// Point value for Marriage scoring (face cards = 10)
  int get points => value >= 10 ? 10 : value;
  
  /// Display string (deprecated alias for symbol, kept for compatibility if needed)
  String get displayString => symbol;
}

/// Represents a playing card in the deck
/// 
/// Unified model for both Game Engine logic and UI/Serialization.
@freezed
abstract class PlayingCard with _$PlayingCard {
  const PlayingCard._();

  const factory PlayingCard({
    required CardSuit suit,
    required CardRank rank,
    @Default(0) int deckIndex,
    @Default(false) bool isJoker,
  }) = _PlayingCard;

  factory PlayingCard.fromJson(Map<String, dynamic> json) =>
      _$PlayingCardFromJson(json);

  /// Create a joker card
  factory PlayingCard.joker([int deckIndex = 0]) => PlayingCard(
    suit: CardSuit.spades, // Dummy suit for Joker
    rank: CardRank.ace,    // Dummy rank for Joker
    deckIndex: deckIndex,
    isJoker: true,
  );

  /// Get a unique string identifier for this card
  String get id => isJoker 
      ? 'joker_$deckIndex' 
      : '${rank.name}_${suit.name}_$deckIndex';
      
  /// Simple ID format without deck index (for simple comparisons where deck doesn't matter)
  String get simpleId => isJoker ? 'joker' : '${suit.name}_${rank.name}';

  /// Display string like "A♠" or "7♥"
  String get displayString => isJoker ? '🃏' : '${rank.symbol}${suit.symbol}';
  
  /// Asset path for card image
  String get assetPath => isJoker 
      ? 'assets/cards/png/joker.png' 
      : 'assets/cards/png/${rank.symbol.toLowerCase()}_of_${suit.name}.png';

  /// Compare two cards for trick-taking logic
  /// Returns 1 if this card wins, -1 if other card wins, 0 if equal
  int compareTo(PlayingCard other, {CardSuit? trumpSuit, CardSuit? ledSuit}) {
    // 1. Joker Logic? (Assuming Jokers are highest trumps or handled separately)
    if (isJoker && !other.isJoker) return 1;
    if (!isJoker && other.isJoker) return -1;
    if (isJoker && other.isJoker) return 0; // Or compare ID/index

    // 2. Standard Logic
    // Both same suit
    if (suit == other.suit) {
      return rank.value.compareTo(other.rank.value);
    }

    if (trumpSuit != null) {
        // This card is trump
        if (suit == trumpSuit) {
        return 1;
        }

        // Other card is trump
        if (other.suit == trumpSuit) {
        return -1;
        }
    }

    if (ledSuit != null) {
        // This card follows led suit (and other doesn't, and wasn't trump)
        if (suit == ledSuit) {
        return 1;
        }

        // Other card follows led suit
        if (other.suit == ledSuit) {
        return -1;
        }
    }

    // Neither card follows suit or is trump (shouldn't happen in valid trick-taking if following rules)
    // Or just simple rank comparison failure
    return 0;
  }
}
