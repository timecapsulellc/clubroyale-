/// Meld - Abstract class for card combinations
/// 
/// Based on gin_rummy SetMeld and RunMeld patterns
/// Extended for Marriage game with TunnelMeld and MarriageMeld
library;

import 'pile.dart';

/// Types of melds possible in card games
enum MeldType {
  set,        // 3+ cards of same rank, different suits (Trial in Marriage)
  run,        // 3+ consecutive cards, same suit (Sequence)
  tunnel,     // 3 identical cards (same rank + suit from different decks)
  dublee,     // 2 identical cards (Pair)
  marriage,   // Tiplu + Poplu + Jhiplu combination
  impureRun,  // Sequence with wildcard substitution
  impureSet,  // Set with wildcard substitution
}

/// Abstract base class for all meld types
abstract class Meld {
  final MeldType type;
  final List<PlayingCard> cards;
  
  const Meld({required this.type, required this.cards});
  
  /// Is this meld valid according to game rules?
  bool get isValid;
  
  /// Point value of this meld
  int get points;
  
  /// Does this meld contain a specific card?
  bool contains(PlayingCard card) => cards.any((c) => c.id == card.id);

  /// Convert to JSON for storage
  Map<String, dynamic> toJson() {
    return {
      'type': type.name,
      'cardIds': cards.map((c) => c.id).toList(),
    };
  }

  /// Reconstruct a Meld from type and cards
  static Meld fromTypeAndCards(MeldType type, List<PlayingCard> cards, {PlayingCard? tiplu}) {
    switch (type) {
      case MeldType.set:
        return SetMeld(cards);
      case MeldType.run:
        return RunMeld(cards);
      case MeldType.tunnel:
        return TunnelMeld(cards);
      case MeldType.dublee:
        return DubleeMeld(cards);
      case MeldType.marriage:
        if (tiplu == null) throw ArgumentError('Tiplu required for MarriageMeld');
        return MarriageMeld(cards, tiplu: tiplu);
      case MeldType.impureRun:
        return ImpureRunMeld(cards, tiplu: tiplu);
      case MeldType.impureSet:
        return ImpureSetMeld(cards, tiplu: tiplu);
    }
  }
}

/// SetMeld - 3+ cards of same rank, different suits (Trial in Marriage)
class SetMeld extends Meld {
  SetMeld(List<PlayingCard> cards) : super(type: MeldType.set, cards: cards);
  
  @override
  bool get isValid {
    if (cards.length < 3) return false;
    
    // All cards must have same rank
    final rank = cards.first.rank;
    if (!cards.every((c) => c.rank == rank)) return false;
    
    // For multi-deck games: validate same-suit cards are from different decks
    // Group cards by suit and check deck indices
    final bySuit = <CardSuit, List<int>>{};
    for (final card in cards) {
      bySuit.putIfAbsent(card.suit, () => []).add(card.deckIndex);
    }
    
    // Each suit group should have unique deck indices
    for (final deckIndices in bySuit.values) {
      if (deckIndices.length != deckIndices.toSet().length) {
        return false; // Duplicate deck index for same suit = invalid
      }
    }
    
    return true;
  }
  
  @override
  int get points => 0; // Complete melds have 0 points (deadwood)
}

/// RunMeld - 3+ consecutive cards of same suit (Sequence)
class RunMeld extends Meld {
  RunMeld(List<PlayingCard> cards) : super(type: MeldType.run, cards: cards);
  
  @override
  bool get isValid {
    if (cards.length < 3) return false;
    
    // All cards must have same suit
    final suit = cards.first.suit;
    if (!cards.every((c) => c.suit == suit)) return false;
    
    // Sort by rank and check consecutive
    final sorted = List<PlayingCard>.from(cards)
      ..sort((a, b) => a.rank.value.compareTo(b.rank.value));
    
    // Check standard consecutive sequence
    bool isConsecutive = true;
    for (int i = 1; i < sorted.length; i++) {
      if (sorted[i].rank.value != sorted[i - 1].rank.value + 1) {
        isConsecutive = false;
        break;
      }
    }
    
    if (isConsecutive) return true;
    
    // Handle Ace-wrap sequences (Q-K-A where Ace is high)
    // Check if it's a high-ace sequence
    if (sorted.first.rank == CardRank.ace && sorted.length >= 3) {
      // Re-sort treating Ace as 14
      final sortedHighAce = List<PlayingCard>.from(cards)
        ..sort((a, b) {
          final aVal = a.rank == CardRank.ace ? 14 : a.rank.value;
          final bVal = b.rank == CardRank.ace ? 14 : b.rank.value;
          return aVal.compareTo(bVal);
        });
      
      // Check consecutive with high ace
      isConsecutive = true;
      for (int i = 1; i < sortedHighAce.length; i++) {
        final prevVal = sortedHighAce[i - 1].rank == CardRank.ace ? 14 : sortedHighAce[i - 1].rank.value;
        final currVal = sortedHighAce[i].rank == CardRank.ace ? 14 : sortedHighAce[i].rank.value;
        if (currVal != prevVal + 1) {
          isConsecutive = false;
          break;
        }
      }
      
      if (isConsecutive) return true;
    }
    
    return false;
  }
  
