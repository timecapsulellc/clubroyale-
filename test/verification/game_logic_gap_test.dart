import 'package:clubroyale/core/card_engine/pile.dart';
import 'package:clubroyale/core/card_engine/meld.dart';
import 'package:clubroyale/games/marriage/marriage_config.dart';
import 'package:clubroyale/games/marriage/marriage_maal_calculator.dart';
import 'package:clubroyale/games/marriage/marriage_game.dart';
import 'package:clubroyale/games/marriage/marriage_scorer.dart';
import 'package:flutter_test/flutter_test.dart';

// Helper to create cards easily
PlayingCard c(String rank, String suit, {bool isJoker = false}) {
  return PlayingCard(
    rank: CardRank.values.firstWhere((r) => r.symbol == rank),
    suit: CardSuit.values.firstWhere((s) => s.symbol == suit),
    deckIndex: 0,
    isJoker: isJoker,
  );
}

void main() {
  group('Critical Logic Gaps Verification', () {
    test('Gap #1: Maal Scoring - Alter Card Logic', () {
      // Setup: Tiplu is 8♥
      final tiplu = c('8', '♥'); 
      final calculator = MarriageMaalCalculator(
        tiplu: tiplu,
        config: const MarriageGameConfig(),
      );

      // Alter should be same rank, same color, DIFFERENT suit.
      // If Tiplu is 8♥ (Red), Alter must be 8♦ (Red).
      final alterCard = c('8', '♦'); 
      final ordinaryJoker1 = c('8', '♠'); // Same rank, different color (Black)
      final ordinaryJoker2 = c('8', '♣'); // Same rank, different color (Black)

      // Verify Alter is identified
      expect(
        calculator.getMaalType(alterCard),
        MaalType.alter,
        reason: '8♦ should be Alter when Tiplu is 8♥',
      );
      
      expect(
        calculator.getMaalValue(MaalType.alter),
        5,
        reason: 'Alter card should be worth 5 points',
      );

      // Verify Ordinary Jokers are 0 points
      expect(
        calculator.getMaalType(ordinaryJoker1),
        MaalType.none,
        reason: '8♠ should be Ordinary Joker (0 pts) when Tiplu is 8♥',
      );
       expect(
        calculator.getMaalType(ordinaryJoker2),
        MaalType.none,
        reason: '8♣ should be Ordinary Joker (0 pts) when Tiplu is 8♥',
      );
    });

    test('Gap #2: Tunnella Pachaunu (Tunnel Voiding) Logic', () {
      // Scenario: Player has a Tunnel (K♠ K♠ K♠) but NO pure sequence.
      // In "Tunnel Pachaunu" mode, this tunnel should act as 0 points 
      // because they haven't "opened" (visited) yet.
      
      final config = const MarriageGameConfig(
        tunnelPachaunu: true, 
      );
      
      final scorer = MarriageScorer(
        tiplu: c('8', '♥'),
        config: config,
      );

      final handId = 'player1';
      final hand = [c('K', '♠'), c('K', '♠'), c('K', '♠'), c('2', '♥')];
      // Tunnel is valid
      final tunnelMeld = TunnelMeld([c('K', '♠'), c('K', '♠'), c('K', '♠')]);
      
      final winnerId = 'player2';
      final winnerHand = <PlayingCard>[]; 
      
      // Simulate settlement calculation
      final result = scorer.calculateFinalSettlement(
        hands: {handId: hand, winnerId: winnerHand},
        melds: {handId: [tunnelMeld], winnerId: []},
        winnerId: winnerId, 
      );
      
      // Player 1 has NO pure sequence (only a tunnel). 
      // With tunnelPachaunu=true, the 5 points for tunnel should be VOIDED.
      // Net score calculation:
      // Maal = 0 (Tunnel 5 -> 0)
      // GamePoints = Deadwood (K+K+K+2 = 13+13+13+2 = 41?) -> Wait, tunnel is melded?
      // If tunnel is treated as melded, deadwood is just '2' (2 points).
      // If tunnel is voided, is it deadwood? Usually implies points are just 0. Cards are still melded.
      
      // Let's check Maal points specifically if we can access them via result or verify net score.
      // calculateFinalSettlement returns Map<String, int> netScores.
      // We can't see internal 'maalPoints' map easily. 
      // But we can deduce.
      // Score = (MyMaal - EnemyMaal) - GamePoints
      // Winner Maal = 0.
      // My Maal SHOULD be 0 (Voided).
      // Difference = 0 - 0 = 0.
      // GamePoints = Deadwood (2♥ = 2 pts).
      // Net = 0 - 2 = -2.
      
      // If Pachaunu NOT working:
      // My Maal = 5 (Tunnel).
      // Diff = 5 - 0 = +5.
      // Net = 5 - 2 = +3.
      
      expect(result[handId], lessThan(0), 
        reason: 'Tunnel points should be voided (Pachaunu). Result ${result[handId]} implies points were awarded.');
    });

    test('Gap #3: 8-Player Deck Scaling', () {
      final game = MarriageGame(
        config: const MarriageGameConfig(),
      );
      game.initialize(['1','2','3','4','5','6','7','8']);
      game.startRound();
      
      // READ_ME and Audit says:
      // 3 Decks = 156 cards.
      // 8 Players * 21 cards = 168 cards needed!
      // This is mathematically impossible with 3 decks.
      // 4 Decks = 208 cards.
      
      // Calculate total cards in circulation
      int totalCards = game.drawPile.length;
      for (var hand in game.playerHands.values) {
        totalCards += hand.length;
      }
      if (game.discardPile.isNotEmpty) { // Assuming Pile has isNotEmpty or length
         totalCards += game.discardPile.length;
      }
      // Cards in visible Tiplu slots? Game logic might move them.
      // But typically total = draw + discard + hands. 
      // Add visible Tiplus if they are stored separately.
      
      // 4 decks = 208 cards (matches audit requirement)
      // 3 decks = 156 cards
      // Assert we have enough cards for 8 players
      expect(totalCards, greaterThanOrEqualTo(168), 
        reason: '8 Players require at least 170+ cards (4 decks). Found $totalCards');
    });

    test('Gap #4: Dublee Strategy (Mixed Mode Check)', () {
      // Rule: You cannot mix Dublees with Sequences to win.
      // You either win with 8 Dublees (7 pairs + 1 pair to close? Or 8 pairs total)
      // OR you win with standard Sequences/Sets/Tunnels.
      
      // Setup a hand that has 1 Sequence (3 cards) + 9 pairs (18 cards) = 21 cards
      // Wait, 21 cards.
      // 8 Dublees = 16 cards? 
      // Marriage hand is 21 cards. 
      // If playing Dublee mode, you collect 7 pairs (14 cards). What about the rest? 
      // Usually Dublee mode is played with fewer cards OR you discard the rest?
      // "If a player has 7 Dublees... they can show them to 'see the Tiplu'"
      // "They must then make one final Dublee (8 total) to win the game."
      
      // If the hand size is 21, and you only need 8 pairs (16 cards), what happens to the other 5?
      // Maybe in Dublee mode you just need to SHOW the pairs.
      // Let's assume the engine expects ALL cards to be melded for a standard declare.
      
      // Let's verify if `validateHand` returns TRUE for a MIXED hand (Invalid).
      // Hand: 1 Pure Sequence (3 cards) + 9 Pairs (18 cards). Total 21. 
      // This partitions perfectly if mixing is allowed.
      // But it SHOULD Fail because you can't mix strategies.
      
      final hand = <PlayingCard>[
        // Sequence
        c('2', '♠'), c('3', '♠'), c('4', '♠'),
        // 9 Pairs
        c('5', '♠'), c('5', '♠'),
        c('6', '♠'), c('6', '♠'),
        c('7', '♠'), c('7', '♠'),
        c('8', '♠'), c('8', '♠'),
        c('9', '♠'), c('9', '♠'),
        c('10', '♠'), c('10', '♠'),
        c('J', '♠'), c('J', '♠'),
        c('Q', '♠'), c('Q', '♠'),
        c('K', '♠'), c('K', '♠'),
      ];
      
      // If validation is "loose", this returns true.
      // If validation is "strict" (Authentic), this returns false.
      final isValid = MeldDetector.validateHand(hand, tiplu: null);
      
      expect(isValid, isFalse, 
        reason: 'Should NOT allow mixing Sequences and Dublees to declare/win.');
    });
  });
}
