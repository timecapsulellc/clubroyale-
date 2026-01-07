import 'package:clubroyale/core/card_engine/pile.dart';

/// Dublee Validator
/// Validates pairs (2 identical cards: same rank AND suit)
/// Also handles 8-Dublee win condition
/// 
/// PhD Audit Finding #8: Dublee Logic

class DubleeValidator {
  /// Check if cards form a valid Dublee (pair)
  static bool isValidDublee(List<Card> cards) {
    if (cards.length != 2) return false;
    
    final first = cards[0];
    final second = cards[1];
    
    // Both must be same rank AND same suit
    if (first.isJoker || second.isJoker) return false;
    return first.rank == second.rank && first.suit == second.suit;
  }
  
  /// Find all dublees in a hand
  static List<List<Card>> findDublees(List<Card> hand) {
    final dublees = <List<Card>>[];
    
    // Group cards by rank+suit
    final Map<String, List<Card>> groups = {};
    for (final card in hand) {
      if (card.isJoker) continue;
      final key = '${card.rank.value}_${card.suit.index}';
      groups.putIfAbsent(key, () => []).add(card);
    }
    
    // Find groups with 2+ cards (extract pairs)
    for (final group in groups.values) {
      if (group.length >= 2) {
        // Can have multiple pairs from same group
        final pairCount = group.length ~/ 2;
        for (var i = 0; i < pairCount; i++) {
          dublees.add([group[i * 2], group[i * 2 + 1]]);
        }
      }
    }
    
    return dublees;
  }
  
  /// Count total dublees in hand
  static int countDublees(List<Card> hand) {
    return findDublees(hand).length;
  }
  
  /// Check if hand qualifies for 8-Dublee win
  /// 8 Dublees (16+ cards forming 8 pairs) is an auto-win
  static bool canWinWith8Dublee(List<Card> hand) {
    if (hand.length < 16) return false;
    return countDublees(hand) >= 8;
  }
  
  /// Calculate 8th Dublee bonus (when player has 8+ pairs)
  /// Returns 5 bonus points
  static int get8thDubleeBonus(List<Card> hand) {
    if (countDublees(hand) >= 8) {
      return 5; // Bonus for 8th dublee
    }
    return 0;
  }
}
