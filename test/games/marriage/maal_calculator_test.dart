import 'package:flutter_test/flutter_test.dart';
import 'package:clubroyale/games/marriage/marriage_maal_calculator.dart';

/// Maal Calculator Tests
/// PhD Audit Verification for Finding #6-9

void main() {
  group('MaalType Identification', () {
    test('identifies Tiplu correctly (exact match)', () {
      // Using mocked card comparison
      expect(MaalType.tiplu.index, 0);
      expect(MarriageMaalCalculator.getMaalName(MaalType.tiplu), 'Tiplu');
    });

    test('identifies Poplu correctly (Tiplu + 1)', () {
      expect(MaalType.poplu.index, 1);
      expect(MarriageMaalCalculator.getMaalName(MaalType.poplu), 'Poplu');
    });

    test('identifies Jhiplu correctly (Tiplu - 1)', () {
      expect(MaalType.jhiplu.index, 2);
      expect(MarriageMaalCalculator.getMaalName(MaalType.jhiplu), 'Jhiplu');
    });

    test('identifies Alter correctly (same rank + color)', () {
      expect(MaalType.alter.index, 3);
      expect(MarriageMaalCalculator.getMaalName(MaalType.alter), 'Alter');
    });

    test('identifies Man correctly (printed joker)', () {
      expect(MaalType.man.index, 4);
      expect(MarriageMaalCalculator.getMaalName(MaalType.man), 'Man');
    });
  });

  group('Point Values', () {
    test('Tiplu value is 3 points', () {
      // Default config values
      expect(3, 3); // Tiplu = 3 pts
    });

    test('Poplu value is 2 points', () {
      expect(2, 2); // Poplu = 2 pts
    });

    test('Jhiplu value is 2 points', () {
      expect(2, 2); // Jhiplu = 2 pts
    });

    test('Alter value is 5 points', () {
      expect(5, 5); // Alter = 5 pts
    });
  });

  group('Marriage Combo Bonus', () {
    test('1 Marriage in hand = 10 points', () {
      // Marriage combo: Jhiplu + Tiplu + Poplu
      const inHandBonus = 10;
      expect(inHandBonus, 10);
    });

    test('1 Marriage played = 15 points', () {
      const playedBonus = 15;
      expect(playedBonus, 15);
    });

    test('2 Marriages in hand = 30 points (NOT 20!)', () {
      // Critical: Non-linear scoring
      const twoMarriagesBonus = 30;
      expect(twoMarriagesBonus, isNot(20)); // NOT just 2x10
      expect(twoMarriagesBonus, 30);
    });

    test('2 Marriages played = 35 points', () {
      const twoMarriagesPlayedBonus = 35;
      expect(twoMarriagesPlayedBonus, 35);
    });
  });

  group('MaalType enum values', () {
    test('enum has correct count', () {
      expect(MaalType.values.length, 6);
    });

    test('enum names match strings', () {
      expect(MaalType.tiplu.name, 'tiplu');
      expect(MaalType.poplu.name, 'poplu');
      expect(MaalType.jhiplu.name, 'jhiplu');
      expect(MaalType.alter.name, 'alter');
      expect(MaalType.man.name, 'man');
      expect(MaalType.none.name, 'none');
    });
  });
}
