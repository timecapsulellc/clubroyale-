/// Royal Meld (Marriage) Game Engine
/// 
/// Implementation of Royal Meld (Marriage) card game
/// 3 decks (156 cards) + 6 jokers, 21 cards per player
/// Uses GameTerminology for multi-region support
library;

import 'package:clubroyale/games/base_game.dart';
import 'package:clubroyale/core/models/playing_card.dart';
import 'package:clubroyale/core/card_engine/pile.dart';
import 'package:clubroyale/core/card_engine/deck.dart';
import 'package:clubroyale/core/card_engine/meld.dart';
import 'package:clubroyale/core/card_engine/player_strategy.dart';
import 'package:clubroyale/core/config/game_terminology.dart';
import 'package:clubroyale/games/marriage/marriage_scorer.dart';
import 'package:clubroyale/games/marriage/marriage_config.dart';

/// Royal Meld (Marriage) Game state
class MarriageGame implements BaseGame {
  @override
  String get gameType => 'marriage';
  
  @override
  // Use GameTerminology for multi-region support
  String get displayName => GameTerminology.royalMeldGame;

  /// Game Configuration
  final MarriageGameConfig config;

  MarriageGame({this.config = MarriageGameConfig.nepaliStandard});


  
  @override
  int get minPlayers => 2;
  
  @override
  int get maxPlayers => 8;
  
  @override
  int get deckCount {
    // Deck scaling by player count:
    // 2-5 players: 3 decks (156 cards)
    // 6-8 players: 4 decks (208 cards)
    if (_playerIds.length >= 6) return 4;
    return 3;
  }
  
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
  PlayingCard? _tiplu;  // The wild card for this round
  String? _roundWinner;
  final Map<String, int> _scores = {};
  final Set<String> _visitedPlayers = {}; // Players who have opened/unlocked
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
  
  /// Get the current wild card (Server Truth)
  PlayingCard? get tiplu => _tiplu;

  /// Check if a player has Visited (Unlocked Phase 2)
  bool isVisited(String playerId) => _visitedPlayers.contains(playerId);
  
  /// Get visible Tiplu for a specific player
  /// Returns null if player hasn't visited (Logic: Blind Phase)
  PlayingCard? getVisibleTiplu(String playerId) {
    if (isVisited(playerId)) return _tiplu;
    return null;
  }
  
  /// Get current round number (1-indexed for display)
  int get currentRound => _currentRound + 1;
  
  /// Get top card of discard pile
  PlayingCard? get topDiscard => _discardPile.topCard;
  
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
    
    // Use new Nepali Scorer with game config
    final scorer = MarriageScorer(tiplu: _tiplu, config: config);

    
    // Gather hands and detected melds for all players
    final Map<String, List<PlayingCard>> handsMap = {};
    final Map<String, List<Meld>> meldsMap = {};
    
    for (final pid in _playerIds) {
      final hand = _hands[pid]!;
      handsMap[pid] = hand.cards;
      meldsMap[pid] = MeldDetector.findAllMelds(hand.cards, tiplu: _tiplu);
    }
    
    // Calculate Matrix Settlement (Maal Exchange + Game Points)
    final settlement = scorer.calculateFinalSettlement(
      hands: handsMap,
      melds: meldsMap,
      winnerId: _roundWinner,
    );
    
    // Apply net results to global score
    for (final entry in settlement.entries) {
      _scores[entry.key] = (_scores[entry.key] ?? 0) + entry.value;
    }
    
