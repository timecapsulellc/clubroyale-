import 'package:flutter_test/flutter_test.dart';
import 'package:clubroyale/features/game/engine/models/card.dart';
import 'package:clubroyale/features/game/engine/models/deck.dart';
import 'package:clubroyale/features/game/models/game_state.dart';
import 'package:clubroyale/features/game/logic/call_break_logic.dart';
import 'package:clubroyale/features/game/services/card_validation_service.dart';

void main() {
  group('Call Break Simulation', () {
    test('Simulate full round with 4 bots', () {
      // 1. Setup Players
      final playerIds = ['P1', 'P2', 'P3', 'P4'];
      
      // 2. Deal Cards
      final hands = Deck.dealHands(playerIds);
      expect(hands.length, 4);
      expect(hands['P1']!.length, 13);
      
      // 3. Bidding Phase
      final bids = <String, int>{};
      for (var playerId in playerIds) {
        // Simple bot: bid based on high cards
        final hand = hands[playerId]!;
        final suggestedBid = CardValidationService.suggestBid(hand);
        bids[playerId] = suggestedBid;
        print('Player $playerId bids $suggestedBid');
      }
      
      // 4. Playing Phase
      final tricksWon = {for (var id in playerIds) id: 0};
      String currentTurn = playerIds[0]; // P1 starts
      
      for (int trickNum = 1; trickNum <= 13; trickNum++) {
        print('\n--- Trick $trickNum ---');
        final currentTrickCards = <PlayedCard>[];
        Trick? currentTrick; // Helper to track state within trick
        
        // Each player plays a card
        for (int i = 0; i < 4; i++) {
          final hand = hands[currentTurn]!;
          
          // Bot logic: pick first valid card
          // In a real simulation, this would be smarter
          final validCards = CardValidationService.getValidCards(hand, currentTrick);
          
          // Simple strategy: try to win if we have high card, otherwise dump low
          // For now, just pick random valid card to ensure rules are followed
          final cardToPlay = validCards.first;
          
          print('$currentTurn plays $cardToPlay');
          
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
        print('Winner: $winnerId');
        
        tricksWon[winnerId] = (tricksWon[winnerId] ?? 0) + 1;
        currentTurn = winnerId; // Winner leads next trick
      }
      
      // 5. Scoring Phase
      print('\n--- Round Results ---');
      print('Bids: $bids');
      print('Tricks Won: $tricksWon');
      
      final scores = CallBreakLogic.calculateRoundScores(
        bids: bids,
        tricksWon: tricksWon,
        pointValue: 10.0,
      );
      
      print('Scores: $scores');
      
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
