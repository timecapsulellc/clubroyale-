/// Marriage Game Engine
/// 
/// Implementation of Nepali Marriage card game
/// 3 decks (156 cards) + 6 jokers, 21 cards per player

import 'package:taasclub/games/base_game.dart';
import 'package:taasclub/core/card_engine/pile.dart';
import 'package:taasclub/core/card_engine/deck.dart';
import 'package:taasclub/core/card_engine/meld.dart';
import 'package:taasclub/core/card_engine/player_strategy.dart';

/// Marriage Game state
class MarriageGame implements BaseGame {
  @override
  String get gameType => 'marriage';
  
  @override
  String get displayName => 'Marriage';
  
  @override
  int get minPlayers => 2;
  
  @override
  int get maxPlayers => 8;
  
  @override
  int get deckCount => _playerIds.length > 5 ? 4 : 3;
  
  @override
  int get cardsPerPlayer => 21;
  
  // Game state
  late Deck _deck;
  late Pile _discardPile;
  final Map<String, Hand> _hands = {};
  List<String> _playerIds = [];
  int _currentPlayerIndex = 0;
  GamePhase _currentPhase = GamePhase.waiting;
  
  // Marriage-specific
  Card? _tiplu;  // The wild card for this round
  String? _roundWinner;
  final Map<String, int> _scores = {};
  int _currentRound = 0;
  static const int totalRounds = 5;
  
  @override
  GamePhase get currentPhase => _currentPhase;
  
  @override
  String? get currentPlayerId => 
      _playerIds.isNotEmpty ? _playerIds[_currentPlayerIndex] : null;
  
  @override
  List<String> get playerIds => List.unmodifiable(_playerIds);
  
  @override
  bool get isFinished => _currentRound >= totalRounds;
  
  /// Get the current wild card
  Card? get tiplu => _tiplu;
  
  /// Get current round number (1-indexed)
  int get currentRound => _currentRound + 1;
  
  /// Get top card of discard pile
  Card? get topDiscard => _discardPile.topCard;
  
  @override
  void initialize(List<String> playerIds) {
    if (playerIds.length < minPlayers || playerIds.length > maxPlayers) {
      throw ArgumentError('Marriage requires $minPlayers-$maxPlayers players');
    }
    
    _playerIds = List.from(playerIds);
    // Use 4 decks for 6-8 players, 3 decks for 2-5 players
    final requiredDecks = playerIds.length > 5 ? 4 : 3;
    _deck = Deck.forMarriage(deckCount: requiredDecks);
    _discardPile = Pile();
    _hands.clear();
    _scores.clear();
    
    for (final pid in _playerIds) {
      _hands[pid] = Hand();
      _scores[pid] = 0;
    }
    
    _currentPhase = GamePhase.waiting;
    _currentRound = 0;
  }
  
  @override
  void dealCards() {
    _currentPhase = GamePhase.dealing;
    _deck.reset();
    
    // Clear hands
    for (final hand in _hands.values) {
      hand.clear();
    }
    _discardPile.clear();
    
    // Deal 21 cards to each player
    final dealt = _deck.deal(_playerIds.length, cardsPerPlayer);
    for (int i = 0; i < _playerIds.length; i++) {
      _hands[_playerIds[i]]!.addCards(dealt[i]);
      _hands[_playerIds[i]]!.sortBySuit();
    }
    
    // Draw tiplu (wild card) from remaining deck
    _tiplu = _deck.drawCard();
    
    // Put first card on discard pile
    final firstDiscard = _deck.drawCard();
    if (firstDiscard != null) {
      _discardPile.addCard(firstDiscard);
    }
    
    _currentPhase = GamePhase.playing;
  }
  
  @override
  void startRound() {
    _currentRound++;
    _currentPlayerIndex = _currentRound % _playerIds.length;
    dealCards();
  }
  
  @override
  void endRound() {
    _currentPhase = GamePhase.scoring;
    
    // Calculate points for non-winners
    for (final pid in _playerIds) {
      if (pid != _roundWinner) {
        final hand = _hands[pid]!;
        final points = _calculateDeadwood(hand.cards);
        _scores[pid] = (_scores[pid] ?? 0) + points;
      }
    }
    
    _currentPhase = GamePhase.finished;
  }
  
  /// Calculate deadwood points in hand
  int _calculateDeadwood(List<Card> cards) {
    int points = 0;
    for (final card in cards) {
      if (card.isJoker || (_tiplu != null && _isTiplu(card))) {
        continue; // Wild cards = 0 points
      }
      points += card.rank.points;
    }
    return points;
  }
  
  /// Check if a card is the tiplu wild card
  bool _isTiplu(Card card) {
    if (_tiplu == null) return false;
    return card.rank == _tiplu!.rank && card.suit == _tiplu!.suit;
  }
  
  @override
  bool isValidMove(String playerId, Card card) {
    if (currentPlayerId != playerId) return false;
    if (_currentPhase != GamePhase.playing) return false;
    return _hands[playerId]?.cards.contains(card) ?? false;
  }
  
  @override
  void playCard(String playerId, Card card) {
    if (!isValidMove(playerId, card)) {
      throw StateError('Invalid move');
    }
    
    _hands[playerId]!.removeCard(card);
    _discardPile.addCard(card);
    nextTurn();
  }
  
  /// Draw a card from deck
  void drawFromDeck(String playerId) {
    if (currentPlayerId != playerId) return;
    
    final card = _deck.drawCard();
    if (card != null) {
      _hands[playerId]!.addCard(card);
    }
  }
  
  /// Draw top card from discard pile
  void drawFromDiscard(String playerId) {
    if (currentPlayerId != playerId) return;
    
    final card = _discardPile.drawCard();
    if (card != null) {
      _hands[playerId]!.addCard(card);
    }
  }
  
  /// Declare/show your hand
  bool declare(String playerId) {
    if (currentPlayerId != playerId) return false;
    
    final hand = _hands[playerId]!;
    
    // Check if hand can be declared (all cards in valid melds)
    final melds = MeldDetector.findAllMelds(hand.cards, tiplu: _tiplu);
    
    // For a valid declaration, all 21 cards must be in melds
    // Simplified check: at least 7 melds (each with 3 cards)
    if (melds.length >= 7) {
      _roundWinner = playerId;
      endRound();
      return true;
    }
    
    return false;
  }
  
  @override
  String? getRoundWinner() => _roundWinner;
  
  @override
  Map<String, int> calculateScores() => Map.unmodifiable(_scores);
  
  @override
  List<Card> getHand(String playerId) {
    return _hands[playerId]?.cards ?? [];
  }
  
  @override
  void nextTurn() {
    _currentPlayerIndex = (_currentPlayerIndex + 1) % _playerIds.length;
  }
  
  /// Get cards remaining in deck
  int get cardsRemaining => _deck.length;
  
  /// Find all possible melds in a player's hand
  List<Meld> findMelds(String playerId) {
    final hand = _hands[playerId];
    if (hand == null) return [];
    return MeldDetector.findAllMelds(hand.cards, tiplu: _tiplu);
  }
}
