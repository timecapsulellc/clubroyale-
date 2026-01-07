import 'dart:math' as math;
import 'package:clubroyale/core/card_engine/pile.dart';
import 'package:clubroyale/games/marriage/models/maal_cards.dart';

/// Joker Selector
/// Selects Tiplu from middle of deck and calculates all Maal cards
/// 
/// PhD Audit Finding #8: core/joker_selector.dart

class JokerSelector {
  final math.Random _random;
  
  JokerSelector({math.Random? random}) 
      : _random = random ?? math.Random.secure();
  
  /// Select Tiplu from the middle portion of the deck
  /// Traditional Marriage rule: Card selected from center of shuffled deck
  Card selectTiplu(List<Card> deck) {
    if (deck.isEmpty) {
      throw StateError('Cannot select Tiplu from empty deck');
    }
    
    // Remove jokers from consideration
    final validCards = deck.where((c) => !c.isJoker).toList();
    
    if (validCards.isEmpty) {
      throw StateError('No valid cards for Tiplu selection');
    }
    
    // Select from middle third of deck (traditional method)
    final startIndex = validCards.length ~/ 3;
    final endIndex = (validCards.length * 2) ~/ 3;
    final middleSection = validCards.sublist(startIndex, endIndex);
    
    if (middleSection.isEmpty) {
      // Fallback: random from all valid cards
      return validCards[_random.nextInt(validCards.length)];
    }
    
    return middleSection[_random.nextInt(middleSection.length)];
  }
  
  /// Select Tiplu and calculate all Maal cards
  MaalCards selectAndCalculateMaal(List<Card> deck) {
    final tiplu = selectTiplu(deck);
    return MaalCards.fromTiplu(tiplu, deck);
  }
  
  /// Calculate Maal cards from an existing Tiplu
  MaalCards calculateMaalFromTiplu(Card tiplu, List<Card> deck) {
    return MaalCards.fromTiplu(tiplu, deck);
  }
  
  /// Get the Poplu rank (Tiplu + 1)
  static int getPopluRank(int tipluRank) {
    if (tipluRank == 13) return 14; // K -> A
    if (tipluRank == 14) return 2;  // A -> 2
    return tipluRank + 1;
  }
  
  /// Get the Jhiplu rank (Tiplu - 1)
  static int getJhipluRank(int tipluRank) {
    if (tipluRank == 14) return 13; // A -> K
    if (tipluRank == 2) return 14;  // 2 -> A
    return tipluRank - 1;
  }
  
  /// Check if a card would be Alter of given Tiplu
  static bool isAlter(Card card, Card tiplu) {
    return card.rank == tiplu.rank &&
           card.suit.isRed == tiplu.suit.isRed &&
           card.suit != tiplu.suit;
  }
}
