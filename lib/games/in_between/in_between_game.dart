/// In Between Game Engine
/// 
/// Implementation of In Between (Acey Deucey) card game
/// Simple betting game - guess if card falls between two dealt cards
/// Based on open source implementations from ranjeetabh/Card-Games
library;

import 'package:clubroyale/games/base_game.dart';
import 'package:clubroyale/core/card_engine/pile.dart';
import 'package:clubroyale/core/card_engine/deck.dart';
import 'package:clubroyale/core/models/playing_card.dart';

/// In Between game state
enum InBetweenPhase {
  dealing,      // Dealing two boundary cards
  betting,      // Player placing bet
  revealing,    // Revealing middle card
  result,       // Showing result
  finished,
}

/// In Between round result
enum RoundResult {
  win,      // Card is between boundaries
  lose,     // Card is outside boundaries
  post,     // Card matches a boundary (lose double)
}

/// In Between Game
class InBetweenGame implements BaseGame {
  @override
  String get gameType => 'in_between';
  
  @override
  String get displayName => 'In Between';
  
  @override
  int get minPlayers => 2;
  
  @override
  int get maxPlayers => 8;
  
  @override
  int get deckCount => 1;
  
  @override
  int get cardsPerPlayer => 0;  // No cards dealt to players
  
  // Game state
  late Deck _deck;
  List<String> _playerIds = [];
  int _currentPlayerIndex = 0;
  GamePhase _currentPhase = GamePhase.waiting;
  InBetweenPhase _inBetweenPhase = InBetweenPhase.dealing;
  
  // Round state
  PlayingCard? _lowCard;
  PlayingCard? _highCard;
  PlayingCard? _middleCard;
  int _currentBet = 0;
  int _pot = 0;
  final Map<String, int> _chips = {};
  static const int startingChips = 100;
  static const int anteCost = 5;
  
  @override
  GamePhase get currentPhase => _currentPhase;
  
  @override
  String? get currentPlayerId => 
      _playerIds.isNotEmpty ? _playerIds[_currentPlayerIndex] : null;
  
  @override
  List<String> get playerIds => List.unmodifiable(_playerIds);
  
  @override
  bool get isFinished => _inBetweenPhase == InBetweenPhase.finished;
  
  // Getters
  int get pot => _pot;
  PlayingCard? get lowCard => _lowCard;
  PlayingCard? get highCard => _highCard;
  PlayingCard? get middleCard => _middleCard;
  int get currentBet => _currentBet;
  
  /// Get chips for a player
  int getChips(String playerId) => _chips[playerId] ?? 0;
  
  @override
  void initialize(List<String> playerIds) {
    if (playerIds.length < minPlayers || playerIds.length > maxPlayers) {
      throw ArgumentError('In Between requires $minPlayers-$maxPlayers players');
    }
    
    _playerIds = List.from(playerIds);
    _deck = Deck.standard();
    _chips.clear();
    
    for (final pid in playerIds) {
      _chips[pid] = startingChips;
    }
    
    _pot = 0;
    _currentPhase = GamePhase.waiting;
    _inBetweenPhase = InBetweenPhase.dealing;
  }
  
  @override
  void dealCards() {
    _currentPhase = GamePhase.playing;
    _inBetweenPhase = InBetweenPhase.dealing;
    
    // Check if deck needs reshuffle
    if (_deck.length < 10) {
      _deck.reset();
    }
    
    // Draw two boundary cards
    _lowCard = _deck.drawCard();
    _highCard = _deck.drawCard();
    _middleCard = null;
    _currentBet = 0;
    
    // Ensure low < high
    if (_lowCard != null && _highCard != null) {
      final lowValue = _cardValue(_lowCard!);
      final highValue = _cardValue(_highCard!);
      
      if (lowValue > highValue) {
        // Swap
        final temp = _lowCard;
        _lowCard = _highCard;
        _highCard = temp;
      }
    }
    
    _inBetweenPhase = InBetweenPhase.betting;
  }
  
