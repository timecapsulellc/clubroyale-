/// Comprehensive Marriage Game Integration Tests
///
/// Tests cover:
/// - Game initialization (2-8 players)
/// - Dealing mechanics
/// - Gameplay flow (draw, discard, turn rotation)
/// - Meld detection
/// - Declare validation
/// - Scoring
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:clubroyale/games/marriage/marriage_game.dart';
import 'package:clubroyale/core/card_engine/card_engine.dart'; // Unified import

void main() {
  group('Marriage Game - Multi-Player Tests', () {
    // =========================================
    // INITIALIZATION TESTS (2-8 Players)
    // =========================================

    group('Initialization', () {
      test('2 players - minimum', () {
        final game = MarriageGame();
        game.initialize(['p1', 'p2']);
        game.startRound();

        expect(game.playerIds.length, 2);
        expect(game.getHand('p1').length, 21);
        expect(game.getHand('p2').length, 21);
        expect(game.deckCount, 3); // 2-5 players use 3 decks
        expect(game.tiplu, isNotNull);
      });

      test('4 players', () {
        final game = MarriageGame();
        game.initialize(['p1', 'p2', 'p3', 'p4']);
        game.startRound();

        expect(game.playerIds.length, 4);
        for (final pid in game.playerIds) {
          expect(game.getHand(pid).length, 21);
        }
        expect(game.deckCount, 3);
      });

      test('5 players - threshold', () {
        final game = MarriageGame();
        game.initialize(['p1', 'p2', 'p3', 'p4', 'p5']);
        game.startRound();

        expect(game.playerIds.length, 5);
        expect(game.deckCount, 3); // Still 3 decks at 5 players
      });

      test('6 players - switches to 4 decks', () {
        final game = MarriageGame();
        game.initialize(['p1', 'p2', 'p3', 'p4', 'p5', 'p6']);
        game.startRound();

        expect(game.playerIds.length, 6);
        expect(game.deckCount, 4); // 6+ players use 4 decks
        for (final pid in game.playerIds) {
          expect(game.getHand(pid).length, 21);
        }
      });

      test('8 players - maximum', () {
        final game = MarriageGame();
        game.initialize(['p1', 'p2', 'p3', 'p4', 'p5', 'p6', 'p7', 'p8']);
        game.startRound();

        expect(game.playerIds.length, 8);
        expect(game.deckCount, 4);
        for (final pid in game.playerIds) {
          expect(
            game.getHand(pid).length,
            21,
            reason: 'Player $pid should have 21 cards',
          );
        }
        expect(game.tiplu, isNotNull);
        expect(game.topDiscard, isNotNull);
      });

      test('Rejects less than 2 players', () {
        final game = MarriageGame();
        expect(() => game.initialize(['p1']), throwsArgumentError);
      });

      test('Rejects more than 8 players', () {
        final game = MarriageGame();
        expect(
          () => game.initialize([
            'p1',
            'p2',
            'p3',
            'p4',
            'p5',
            'p6',
            'p7',
            'p8',
            'p9',
          ]),
          throwsArgumentError,
        );
      });
    });

    // =========================================
    // GAMEPLAY MECHANICS TESTS
    // =========================================

    group('Gameplay Mechanics', () {
      late MarriageGame game;

      setUp(() {
        game = MarriageGame();
        game.initialize(['p1', 'p2', 'p3', 'p4']);
        game.startRound();
      });

      test('Turn rotation works correctly', () {
        final firstPlayer = game.currentPlayerId;
        expect(firstPlayer, isNotNull);

        // Play a card to advance turn
        final card = game.getHand(firstPlayer!).first;
        game.playCard(firstPlayer, card);

        final secondPlayer = game.currentPlayerId;
        expect(secondPlayer, isNot(firstPlayer));

        // Continue rotation
        final card2 = game.getHand(secondPlayer!).first;
        game.playCard(secondPlayer, card2);

        final thirdPlayer = game.currentPlayerId;
        expect(thirdPlayer, isNot(secondPlayer));
        expect(thirdPlayer, isNot(firstPlayer));
      });

      test('Discard adds card to pile', () {
        final player = game.currentPlayerId!;
        final card = game.getHand(player).first;

        game.playCard(player, card);

        expect(game.topDiscard, equals(card));
      });

      test('Draw from deck adds card to hand', () {
        final player = game.currentPlayerId!;
        final initialCount = game.getHand(player).length;
        final initialDeckSize = game.cardsRemaining;

        game.drawFromDeck(player);

        expect(game.getHand(player).length, initialCount + 1);
        expect(game.cardsRemaining, initialDeckSize - 1);
      });

      test('Draw from discard adds correct card', () {
        final player = game.currentPlayerId!;
        final discardCard = game.topDiscard;

        // Wild cards cannot be picked from discard per Marriage rules
        if (discardCard != null && discardCard.rank != game.tiplu?.rank) {
          game.drawFromDiscard(player);
          expect(game.getHand(player).contains(discardCard), true);
        } else {
          // If discard is wild, just draw from deck instead
          final initialSize = game.getHand(player).length;
          game.drawFromDeck(player);
          expect(game.getHand(player).length, initialSize + 1);
        }
      });

      test('Cannot play out of turn', () {
        final currentPlayer = game.currentPlayerId!;
        final otherPlayer = game.playerIds.firstWhere(
          (p) => p != currentPlayer,
        );
        final card = game.getHand(otherPlayer).first;

        expect(
          () => game.playCard(otherPlayer, card),
          throwsA(isA<StateError>()),
        );
      });

      test('Cannot play card not in hand', () {
        final player = game.currentPlayerId!;
        final otherPlayer = game.playerIds.firstWhere((p) => p != player);
        final otherCard = game.getHand(otherPlayer).first;

        expect(
          () => game.playCard(player, otherCard),
          throwsA(isA<StateError>()),
        );
      });
    });

    // =========================================
    // MELD DETECTION TESTS
    // =========================================

    group('Meld Detection', () {
      test('Detects valid Set (3 of same rank)', () {
        final cards = <PlayingCard>[
          PlayingCard(
            suit: CardSuit.hearts,
            rank: CardRank.queen,
            deckIndex: 0,
          ),
          PlayingCard(
            suit: CardSuit.diamonds,
            rank: CardRank.queen,
            deckIndex: 0,
          ),
          PlayingCard(
            suit: CardSuit.spades,
            rank: CardRank.queen,
            deckIndex: 0,
          ),
        ];

        final sets = MeldDetector.findSets(cards);
        expect(sets.length, greaterThanOrEqualTo(1));
        expect(sets.first.isValid, true);
      });

      test('Detects valid Run (3 consecutive same suit)', () {
        final cards = <PlayingCard>[
          PlayingCard(suit: CardSuit.hearts, rank: CardRank.four, deckIndex: 0),
          PlayingCard(suit: CardSuit.hearts, rank: CardRank.five, deckIndex: 0),
          PlayingCard(suit: CardSuit.hearts, rank: CardRank.six, deckIndex: 0),
        ];

        final runs = MeldDetector.findRuns(cards);
        expect(runs.length, greaterThanOrEqualTo(1));
        expect(runs.first.isValid, true);
      });

      test('Detects valid Tunnel (3 identical from different decks)', () {
        final cards = <PlayingCard>[
          PlayingCard(
            suit: CardSuit.hearts,
            rank: CardRank.king,
            deckIndex: 0,
          ), // Deck 0
          PlayingCard(
            suit: CardSuit.hearts,
            rank: CardRank.king,
            deckIndex: 1,
          ), // Deck 1
          PlayingCard(
            suit: CardSuit.hearts,
            rank: CardRank.king,
            deckIndex: 2,
          ), // Deck 2
        ];

        final tunnels = MeldDetector.findTunnels(cards);
        expect(tunnels.length, greaterThanOrEqualTo(1));
        expect(tunnels.first.isValid, true);
      });

      test('findAllMelds finds multiple meld types', () {
        final cards = <PlayingCard>[
          // A set of Jacks
          PlayingCard(suit: CardSuit.hearts, rank: CardRank.jack, deckIndex: 0),
          PlayingCard(
            suit: CardSuit.diamonds,
            rank: CardRank.jack,
            deckIndex: 0,
          ),
          PlayingCard(suit: CardSuit.spades, rank: CardRank.jack, deckIndex: 0),
          // A run in clubs
          PlayingCard(suit: CardSuit.clubs, rank: CardRank.seven, deckIndex: 0),
          PlayingCard(suit: CardSuit.clubs, rank: CardRank.eight, deckIndex: 0),
          PlayingCard(suit: CardSuit.clubs, rank: CardRank.nine, deckIndex: 0),
        ];

        final melds = MeldDetector.findAllMelds(cards);
        expect(melds.length, greaterThanOrEqualTo(2));
      });
    });

    // =========================================
    // DECLARE VALIDATION TESTS
    // =========================================

    group('Declare Validation', () {
      test('Random hand cannot declare (invalid)', () {
        final game = MarriageGame();
        game.initialize(['p1', 'p2']);
        game.startRound();

        final player = game.currentPlayerId!;
        final result = game.declare(player);

        // Random hands are very unlikely to be valid
        expect(result, false);
        expect(game.getRoundWinner(), isNull);
      });

      test('Cannot declare out of turn', () {
        final game = MarriageGame();
        game.initialize(['p1', 'p2']);
        game.startRound();

        final currentPlayer = game.currentPlayerId!;
        final otherPlayer = game.playerIds.firstWhere(
          (p) => p != currentPlayer,
        );

        final result = game.declare(otherPlayer);
        expect(result, false);
      });

      test('validateHand rejects incomplete partition', () {
        // Hand that has some melds but not complete partition
        final partialHand = <PlayingCard>[
          // One valid set
          PlayingCard(suit: CardSuit.hearts, rank: CardRank.ace, deckIndex: 0),
          PlayingCard(
            suit: CardSuit.diamonds,
            rank: CardRank.ace,
            deckIndex: 0,
          ),
          PlayingCard(suit: CardSuit.spades, rank: CardRank.ace, deckIndex: 0),
          // Some random cards that don't form melds
          PlayingCard(suit: CardSuit.hearts, rank: CardRank.two, deckIndex: 0),
          PlayingCard(suit: CardSuit.clubs, rank: CardRank.seven, deckIndex: 0),
          PlayingCard(
            suit: CardSuit.diamonds,
            rank: CardRank.ten,
            deckIndex: 0,
          ),
        ];

        final isValid = MeldDetector.validateHand(partialHand);
        expect(isValid, false);
      });

      test('validateHand accepts perfect 6-card partition (2 melds)', () {
        // Perfect hand with exactly 2 melds covering 6 cards
        final perfectHand = <PlayingCard>[
          // Set 1: Three 5s
          PlayingCard(suit: CardSuit.hearts, rank: CardRank.five, deckIndex: 0),
          PlayingCard(
            suit: CardSuit.diamonds,
            rank: CardRank.five,
            deckIndex: 0,
          ),
          PlayingCard(suit: CardSuit.spades, rank: CardRank.five, deckIndex: 0),
          // Set 2: Three 9s
          PlayingCard(suit: CardSuit.hearts, rank: CardRank.nine, deckIndex: 0),
          PlayingCard(
            suit: CardSuit.diamonds,
            rank: CardRank.nine,
            deckIndex: 0,
          ),
          PlayingCard(suit: CardSuit.clubs, rank: CardRank.nine, deckIndex: 0),
        ];

        final isValid = MeldDetector.validateHand(perfectHand);
        expect(isValid, true);
      });

      test('validateHand accepts perfect 9-card partition (3 melds)', () {
        final perfectHand = <PlayingCard>[
          // Run 1: 2-3-4 of hearts
          PlayingCard(suit: CardSuit.hearts, rank: CardRank.two, deckIndex: 0),
          PlayingCard(
            suit: CardSuit.hearts,
            rank: CardRank.three,
            deckIndex: 0,
          ),
          PlayingCard(suit: CardSuit.hearts, rank: CardRank.four, deckIndex: 0),
          // Set: Three Kings
          PlayingCard(
            suit: CardSuit.diamonds,
            rank: CardRank.king,
            deckIndex: 0,
          ),
          PlayingCard(suit: CardSuit.spades, rank: CardRank.king, deckIndex: 0),
          PlayingCard(suit: CardSuit.clubs, rank: CardRank.king, deckIndex: 0),
          // Run 2: 7-8-9 of spades
          PlayingCard(
            suit: CardSuit.spades,
            rank: CardRank.seven,
            deckIndex: 0,
          ),
          PlayingCard(
            suit: CardSuit.spades,
            rank: CardRank.eight,
            deckIndex: 0,
          ),
          PlayingCard(suit: CardSuit.spades, rank: CardRank.nine, deckIndex: 0),
        ];

        final isValid = MeldDetector.validateHand(perfectHand);
        expect(isValid, true);
      });
    });

    // =========================================
    // SCORING TESTS
    // =========================================

    group('Scoring', () {
      test('Scores start at zero', () {
        final game = MarriageGame();
        game.initialize(['p1', 'p2', 'p3']);
        game.startRound();

        final scores = game.calculateScores();
        for (final pid in game.playerIds) {
          expect(scores[pid], 0);
        }
      });
    });

    // =========================================
    // 8-PLAYER STRESS TESTS
    // =========================================

    group('8-Player Stress Tests', () {
      test('Full round simulation with 8 players', () {
        final game = MarriageGame();
        final players = List.generate(8, (i) => 'player_$i');
        game.initialize(players);
        game.startRound();

        // Verify setup
        expect(game.playerIds.length, 8);
        expect(game.deckCount, 4);

        // Total cards dealt: 8 * 21 = 168 cards
        // Plus tiplu (1) + discard (1) = 170 cards used
        // 4 decks = 52*4 + jokers = 208+ cards, so plenty remain
        expect(game.cardsRemaining, greaterThan(0));

        // Simulate 10 rounds of draw-discard for each player
        for (int round = 0; round < 10; round++) {
          final player = game.currentPlayerId!;

          // Draw a card
          game.drawFromDeck(player);
          expect(game.getHand(player).length, 22);

          // Discard a card
          final cardToDiscard = game.getHand(player).first;
          game.playCard(player, cardToDiscard);
          expect(game.getHand(player).length, 21);
        }

        // Verify all players still have 21 cards
        for (final pid in players) {
          expect(game.getHand(pid).length, 21);
        }
      });

      test('8-player deck has enough cards', () {
        final game = MarriageGame();
        final players = List.generate(8, (i) => 'player_$i');
        game.initialize(players);
        game.startRound();

        // 8 players * 21 cards = 168 cards dealt
        // 4 decks * 52 = 208 standard cards + jokers
        // Should have at least 30 cards remaining
        expect(game.cardsRemaining, greaterThanOrEqualTo(30));
      });

      test('All 8 players can attempt declare (all should fail)', () {
        final game = MarriageGame();
        final players = List.generate(8, (i) => 'player_$i');
        game.initialize(players);
        game.startRound();

        // Each player's random hand should NOT be valid for declare
        for (int i = 0; i < 8; i++) {
          final player = game.currentPlayerId!;
          final result = game.declare(player);

          // Random hands should fail declare
          expect(
            result,
            false,
            reason: 'Player $player should not win with random hand',
          );

          // Advance turn by playing a card
          if (i < 7) {
            game.drawFromDeck(player);
            game.playCard(player, game.getHand(player).first);
          }
        }
      });
    });

    // =========================================
    // COMPLETE GAME FLOW SIMULATION
    // =========================================

    group('Complete Game Flow', () {
      test('Full game flow: 4 players, multiple turns', () {
        final game = MarriageGame();
        game.initialize(['Alice', 'Bob', 'Charlie', 'Diana']);
        game.startRound();

        // Simulate 20 turns (5 per player)
        for (int turn = 0; turn < 20; turn++) {
          final player = game.currentPlayerId!;

          // Alternate between drawing from deck and discard
          // Note: Wild cards cannot be picked from discard per Marriage rules
          final topDiscard = game.topDiscard;
          final tiplu = game.tiplu;
          final isDiscardWild =
              topDiscard != null &&
              tiplu != null &&
              topDiscard.rank == tiplu.rank;
          final canDrawFromDiscard = topDiscard != null && !isDiscardWild;
          if (turn % 2 == 0 || !canDrawFromDiscard) {
            game.drawFromDeck(player);
          } else {
            // Additional safety: fall back to deck if discard draw fails
            try {
              game.drawFromDiscard(player);
            } catch (e) {
              game.drawFromDeck(player);
            }
          }

          // Discard a random card
          final hand = game.getHand(player);
          final cardToDiscard = hand[turn % hand.length];
          game.playCard(player, cardToDiscard);

          // Verify hand size is back to 21
          expect(game.getHand(player).length, 21);
        }

        // All players should still have 21 cards
        expect(game.getHand('Alice').length, 21);
        expect(game.getHand('Bob').length, 21);
        expect(game.getHand('Charlie').length, 21);
        expect(game.getHand('Diana').length, 21);
      });
    });
  });
}