  @override
  int get points => 0;
}

/// TunnelMeld - 3 identical cards (Marriage game only)
/// Three cards of exact same rank and suit from different decks
class TunnelMeld extends Meld {
  TunnelMeld(List<PlayingCard> cards) : super(type: MeldType.tunnel, cards: cards);
  
  @override
  bool get isValid {
    if (cards.length != 3) return false;
    
    final first = cards.first;
    // All cards must have same rank and suit
    if (!cards.every((c) => c.rank == first.rank && c.suit == first.suit)) {
      return false;
    }
    
    // All cards must be from different decks
    final deckIndices = cards.map((c) => c.deckIndex).toSet();
    return deckIndices.length == 3;
  }
  
  @override
  int get points => -50; // Bonus points for tunnel (negative = good)
}

/// DubleeMeld - 2 identical cards (Pair)
/// Two cards of exact same rank and suit
class DubleeMeld extends Meld {
  DubleeMeld(List<PlayingCard> cards) : super(type: MeldType.dublee, cards: cards);
  
  @override
  bool get isValid {
    if (cards.length != 2) return false;
    final first = cards.first;
    // Must be same rank and suit
    if (cards[1].rank != first.rank || cards[1].suit != first.suit) return false;
    // Must be from different decks (implied, as you can't have duplicate card objects likely)
    if (cards[1].deckIndex == first.deckIndex) return false; 
    return true;
  }
  
  @override
  int get points => 0; 
}

/// MarriageMeld - Special combination in Marriage game
/// Tiplu (wild) + Poplu (card above tiplu) + Jhiplu (card below tiplu)
class MarriageMeld extends Meld {
  final PlayingCard tiplu; // The wild card for this round
  
  MarriageMeld(List<PlayingCard> cards, {required this.tiplu}) 
      : super(type: MeldType.marriage, cards: cards);
  
  @override
  bool get isValid {
    if (cards.length != 3) return false;
    
    // Calculate Jhiplu and Poplu values with wrap-around
    // Jhiplu: rank below tiplu (Ace wraps to King)
    final jhipluValue = tiplu.rank.value == 1 ? 13 : tiplu.rank.value - 1;
    // Poplu: rank above tiplu (King wraps to Ace)
    final popluValue = tiplu.rank.value == 13 ? 1 : tiplu.rank.value + 1;
    
    // Must contain tiplu, poplu, and jhiplu
    final hasJhiplu = cards.any((c) => 
        c.suit == tiplu.suit && c.rank.value == jhipluValue);
    final hasTiplu = cards.any((c) => 
        c.suit == tiplu.suit && c.rank == tiplu.rank);
    final hasPoplu = cards.any((c) => 
        c.suit == tiplu.suit && c.rank.value == popluValue);
    
    return hasJhiplu && hasTiplu && hasPoplu;
  }
  
  @override
  int get points => -100; // Big bonus for marriage (negative = very good)
}

/// Utility class for wildcard detection in Marriage game
class WildcardHelper {
  final PlayingCard tiplu;
  
  WildcardHelper(this.tiplu);
  
  /// Check if a card is a wildcard (Joker, Tiplu, or Joker-equivalent)
  /// Check if a card is a wildcard (Joker, Tiplu, or Joker-equivalent)
  bool isWildcard(PlayingCard card) {
    if (card.isJoker) return true;
    
    // Tiplu: exact match
    if (card.rank == tiplu.rank && card.suit == tiplu.suit) return true;
    
    final tVal = tiplu.rank.value;
    final cVal = card.rank.value;

    // Poplu: Rank + 1 (same suit)
    int popluVal = tVal == 13 ? 1 : tVal + 1;
    if (card.suit == tiplu.suit && cVal == popluVal) return true;

    // Jhiplu: Rank - 1 (same suit)
    int jhipluVal = tVal == 1 ? 13 : tVal - 1;
    if (card.suit == tiplu.suit && cVal == jhipluVal) return true;
    
    // Alter: Same rank AND color, different suit
    if (card.rank == tiplu.rank && card.suit.isRed == tiplu.suit.isRed && card.suit != tiplu.suit) {
      return true;
    }
    
    return false;
  }
  
