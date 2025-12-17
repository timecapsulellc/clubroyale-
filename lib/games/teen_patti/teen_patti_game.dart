/// Teen Patti Game Engine
/// 
/// Implementation of Indian Teen Patti (Three Patti) card game
/// 52 cards, 3 cards per player, betting-based gameplay
library;

import 'package:clubroyale/games/base_game.dart';
import 'package:clubroyale/core/card_engine/pile.dart';
import 'package:clubroyale/core/card_engine/deck.dart';
import 'teen_patti_hand.dart';

/// Player status in Teen Patti
enum PlayerStatus {
  blind,    // Haven't seen cards yet
  seen,     // Have seen cards
  folded,   // Dropped out
}

/// Teen Patti round phase
enum TeenPattiPhase {
  dealing,
  betting,
  sideShow,
  showdown,
  finished,
}

/// Teen Patti player state
class TeenPattiPlayer {
  final String id;
  final String name;
  List<Card> cards;
  PlayerStatus status;
  int totalBet;
  bool hasFolded;
  
  TeenPattiPlayer({
    required this.id,
    required this.name,
    this.cards = const [],
    this.status = PlayerStatus.blind,
    this.totalBet = 0,
    this.hasFolded = false,
  });
  
  TeenPattiHand? get hand => cards.length == 3 ? TeenPattiHand(cards) : null;
  
  void reset() {
    cards = [];
    status = PlayerStatus.blind;
    totalBet = 0;
    hasFolded = false;
  }
}

/// Teen Patti Game
class TeenPattiGame implements BaseGame {
  @override
  String get gameType => 'teen_patti';
  
  @override
  String get displayName => 'Teen Patti';
  
  @override
  int get minPlayers => 3;
  
  @override
  int get maxPlayers => 6;
  
  @override
  int get deckCount => 1;
  
  @override
  int get cardsPerPlayer => 3;
  
  // Game state
  late Deck _deck;
  final Map<String, TeenPattiPlayer> _players = {};
  List<String> _playerIds = [];
  int _currentPlayerIndex = 0;
  GamePhase _currentPhase = GamePhase.waiting;
  TeenPattiPhase _teenPattiPhase = TeenPattiPhase.dealing;
  
  // Betting state
  final int _bootAmount = 10;  // Initial ante
  int _pot = 0;
  int _currentStake = 1;  // Current betting unit
  final int _maxStake = 128;    // Maximum stake limit
  String? _gameWinner;
  
  @override
  GamePhase get currentPhase => _currentPhase;
  
  @override
  String? get currentPlayerId => 
      _playerIds.isNotEmpty ? _playerIds[_currentPlayerIndex] : null;
  
  @override
  List<String> get playerIds => List.unmodifiable(_playerIds);
  
  @override
  bool get isFinished => _teenPattiPhase == TeenPattiPhase.finished;
  
  // Teen Patti specific getters
  int get pot => _pot;
  int get currentStake => _currentStake;
  int get bootAmount => _bootAmount;
  
  @override
  void initialize(List<String> playerIds) {
    if (playerIds.length < minPlayers || playerIds.length > maxPlayers) {
      throw ArgumentError('Teen Patti requires $minPlayers-$maxPlayers players');
    }
    
    _playerIds = List.from(playerIds);
    _deck = Deck.standard();
    _players.clear();
    
    for (int i = 0; i < playerIds.length; i++) {
      _players[playerIds[i]] = TeenPattiPlayer(
        id: playerIds[i],
        name: 'Player ${i + 1}',
      );
    }
    
    _pot = 0;
    _currentPhase = GamePhase.waiting;
    _teenPattiPhase = TeenPattiPhase.dealing;
  }
  
  @override
  void dealCards() {
    _currentPhase = GamePhase.dealing;
    _teenPattiPhase = TeenPattiPhase.dealing;
    _deck.reset();
    
    // Reset all players
    for (final player in _players.values) {
      player.reset();
    }
    
    // Collect boot from all players
    _pot = _bootAmount * _playerIds.length;
    for (final player in _players.values) {
      player.totalBet = _bootAmount;
    }
    
    // Deal 3 cards to each player
    final dealt = _deck.deal(_playerIds.length, cardsPerPlayer);
    for (int i = 0; i < _playerIds.length; i++) {
      _players[_playerIds[i]]!.cards = dealt[i];
    }
    
    _teenPattiPhase = TeenPattiPhase.betting;
    _currentPhase = GamePhase.playing;
    _currentStake = 1;
    _currentPlayerIndex = 0;
  }
  
  @override
  void startRound() {
    dealCards();
  }
  
  @override
  void endRound() {
    _teenPattiPhase = TeenPattiPhase.finished;
    _currentPhase = GamePhase.finished;
  }
  
  /// See your cards (convert from blind to seen)
  void seeCards(String playerId) {
    final player = _players[playerId];
    if (player == null || player.hasFolded) return;
    player.status = PlayerStatus.seen;
  }
  