    _currentPhase = GamePhase.finished;
  }
  
  // (Removed _calculateDeadwood as it is now in Scorer)
  
  /// Check if a card is the tiplu wild card
  bool _isTiplu(PlayingCard card) {
    if (_tiplu == null) return false;
    return card.rank == _tiplu!.rank && card.suit == _tiplu!.suit;
  }
  
  @override
  bool isValidMove(String playerId, PlayingCard card) {
    if (currentPlayerId != playerId) return false;
    if (_currentPhase != GamePhase.playing) return false;
    return _hands[playerId]?.cards.contains(card) ?? false;
  }
  
  @override
  void playCard(String playerId, PlayingCard card) {
    if (!isValidMove(playerId, card)) {
      throw StateError('Invalid move');
    }
    
    _hands[playerId]!.removeCard(card);
    _discardPile.addCard(card);
    nextTurn();
  }
  
  /// Draw a card from deck
  /// Handles deck exhaustion by reshuffling discard pile
  void drawFromDeck(String playerId) {
    if (currentPlayerId != playerId) return;
    
    // Handle deck exhaustion
    if (_deck.isEmpty) {
      _refreshDeckFromDiscard();
    }
    
    final card = _deck.drawCard();
    if (card != null) {
      _hands[playerId]!.addCard(card);
    }
  }
  
  /// Refresh the deck by shuffling the discard pile back
  void _refreshDeckFromDiscard() {
    if (_discardPile.length <= 1) return; // Keep at least the top card
    
    // Save the top card
    final topCard = _discardPile.drawCard();
    
    // Move all remaining cards from discard to deck
    while (_discardPile.isNotEmpty) {
      final card = _discardPile.drawCard();
      if (card != null) {
        _deck.addCard(card);
      }
    }
    
    // Shuffle the deck
    _deck.shuffle();
    
    // Put the top card back on discard
    if (topCard != null) {
      _discardPile.addCard(topCard);
    }
  }
  
  /// Draw top card from discard pile
  /// Throws StateError if move is illegal under current rules.
  void drawFromDiscard(String playerId) {
    if (currentPlayerId != playerId) return;
    
    final top = _discardPile.topCard;
    if (top == null) return;

    // 1. Strict Visiting Rule (optional)
    if (config.mustVisitToPickDiscard && !isVisited(playerId)) {
      throw StateError('Must visit (show pure sets) before picking from discard pile!');
    }

    // 2. Joker Block / Wild Pickup Rule
    final isWild = _isTiplu(top) || top.isJoker; // Simplified wildcard check
    
    if (isWild) {
      if (!config.canPickupWildFromDiscard) {
        throw StateError('Cannot pick up wild card from discard pile!');
      }
    }
    
    // 3. Joker Block (If previous discard was wild, pile might be blocked?)
    // Actually "Joker Blocks Discard" usually means: If top card is Joker, you can't pick it.
    // Which is covered by canPickupWildFromDiscard logic above.
    // Wait, "Joker Blocks Discard" specifically means: If the PREVIOUS player discarded a Joker,
    // the NEXT player is forced to draw from deck. The pile is "frozen".
    if (config.jokerBlocksDiscard && isWild) {
       throw StateError('Discard pile is blocked by a Joker!');
    }
    
    final card = _discardPile.drawCard();
    if (card != null) {
      _hands[playerId]!.addCard(card);
    }
  }
  
  /// Attempt to "Visit" (Unlock Phase 2) by showing pure sets
  bool visit(String playerId, List<List<PlayingCard>> meldPlayingCards) {
    if (currentPlayerId != playerId) return false;
    if (_visitedPlayers.contains(playerId)) return true; // Already visited
    
    // Construct melds (Without Tiplu context, strictly checking purity)
    final melds = <Meld>[];
    for (final cards in meldPlayingCards) {
      if (cards.length < 3) return false;
      
      // Try to form Sequence (Run) or Tunnel
      final run = RunMeld(cards);
      final tunnel = TunnelMeld(cards);
      
      if (run.isValid) {
        melds.add(run);
      } else if (tunnel.isValid) {
        melds.add(tunnel);
      } else {
        return false; // Invalid meld submitted
      }
    }
    
    // Validate Gateway Requirement
    final scorer = MarriageScorer(); // No tiplu context needed for purity check
    final pureCount = melds.where((m) => scorer.isPureSequence(m)).length;
    final tunnelCount = melds.where((m) => m.type == MeldType.tunnel).length;
    
    // Use config for visit requirement instead of hardcoded value
    // Tunnels count as Pure Sequences for visiting purposes
    final totalValid = pureCount + tunnelCount;
    
    if (totalValid >= config.sequencesRequiredToVisit) {
      _visitedPlayers.add(playerId);
      return true;
    }
    
    return false;
  }

  /// Declare/show your hand (Finish Game)
  bool declare(String playerId) {
    if (currentPlayerId != playerId) return false;
    
    final hand = _hands[playerId]!;
    
    // Validation:
    // 1. Must be Visited (Phase 2) to declare?
    // Actually, you can declare directly if you have everything pure.
    // But typically you visit first. Let's allow direct declare if comprehensive.
    // But for simplicity, we assume we use Tiplu only if Visited logic applies.
    
    final effectiveTiplu = isVisited(playerId) ? _tiplu : null; // Only use wildcards if visited (or check full hand purity)
    
    // If NOT visited, validateHand(tiplu: null) enforces PURE declaration (Blind Win) which is allowed.
    // If visited, validateHand uses real Tiplu.
    
    if (MeldDetector.validateHand(hand.cards, tiplu: effectiveTiplu)) {
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
  List<PlayingCard> getHand(String playerId) {
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
  
  /// Check for Tunnel Win condition (7+ tunnels = instant win)
  /// Returns true if player can claim an instant tunnel win
  bool checkTunnelWin(String playerId) {
    final melds = findMelds(playerId);
    final tunnelCount = melds.where((m) => m.type == MeldType.tunnel).length;
    
    // Standard rule: 7 tunnels = instant win (21 cards / 3 per tunnel = 7 tunnels max)
    if (tunnelCount >= 7) {
      _roundWinner = playerId;
      endRound();
      return true;
    }
    
    return false;
  }
  
  /// Quick check if deck is empty
  bool get isDeckEmpty => _deck.isEmpty;
}