  /// Check if card can substitute for a given rank in a sequence
  bool canSubstituteInRun(PlayingCard card, CardRank targetRank, CardSuit targetSuit) {
    // Wildcards can substitute for any card
    if (isWildcard(card)) return true;
    // Natural match
    return card.rank == targetRank && card.suit == targetSuit;
  }
  
  /// Check if card can substitute in a set (same rank, any suit)
  bool canSubstituteInSet(PlayingCard card, CardRank targetRank) {
    if (isWildcard(card)) return true;
    return card.rank == targetRank;
  }
}

/// ImpureRunMeld - Sequence with wildcard substitution
class ImpureRunMeld extends Meld {
  final PlayingCard? tiplu;
  final int wildcardCount;
  
  ImpureRunMeld(List<PlayingCard> cards, {this.tiplu}) 
      : wildcardCount = _countWildcards(cards, tiplu),
        super(type: MeldType.impureRun, cards: cards);
  
  static int _countWildcards(List<PlayingCard> cards, PlayingCard? tiplu) {
    if (tiplu == null) return cards.where((c) => c.isJoker).length;
    final helper = WildcardHelper(tiplu);
    return cards.where((c) => helper.isWildcard(c)).length;
  }
  
  @override
  bool get isValid {
    if (cards.length < 3) return false;
    if (wildcardCount == 0) return false; // Must have at least 1 wildcard for impure
    if (wildcardCount >= cards.length) return false; // Can't be all wildcards
    
    // Get non-wildcard cards to determine suit and expected sequence
    final helper = tiplu != null ? WildcardHelper(tiplu!) : null;
    final naturalCards = cards.where((c) => 
        !c.isJoker && (helper == null || !helper.isWildcard(c))).toList();
    
    if (naturalCards.isEmpty) return false;
    
    // All natural cards must have same suit
    final suit = naturalCards.first.suit;
    if (!naturalCards.every((c) => c.suit == suit)) return false;
    
    // Sort all cards, placing wildcards after natural cards of same "slot"
    final sorted = List<PlayingCard>.from(cards);
    sorted.sort((a, b) {
      final aWild = a.isJoker || (helper?.isWildcard(a) ?? false);
      final bWild = b.isJoker || (helper?.isWildcard(b) ?? false);
      if (aWild && !bWild) return 1;
      if (!aWild && bWild) return -1;
      return a.rank.value.compareTo(b.rank.value);
    });
    
    // Check if natural cards can form a sequence with gaps filled by wildcards
    naturalCards.sort((a, b) => a.rank.value.compareTo(b.rank.value));
    final minRank = naturalCards.first.rank.value;
    final maxRank = naturalCards.last.rank.value;
    final neededLength = maxRank - minRank + 1;
    
    // Cards length must match sequence length
    if (cards.length < neededLength) return false;
    
    return true;
  }
  
  @override
  int get points => 0;
}

/// ImpureSetMeld - Set with wildcard substitution
class ImpureSetMeld extends Meld {
  final PlayingCard? tiplu;
  final int wildcardCount;
  
  ImpureSetMeld(List<PlayingCard> cards, {this.tiplu})
      : wildcardCount = _countWildcards(cards, tiplu),
        super(type: MeldType.impureSet, cards: cards);
  
  static int _countWildcards(List<PlayingCard> cards, PlayingCard? tiplu) {
    if (tiplu == null) return cards.where((c) => c.isJoker).length;
    final helper = WildcardHelper(tiplu);
    return cards.where((c) => helper.isWildcard(c)).length;
  }
  
  @override
  bool get isValid {
    if (cards.length < 3) return false;
    if (wildcardCount == 0) return false; // Must have wildcard for impure
    if (wildcardCount >= cards.length) return false; // Can't be all wildcards
    
    // Get non-wildcard cards
    final helper = tiplu != null ? WildcardHelper(tiplu!) : null;
    final naturalCards = cards.where((c) => 
        !c.isJoker && (helper == null || !helper.isWildcard(c))).toList();
    
    if (naturalCards.isEmpty) return false;
    
    // All natural cards must have same rank
    final rank = naturalCards.first.rank;
    return naturalCards.every((c) => c.rank == rank);
  }
  
