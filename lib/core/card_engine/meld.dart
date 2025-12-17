/// Meld - Abstract class for card combinations
/// 
/// Based on gin_rummy SetMeld and RunMeld patterns
/// Extended for Marriage game with TunnelMeld and MarriageMeld
library;

import 'pile.dart';

/// Types of melds possible in card games
enum MeldType {
  set,       // 3+ cards of same rank, different suits (Trial in Marriage)
  run,       // 3+ consecutive cards, same suit (Sequence)
  tunnel,    // 3 identical cards (same rank + suit from different decks)
  marriage,  // Tiplu + Poplu + Jhiplu combination
}

/// Abstract base class for all meld types
abstract class Meld {
  final MeldType type;
  final List<Card> cards;
  
  const Meld({required this.type, required this.cards});
  
  /// Is this meld valid according to game rules?
  bool get isValid;
  
  /// Point value of this meld
  int get points;
  
  /// Does this meld contain a specific card?
  bool contains(Card card) => cards.any((c) => c.id == card.id);
}

/// SetMeld - 3+ cards of same rank, different suits (Trial in Marriage)
class SetMeld extends Meld {
  SetMeld(List<Card> cards) : super(type: MeldType.set, cards: cards);
  
  @override
  bool get isValid {
    if (cards.length < 3) return false;
    
    // All cards must have same rank
    final rank = cards.first.rank;
    if (!cards.every((c) => c.rank == rank)) return false;
    
    // All suits must be different (for single deck games)
    // For multi-deck, we allow same suit from different decks
    return true;
  }
  
  @override
  int get points => 0; // Complete melds have 0 points (deadwood)
}

/// RunMeld - 3+ consecutive cards of same suit (Sequence)
class RunMeld extends Meld {
  RunMeld(List<Card> cards) : super(type: MeldType.run, cards: cards);
  
  @override
  bool get isValid {
    if (cards.length < 3) return false;
    
    // All cards must have same suit
    final suit = cards.first.suit;
    if (!cards.every((c) => c.suit == suit)) return false;
    
    // Sort by rank and check consecutive
    final sorted = List<Card>.from(cards)
      ..sort((a, b) => a.rank.value.compareTo(b.rank.value));
    
    for (int i = 1; i < sorted.length; i++) {
      if (sorted[i].rank.value != sorted[i - 1].rank.value + 1) {
        return false;
      }
    }
    
    return true;
  }
  
  @override
  int get points => 0;
}

/// TunnelMeld - 3 identical cards (Marriage game only)
/// Three cards of exact same rank and suit from different decks
class TunnelMeld extends Meld {
  TunnelMeld(List<Card> cards) : super(type: MeldType.tunnel, cards: cards);
  
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

/// MarriageMeld - Special combination in Marriage game
/// Tiplu (wild) + Poplu (card above tiplu) + Jhiplu (card below tiplu)
class MarriageMeld extends Meld {
  final Card tiplu; // The wild card for this round
  
  MarriageMeld(List<Card> cards, {required this.tiplu}) 
      : super(type: MeldType.marriage, cards: cards);
  
  @override
  bool get isValid {
    if (cards.length != 3) return false;
    
    // Must contain tiplu, poplu, and jhiplu
    final hasJhiplu = cards.any((c) => 
        c.suit == tiplu.suit && c.rank.value == tiplu.rank.value - 1);
    final hasTiplu = cards.any((c) => 
        c.suit == tiplu.suit && c.rank == tiplu.rank);
    final hasPoplu = cards.any((c) => 
        c.suit == tiplu.suit && c.rank.value == tiplu.rank.value + 1);
    
    return hasJhiplu && hasTiplu && hasPoplu;
  }
  
  @override
  int get points => -100; // Big bonus for marriage (negative = very good)
}

/// Utility class for detecting melds in a hand
class MeldDetector {
  /// Find all possible set melds in a hand
  static List<SetMeld> findSets(List<Card> hand) {
    final melds = <SetMeld>[];
    final byRank = <Rank, List<Card>>{};
    
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
  static List<RunMeld> findRuns(List<Card> hand) {
    final melds = <RunMeld>[];
    final bySuit = <Suit, List<Card>>{};
    
    for (final card in hand) {
      bySuit.putIfAbsent(card.suit, () => []).add(card);
    }
    
    for (final cards in bySuit.values) {
      if (cards.length < 3) continue;
      
      final sorted = List<Card>.from(cards)
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
  static List<TunnelMeld> findTunnels(List<Card> hand) {
    final melds = <TunnelMeld>[];
    final byRankSuit = <String, List<Card>>{};
    
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
          final tunnel = <Card>[];
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
  
  /// Find all possible melds including marriage (if tiplu provided)
  static List<Meld> findAllMelds(List<Card> hand, {Card? tiplu}) {
    final melds = <Meld>[];
    melds.addAll(findSets(hand));
    melds.addAll(findRuns(hand));
    melds.addAll(findTunnels(hand));
    
    // Check for marriage if tiplu is provided
    if (tiplu != null) {
      final jhipluRank = tiplu.rank.value - 1;
      final popluRank = tiplu.rank.value + 1;
      
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
  /// Validates if a hand can be completely partitioned into valid melds
  static bool validateHand(List<Card> hand, {Card? tiplu}) {
    if (hand.isEmpty) return true;
    
    // Sort hand to ensure consistent processing
    final sortedHand = List<Card>.from(hand)
      ..sort((a, b) => a.id.compareTo(b.id)); 
      
    return _canPartition(sortedHand, tiplu);
  }
  
  static bool _canPartition(List<Card> remaining, Card? tiplu) {
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
    
    // 4. Marriage containing pivot
    if (tiplu != null) {
      final marriages = _findMarriagesWithCard(pivot, remaining, tiplu);
      for (final meld in marriages) {
        if (_tryMeld(meld, remaining, tiplu)) return true;
      }
    }
    
    return false;
  }
  
  static bool _tryMeld(Meld meld, List<Card> remaining, Card? tiplu) {
    final meldIds = meld.cards.map((c) => c.id).toSet();
    if (!meld.cards.every((c) => remaining.any((r) => r.id == c.id))) return false;
    
    final newRemaining = remaining.where((c) => !meldIds.contains(c.id)).toList();
    return _canPartition(newRemaining, tiplu);
  }
  
  static List<SetMeld> _findSetsWithCard(Card target, List<Card> pool) {
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
  
  static List<RunMeld> _findRunsWithCard(Card target, List<Card> pool) {
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
  
  static List<TunnelMeld> _findTunnelsWithCard(Card target, List<Card> pool) {
     final matches = pool.where((c) => c.rank == target.rank && c.suit == target.suit).toList();
     if (matches.length < 3) return [];
     
     final tunnels = <TunnelMeld>[];
     final deckMap = <int, Card>{};
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
  
  static List<MarriageMeld> _findMarriagesWithCard(Card target, List<Card> pool, Card tiplu) {
     final marriages = <MarriageMeld>[];
     if (target.suit != tiplu.suit) return [];
     
     final val = target.rank.value;
     final tVal = tiplu.rank.value;
     if ((val - tVal).abs() > 1 && val != tVal) return [];
     
     final jhipluRank = tVal - 1;
     final popluRank = tVal + 1;
     
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
}