  @override
  void startRound() {
    // Collect ante from all players
    for (final pid in _playerIds) {
      if (_chips[pid]! >= anteCost) {
        _chips[pid] = _chips[pid]! - anteCost;
        _pot += anteCost;
      }
    }
    
    dealCards();
  }
  
  @override
  void endRound() {
    _inBetweenPhase = InBetweenPhase.finished;
    _currentPhase = GamePhase.finished;
  }
  
  /// Place a bet (max is pot amount)
  bool placeBet(String playerId, int amount) {
    if (currentPlayerId != playerId) return false;
    if (_inBetweenPhase != InBetweenPhase.betting) return false;
    
    final playerChips = _chips[playerId] ?? 0;
    final maxBet = playerChips < _pot ? playerChips : _pot;
    
    if (amount < 0 || amount > maxBet) return false;
    
    _currentBet = amount;
    _inBetweenPhase = InBetweenPhase.revealing;
    
    return true;
  }
  
  /// Reveal the middle card and calculate result
  RoundResult reveal() {
    if (_inBetweenPhase != InBetweenPhase.revealing) {
      throw StateError('Cannot reveal in current phase');
    }
    
    _middleCard = _deck.drawCard();
    _inBetweenPhase = InBetweenPhase.result;
    
    final lowValue = _cardValue(_lowCard!);
    final highValue = _cardValue(_highCard!);
    final middleValue = _cardValue(_middleCard!);
    
    // Check for post (hitting boundary)
    if (middleValue == lowValue || middleValue == highValue) {
      // Post - lose double
      _chips[currentPlayerId!] = (_chips[currentPlayerId!] ?? 0) - _currentBet;
      _pot += _currentBet * 2;
      return RoundResult.post;
    }
    
    // Check if between
    if (middleValue > lowValue && middleValue < highValue) {
      // Win - double bet from pot
      _chips[currentPlayerId!] = (_chips[currentPlayerId!] ?? 0) + _currentBet;
      _pot -= _currentBet;
      return RoundResult.win;
    }
    
    // Lose - bet goes to pot
    _chips[currentPlayerId!] = (_chips[currentPlayerId!] ?? 0) - _currentBet;
    _pot += _currentBet;
    return RoundResult.lose;
  }
  
  /// Get card numeric value (Ace = 14 for consistency)
  /// Get card numeric value (Ace = 14 for consistency)
  int _cardValue(PlayingCard card) {
    switch (card.rank) {
      case CardRank.ace: return 14;
      case CardRank.king: return 13;
      case CardRank.queen: return 12;
      case CardRank.jack: return 11;
      default: return card.rank.points;
    }
  }
  
  /// Calculate probability of winning
  double getWinProbability() {
    if (_lowCard == null || _highCard == null) return 0;
    
    final lowValue = _cardValue(_lowCard!);
    final highValue = _cardValue(_highCard!);
    
    // Cards between low and high (exclusive)
    final winningCards = highValue - lowValue - 1;
    
    // Total remaining cards (approximately)
    final remainingCards = _deck.length;
    
    if (winningCards <= 0 || remainingCards <= 0) return 0;
    
    // Rough probability (doesn't account for cards already out)
    return (winningCards * 4) / remainingCards;
  }
  
  @override
  bool isValidMove(String playerId, PlayingCard card) => false;
  
  @override
  void playCard(String playerId, PlayingCard card) {
    // Not applicable
  }
  
  @override
  String? getRoundWinner() {
    // Winner is whoever has most chips at end
    String? winner;
    int maxChips = 0;
    
    for (final entry in _chips.entries) {
      if (entry.value > maxChips) {
        maxChips = entry.value;
        winner = entry.key;
      }
    }
    
    return winner;
  }
  
  @override
  Map<String, int> calculateScores() => Map.from(_chips);
  
  @override
  List<PlayingCard> getHand(String playerId) => [];
  
  @override
  void nextTurn() {
    _currentPlayerIndex = (_currentPlayerIndex + 1) % _playerIds.length;
    dealCards();
  }
  
  /// Pass turn (bet 0)
  void pass() {
    _currentBet = 0;
    nextTurn();
  }
}