  @override
  int get points => 0;
}

/// Utility class for detecting melds in a hand
class MeldDetector {
  /// Find all possible set melds in a hand
  static List<SetMeld> findSets(List<PlayingCard> hand) {
    final melds = <SetMeld>[];
    final byRank = <CardRank, List<PlayingCard>>{};
    
    for (final card in hand) {
      byRank.putIfAbsent(card.rank, () => []).add(card);
    }
    
    for (final cards in byRank.values) {
      if (cards.length >= 3) {
        melds.add(SetMeld(cards.take(3).toList()));
        if (cards.length >= 4) {
          melds.add(SetMeld(cards.toList()));
        }
      }
    }
    
    return melds;
  }
  
  /// Find all possible run melds in a hand
  static List<RunMeld> findRuns(List<PlayingCard> hand) {
    final melds = <RunMeld>[];
    final bySuit = <CardSuit, List<PlayingCard>>{};
    
    for (final card in hand) {
      bySuit.putIfAbsent(card.suit, () => []).add(card);
    }
    
    for (final cards in bySuit.values) {
      if (cards.length < 3) continue;
      
      final sorted = List<PlayingCard>.from(cards)
        ..sort((a, b) => a.rank.value.compareTo(b.rank.value));
      
      // Find consecutive sequences
      var runStart = 0;
      for (int i = 1; i <= sorted.length; i++) {
        final isConsecutive = i < sorted.length &&
            sorted[i].rank.value == sorted[i - 1].rank.value + 1;
        
        if (!isConsecutive || i == sorted.length) {
          final runLength = i - runStart;
          if (runLength >= 3) {
            melds.add(RunMeld(sorted.sublist(runStart, i)));
          }
          runStart = i;
        }
      }
    }
    
    return melds;
  }
  
  /// Find all tunnel melds (Marriage game only)
  static List<TunnelMeld> findTunnels(List<PlayingCard> hand) {
    final melds = <TunnelMeld>[];
    final byRankSuit = <String, List<PlayingCard>>{};
    
    for (final card in hand) {
      final key = '${card.rank.value}_${card.suit.index}';
      byRankSuit.putIfAbsent(key, () => []).add(card);
    }
    
    for (final cards in byRankSuit.values) {
      if (cards.length >= 3) {
        // Ensure they're from different decks
        final deckIndices = cards.map((c) => c.deckIndex).toSet();
        if (deckIndices.length >= 3) {
          // Take one from each deck
          final tunnel = <PlayingCard>[];
          for (int d = 0; d < 3; d++) {
            final card = cards.firstWhere((c) => c.deckIndex == d, orElse: () => cards.first);
            tunnel.add(card);
          }
          melds.add(TunnelMeld(tunnel));
        }
      }
    }

    return melds;
  }
    
  /// Find all Dublee melds (Pairs)
  static List<DubleeMeld> findDublees(List<PlayingCard> hand) {
    final melds = <DubleeMeld>[];
    final byRankSuit = <String, List<PlayingCard>>{};
    
    for (final card in hand) {
      final key = '${card.rank.value}_${card.suit.index}';
      byRankSuit.putIfAbsent(key, () => []).add(card);
    }
    
    for (final cards in byRankSuit.values) {
      // Need exactly 2 or more cards of same rank+suit
      if (cards.length >= 2) {
         // Create pairs from available cards
         // Strategy: Just take the first 2. 
         // Real logic might need to be combinatorial if you have 3 cards (could make Tunnel OR Dublee)
         // For 'findDublees', we just report all valid distinct pairs?
         // No, standard flow: Find Tunnels first. If not tunnel, maybe Dublee.
         // Here we just find all possible independent pairs.
         // Combinations: With 3 cards A,B,C -> AB, BC, AC?
         // Simplest: greedy pairs.
         
         // Sort by deck index to ensure stable pairs
         cards.sort((a,b) => a.deckIndex.compareTo(b.deckIndex));
         
         for (int i = 0; i < cards.length - 1; i++) {
           for (int j = i+1; j < cards.length; j++) {
             // Ensure different decks
             if (cards[i].deckIndex != cards[j].deckIndex) {
               melds.add(DubleeMeld([cards[i], cards[j]]));
             }
           }
         }
      }
    }
    return melds;
  }
  
