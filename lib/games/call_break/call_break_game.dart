/// Call Break Game Engine
/// 
/// Implementation of the popular South Asian trick-taking card game
/// 4 players, 13 cards each, spades are always trump
library;

import 'package:clubroyale/games/base_game.dart';
import 'package:clubroyale/core/card_engine/pile.dart';
import 'package:clubroyale/core/card_engine/deck.dart';
import 'package:clubroyale/core/models/playing_card.dart';

/// Call Break game phase
enum CallBreakPhase {
  waiting,
  bidding,
  playing,
  scoring,
  finished,
}

/// A single trick in the game
/// A single trick in the game
class Trick {
  final List<TrickCard> cards = [];
  final CardSuit ledSuit;
  String? winnerId;
  
  Trick({required this.ledSuit});
  
  void addCard(String playerId, PlayingCard card) {
    cards.add(TrickCard(playerId: playerId, card: card));
  }
  
  bool get isComplete => cards.length == 4;
}

/// A card played in a trick
class TrickCard {
  final String playerId;
  final PlayingCard card;
  
  TrickCard({required this.playerId, required this.card});
}

/// Call Break Game state
class CallBreakGame implements BaseGame {
  @override
  String get gameType => 'call_break';
  
  @override
  String get displayName => 'Call Break';
  
  @override
  int get minPlayers => 4;
  
  @override
  int get maxPlayers => 4;
  
  @override
  int get deckCount => 1;
  
  @override
  int get cardsPerPlayer => 13;
  
  // Constants
  static const CardSuit trumpSuit = CardSuit.spades;
  static const int minBid = 1;
  static const int maxBid = 13;
  static const int totalRounds = 5;
  
  // Config options
  bool mustCutWithTrump = false; // When true, must play trump if can't follow suit
  
  // Game state
  late Deck _deck;
  final Map<String, Hand> _hands = {};
  List<String> _playerIds = [];
  int _currentPlayerIndex = 0;
  CallBreakPhase _phase = CallBreakPhase.waiting;
  
  // Bidding
  final Map<String, int> _bids = {};
  
  // Playing
  Trick? _currentTrick;
  final Map<String, int> _tricksWon = {};
  int _tricksPlayed = 0;
  bool _spadesBroken = false;  // Track if spades have been played
  final List<Trick> _trickHistory = [];  // Store previous tricks
  
  // Scoring
  final Map<String, int> _scores = {};
  int _currentRound = 0;
  
  // Getters for new state
  bool get spadesBroken => _spadesBroken;
  List<Trick> get trickHistory => List.unmodifiable(_trickHistory);
  
  @override
  GamePhase get currentPhase {
    switch (_phase) {
      case CallBreakPhase.waiting:
        return GamePhase.waiting;
      case CallBreakPhase.bidding:
      case CallBreakPhase.playing:
        return GamePhase.playing;
      case CallBreakPhase.scoring:
        return GamePhase.scoring;
      case CallBreakPhase.finished:
        return GamePhase.finished;
    }
  }
  
  CallBreakPhase get phase => _phase;
  
  @override
  String? get currentPlayerId => 
      _playerIds.isNotEmpty ? _playerIds[_currentPlayerIndex] : null;
  
  @override
  List<String> get playerIds => List.unmodifiable(_playerIds);
  
  @override
  bool get isFinished => _currentRound >= totalRounds;
  
  /// Get current round (1-indexed)
  int get currentRound => _currentRound + 1;
  
  /// Get bids
  Map<String, int> get bids => Map.unmodifiable(_bids);
  
  /// Get tricks won this round
  Map<String, int> get tricksWon => Map.unmodifiable(_tricksWon);
  
  /// Get current trick
  Trick? get currentTrick => _currentTrick;
  
  /// Cards remaining in deck
  int get cardsRemaining => _deck.length;
  
  @override
  void initialize(List<String> playerIds) {
    if (playerIds.length != 4) {
      throw ArgumentError('Call Break requires exactly 4 players');
    }
    
    _playerIds = List.from(playerIds);
    _deck = Deck.standard();
    _hands.clear();
    _scores.clear();
    _bids.clear();
    _tricksWon.clear();
    
    for (final pid in _playerIds) {
      _hands[pid] = Hand();
      _scores[pid] = 0;
    }
    
    _phase = CallBreakPhase.waiting;
    _currentRound = 0;
  }
  
