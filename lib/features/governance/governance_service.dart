
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:clubroyale/features/wallet/diamond_service.dart';
import 'package:clubroyale/features/wallet/diamond_wallet.dart';
import 'package:clubroyale/features/wallet/models/diamond_origin.dart';

final governanceServiceProvider = Provider<GovernanceService>((ref) {
  final diamondService = ref.watch(diamondServiceProvider);
  return GovernanceService(diamondService);
});

class GovernanceService {
  final DiamondService _diamondService;

  GovernanceService(this._diamondService);

  /// Calculate user's voting power based on diamond origins
  Future<double> getVotingPower(String userId) async {
    final wallet = await _diamondService.getWallet(userId);
    
    // In V5, diamondsByOrigin tracks total accumulated per category.
    // However, the 'balance' is a single number. 
    // We need to estimate the composition of the *current* balance.
    // Simplifying assumption for V5 Phase 1: 
    // Voting Power is proportional to *total accumulated* weighted score, 
    // or we can use the current balance weighted by the *ratio* of historical earnings.
    
    // Approach: Weighted Ratio of Historical Earnings * Current Balance
    // This allows spending diamonds to reduce voting power, but maintains the "quality" of the diamonds held.
    
    return calculateVotingPowerForWallet(wallet);
  }

  /// Pure calculation logic (Testable)
  static double calculateVotingPowerForWallet(DiamondWallet wallet) {
    double totalWeightedScore = 0;
    double totalTrackedOriginAmount = 0;

    for (final originKey in wallet.diamondsByOrigin.keys) {
      final amount = wallet.diamondsByOrigin[originKey] ?? 0;
      final origin = _parseOrigin(originKey);
      
      if (origin != DiamondOrigin.unknown) {
         totalWeightedScore += amount * origin.governanceWeight;
         totalTrackedOriginAmount += amount;
      }
    }

    if (totalTrackedOriginAmount == 0) return 0;
    
    final averageWeight = totalWeightedScore / totalTrackedOriginAmount;
    
    // Voting Power = Current Balance * Average Weight
    return wallet.balance * averageWeight;
  }

  static DiamondOrigin _parseOrigin(String key) {
    try {
      return DiamondOrigin.values.firstWhere((e) => e.name == key);
    } catch (_) {
      return DiamondOrigin.unknown;
    }
  }
}