  /// Find all possible melds including marriage (if tiplu provided)
  static List<Meld> findAllMelds(List<PlayingCard> hand, {PlayingCard? tiplu}) {
    final melds = <Meld>[];
    melds.addAll(findSets(hand));
    melds.addAll(findRuns(hand));
    melds.addAll(findRuns(hand));
    melds.addAll(findTunnels(hand));
    melds.addAll(findDublees(hand));
    
    // Find impure melds (with wildcards)
    if (tiplu != null) {
      melds.addAll(findImpureRuns(hand, tiplu));
      melds.addAll(findImpureSets(hand, tiplu));
    }
    
    // Check for marriage if tiplu is provided
    if (tiplu != null) {
      // Use wrap-around logic for edge cases (Ace tiplu)
      final jhipluRank = tiplu.rank.value == 1 ? 13 : tiplu.rank.value - 1;
      final popluRank = tiplu.rank.value == 13 ? 1 : tiplu.rank.value + 1;
      
      final hasJhiplu = hand.any((c) => 
          c.suit == tiplu.suit && c.rank.value == jhipluRank);
      final hasTiplu = hand.any((c) => 
          c.suit == tiplu.suit && c.rank == tiplu.rank);
      final hasPoplu = hand.any((c) => 
          c.suit == tiplu.suit && c.rank.value == popluRank);
      
      if (hasJhiplu && hasTiplu && hasPoplu) {
        final marriageCards = hand.where((c) =>
            c.suit == tiplu.suit &&
            (c.rank.value == jhipluRank || 
             c.rank == tiplu.rank || 
             c.rank.value == popluRank)).take(3).toList();
        melds.add(MarriageMeld(marriageCards, tiplu: tiplu));
      }
    }
    
    return melds;
  }
  
  /// Find impure runs (sequences with wildcards)
  static List<ImpureRunMeld> findImpureRuns(List<PlayingCard> hand, PlayingCard tiplu) {
    final melds = <ImpureRunMeld>[];
    final helper = WildcardHelper(tiplu);
    
    // Get wildcards and natural cards
    final wildcards = hand.where((c) => helper.isWildcard(c)).toList();
    final naturalCards = hand.where((c) => !helper.isWildcard(c)).toList();
    
    if (wildcards.isEmpty) return melds; // No wildcards, no impure melds
    
    // Group natural cards by suit
    final bySuit = <CardSuit, List<PlayingCard>>{};
    for (final card in naturalCards) {
      bySuit.putIfAbsent(card.suit, () => []).add(card);
    }
    
    // For each suit, try to form sequences using wildcards
    for (final entry in bySuit.entries) {
      final suitCards = entry.value;
      if (suitCards.isEmpty) continue;
      
      suitCards.sort((a, b) => a.rank.value.compareTo(b.rank.value));
      
      // Try sequences starting from each card
      for (int start = 0; start < suitCards.length; start++) {
        final startRank = suitCards[start].rank.value;
        
        // Try different sequence lengths (3 to 7)
        for (int length = 3; length <= 7 && startRank + length - 1 <= 14; length++) {
          final sequenceCards = <PlayingCard>[];
          int wildcardsNeeded = 0;
          bool valid = true;
          
          for (int rank = startRank; rank < startRank + length; rank++) {
            final matching = suitCards.where((c) => c.rank.value == rank).toList();
            if (matching.isNotEmpty) {
              sequenceCards.add(matching.first);
            } else {
              wildcardsNeeded++;
              if (wildcardsNeeded > wildcards.length) {
                valid = false;
                break;
              }
            }
          }
          
          if (valid && wildcardsNeeded > 0 && wildcardsNeeded <= wildcards.length) {
            // Add wildcards to fill gaps
            sequenceCards.addAll(wildcards.take(wildcardsNeeded));
            final meld = ImpureRunMeld(sequenceCards, tiplu: tiplu);
            if (meld.isValid) melds.add(meld);
          }
        }
      }
    }
    
    return melds;
  }
  
