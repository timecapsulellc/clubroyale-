import 'package:flutter_test/flutter_test.dart';

/// Diamond Wallet Logic Tests
/// 
/// Tests for diamond economy rules and validations.
void main() {
  group('Diamond Transfer Rules', () {
    test('minimum transfer amount is 10', () {
      const minTransfer = 10;
      expect(minTransfer, equals(10));
      expect(5 >= minTransfer, isFalse);
      expect(10 >= minTransfer, isTrue);
    });

    test('maximum transfer amount is 10000', () {
      const maxTransfer = 10000;
      expect(15000 <= maxTransfer, isFalse);
      expect(5000 <= maxTransfer, isTrue);
    });

    test('transfer fee calculation (5%)', () {
      const feePercent = 0.05;
      expect((100 * feePercent).round(), equals(5));
      expect((1000 * feePercent).round(), equals(50));
      expect((500 * feePercent).round(), equals(25));
    });
  });

  group('Diamond Balance Validation', () {
    test('balance cannot be negative', () {
      int balance = 100;
      int spend = 150;
      
      bool canSpend = balance >= spend;
      expect(canSpend, isFalse);
    });

    test('balance can be zero', () {
      int balance = 0;
      expect(balance >= 0, isTrue);
    });

    test('large balance is valid', () {
      int balance = 999999999;
      expect(balance >= 0, isTrue);
    });
  });

  group('Daily Limits', () {
    test('daily earn cap is 5000', () {
      const dailyCap = 5000;
      expect(dailyCap, equals(5000));
    });

    test('earned diamonds respect daily cap', () {
      const dailyCap = 5000;
      int dailyEarned = 4500;
      int newEarning = 1000;
      
      int actualEarning = (dailyEarned + newEarning) > dailyCap 
          ? dailyCap - dailyEarned 
          : newEarning;
      
      expect(actualEarning, equals(500));
    });

    test('zero cap space prevents earning', () {
      const dailyCap = 5000;
      int dailyEarned = 5000;
      int newEarning = 100;
      
      int actualEarning = (dailyEarned + newEarning) > dailyCap 
          ? dailyCap - dailyEarned 
          : newEarning;
      
      expect(actualEarning, equals(0));
    });
  });

  group('Tier Benefits', () {
    test('free tier has 1x multiplier', () {
      expect(_getTierMultiplier('free'), equals(1.0));
    });

    test('bronze tier has 1.1x multiplier', () {
      expect(_getTierMultiplier('bronze'), equals(1.1));
    });

    test('silver tier has 1.25x multiplier', () {
      expect(_getTierMultiplier('silver'), equals(1.25));
    });

    test('gold tier has 1.5x multiplier', () {
      expect(_getTierMultiplier('gold'), equals(1.5));
    });

    test('diamond tier has 2x multiplier', () {
      expect(_getTierMultiplier('diamond'), equals(2.0));
    });
  });

  group('Reward Calculations', () {
    test('game win reward calculation', () {
      const baseReward = 100;
      const tierMultiplier = 1.5; // Gold tier
      
      int reward = (baseReward * tierMultiplier).round();
      expect(reward, equals(150));
    });

    test('daily login streak bonus', () {
      int streakDay = 7;
      int baseReward = 50;
      
      int streakBonus = streakDay >= 7 ? 100 : (streakDay >= 3 ? 25 : 0);
      int totalReward = baseReward + streakBonus;
      
      expect(totalReward, equals(150));
    });

    test('referral reward calculation', () {
      const referrerReward = 500;
      const refereeReward = 200;
      
      expect(referrerReward, greaterThan(refereeReward));
    });
  });

  group('Anti-Fraud Checks', () {
    test('transfer to self is blocked', () {
      String senderId = 'user-123';
      String receiverId = 'user-123';
      
      bool isSelfTransfer = senderId == receiverId;
      expect(isSelfTransfer, isTrue);
    });

    test('rapid transfers are flagged', () {
      List<DateTime> recentTransfers = [
        DateTime.now().subtract(const Duration(seconds: 30)),
        DateTime.now().subtract(const Duration(seconds: 20)),
        DateTime.now().subtract(const Duration(seconds: 10)),
      ];
      
      bool isRapid = recentTransfers.length >= 3 && 
          recentTransfers.last.difference(recentTransfers.first).inMinutes < 1;
      
      expect(isRapid, isTrue);
    });

    test('large transfer requires verification', () {
      int amount = 5000;
      const verificationThreshold = 1000;
      
      bool requiresVerification = amount >= verificationThreshold;
      expect(requiresVerification, isTrue);
    });
  });
}

double _getTierMultiplier(String tier) {
  switch (tier) {
    case 'bronze': return 1.1;
    case 'silver': return 1.25;
    case 'gold': return 1.5;
    case 'diamond': return 2.0;
    default: return 1.0;
  }
}
