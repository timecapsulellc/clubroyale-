/// Call Break Game Unit Tests

import 'package:flutter_test/flutter_test.dart';
import 'package:clubroyale/games/call_break/call_break_game.dart';
import 'package:clubroyale/core/card_engine/pile.dart';

void main() {
  group('CallBreakGame - Initialization', () {
    test('Initializes with exactly 4 players', () {
      final game = CallBreakGame();
      game.initialize(['p1', 'p2', 'p3', 'p4']);
      
      expect(game.playerIds.length, 4);
      expect(game.phase, CallBreakPhase.waiting);
    });
    
    test('Rejects less than 4 players', () {
      final game = CallBreakGame();
      expect(
        () => game.initialize(['p1', 'p2', 'p3']),
        throwsArgumentError,
      );
    });
    
    test('Rejects more than 4 players', () {
      final game = CallBreakGame();
      expect(
        () => game.initialize(['p1', 'p2', 'p3', 'p4', 'p5']),
        throwsArgumentError,
      );
    });
    
    test('Starting round deals 13 cards to each player', () {
      final game = CallBreakGame();
      game.initialize(['p1', 'p2', 'p3', 'p4']);
      game.startRound();
      
      for (final pid in game.playerIds) {
        expect(game.getHand(pid).length, 13);
      }
    });
    
    test('Starting round sets bidding phase', () {
      final game = CallBreakGame();
      game.initialize(['p1', 'p2', 'p3', 'p4']);
      game.startRound();
      
      expect(game.phase, CallBreakPhase.bidding);
    });
  });
  
  group('CallBreakGame - Bidding', () {
    late CallBreakGame game;
    
    setUp(() {
      game = CallBreakGame();
      game.initialize(['p1', 'p2', 'p3', 'p4']);
      game.startRound();
    });
    
    test('Current player can submit valid bid', () {
      final player = game.currentPlayerId!;
      final result = game.submitBid(player, 5);
      
      expect(result, true);
      expect(game.getBid(player), 5);
    });
    
    test('Rejects bid below minimum', () {
      final player = game.currentPlayerId!;
      final result = game.submitBid(player, 0);
      
      expect(result, false);
    });
    
    test('Rejects bid above maximum', () {
      final player = game.currentPlayerId!;
      final result = game.submitBid(player, 14);
      
      expect(result, false);
    });
    
    test('Non-current player cannot bid', () {
      final currentPlayer = game.currentPlayerId!;
      final otherPlayer = game.playerIds.firstWhere((p) => p != currentPlayer);
      
      final result = game.submitBid(otherPlayer, 5);
      expect(result, false);
    });
    
    test('Turn advances after bid', () {
      final firstPlayer = game.currentPlayerId!;
      game.submitBid(firstPlayer, 5);
      
      expect(game.currentPlayerId, isNot(firstPlayer));
    });
    
    test('Phase changes to playing after all bids', () {
      // Simply submit bids for all 4 players in turn order
      for (int i = 0; i < 4; i++) {
        final player = game.currentPlayerId!;
        game.submitBid(player, 3);
      }
      
      expect(game.phase, CallBreakPhase.playing);
      expect(game.biddingComplete, true);
    });

  });
  
  group('CallBreakGame - Card Play', () {
    late CallBreakGame game;
    
    setUp(() {
      game = CallBreakGame();
      game.initialize(['p1', 'p2', 'p3', 'p4']);
      game.startRound();
      
      // Complete bidding - 4 players each bid once
      for (int i = 0; i < 4; i++) {
        game.submitBid(game.currentPlayerId!, 3);
      }
    });
    
    test('Current player can play valid card', () {
      final player = game.currentPlayerId!;
      final hand = game.getHand(player);
      final card = hand.first;
      
      expect(game.isValidMove(player, card), true);
    });
    
    test('Playing card removes it from hand', () {
      final player = game.currentPlayerId!;
      final hand = game.getHand(player);
      final card = hand.first;
      
      game.playCard(player, card);
      
      expect(game.getHand(player).contains(card), false);
      expect(game.getHand(player).length, 12);
    });
    
    test('First card of trick - any card valid', () {
      final player = game.currentPlayerId!;
      final hand = game.getHand(player);
      
      // All cards should be valid for first play
      for (final card in hand) {
        expect(game.isValidMove(player, card), true);
      }
    });
    
    test('Turn advances after playing card', () {
      final firstPlayer = game.currentPlayerId!;
      final card = game.getHand(firstPlayer).first;
      
      game.playCard(firstPlayer, card);
      
      expect(game.currentPlayerId, isNot(firstPlayer));
    });
    
    test('Playing 4 cards completes a trick', () {
      // Play 4 cards
      for (int i = 0; i < 4; i++) {
        final player = game.currentPlayerId!;
        final validCards = game.getValidCards(player);
        game.playCard(player, validCards.first);
      }
      
      // Someone should have won a trick
      final totalTricks = game.tricksWon.values.fold(0, (a, b) => a + b);
      expect(totalTricks, 1);
    });
  });
  
  group('CallBreakGame - Follow Suit Rule', () {
    late CallBreakGame game;
    
    setUp(() {
      game = CallBreakGame();
      game.initialize(['p1', 'p2', 'p3', 'p4']);
      game.startRound();
      
      // Complete bidding - 4 players each bid once
      for (int i = 0; i < 4; i++) {
        game.submitBid(game.currentPlayerId!, 3);
      }
    });
    
    test('getValidCards returns only suit cards when must follow', () {
      // First player leads
      final leader = game.currentPlayerId!;
      final leaderHand = game.getHand(leader);
      final leadCard = leaderHand.first;
      
      game.playCard(leader, leadCard);
      
      // Next player must follow suit if possible
      final follower = game.currentPlayerId!;
      final followerHand = game.getHand(follower);
      final validCards = game.getValidCards(follower);
      
      // Check if follower has the led suit
      final hasSuit = followerHand.any((c) => c.suit == leadCard.suit);
      
      if (hasSuit) {
        // All valid cards should be of the led suit
        for (final card in validCards) {
          expect(card.suit, leadCard.suit);
        }
      } else {
        // Can play any card
        expect(validCards.length, followerHand.length);
      }
    });
  });
  
  group('CallBreakGame - Scoring', () {
    test('Making bid adds bid to score', () {
      final game = CallBreakGame();
      game.initialize(['p1', 'p2', 'p3', 'p4']);
      game.startRound();
      
      // Complete bidding with bid of 3 each
      for (int i = 0; i < 4; i++) {
        game.submitBid(game.currentPlayerId!, 3);
      }
      
      // Play 13 tricks
      for (int trick = 0; trick < 13; trick++) {
        for (int i = 0; i < 4; i++) {
          final player = game.currentPlayerId!;
          final validCards = game.getValidCards(player);
          game.playCard(player, validCards.first);
        }
      }
      
      // Check scores are set
      final scores = game.calculateScores();
      expect(scores.values.any((s) => s != 0), true);
    });
  });
  
  group('CallBreakGame - Trump (Spades)', () {
    test('Trump suit is spades', () {
      expect(CallBreakGame.trumpSuit, Suit.spades);
    });
  });
  
  group('CallBreakGame - Complete Game Flow', () {
    test('Full round plays without errors', () {
      final game = CallBreakGame();
      game.initialize(['p1', 'p2', 'p3', 'p4']);
      game.startRound();
      
      // Bidding - 4 players each bid once
      for (int i = 0; i < 4; i++) {
        game.submitBid(game.currentPlayerId!, 3);
      }
      
      expect(game.phase, CallBreakPhase.playing);
      
      // Play all 13 tricks
      for (int trick = 0; trick < 13; trick++) {
        for (int i = 0; i < 4; i++) {
          if (game.phase != CallBreakPhase.playing) break;
          final player = game.currentPlayerId!;
          final validCards = game.getValidCards(player);
          game.playCard(player, validCards.first);
        }
      }
      
      // Round should end in scoring
      expect(game.phase, CallBreakPhase.scoring);
      
      // Total tricks won should be 13
      final totalTricks = game.tricksWon.values.fold(0, (a, b) => a + b);
      expect(totalTricks, 13);
    });
  });
}
