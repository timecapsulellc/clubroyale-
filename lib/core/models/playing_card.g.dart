// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'playing_card.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_PlayingCard _$PlayingCardFromJson(Map<String, dynamic> json) => _PlayingCard(
  suit: $enumDecode(_$CardSuitEnumMap, json['suit']),
  rank: $enumDecode(_$CardRankEnumMap, json['rank']),
  deckIndex: (json['deckIndex'] as num?)?.toInt() ?? 0,
  isJoker: json['isJoker'] as bool? ?? false,
);

Map<String, dynamic> _$PlayingCardToJson(_PlayingCard instance) =>
    <String, dynamic>{
      'suit': _$CardSuitEnumMap[instance.suit]!,
      'rank': _$CardRankEnumMap[instance.rank]!,
      'deckIndex': instance.deckIndex,
      'isJoker': instance.isJoker,
    };

const _$CardSuitEnumMap = {
  CardSuit.hearts: 'hearts',
  CardSuit.diamonds: 'diamonds',
  CardSuit.clubs: 'clubs',
  CardSuit.spades: 'spades',
};

const _$CardRankEnumMap = {
  CardRank.two: 'two',
  CardRank.three: 'three',
  CardRank.four: 'four',
  CardRank.five: 'five',
  CardRank.six: 'six',
  CardRank.seven: 'seven',
  CardRank.eight: 'eight',
  CardRank.nine: 'nine',
  CardRank.ten: 'ten',
  CardRank.jack: 'jack',
  CardRank.queen: 'queen',
  CardRank.king: 'king',
  CardRank.ace: 'ace',
};
