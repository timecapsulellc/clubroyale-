import 'package:flutter_test/flutter_test.dart';
import 'package:clubroyale/features/game/engine/models/card.dart';
import 'package:clubroyale/features/game/logic/call_break_logic.dart';
import 'package:clubroyale/features/game/models/game_state.dart';

void main() {
  group('CallBreakLogic', () {
    group('determineTrickWinner', () {
      test('highest card of led suit wins when no trump played', () {
        final trick = Trick(
          ledSuit: CardSuit.hearts,
          cards: [
            PlayedCard(
              playerId: 'p1',
              card: const PlayingCard(suit: CardSuit.hearts, rank: CardRank.five),
            ),
            PlayedCard(
              playerId: 'p2',
              card: const PlayingCard(suit: CardSuit.hearts, rank: CardRank.ace),
            ),
            PlayedCard(
              playerId: 'p3',
              card: const PlayingCard(suit: CardSuit.hearts, rank: CardRank.king),
            ),
            PlayedCard(
              playerId: 'p4',
              card: const PlayingCard(suit: CardSuit.clubs, rank: CardRank.two),
            ),
          ],
        );

        final winner = CallBreakLogic.determineTrickWinner(trick);
        expect(winner, 'p2'); // Ace of Hearts wins
      });

      test('trump card wins over led suit', () {
        final trick = Trick(
          ledSuit: CardSuit.hearts,
          cards: [
            PlayedCard(
              playerId: 'p1',
              card: const PlayingCard(suit: CardSuit.hearts, rank: CardRank.ace),
            ),
            PlayedCard(
              playerId: 'p2',
              card: const PlayingCard(suit: CardSuit.spades, rank: CardRank.two), // Trump
            ),
            PlayedCard(
              playerId: 'p3',
              card: const PlayingCard(suit: CardSuit.hearts, rank: CardRank.king),
            ),
            PlayedCard(
              playerId: 'p4',
              card: const PlayingCard(suit: CardSuit.diamonds, rank: CardRank.ace),
            ),
          ],
        );

        final winner = CallBreakLogic.determineTrickWinner(trick);
        expect(winner, 'p2'); // 2 of Spades (trump) wins over Ace of Hearts
      });

      test('highest trump wins if multiple trumps played', () {
        final trick = Trick(
          ledSuit: CardSuit.hearts,
          cards: [
            PlayedCard(
              playerId: 'p1',
              card: const PlayingCard(suit: CardSuit.hearts, rank: CardRank.ace),
            ),
            PlayedCard(
              playerId: 'p2',
              card: const PlayingCard(suit: CardSuit.spades, rank: CardRank.five),
            ),
            PlayedCard(
              playerId: 'p3',
              card: const PlayingCard(suit: CardSuit.spades, rank: CardRank.jack),
            ),
            PlayedCard(
              playerId: 'p4',
              card: const PlayingCard(suit: CardSuit.spades, rank: CardRank.two),
            ),
          ],
        );

        final winner = CallBreakLogic.determineTrickWinner(trick);
        expect(winner, 'p3'); // Jack of Spades wins
      });
    });

    group('calculateRoundScores', () {
      test('calculates positive scores for meeting bid', () {
        final bids = {'p1': 3};
        final tricksWon = {'p1': 4}; // Won 4, bid 3 (1 extra)

        final scores = CallBreakLogic.calculateRoundScores(
          bids: bids,
          tricksWon: tricksWon,
          pointValue: 1.0,
        );

        // Score = (Bid + (Extra * 0.1)) * pointValue
        // (3 + 0.1) * 1.0 = 3.1
        expect(scores['p1'], 3.1);
      });

      test('calculates negative scores for failing bid', () {
        final bids = {'p1': 4};
        final tricksWon = {'p1': 3}; // Won 3, bid 4 (failed)

        final scores = CallBreakLogic.calculateRoundScores(
          bids: bids,
          tricksWon: tricksWon,
          pointValue: 1.0,
        );

        // Score = -Bid * pointValue
        expect(scores['p1'], -4.0);
      });

      test('calculates exact bid score', () {
        final bids = {'p1': 5};
        final tricksWon = {'p1': 5};

        final scores = CallBreakLogic.calculateRoundScores(
          bids: bids,
          tricksWon: tricksWon,
          pointValue: 1.0,
        );

        expect(scores['p1'], 5.0);
      });
    });
  });
}
