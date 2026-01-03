import 'package:flutter_test/flutter_test.dart';
import 'package:clubroyale/games/marriage/marriage_game.dart';
import 'package:clubroyale/games/base_game.dart';

/// Tests for Marriage Game Logic
void main() {
  group('Player Count Tests', () {
    
    test('Test 2.1: Minimum Players (2)', () {
      // Arrange
      final game = MarriageGame();
      final playerIds = ['player1', 'player2'];
      
      // Act
      game.initialize(playerIds);
      game.dealCards();
      
      // Assert
      expect(game.playerIds.length, 2);
      expect(game.currentPhase, GamePhase.playing);
      expect(game.deckCount, 3); // Should use 3 decks
      
      // Each player should have 21 cards
      for (final playerId in playerIds) {
        final hand = game.getHand(playerId);
        expect(hand.length, 21, reason: '$playerId should have 21 cards');
      }
      
      // Tiplu should be drawn
      expect(game.tiplu, isNotNull);
      
      // Discard pile should have at least 1 card
      expect(game.topDiscard, isNotNull);
    });
    
    test('Test 2.2: Medium Players (5)', () {
      // Arrange
      final game = MarriageGame();
      final playerIds = ['p1', 'p2', 'p3', 'p4', 'p5'];
      
      // Act
      game.initialize(playerIds);
      game.dealCards();
      
      // Assert
      expect(game.playerIds.length, 5);
      expect(game.deckCount, 3); // Still 3 decks
      
      // Each player should have 21 cards
      for (final playerId in playerIds) {
        final hand = game.getHand(playerId);
        expect(hand.length, 21);
      }
      
      // Should have cards remaining in deck
      expect(game.cardsRemaining, greaterThan(0));
    });
    
    test('Test 2.3: Maximum Players (8)', () {
      // Arrange
      final game = MarriageGame();
      final playerIds = ['p1', 'p2', 'p3', 'p4', 'p5', 'p6', 'p7', 'p8'];
      
      // Act
      game.initialize(playerIds);
      game.dealCards();
      
      // Assert
      expect(game.playerIds.length, 8);
      expect(game.maxPlayers, 8);
      expect(game.deckCount, 4); // Should use 4 decks
      
      // Each player should have 21 cards
      for (final playerId in playerIds) {
        final hand = game.getHand(playerId);
        expect(hand.length, 21, reason: '$playerId should have 21 cards');
      }
      
      // Should still have cards in deck (at least ~48)
      expect(game.cardsRemaining, greaterThan(40));
      
      // Tiplu and discard pile
      expect(game.tiplu, isNotNull);
      expect(game.topDiscard, isNotNull);
    });
    
    test('Test 2.4: Six Players (Boundary - Switches to 4 Decks)', () {
      // Arrange
      final game = MarriageGame();
      final playerIds = ['p1', 'p2', 'p3', 'p4', 'p5', 'p6'];
      
      // Act
      game.initialize(playerIds);
      
      // Assert - should switch to 4 decks
      expect(game.deckCount, 4);
      expect(game.playerIds.length, 6);
    });
    
    test('Test 2.5: Invalid Player Count - Below Minimum', () {
      // Arrange
      final game = MarriageGame();
      final playerIds = ['player1']; // Only 1 player
      
      // Act & Assert
      expect(
        () => game.initialize(playerIds),
        throwsA(isA<ArgumentError>()),
        reason: 'Should throw error for < 2 players'
      );
    });
    
    test('Test 2.6: Invalid Player Count - Above Maximum', () {
      // Arrange
      final game = MarriageGame();
      final playerIds = ['p1', 'p2', 'p3', 'p4', 'p5', 'p6', 'p7', 'p8', 'p9'];
      
      // Act & Assert
      expect(
        () => game.initialize(playerIds),
        throwsA(isA<ArgumentError>()),
        reason: 'Should throw error for > 8 players'
      );
    });
    
    test('Test 2.7: Empty Player List', () {
      // Arrange
      final game = MarriageGame();
      final playerIds = <String>[];
      
      // Act & Assert
      expect(
        () => game.initialize(playerIds),
        throwsA(isA<ArgumentError>()),
      );
    });
  });
  
  group('Game Flow Tests', () {
    
    test('Test 5.1: Turn Rotation - 2 Players', () {
      // Arrange
      final game = MarriageGame();
      game.initialize(['p1', 'p2']);
      game.dealCards();
      
      // Act & Assert
      expect(game.currentPlayerId, 'p1');
      
      game.nextTurn();
      expect(game.currentPlayerId, 'p2');
      
      game.nextTurn();
      expect(game.currentPlayerId, 'p1'); // Back to first player
    });
    
    test('Test 5.2: Turn Rotation - 8 Players', () {
      // Arrange
      final game = MarriageGame();
      final playerIds = ['p1', 'p2', 'p3', 'p4', 'p5', 'p6', 'p7', 'p8'];
      game.initialize(playerIds);
      game.dealCards();
      
      // Act & Assert - cycle through all players
      for (int i = 0; i < 8; i++) {
        expect(game.currentPlayerId, playerIds[i]);
        game.nextTurn();
      }
      
      // Should wrap back to first player
      expect(game.currentPlayerId, 'p1');
    });
    
    test('Test 5.3: Initial Game Phase', () {
      // Arrange & Act
      final game = MarriageGame();
      
      // Assert - should start in waiting phase
      expect(game.currentPhase, GamePhase.waiting);
      
      game.initialize(['p1', 'p2']);
      expect(game.currentPhase, GamePhase.waiting);
      
      game.dealCards();
      expect(game.currentPhase, GamePhase.playing);
    });
    
    test('Test 5.4: Round Progression', () {
      // Arrange
      final game = MarriageGame();
      game.initialize(['p1', 'p2']);
      
      // Assert initial state - currentRound getter returns 1-indexed (starts at 1)
      expect(game.currentRound, 1);
      expect(game.isFinished, false);
      
      // Act - start multiple rounds (each startRound increments the round)
      // Round progression: 1 (initial) -> 2 -> 3 -> 4 -> 5 -> 6
      for (int i = 0; i < 5; i++) {
        game.startRound();
      }
      
      // After 5 startRound calls, currentRound should be 6
      expect(game.currentRound, 6);
      
      // Game should be finished after 5 rounds played (internal count >= 5)
      expect(game.isFinished, true);
    });
    
    test('Test 5.5: Card Drawing from Deck', () {
      // Arrange
      final game = MarriageGame();
      game.initialize(['p1', 'p2']);
      game.dealCards();
      
      final initialHandSize = game.getHand('p1').length;
      final initialDeckSize = game.cardsRemaining;
      
      // Act
      game.drawFromDeck('p1');
      
      // Assert
      expect(game.getHand('p1').length, initialHandSize + 1);
      expect(game.cardsRemaining, initialDeckSize - 1);
    });
    
    test('Test 5.6: Card Drawing from Discard', () {
      // Arrange
      final game = MarriageGame();
      game.initialize(['p1', 'p2']);
      game.dealCards();
      
      // First, play a card from p1's hand to ensure a non-wild card is on discard
      // (Wild cards cannot be picked from discard per Marriage rules)
      final hand = game.getHand('p1');
      final nonWildCard = hand.firstWhere(
        (c) => c.rank != game.tiplu?.rank, // Find non-wild card 
        orElse: () => hand.first,
      );
      game.playCard('p1', nonWildCard);
      
      // Now p2 can draw from discard
      final p2InitialHandSize = game.getHand('p2').length;
      final discardCard = game.topDiscard;
      
      // Ensure discard is not a wild card before drawing
      if (discardCard != null && discardCard.rank != game.tiplu?.rank) {
        // Act
        game.drawFromDiscard('p2');
        
        // Assert
        expect(game.getHand('p2').length, p2InitialHandSize + 1);
        
        // The drawn card should be in player's hand
        final p2Hand = game.getHand('p2');
        expect(p2Hand.any((c) => c.id == discardCard.id), true);
      } else {
        // If it's wild, just verify draw from deck works
        game.drawFromDeck('p2');
        expect(game.getHand('p2').length, p2InitialHandSize + 1);
      }
    });
  });
  
  group('Scoring Tests', () {
    
    test('Test: Score Initialization', () {
      // Arrange & Act
      final game = MarriageGame();
      game.initialize(['p1', 'p2', 'p3']);
      
      // Assert - all players should start with 0 score
      final scores = game.calculateScores();
      expect(scores['p1'], 0);
      expect(scores['p2'], 0);
      expect(scores['p3'], 0);
    });
    
    test('Test: Tiplu Changes Each Round', () {
      // Arrange
      final game = MarriageGame();
      game.initialize(['p1', 'p2']);
      
      // Act & Assert
      final tiplus = <String?>[];
      
      for (int i = 0; i < 3; i++) {
        game.startRound();
        tiplus.add(game.tiplu?.id);
      }
      
      // Tiplus should be different (very high probability)
      // Note: There's a tiny chance they could be the same by random
      expect(tiplus.toSet().length, greaterThan(1));
    });
  });
  
  group('Edge Cases', () {
    
    test('Test: No Duplicate Cards Dealt', () {
      // Arrange
      final game = MarriageGame();
      game.initialize(['p1', 'p2', 'p3', 'p4', 'p5', 'p6', 'p7', 'p8']);
      game.dealCards();
      
      // Act - collect all dealt cards
      final allCards = <String>[];
      for (final playerId in game.playerIds) {
        final hand = game.getHand(playerId);
        allCards.addAll(hand.map((c) => c.id));
      }
      
      // Add tiplu and discard
      if (game.tiplu != null) allCards.add(game.tiplu!.id);
      if (game.topDiscard != null) allCards.add(game.topDiscard!.id);
      
      // Assert - all cards should be unique
      final uniqueCards = allCards.toSet();
      expect(uniqueCards.length, allCards.length, 
        reason: 'No duplicate cards should exist');
    });
    
    test('Test: Cannot Draw from Empty Deck', () {
      // Arrange
      final game = MarriageGame();
      game.initialize(['p1', 'p2']);
      game.dealCards();
      
      // Act - drain the deck
      while (game.cardsRemaining > 0) {
        game.drawFromDeck('p1');
      }
      
      final handSizeBefore = game.getHand('p1').length;
      
      // Try to draw from empty deck
      game.drawFromDeck('p1');
      
      // Assert - hand size should not change
      expect(game.getHand('p1').length, handSizeBefore);
    });
  });
}
