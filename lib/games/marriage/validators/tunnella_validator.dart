import 'package:clubroyale/core/card_engine/pile.dart';

/// Tunnella Validator
/// Validates pure triplets (3 identical cards: same rank AND suit)
/// 
/// PhD Audit Finding #7: Tunnella Logic

class TunnellaValidator {
  /// Check if cards form a valid Tunnella (pure triplet)
  static bool isValidTunnella(List<Card> cards) {
    if (cards.length != 3) return false;
    
    // All cards must have same rank AND same suit
    final first = cards[0];
    
    for (final card in cards) {
      if (card.isJoker) return false; // Jokers can't form pure tunnella
      if (card.rank != first.rank || card.suit != first.suit) {
        return false;
      }
    }
    
    return true;
  }
  
  /// Find all tunnellas in a hand
  static List<List<Card>> findTunnellas(List<Card> hand) {
    final tunnellas = <List<Card>>[];
    
    // Group cards by rank+suit
    final Map<String, List<Card>> groups = {};
    for (final card in hand) {
      if (card.isJoker) continue;
      final key = '${card.rank.value}_${card.suit.index}';
      groups.putIfAbsent(key, () => []).add(card);
    }
    
    // Find groups with 3+ cards
    for (final group in groups.values) {
      if (group.length >= 3) {
        tunnellas.add(group.sublist(0, 3));
      }
    }
    
    return tunnellas;
  }
  
  /// Calculate tunnella bonus points
  /// 1 Tunnella = 5 pts
  /// 2 Tunnellas = 15 pts (not 10!)
  /// 3 Tunnellas = 25 pts
  static int calculateTunnellaBonus(List<Card> hand) {
    final count = findTunnellas(hand).length;
    
    if (count == 0) return 0;
    if (count == 1) return 5;
    if (count == 2) return 15;
    return 25; // 3+
  }
}