  /// Find impure sets (sets with wildcards)
  static List<ImpureSetMeld> findImpureSets(List<PlayingCard> hand, PlayingCard tiplu) {
    final melds = <ImpureSetMeld>[];
    final helper = WildcardHelper(tiplu);
    
    final wildcards = hand.where((c) => helper.isWildcard(c)).toList();
    final naturalCards = hand.where((c) => !helper.isWildcard(c)).toList();
    
    if (wildcards.isEmpty) return melds;
    
    // Group by rank
    final byRank = <CardRank, List<PlayingCard>>{};
    for (final card in naturalCards) {
      byRank.putIfAbsent(card.rank, () => []).add(card);
    }
    
    // For each rank with 2 cards, try to form set with 1 wildcard
    for (final entry in byRank.entries) {
      final rankCards = entry.value;
      
      if (rankCards.length == 2 && wildcards.isNotEmpty) {
        // 2 natural + 1 wild = impure set
        final setCards = [...rankCards, wildcards.first];
        final meld = ImpureSetMeld(setCards, tiplu: tiplu);
        if (meld.isValid) melds.add(meld);
      }
      
      if (rankCards.length == 1 && wildcards.length >= 2) {
        // 1 natural + 2 wild = impure set
        final setCards = [rankCards.first, ...wildcards.take(2)];
        final meld = ImpureSetMeld(setCards, tiplu: tiplu);
        if (meld.isValid) melds.add(meld);
      }
    }
    
    return melds;
  }
  /// Validates if a hand can be completely partitioned into valid melds
  static bool validateHand(List<PlayingCard> hand, {PlayingCard? tiplu}) {
    if (hand.isEmpty) return true;
    
    // Sort hand to ensure consistent processing
    final sortedHand = List<PlayingCard>.from(hand)
      ..sort((a, b) => a.id.compareTo(b.id)); 
      
    return _canPartition(sortedHand, tiplu);
  }
  
  static bool _canPartition(List<PlayingCard> remaining, PlayingCard? tiplu) {
    if (remaining.isEmpty) return true;
    
    // Optimization: Always try to fuse the first card
    final pivot = remaining.first;
    
    // Find all valid melds containing the pivot
    // 1. Sets containing pivot
    final sets = _findSetsWithCard(pivot, remaining);
    for (final meld in sets) {
      if (_tryMeld(meld, remaining, tiplu)) return true;
    }
    
    // 2. Runs containing pivot
    final runs = _findRunsWithCard(pivot, remaining);
    for (final meld in runs) {
      if (_tryMeld(meld, remaining, tiplu)) return true;
    }
    
    // 3. Tunnels containing pivot
    final tunnels = _findTunnelsWithCard(pivot, remaining);
    for (final meld in tunnels) {
      if (_tryMeld(meld, remaining, tiplu)) return true;
    }

    // 3b. Dublees containing pivot (Simulate Dublee mode win check?)
    // Note: validateHand is usually for "Declare".
    // If player is in Dublee mode, they need 8 dublees?
    // This generic validateHand usually assumes Standard mode (Seqs+Sets).
    // But if we want to valid "DUBLEE WIN", we need to support Dublee partitioning.
    // Let's add Dublee check.
    final dublees = _findDubleesWithCard(pivot, remaining);
    for (final meld in dublees) {
      if (_tryMeld(meld, remaining, tiplu)) return true;
    }
    
    // 4. Marriage containing pivot
    if (tiplu != null) {
      final marriages = _findMarriagesWithCard(pivot, remaining, tiplu);
      for (final meld in marriages) {
        if (_tryMeld(meld, remaining, tiplu)) return true;
      }
      
      // 5. Impure Runs containing pivot (wildcards fill gaps)
      final impureRuns = _findImpureRunsWithCard(pivot, remaining, tiplu);
      for (final meld in impureRuns) {
        if (_tryMeld(meld, remaining, tiplu)) return true;
      }
      
      // 6. Impure Sets containing pivot (wildcards substitute)
      final impureSets = _findImpureSetsWithCard(pivot, remaining, tiplu);
      for (final meld in impureSets) {
        if (_tryMeld(meld, remaining, tiplu)) return true;
      }
    }
    
    return false;
  }
  
  static bool _tryMeld(Meld meld, List<PlayingCard> remaining, PlayingCard? tiplu) {
    final meldIds = meld.cards.map((c) => c.id).toSet();
    if (!meld.cards.every((c) => remaining.any((r) => r.id == c.id))) return false;
    
    final newRemaining = remaining.where((c) => !meldIds.contains(c.id)).toList();
    return _canPartition(newRemaining, tiplu);
  }
  
  static List<SetMeld> _findSetsWithCard(PlayingCard target, List<PlayingCard> pool) {
    final matches = pool.where((c) => c.rank == target.rank).toList();
    if (matches.length < 3) return [];
    
    final sets = <SetMeld>[];
    if (matches.length >= 3) {
      final others = matches.where((c) => c.id != target.id).toList();
      for (int i = 0; i < others.length; i++) {
        for (int j = i + 1; j < others.length; j++) {
           sets.add(SetMeld([target, others[i], others[j]]));
        }
      }
    }
    return sets;
  }
  
