
import 'package:flutter_test/flutter_test.dart';
import 'package:clubroyale/features/wallet/models/user_tier.dart';
import 'package:clubroyale/features/wallet/diamond_wallet.dart';
import 'package:clubroyale/features/governance/governance_service.dart';
// Imports Firestore? No, need explicit.
import 'package:cloud_firestore/cloud_firestore.dart';

// Mock Timestamp for testing
class MockTimestamp extends Timestamp {
  MockTimestamp(super.seconds, super.nanoseconds);
}

void main() {
  group('UserTier V5 Logic', () {
    test('Basic Tier Limits', () {
      const tier = UserTier.basic;
      expect(tier.canTransfer, false);
      expect(tier.dailyTransferLimit, 0);
      expect(tier.dailyEarningCap, 200);
    });

    test('Verified Tier Limits', () {
      const tier = UserTier.verified;
      expect(tier.canTransfer, true);
      expect(tier.dailyTransferLimit, 500);
      expect(tier.dailyEarningCap, 1000);
    });

    test('Trusted Tier Limits', () {
      const tier = UserTier.trusted;
      expect(tier.canTransfer, true);
      expect(tier.dailyTransferLimit, 5000);
      expect(tier.dailyEarningCap, 5000);
    });

    test('Ambassador Tier Limits', () {
      const tier = UserTier.ambassador;
      expect(tier.canTransfer, true);
      expect(tier.dailyTransferLimit, -1); // Unlimited
      expect(tier.dailyEarningCap, -1); // Unlimited
    });
  });

  group('Governance Voting Power', () {
    test('Calculate Voting Power - Gameplay Only (Weight 2.0)', () {
      final wallet = DiamondWallet(
         userId: 'test_user',
         balance: 1000,
         tier: UserTier.basic,
         diamondsByOrigin: {
           'gameplayWin': 1000, // Weight 2.0
         },
         dailyEarned: 0,
         dailyTransferred: 0,
         dailyReceived: 0,
         loginStreak: 0,
         lastDailyLoginClaim: DateTime.now(),
      );
      
      final power = GovernanceService.calculateVotingPowerForWallet(wallet);
      expect(power, 2000.0); // 1000 * 2.0
    });

    test('Calculate Voting Power - Mixed (Gameplay 2.0 + Purchase 0.5)', () {
      // 500 Gameplay (2.0) + 500 Purchased (0.5)
      // Weighted Score = 500*2.0 + 500*0.5 = 1000 + 250 = 1250
      // Total Tracked = 1000
      // Avg Weight = 1.25
      // Balance = 1000 => Power = 1250
      
      final wallet = DiamondWallet(
         userId: 'test_user',
         balance: 1000,
         tier: UserTier.basic,
         diamondsByOrigin: {
           'gameplayWin': 500,
           'purchase': 500,
         },
         dailyEarned: 0,
         dailyTransferred: 0,
         dailyReceived: 0,
         loginStreak: 0,
         lastDailyLoginClaim: DateTime.now(),
      );
      
      final power = GovernanceService.calculateVotingPowerForWallet(wallet);
      expect(power, 1250.0);
    });
  });
}