  @override
  void dealCards() {
    _deck.reset();
    
    // Clear hands
    for (final hand in _hands.values) {
      hand.clear();
    }
    
    // Deal 13 cards to each player
    final dealt = _deck.deal(4, cardsPerPlayer);
    for (int i = 0; i < _playerIds.length; i++) {
      _hands[_playerIds[i]]!.addCards(dealt[i]);
      _hands[_playerIds[i]]!.sortBySuit();
    }
  }
  
  @override
  void startRound() {
    _currentRound++;
    _bids.clear();
    _tricksWon.clear();
    _tricksPlayed = 0;
    _currentTrick = null;
    
    for (final pid in _playerIds) {
      _tricksWon[pid] = 0;
    }
    
    // Reset round state
    _spadesBroken = false;
    _trickHistory.clear();
    
    // Rotate dealer - first player after dealer starts
    _currentPlayerIndex = _currentRound % _playerIds.length;
    
    dealCards();
    _phase = CallBreakPhase.bidding;
  }
  
  /// Submit a bid (1-13)
  bool submitBid(String playerId, int bid) {
    if (_phase != CallBreakPhase.bidding) return false;
    if (currentPlayerId != playerId) return false;
    if (bid < minBid || bid > maxBid) return false;
    if (_bids.containsKey(playerId)) return false;
    
    _bids[playerId] = bid;
    nextTurn();
    
    // Check if all bids are in
    if (_bids.length == 4) {
      _phase = CallBreakPhase.playing;
      // First bidder leads first trick
      _currentPlayerIndex = (_currentRound % _playerIds.length);
    }
    
    return true;
  }
  
  /// Get player's bid
  int? getBid(String playerId) => _bids[playerId];
  
  /// Check if bidding is complete
  bool get biddingComplete => _bids.length == 4;
  
  @override
  bool isValidMove(String playerId, PlayingCard card) {
    if (_phase != CallBreakPhase.playing) return false;
    if (currentPlayerId != playerId) return false;
    
    final hand = _hands[playerId];
    if (hand == null || !hand.cards.contains(card)) return false;
    
    // First card of trick - any card is valid
    if (_currentTrick == null || _currentTrick!.cards.isEmpty) {
      return true;
    }
    
    // Must follow suit if possible
    final ledSuit = _currentTrick!.ledSuit;
    final hasSuit = hand.cards.any((c) => c.suit == ledSuit);
    
    if (hasSuit) {
      return card.suit == ledSuit;
    }
    
    // Can't follow suit - check trump cutting rule
    if (mustCutWithTrump) {
      final hasTrump = hand.cards.any((c) => c.suit == trumpSuit);
      if (hasTrump) {
        // Must play trump if we have one
        return card.suit == trumpSuit;
      }
    }
    
    // No trump or rule disabled - any card is valid
    return true;
  }
  
  @override
  void playCard(String playerId, PlayingCard card) {
    if (!isValidMove(playerId, card)) {
      throw StateError('Invalid move');
    }
    
    // Start new trick if needed
    if (_currentTrick == null || _currentTrick!.isComplete) {
      _currentTrick = Trick(ledSuit: card.suit);
    }
    
    // Play the card
    _hands[playerId]!.removeCard(card);
    _currentTrick!.addCard(playerId, card);
    
    // Check if trick is complete
    if (_currentTrick!.isComplete) {
      _resolveTrick();
    } else {
      nextTurn();
    }
  }
  
  /// Resolve completed trick
  void _resolveTrick() {
    final trick = _currentTrick!;
    final winnerId = _findTrickWinner(trick);
    
    // Check if spades were broken
    if (!_spadesBroken) {
      _spadesBroken = trick.cards.any((tc) => tc.card.suit == trumpSuit);
    }
    
    trick.winnerId = winnerId;
    _tricksWon[winnerId] = (_tricksWon[winnerId] ?? 0) + 1;
    _tricksPlayed++;
    
    // Store trick in history
    _trickHistory.add(trick);
    
    // Winner leads next trick
    _currentPlayerIndex = _playerIds.indexOf(winnerId);
    
    // Check if round is complete
    if (_tricksPlayed >= 13) {
      _endRound();
    }
  }
  
