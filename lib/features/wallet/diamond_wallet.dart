import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

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
    @JsonKey(fromJson: _nullableDateTimeFromJson, toJson: _nullableDateTimeToJson)
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
  purchase,    // IAP purchase
  roomCreation, // Spent on creating a room
  adDisable,   // Spent to disable ads
  refund,      // Refund from cancelled room
  bonus,       // Free diamonds (referral, etc.)
}
