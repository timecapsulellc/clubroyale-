/// BaseGame - Abstract interface for all card games
/// 
/// This defines the contract that all games must implement

import 'package:taasclub/core/card_engine/pile.dart';

/// Game phases common to most card games
enum GamePhase {
  waiting,    // Waiting for players
  dealing,    // Cards being dealt
  bidding,    // Players placing bids
  playing,    // Active gameplay
  scoring,    // Round/game scoring
  finished,   // Game complete
}

/// Abstract base game interface
abstract class BaseGame {
  /// Unique identifier for this game type
  String get gameType;
  
  /// Display name for the game
  String get displayName;
  
  /// Minimum players required
  int get minPlayers;
  
  /// Maximum players allowed
  int get maxPlayers;
  
  /// Number of decks used
  int get deckCount;
  
  /// Cards dealt per player
  int get cardsPerPlayer;
  
  /// Current game phase
  GamePhase get currentPhase;
  
  /// Current player's ID
  String? get currentPlayerId;
  
  /// All player IDs in turn order
  List<String> get playerIds;
  
  /// Initialize game with players
  void initialize(List<String> playerIds);
  
  /// Deal cards to all players
  void dealCards();
  
  /// Start a new round
  void startRound();
  
  /// End the current round
  void endRound();
  
  /// Check if a move is valid
  bool isValidMove(String playerId, Card card);
  
  /// Play a card
  void playCard(String playerId, Card card);
  
  /// Get the winner of current round/trick
  String? getRoundWinner();
  
  /// Calculate scores for all players
  Map<String, int> calculateScores();
  
  /// Get a player's hand
  List<Card> getHand(String playerId);
  
  /// Advance to next player's turn
  void nextTurn();
  
  /// Is the game finished?
  bool get isFinished;
}

/// Supported game types
enum GameType {
  callBreak('call_break', 'Call Break'),
  marriage('marriage', 'Marriage'),
  teenPatti('teen_patti', 'Teen Patti'),
  inBetween('in_between', 'In Between'),
  dhumbal('dhumbal', 'Dhumbal');
  
  final String id;
  final String displayName;
  
  const GameType(this.id, this.displayName);
}