  static List<RunMeld> _findRunsWithCard(PlayingCard target, List<PlayingCard> pool) {
    final sameSuit = pool.where((c) => c.suit == target.suit).toList()
      ..sort((a, b) => a.rank.value.compareTo(b.rank.value));
      
    final runs = <RunMeld>[];
    final targetIdx = sameSuit.indexWhere((c) => c.id == target.id);
    if (targetIdx == -1) return [];
    
    // Check all valid sub-windows of length 3+ containing target
    for (int start = 0; start < sameSuit.length; start++) {
      for (int end = start + 3; end <= sameSuit.length; end++) {
        final window = sameSuit.sublist(start, end);
        if (!window.any((c) => c.id == target.id)) continue;
        
        bool consecutive = true;
        for (int k = 1; k < window.length; k++) {
           if (window[k].rank.value != window[k-1].rank.value + 1) {
             consecutive = false;
             break;
           }
        }
        if (consecutive) runs.add(RunMeld(window));
      }
    }
    return runs;
  }
  
  static List<TunnelMeld> _findTunnelsWithCard(PlayingCard target, List<PlayingCard> pool) {
     final matches = pool.where((c) => c.rank == target.rank && c.suit == target.suit).toList();
     if (matches.length < 3) return [];
     
     final tunnels = <TunnelMeld>[];
     final deckMap = <int, PlayingCard>{};
     for (var c in matches) {
       deckMap[c.deckIndex] = c;
     }
     
     if (deckMap.keys.toSet().length >= 3) {
       final distinct = deckMap.values.take(3).toList();
       if (distinct.any((c) => c.id == target.id)) {
          tunnels.add(TunnelMeld(distinct));
       }
     }
     return tunnels;
  }
  
  static List<DubleeMeld> _findDubleesWithCard(PlayingCard target, List<PlayingCard> pool) {
     final matches = pool.where((c) => c.rank == target.rank && c.suit == target.suit).toList();
     if (matches.length < 2) return [];
     
     final dublees = <DubleeMeld>[];
     for (final other in matches) {
       if (other.id != target.id && other.deckIndex != target.deckIndex) {
         dublees.add(DubleeMeld([target, other]));
       }
     }
     return dublees;
  }
  
  static List<MarriageMeld> _findMarriagesWithCard(PlayingCard target, List<PlayingCard> pool, PlayingCard tiplu) {
     final marriages = <MarriageMeld>[];
     if (target.suit != tiplu.suit) return [];
     
     final val = target.rank.value;
     final tVal = tiplu.rank.value;
     
     // Use wrap-around logic for edge cases (Ace tiplu)
     final jhipluRank = tVal == 1 ? 13 : tVal - 1;
     final popluRank = tVal == 13 ? 1 : tVal + 1;
     
     // Check if target could be part of a marriage
     if (val != jhipluRank && val != tVal && val != popluRank) return [];
     
     try {
       final hasJhiplu = pool.firstWhere((c) => c.suit == tiplu.suit && c.rank.value == jhipluRank);
       final hasTiplu = pool.firstWhere((c) => c.suit == tiplu.suit && c.rank.value == tVal);
       final hasPoplu = pool.firstWhere((c) => c.suit == tiplu.suit && c.rank.value == popluRank);
       
        if (hasJhiplu.id != hasTiplu.id && hasTiplu.id != hasPoplu.id) {
           final m = MarriageMeld([hasJhiplu, hasTiplu, hasPoplu], tiplu: tiplu);
           if (m.contains(target)) marriages.add(m);
        }
     } catch (e) {
       // missing card
     }
     return marriages;
  }
  