  /// Find winner of a trick
  String _findTrickWinner(Trick trick) {
    final ledSuit = trick.ledSuit;
    TrickCard? winning;
    
    for (final tc in trick.cards) {
      if (winning == null) {
        winning = tc;
        continue;
      }
      
      final current = tc.card;
      final best = winning.card;
      
      // Trump beats non-trump
      if (current.suit == trumpSuit && best.suit != trumpSuit) {
        winning = tc;
      }
      // Higher trump beats lower trump
      else if (current.suit == trumpSuit && best.suit == trumpSuit) {
        if (current.rank.value > best.rank.value) {
          winning = tc;
        }
      }
      // Following led suit - higher wins
      else if (current.suit == ledSuit && best.suit == ledSuit) {
        if (current.rank.value > best.rank.value) {
          winning = tc;
        }
      }
      // Non-led, non-trump doesn't beat anything
    }
    
    return winning!.playerId;
  }
  
  void _endRound() {
    _phase = CallBreakPhase.scoring;
    
    // Calculate scores
    // Scores are stored as x10 to handle 0.1-point overtricks
    // Display should divide by 10 for proper decimal display
    for (final pid in _playerIds) {
      final bid = _bids[pid] ?? 0;
      final won = _tricksWon[pid] ?? 0;
      
      if (won >= bid) {
        // Made bid: score = bid + 0.1 per overtrick
        // Store as: bid*10 + overtricks (to avoid floating point)
        final overtricks = won - bid;
        _scores[pid] = (_scores[pid] ?? 0) + (bid * 10) + overtricks;
      } else {
        // Failed bid: score = -bid (stored as x10)
        _scores[pid] = (_scores[pid] ?? 0) - (bid * 10);
      }
    }
    
    if (_currentRound >= totalRounds) {
      _phase = CallBreakPhase.finished;
    }
  }
  
  @override
  void endRound() {
    _endRound();
  }
  
  @override
  String? getRoundWinner() {
    if (_phase != CallBreakPhase.scoring && _phase != CallBreakPhase.finished) {
      return null;
    }
    
    // Winner is player with highest score
    String? winner;
    int highScore = -1000;
    
    for (final entry in _scores.entries) {
      if (entry.value > highScore) {
        highScore = entry.value;
        winner = entry.key;
      }
    }
    
    return winner;
  }
  
  @override
  Map<String, int> calculateScores() => Map.unmodifiable(_scores);
  
  @override
  List<PlayingCard> getHand(String playerId) {
    return _hands[playerId]?.cards ?? [];
  }
  
  @override
  void nextTurn() {
    _currentPlayerIndex = (_currentPlayerIndex + 1) % _playerIds.length;
  }
  
  /// Check if player can follow suit
  bool canFollowSuit(String playerId, CardSuit suit) {
    final hand = _hands[playerId];
    if (hand == null) return false;
    return hand.cards.any((c) => c.suit == suit);
  }
  
  /// Get valid cards for current player
  List<PlayingCard> getValidCards(String playerId) {
    if (currentPlayerId != playerId) return [];
    
    final hand = _hands[playerId];
    if (hand == null) return [];
    
    // First card - all valid
    if (_currentTrick == null || _currentTrick!.cards.isEmpty) {
      return hand.cards;
    }
    
    // Must follow suit if possible
    final ledSuit = _currentTrick!.ledSuit;
    final suitCards = hand.cards.where((c) => c.suit == ledSuit).toList();
    
    if (suitCards.isNotEmpty) {
      return suitCards;
    }
    
    // Can't follow - all cards valid
    return hand.cards;
  }
}

/// Hand class for managing player's cards
class Hand {
  final List<PlayingCard> _cards = [];
  
  List<PlayingCard> get cards => List.unmodifiable(_cards);
  
  void addCard(PlayingCard card) => _cards.add(card);
  
  void addCards(List<PlayingCard> cards) => _cards.addAll(cards);
  
  bool removeCard(PlayingCard card) => _cards.remove(card);
  
  void clear() => _cards.clear();
  
  void sortBySuit() {
    _cards.sort((a, b) {
      final suitCompare = a.suit.index.compareTo(b.suit.index);
      if (suitCompare != 0) return suitCompare;
      return a.rank.value.compareTo(b.rank.value);
    });
  }
}
