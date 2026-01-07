import 'package:clubroyale/core/card_engine/pile.dart';

/// Maal Cards Model
/// Represents all Maal (value cards) based on Tiplu selection
/// 
/// PhD Audit Finding #8: models/maal_cards.dart

class MaalCards {
  final Card tiplu;
  final Card? poplu;
  final Card? jhiplu;
  final Card? alter;
  final List<Card> ordinaryJokers;
  
  MaalCards({
    required this.tiplu,
    this.poplu,
    this.jhiplu,
    this.alter,
    this.ordinaryJokers = const [],
  });
  
  /// Create MaalCards from a Tiplu card
  factory MaalCards.fromTiplu(Card tiplu, List<Card> deck) {
    Card? poplu;
    Card? jhiplu;
    Card? alter;
    final ordinaryJokers = <Card>[];
    
    final tipluRank = tiplu.rank.value;
    
    // Calculate Poplu rank (Tiplu + 1)
    int popluRank;
    if (tipluRank == 13) {
      popluRank = 14; // K -> A
    } else if (tipluRank == 14) {
      popluRank = 2; // A -> 2
    } else {
      popluRank = tipluRank + 1;
    }
    
    // Calculate Jhiplu rank (Tiplu - 1)
    int jhipluRank;
    if (tipluRank == 14) {
      jhipluRank = 13; // A -> K
    } else if (tipluRank == 2) {
      jhipluRank = 14; // 2 -> A
    } else {
      jhipluRank = tipluRank - 1;
    }
    
    // Find matching cards in deck
    for (final card in deck) {
      if (card.isJoker) {
        ordinaryJokers.add(card);
        continue;
      }
      
      // Poplu: same suit, rank+1
      if (card.suit == tiplu.suit && card.rank.value == popluRank) {
        poplu = card;
      }
      
      // Jhiplu: same suit, rank-1
      if (card.suit == tiplu.suit && card.rank.value == jhipluRank) {
        jhiplu = card;
      }
      
      // Alter: same rank, same color, different suit
      if (card.rank == tiplu.rank &&
          card.suit.isRed == tiplu.suit.isRed &&
          card.suit != tiplu.suit) {
        alter = card;
      }
    }
    
    return MaalCards(
      tiplu: tiplu,
      poplu: poplu,
      jhiplu: jhiplu,
      alter: alter,
      ordinaryJokers: ordinaryJokers,
    );
  }
  
  /// Get all Maal cards as a list
  List<Card> get allMaalCards {
    final cards = <Card>[tiplu];
    if (poplu != null) cards.add(poplu!);
    if (jhiplu != null) cards.add(jhiplu!);
    if (alter != null) cards.add(alter!);
    cards.addAll(ordinaryJokers);
    return cards;
  }
  
  /// Check if a card is any type of Maal
  bool isMaalCard(Card card) {
    if (card == tiplu) return true;
    if (poplu != null && card == poplu) return true;
    if (jhiplu != null && card == jhiplu) return true;
    if (alter != null && card == alter) return true;
    if (ordinaryJokers.contains(card)) return true;
    return false;
  }
  
  /// Get point value for a card
  int getPointValue(Card card) {
    if (card == tiplu) return 3;
    if (poplu != null && card == poplu) return 2;
    if (jhiplu != null && card == jhiplu) return 2;
    if (alter != null && card == alter) return 5;
    if (ordinaryJokers.contains(card)) return 2;
    return 0;
  }
  
  /// Total Maal count
  int get totalMaalCount {
    int count = 1; // Tiplu
    if (poplu != null) count++;
    if (jhiplu != null) count++;
    if (alter != null) count++;
    count += ordinaryJokers.length;
    return count;
  }
  
  @override
  String toString() {
    return 'MaalCards(tiplu: $tiplu, poplu: $poplu, jhiplu: $jhiplu, '
        'alter: $alter, jokers: ${ordinaryJokers.length})';
  }
}
