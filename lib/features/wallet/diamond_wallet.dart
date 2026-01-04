import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:clubroyale/features/wallet/models/user_tier.dart';

part 'diamond_wallet.freezed.dart';
part 'diamond_wallet.g.dart';

/// Convert DateTime from JSON (handles Firestore Timestamp and String)
DateTime? _nullableDateTimeFromJson(dynamic json) {
  if (json == null) return null;
  if (json is Timestamp) return json.toDate();
  if (json is String) return DateTime.tryParse(json);
  return null;
}

DateTime _dateTimeFromJson(dynamic json) {
  if (json is Timestamp) return json.toDate();
  if (json is String) return DateTime.parse(json);
  return DateTime.now();
}

String? _nullableDateTimeToJson(DateTime? dt) => dt?.toIso8601String();
String _dateTimeToJson(DateTime dt) => dt.toIso8601String();

/// Diamond wallet for V5 Economy
/// Now integrated directly into the `users` collection in Firestore.
@freezed
abstract class DiamondWallet with _$DiamondWallet {
  const factory DiamondWallet({
    /// User ID
    required String userId,

    /// Current diamond balance
    @JsonKey(name: 'diamondBalance') @Default(0) int balance,

    /// User Tier (V5)
    @Default(UserTier.basic) UserTier tier,

    /// Diamonds breakdown by origin (V5)
    @Default({}) Map<String, int> diamondsByOrigin,

    /// Daily limits tracking
    @Default(0) int dailyEarned,
    @Default(0) int dailyTransferred,
    @Default(0) int dailyReceived,

    /// Login streak tracking
    @Default(0) int loginStreak,

    /// Last daily login claim
    @JsonKey(
      fromJson: _nullableDateTimeFromJson,
      toJson: _nullableDateTimeToJson,
    )
    DateTime? lastDailyLoginClaim,

    /// Verification timestamps
    @JsonKey(
      fromJson: _nullableDateTimeFromJson,
      toJson: _nullableDateTimeToJson,
    )
    DateTime? verifiedAt,

    @JsonKey(
      fromJson: _nullableDateTimeFromJson,
      toJson: _nullableDateTimeToJson,
    )
    DateTime? trustedAt,

    /// Legacy fields (kept for backward compatibility if needed)
    @Default(0) int totalPurchased,
    @Default(0) int totalSpent,
    @JsonKey(
      fromJson: _nullableDateTimeFromJson,
      toJson: _nullableDateTimeToJson,
    )
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
    @JsonKey(fromJson: _dateTimeFromJson, toJson: _dateTimeToJson)
    required DateTime createdAt,
  }) = _DiamondTransaction;

  factory DiamondTransaction.fromJson(Map<String, dynamic> json) =>
      _$DiamondTransactionFromJson(json);
}

enum DiamondTransactionType {
  purchase, // IAP purchase
  roomCreation, // Spent on creating a room
  adDisable, // Spent to disable ads
  refund, // Refund from cancelled room
  bonus, // Free diamonds (referral, etc.)
  signup, // Signup bonus diamonds
  tierUpgrade, // Spent to upgrade tier
}
