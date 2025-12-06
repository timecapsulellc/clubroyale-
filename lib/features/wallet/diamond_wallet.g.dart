// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'diamond_wallet.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_DiamondWallet _$DiamondWalletFromJson(Map<String, dynamic> json) =>
    _DiamondWallet(
      userId: json['userId'] as String,
      balance: (json['balance'] as num?)?.toInt() ?? 0,
      totalPurchased: (json['totalPurchased'] as num?)?.toInt() ?? 0,
      totalSpent: (json['totalSpent'] as num?)?.toInt() ?? 0,
      lastUpdated: json['lastUpdated'] == null
          ? null
          : DateTime.parse(json['lastUpdated'] as String),
    );

Map<String, dynamic> _$DiamondWalletToJson(_DiamondWallet instance) =>
    <String, dynamic>{
      'userId': instance.userId,
      'balance': instance.balance,
      'totalPurchased': instance.totalPurchased,
      'totalSpent': instance.totalSpent,
      'lastUpdated': instance.lastUpdated?.toIso8601String(),
    };

_DiamondTransaction _$DiamondTransactionFromJson(Map<String, dynamic> json) =>
    _DiamondTransaction(
      id: json['id'] as String,
      userId: json['userId'] as String,
      amount: (json['amount'] as num).toInt(),
      type: $enumDecode(_$DiamondTransactionTypeEnumMap, json['type']),
      description: json['description'] as String?,
      gameId: json['gameId'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );

Map<String, dynamic> _$DiamondTransactionToJson(_DiamondTransaction instance) =>
    <String, dynamic>{
      'id': instance.id,
      'userId': instance.userId,
      'amount': instance.amount,
      'type': _$DiamondTransactionTypeEnumMap[instance.type]!,
      'description': instance.description,
      'gameId': instance.gameId,
      'createdAt': instance.createdAt.toIso8601String(),
    };

const _$DiamondTransactionTypeEnumMap = {
  DiamondTransactionType.purchase: 'purchase',
  DiamondTransactionType.roomCreation: 'roomCreation',
  DiamondTransactionType.adDisable: 'adDisable',
  DiamondTransactionType.refund: 'refund',
  DiamondTransactionType.bonus: 'bonus',
};
