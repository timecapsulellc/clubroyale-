import 'package:freezed_annotation/freezed_annotation.dart';

part 'diamond_wallet.freezed.dart';
part 'diamond_wallet.g.dart';

/// Diamond wallet for virtual currency (monetization)
/// Host buys diamonds via IAP to create rooms
@freezed
abstract class DiamondWallet with _$DiamondWallet {
  const factory DiamondWallet({
    /// User ID who owns this wallet
    required String userId,
    
    /// Current diamond balance
    @Default(0) int balance,
    
    /// Total diamonds purchased (lifetime)
    @Default(0) int totalPurchased,
    
    /// Total diamonds spent (lifetime)
    @Default(0) int totalSpent,
    
    /// Last transaction timestamp
    DateTime? lastUpdated,
  }) = _DiamondWallet;

  factory DiamondWallet.fromJson(Map<String, dynamic> json) =>
      _$DiamondWalletFromJson(json);
}

/// Diamond transaction record
@freezed
abstract class DiamondTransaction with _$DiamondTransaction {
  const factory DiamondTransaction({
    required String id,
    required String userId,
    required int amount,
    required DiamondTransactionType type,
    String? description,
    String? gameId,
    required DateTime createdAt,
  }) = _DiamondTransaction;

  factory DiamondTransaction.fromJson(Map<String, dynamic> json) =>
      _$DiamondTransactionFromJson(json);
}

enum DiamondTransactionType {
  purchase,    // IAP purchase
  roomCreation, // Spent on creating a room
  adDisable,   // Spent to disable ads
  refund,      // Refund from cancelled room
  bonus,       // Free diamonds (referral, etc.)
}
