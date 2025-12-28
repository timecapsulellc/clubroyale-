import 'package:flutter_test/flutter_test.dart';
import 'package:clubroyale/core/card_engine/card_engine.dart';
import 'package:clubroyale/features/game/models/game_state.dart';
import 'package:clubroyale/features/game/logic/call_break_logic.dart';
import 'package:clubroyale/features/game/services/card_validation_service.dart';

void main() {
  group('Call Break Simulation', () {
    test('Simulate full round with 4 bots', () {
      // 1. Setup Players
      final playerIds = ['P1', 'P2', 'P3', 'P4'];
      
      // 2. Deal Cards using new Deck API
      final deck = Deck();
      deck.reset();
      deck.shuffle();
      
      final hands = <String, List<PlayingCard>>{};
      for (var playerId in playerIds) {
        hands[playerId] = deck.drawCards(13);
      }
      
      expect(hands.length, 4);
      expect(hands['P1']!.length, 13);
      expect(deck.length, 0); // All cards dealt
      
      // 3. Bidding Phase
      final bids = <String, int>{};
      for (var playerId in playerIds) {
        final hand = hands[playerId]!;
        final suggestedBid = CardValidationService.suggestBid(hand);
        bids[playerId] = suggestedBid;
      }
      
      // 4. Playing Phase
      final tricksWon = {for (var id in playerIds) id: 0};
      String currentTurn = playerIds[0];
      
      for (int trickNum = 1; trickNum <= 13; trickNum++) {
        final currentTrickCards = <PlayedCard>[];
        Trick? currentTrick;
        
        // Each player plays a card
        for (int i = 0; i < 4; i++) {
          final hand = hands[currentTurn]!;
          
          // Bot logic: get valid cards and play first
          final validCards = CardValidationService.getValidCards(hand, currentTrick);
          final cardToPlay = validCards.first;
          
          // Remove from hand
          hand.remove(cardToPlay);
          
          // Add to trick
          final playedCard = PlayedCard(playerId: currentTurn, card: cardToPlay);
          currentTrickCards.add(playedCard);
          
          if (currentTrick == null) {
            currentTrick = Trick(ledSuit: cardToPlay.suit, cards: [playedCard]);
          } else {
            currentTrick = currentTrick.copyWith(
              cards: [...currentTrick.cards, playedCard],
            );
          }
          
          // Next player
          currentTurn = CallBreakLogic.getNextPlayer(playerIds, currentTurn);
        }
        
        // Determine winner
        final winnerId = CallBreakLogic.determineTrickWinner(currentTrick!);
        tricksWon[winnerId] = (tricksWon[winnerId] ?? 0) + 1;
        currentTurn = winnerId;
      }
      
      // 5. Scoring Phase
      final scores = CallBreakLogic.calculateRoundScores(
        bids: bids,
        tricksWon: tricksWon,
        pointValue: 10.0,
      );
      
      // Verification
      expect(tricksWon.values.reduce((a, b) => a + b), 13, reason: 'Total tricks must be 13');
      expect(scores.length, 4);
      
      // Verify score calculation logic for P1
      final p1Bid = bids['P1']!;
      final p1Won = tricksWon['P1']!;
      final p1Score = scores['P1']!;
      
      if (p1Won >= p1Bid) {
        final expected = (p1Bid + (p1Won - p1Bid) * 0.1) * 10.0;
        expect(p1Score, closeTo(expected, 0.01));
      } else {
        final expected = -(p1Bid * 10.0);
        expect(p1Score, closeTo(expected, 0.01));
      }
    });
  });
}
