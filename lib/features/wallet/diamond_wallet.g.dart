// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'diamond_wallet.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_DiamondWallet _$DiamondWalletFromJson(
  Map<String, dynamic> json,
) => _DiamondWallet(
  userId: json['userId'] as String,
  balance: (json['diamondBalance'] as num?)?.toInt() ?? 0,
  tier: $enumDecodeNullable(_$UserTierEnumMap, json['tier']) ?? UserTier.basic,
  diamondsByOrigin:
      (json['diamondsByOrigin'] as Map<String, dynamic>?)?.map(
        (k, e) => MapEntry(k, (e as num).toInt()),
      ) ??
      const {},
  dailyEarned: (json['dailyEarned'] as num?)?.toInt() ?? 0,
  dailyTransferred: (json['dailyTransferred'] as num?)?.toInt() ?? 0,
  dailyReceived: (json['dailyReceived'] as num?)?.toInt() ?? 0,
  loginStreak: (json['loginStreak'] as num?)?.toInt() ?? 0,
  lastDailyLoginClaim: _nullableDateTimeFromJson(json['lastDailyLoginClaim']),
  verifiedAt: _nullableDateTimeFromJson(json['verifiedAt']),
  trustedAt: _nullableDateTimeFromJson(json['trustedAt']),
  totalPurchased: (json['totalPurchased'] as num?)?.toInt() ?? 0,
  totalSpent: (json['totalSpent'] as num?)?.toInt() ?? 0,
  lastUpdated: _nullableDateTimeFromJson(json['lastUpdated']),
);

Map<String, dynamic> _$DiamondWalletToJson(
  _DiamondWallet instance,
) => <String, dynamic>{
  'userId': instance.userId,
  'diamondBalance': instance.balance,
  'tier': _$UserTierEnumMap[instance.tier]!,
  'diamondsByOrigin': instance.diamondsByOrigin,
  'dailyEarned': instance.dailyEarned,
  'dailyTransferred': instance.dailyTransferred,
  'dailyReceived': instance.dailyReceived,
  'loginStreak': instance.loginStreak,
  'lastDailyLoginClaim': _nullableDateTimeToJson(instance.lastDailyLoginClaim),
  'verifiedAt': _nullableDateTimeToJson(instance.verifiedAt),
  'trustedAt': _nullableDateTimeToJson(instance.trustedAt),
  'totalPurchased': instance.totalPurchased,
  'totalSpent': instance.totalSpent,
  'lastUpdated': _nullableDateTimeToJson(instance.lastUpdated),
};

const _$UserTierEnumMap = {
  UserTier.basic: 'basic',
  UserTier.verified: 'verified',
  UserTier.trusted: 'trusted',
  UserTier.leader: 'leader',
  UserTier.ambassador: 'ambassador',
};

_DiamondTransaction _$DiamondTransactionFromJson(Map<String, dynamic> json) =>
    _DiamondTransaction(
      id: json['id'] as String,
      userId: json['userId'] as String,
      amount: (json['amount'] as num).toInt(),
      type: $enumDecode(_$DiamondTransactionTypeEnumMap, json['type']),
      description: json['description'] as String?,
      gameId: json['gameId'] as String?,
      createdAt: _dateTimeFromJson(json['createdAt']),
    );

Map<String, dynamic> _$DiamondTransactionToJson(_DiamondTransaction instance) =>
    <String, dynamic>{
      'id': instance.id,
      'userId': instance.userId,
      'amount': instance.amount,
      'type': _$DiamondTransactionTypeEnumMap[instance.type]!,
      'description': instance.description,
      'gameId': instance.gameId,
      'createdAt': _dateTimeToJson(instance.createdAt),
    };

const _$DiamondTransactionTypeEnumMap = {
  DiamondTransactionType.purchase: 'purchase',
  DiamondTransactionType.roomCreation: 'roomCreation',
  DiamondTransactionType.adDisable: 'adDisable',
  DiamondTransactionType.refund: 'refund',
  DiamondTransactionType.bonus: 'bonus',
};