  /// Find impure runs containing target card (sequences with wildcards filling gaps)
  static List<ImpureRunMeld> _findImpureRunsWithCard(PlayingCard target, List<PlayingCard> pool, PlayingCard tiplu) {
    final melds = <ImpureRunMeld>[];
    final helper = WildcardHelper(tiplu);
    
    // Separate wildcards and natural cards
    final wildcards = pool.where((c) => helper.isWildcard(c)).toList();
    final naturalCards = pool.where((c) => !helper.isWildcard(c)).toList();
    
    if (wildcards.isEmpty) return melds; // No wildcards means no impure melds
    
    // If target is a wildcard, it can be part of any impure run
    final isTargetWild = helper.isWildcard(target);
    
    if (isTargetWild) {
      // Wildcard can join any partial sequence
      // Group natural cards by suit
      final bySuit = <CardSuit, List<PlayingCard>>{};
      for (final card in naturalCards) {
        bySuit.putIfAbsent(card.suit, () => []).add(card);
      }
      
      for (final entry in bySuit.entries) {
        final suitCards = entry.value..sort((a, b) => a.rank.value.compareTo(b.rank.value));
        if (suitCards.length < 2) continue; // Need at least 2 natural cards
        
        // Try forming runs with wildcards
        for (int i = 0; i < suitCards.length - 1; i++) {
          final gap = suitCards[i + 1].rank.value - suitCards[i].rank.value;
          if (gap == 2 && wildcards.isNotEmpty) {
            // One card gap - fill with wildcard
            final meld = ImpureRunMeld(
              [suitCards[i], target, suitCards[i + 1]],
              tiplu: tiplu,
            );
            if (meld.isValid) melds.add(meld);
          }
        }
      }
    } else {
      // Target is natural - find sequences where wildcards fill gaps
      final sameSuit = naturalCards.where((c) => c.suit == target.suit).toList()
        ..sort((a, b) => a.rank.value.compareTo(b.rank.value));
      
      final targetRank = target.rank.value;
      
      // Look for adjacent natural cards with gaps that wildcards can fill
      for (int length = 3; length <= 5; length++) {
        // Try target at different positions in the sequence
        for (int offset = 0; offset < length; offset++) {
          final startRank = targetRank - offset;
          if (startRank < 1 || startRank + length - 1 > 14) continue;
          
          final sequenceCards = <PlayingCard>[];
          int wildcardsNeeded = 0;
          bool containsTarget = false;
          
          for (int rank = startRank; rank < startRank + length; rank++) {
            final card = sameSuit.where((c) => c.rank.value == rank).firstOrNull;
            if (card != null) {
              sequenceCards.add(card);
              if (card.id == target.id) containsTarget = true;
            } else {
              wildcardsNeeded++;
            }
          }
          
          // Valid impure run: contains target, has wildcards, has natural cards
          if (containsTarget && 
              wildcardsNeeded > 0 && 
              wildcardsNeeded <= wildcards.length &&
              sequenceCards.isNotEmpty) {
            final allCards = [...sequenceCards, ...wildcards.take(wildcardsNeeded)];
            final meld = ImpureRunMeld(allCards, tiplu: tiplu);
            if (meld.isValid && meld.cards.any((c) => c.id == target.id)) {
              melds.add(meld);
            }
          }
        }
      }
    }
    
    return melds;
  }
  
  /// Find impure sets containing target card (sets with wildcards substituting)
  static List<ImpureSetMeld> _findImpureSetsWithCard(PlayingCard target, List<PlayingCard> pool, PlayingCard tiplu) {
    final melds = <ImpureSetMeld>[];
    final helper = WildcardHelper(tiplu);
    
    final wildcards = pool.where((c) => helper.isWildcard(c)).toList();
    final naturalCards = pool.where((c) => !helper.isWildcard(c)).toList();
    
    if (wildcards.isEmpty) return melds;
    
    final isTargetWild = helper.isWildcard(target);
    
    if (isTargetWild) {
      // Wildcard can join any partial set (2 natural cards of same rank)
      final byRank = <CardRank, List<PlayingCard>>{};
      for (final card in naturalCards) {
        byRank.putIfAbsent(card.rank, () => []).add(card);
      }
      
      for (final entry in byRank.entries) {
        if (entry.value.length >= 2) {
          // 2 natural + 1 wild (target) = impure set
          final meld = ImpureSetMeld(
            [entry.value[0], entry.value[1], target],
            tiplu: tiplu,
          );
          if (meld.isValid) melds.add(meld);
        }
      }
    } else {
      // Target is natural - find same-rank cards and add wildcard
      final sameRank = naturalCards.where((c) => c.rank == target.rank).toList();
      
      if (sameRank.length >= 2 && wildcards.isNotEmpty) {
        // 2 natural (including target) + 1 wild
        final others = sameRank.where((c) => c.id != target.id).take(1).toList();
        if (others.isNotEmpty) {
          final meld = ImpureSetMeld(
            [target, others.first, wildcards.first],
            tiplu: tiplu,
          );
          if (meld.isValid) melds.add(meld);
        }
      }
      
      if (sameRank.length == 1 && wildcards.length >= 2) {
        // 1 natural (target) + 2 wilds
        final meld = ImpureSetMeld(
          [target, wildcards[0], wildcards[1]],
          tiplu: tiplu,
        );
        if (meld.isValid) melds.add(meld);
      }
    }
    
    return melds;
  }
}
