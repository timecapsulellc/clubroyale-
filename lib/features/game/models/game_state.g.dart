// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'game_state.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Bid _$BidFromJson(Map<String, dynamic> json) => _Bid(
  playerId: json['playerId'] as String,
  amount: (json['amount'] as num).toInt(),
);

Map<String, dynamic> _$BidToJson(_Bid instance) => <String, dynamic>{
  'playerId': instance.playerId,
  'amount': instance.amount,
};

_PlayedCard _$PlayedCardFromJson(Map<String, dynamic> json) => _PlayedCard(
  playerId: json['playerId'] as String,
  card: PlayingCard.fromJson(json['card'] as Map<String, dynamic>),
);

Map<String, dynamic> _$PlayedCardToJson(_PlayedCard instance) =>
    <String, dynamic>{'playerId': instance.playerId, 'card': instance.card};

_Trick _$TrickFromJson(Map<String, dynamic> json) => _Trick(
  ledSuit: $enumDecode(_$CardSuitEnumMap, json['ledSuit']),
  cards: (json['cards'] as List<dynamic>)
      .map((e) => PlayedCard.fromJson(e as Map<String, dynamic>))
      .toList(),
  winnerId: json['winnerId'] as String?,
);

Map<String, dynamic> _$TrickToJson(_Trick instance) => <String, dynamic>{
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

_PlayerTricks _$PlayerTricksFromJson(Map<String, dynamic> json) =>
    _PlayerTricks(
      playerId: json['playerId'] as String,
      tricksWon: (json['tricksWon'] as num?)?.toInt() ?? 0,
    );

Map<String, dynamic> _$PlayerTricksToJson(_PlayerTricks instance) =>
    <String, dynamic>{
      'playerId': instance.playerId,
      'tricksWon': instance.tricksWon,
    };