  /// Place a bet (chaal)
  bool bet(String playerId, int amount) {
    if (currentPlayerId != playerId) return false;
    
    final player = _players[playerId];
    if (player == null || player.hasFolded) return false;
    
    // Validate bet amount
    final minBet = _getMinBet(player);
    final maxBet = _getMaxBet(player);
    
    if (amount < minBet || amount > maxBet) return false;
    
    // Place bet
    player.totalBet += amount;
    _pot += amount;
    
    // Update stake for next player
    if (player.status == PlayerStatus.seen) {
      _currentStake = amount ~/ 2;  // Seen bets half as effective
    } else {
      _currentStake = amount;
    }
    
    nextTurn();
    _checkForWinner();
    
    return true;
  }
  
  /// Fold (pack)
  void fold(String playerId) {
    final player = _players[playerId];
    if (player == null) return;
    
    player.hasFolded = true;
    
    if (currentPlayerId == playerId) {
      nextTurn();
    }
    
    _checkForWinner();
  }
  
  /// Request side show with previous player
  bool requestSideShow(String playerId) {
    if (currentPlayerId != playerId) return false;
    
    final player = _players[playerId];
    if (player == null || player.status == PlayerStatus.blind) return false;
    
    // Find previous active player
    int prevIndex = (_currentPlayerIndex - 1 + _playerIds.length) % _playerIds.length;
    String prevPlayerId = _playerIds[prevIndex];
    final prevPlayer = _players[prevPlayerId];
    
    if (prevPlayer == null || prevPlayer.hasFolded) return false;
    if (prevPlayer.status == PlayerStatus.blind) return false;
    
    // Side show - compare hands, loser folds
    final myHand = player.hand;
    final theirHand = prevPlayer.hand;
    
    if (myHand == null || theirHand == null) return false;
    
    final result = myHand.compareTo(theirHand);
    if (result <= 0) {
      // I lose (or tie, requester loses on tie)
      player.hasFolded = true;
    } else {
      prevPlayer.hasFolded = true;
    }
    
    nextTurn();
    _checkForWinner();
    return true;
  }
  
  /// Request showdown (only when 2 players left)
  bool requestShowdown(String playerId) {
    if (currentPlayerId != playerId) return false;
    
    final activePlayers = _players.values.where((p) => !p.hasFolded).toList();
    if (activePlayers.length != 2) return false;
    
    // Compare hands
    final hands = activePlayers.map((p) => p.hand!).toList();
    final winners = TeenPattiHandEvaluator.findWinners(hands);
    
    if (winners.length == 1) {
      _gameWinner = activePlayers[winners[0]].id;
    } else {
      // Tie - pot split (for simplicity, first player wins)
      _gameWinner = activePlayers[0].id;
    }
    
    _teenPattiPhase = TeenPattiPhase.finished;
    _currentPhase = GamePhase.finished;
    
    return true;
  }
  
  int _getMinBet(TeenPattiPlayer player) {
    if (player.status == PlayerStatus.blind) {
      return _currentStake;  // Blind players bet at stake
    } else {
      return _currentStake * 2;  // Seen players bet 2x stake minimum
    }
  }
  
  int _getMaxBet(TeenPattiPlayer player) {
    if (player.status == PlayerStatus.blind) {
      return _currentStake * 2;  // Blind max is 2x stake
    } else {
      return _currentStake * 4;  // Seen max is 4x stake
    }
  }
  
  void _checkForWinner() {
    final activePlayers = _players.values.where((p) => !p.hasFolded).toList();
    
    if (activePlayers.length == 1) {
      _gameWinner = activePlayers[0].id;
      _teenPattiPhase = TeenPattiPhase.finished;
      _currentPhase = GamePhase.finished;
    }
  }
  
  @override
  bool isValidMove(String playerId, Card card) {
    // In Teen Patti, cards aren't "played" - betting is the action
    return false;
  }
  
  @override
  void playCard(String playerId, Card card) {
    // Not applicable for Teen Patti
  }
  
  @override
  String? getRoundWinner() => _gameWinner;
  
  @override
  Map<String, int> calculateScores() {
    final scores = <String, int>{};
    for (final pid in _playerIds) {
      if (pid == _gameWinner) {
        scores[pid] = _pot;  // Winner gets pot
      } else {
        scores[pid] = -_players[pid]!.totalBet;  // Others lose their bets
      }
    }
    return scores;
  }
  
  @override
  List<Card> getHand(String playerId) {
    return _players[playerId]?.cards ?? [];
  }
  
  @override
  void nextTurn() {
    // Find next active player
    int attempts = 0;
    do {
      _currentPlayerIndex = (_currentPlayerIndex + 1) % _playerIds.length;
      attempts++;
    } while (_players[_playerIds[_currentPlayerIndex]]!.hasFolded && 
             attempts < _playerIds.length);
  }
  
  /// Get player by ID
  TeenPattiPlayer? getPlayer(String playerId) => _players[playerId];
  
  /// Get all active (non-folded) player count
  int get activePlayerCount => 
      _players.values.where((p) => !p.hasFolded).length;
}
