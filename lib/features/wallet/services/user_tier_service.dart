
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:clubroyale/features/wallet/models/user_tier.dart';
import 'package:clubroyale/features/wallet/diamond_service.dart';
import 'package:clubroyale/features/auth/auth_service.dart';

final userTierServiceProvider = Provider<UserTierService>((ref) {
  final diamondService = ref.watch(diamondServiceProvider);
  return UserTierService(diamondService);
});

final currentUserTierProvider = StreamProvider<UserTier>((ref) {
  final authState = ref.watch(authStateProvider);
  final user = authState.value;
  
  if (user == null) return Stream.value(UserTier.basic);
  
  final service = ref.watch(userTierServiceProvider);
  return service.watchUserTier(user.uid);
});

class UserTierService {
  final DiamondService _diamondService;

  UserTierService(this._diamondService);

  /// Watch the tier of a specific user
  Stream<UserTier> watchUserTier(String userId) {
    return _diamondService.watchWallet(userId).map((wallet) => wallet.tier);
  }

  /// Check if user can transfer diamons
  Future<bool> canTransfer(String userId) async {
    final wallet = await _diamondService.getWallet(userId);
    return wallet.tier.canTransfer;
  }

  /// Get remaining daily transfer limit
  Future<int> getRemainingTransferLimit(String userId) async {
    final wallet = await _diamondService.getWallet(userId);
    final limit = wallet.tier.dailyTransferLimit;
    
    if (limit == -1) return -1; // Unlimited
    
    return (limit - wallet.dailyTransferred).clamp(0, limit);
  }

  /// Get remaining daily earning cap
  Future<int> getRemainingEarningCap(String userId) async {
    final wallet = await _diamondService.getWallet(userId);
    final cap = wallet.tier.dailyEarningCap;
    
    if (cap == -1) return -1; // Unlimited
    
    return (cap - wallet.dailyEarned).clamp(0, cap);
  }

  /// Get next tier (or null if max)
  UserTier? getNextTier(UserTier current) {
    final index = current.index;
    if (index < UserTier.values.length - 1) {
      return UserTier.values[index + 1];
    }
    return null;
  }
}
