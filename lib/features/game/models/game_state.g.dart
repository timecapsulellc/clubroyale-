// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'game_state.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$BidImpl _$$BidImplFromJson(Map<String, dynamic> json) => _$BidImpl(
      playerId: json['playerId'] as String,
      amount: (json['amount'] as num).toInt(),
    );

Map<String, dynamic> _$$BidImplToJson(_$BidImpl instance) => <String, dynamic>{
      'playerId': instance.playerId,
      'amount': instance.amount,
    };

_$PlayedCardImpl _$$PlayedCardImplFromJson(Map<String, dynamic> json) =>
    _$PlayedCardImpl(
      playerId: json['playerId'] as String,
      card: PlayingCard.fromJson(json['card'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$$PlayedCardImplToJson(_$PlayedCardImpl instance) =>
    <String, dynamic>{
      'playerId': instance.playerId,
      'card': instance.card,
    };

_$TrickImpl _$$TrickImplFromJson(Map<String, dynamic> json) => _$TrickImpl(
      ledSuit: $enumDecode(_$CardSuitEnumMap, json['ledSuit']),
      cards: (json['cards'] as List<dynamic>)
          .map((e) => PlayedCard.fromJson(e as Map<String, dynamic>))
          .toList(),
      winnerId: json['winnerId'] as String?,
    );

Map<String, dynamic> _$$TrickImplToJson(_$TrickImpl instance) =>
    <String, dynamic>{
      'ledSuit': _$CardSuitEnumMap[instance.ledSuit]!,
      'cards': instance.cards,
      'winnerId': instance.winnerId,
    };

const _$CardSuitEnumMap = {
  CardSuit.hearts: 'hearts',
  CardSuit.diamonds: 'diamonds',
  CardSuit.clubs: 'clubs',
  CardSuit.spades: 'spades',
};

_$PlayerTricksImpl _$$PlayerTricksImplFromJson(Map<String, dynamic> json) =>
    _$PlayerTricksImpl(
      playerId: json['playerId'] as String,
      tricksWon: (json['tricksWon'] as num?)?.toInt() ?? 0,
    );

Map<String, dynamic> _$$PlayerTricksImplToJson(_$PlayerTricksImpl instance) =>
    <String, dynamic>{
      'playerId': instance.playerId,
      'tricksWon': instance.tricksWon,
    };
