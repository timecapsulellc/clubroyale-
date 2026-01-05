
import 'package:flutter_test/flutter_test.dart';
import 'package:clubroyale/features/game/game_config.dart';
import 'package:clubroyale/games/marriage/marriage_config.dart';

void main() {
  group('Variant Config Bridge Verification', () {
    test('Should correctly bridge GameConfig variants to MarriageGameConfig', () {
      // 1. Simulate data coming from Lobby (GameConfig with variants map)
      const lobbyConfig = GameConfig(
        pointValue: 10.0,
        totalRounds: 5,
        variants: {
          'tunnelPachaunu': true,
          'enableKidnap': false,
          'enableMurder': true,
        },
      );

      // 2. Simulate _startGame logic in RoomWaitingScreen
      final variants = lobbyConfig.variants;
      final marriageConfig = MarriageGameConfig(
        tunnelPachaunu: variants['tunnelPachaunu'] as bool? ?? false,
        enableKidnap: variants['enableKidnap'] as bool? ?? true,
        enableMurder: variants['enableMurder'] as bool? ?? false,
      );

      // 3. Verify mappings
      expect(marriageConfig.tunnelPachaunu, isTrue, reason: "Tunnel Pachaunu should be enabled");
      expect(marriageConfig.enableKidnap, isFalse, reason: "Kidnap should be disabled");
      expect(marriageConfig.enableMurder, isTrue, reason: "Murder should be enabled");
    });

    test('Should fallback to defaults when variants are missing', () {
      // 1. Simulate default GameConfig (empty variants)
      const lobbyConfig = GameConfig(
        pointValue: 10.0,
        totalRounds: 5,
        variants: {},
      );

      // 2. Simulate _startGame logic
      final variants = lobbyConfig.variants;
      final marriageConfig = MarriageGameConfig(
        tunnelPachaunu: variants['tunnelPachaunu'] as bool? ?? false,
        enableKidnap: variants['enableKidnap'] as bool? ?? true,
        enableMurder: variants['enableMurder'] as bool? ?? false,
      );

      // 3. Verify defaults
      expect(marriageConfig.tunnelPachaunu, isFalse, reason: "Default Tunnel Pachaunu should be false");
      expect(marriageConfig.enableKidnap, isTrue, reason: "Default Kidnap should be true");
      expect(marriageConfig.enableMurder, isFalse, reason: "Default Murder should be false");
    });
  });
}
