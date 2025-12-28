import 'package:flutter_test/flutter_test.dart';
import 'package:clubroyale/games/call_break/call_break_game.dart';
import 'package:clubroyale/games/teen_patti/teen_patti_game.dart';
import 'package:clubroyale/games/in_between/in_between_game.dart';
import 'package:clubroyale/features/agents/models/bot_personality.dart';

/// Bot Integration Tests
/// 
/// Tests for bot integration across all games
void main() {
  group('BotPersonality System', () {
    test('All personality types exist', () {
      expect(BotPersonalityType.values.length, equals(8));
    });

    test('Can get random personality', () {
      final personality = BotPersonality.getRandom();
      expect(personality, isNotNull);
      expect(personality.name, isNotEmpty);
    });

    test('Personality has valid trait values', () {
      final personality = BotPersonality.getRandom();
      expect(personality.aggression, inInclusiveRange(0.0, 1.0));
      expect(personality.bluffRate, inInclusiveRange(0.0, 1.0));
      expect(personality.riskTolerance, inInclusiveRange(0.0, 1.0));
      expect(personality.patience, inInclusiveRange(0.0, 1.0));
    });

    test('Personality generates reactions', () {
      final personality = BotPersonality.all.first;
      final winReaction = personality.getReaction('win');
      expect(winReaction, isNotEmpty);
      expect(winReaction, contains(personality.avatarEmoji));
      
      final loseReaction = personality.getReaction('lose');
      expect(loseReaction, isNotEmpty);
    });

    test('Can filter by personality type', () {
      final cautious = BotPersonality.all.where((p) => p.type == BotPersonalityType.cautious).toList();
      expect(cautious.length, greaterThan(0));
      for (final p in cautious) {
        expect(p.type, equals(BotPersonalityType.cautious));
      }
    });
  });

  group('Call Break Game Bot Integration', () {
    test('CallBreakGame initializes correctly', () {
      final game = CallBreakGame();
      game.initialize(['p1', 'p2', 'p3', 'p4']);
      expect(game.minPlayers, equals(4));
      expect(game.maxPlayers, equals(4));
    });

    test('Bot can bid when it is their turn', () {
      final game = CallBreakGame();
      game.initialize(['bot_1', 'p2', 'p3', 'p4']);
      game.dealCards();
      // Game should be in bidding phase
      expect(game.currentPlayerId, isNotNull);
    });
  });

  group('Teen Patti Game Bot Integration', () {
    test('TeenPattiGame initializes correctly', () {
      final game = TeenPattiGame();
      game.initialize(['p1', 'p2', 'p3']);
      expect(game.minPlayers, equals(3));
    });

    test('Bot personality affects betting decisions', () {
      // Aggressive personality should bet more
      final aggressive = BotPersonality.all.firstWhere((p) => p.type == BotPersonalityType.aggressive);
      final cautious = BotPersonality.all.firstWhere((p) => p.type == BotPersonalityType.cautious);
      
      expect(aggressive.aggression, greaterThan(cautious.aggression));
      expect(aggressive.bluffRate, greaterThan(cautious.bluffRate));
    });
  });

  group('In-Between Game Bot Integration', () {
    test('InBetweenGame initializes correctly', () {
      final game = InBetweenGame();
      game.initialize(['p1', 'p2']);
      expect(game.minPlayers, equals(2));
    });

    test('Bot risk tolerance affects betting', () {
      final highRoller = BotPersonality.all.firstWhere((p) => p.type == BotPersonalityType.highRoller);
      final analytical = BotPersonality.all.firstWhere((p) => p.type == BotPersonalityType.analytical);
      
      expect(highRoller.riskTolerance, greaterThan(analytical.riskTolerance));
    });

    test('Win probability calculation is valid', () {
      final game = InBetweenGame();
      game.initialize(['p1', 'p2']); // Need 2 players minimum
      game.startRound();
      
      final probability = game.getWinProbability();
      expect(probability, inInclusiveRange(0.0, 1.0));
    });
  });

  group('Personality Consistency', () {
    test('All predefined personalities have unique IDs', () {
      final ids = BotPersonality.all.map((p) => p.id).toSet();
      expect(ids.length, equals(BotPersonality.all.length));
    });

    test('All personalities have valid catchphrases', () {
      for (final p in BotPersonality.all) {
        expect(p.catchphrase, isNotEmpty);
        expect(p.avatarEmoji, isNotEmpty);
      }
    });
  });
}
