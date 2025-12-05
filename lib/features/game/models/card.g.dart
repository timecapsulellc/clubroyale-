// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'card.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$PlayingCardImpl _$$PlayingCardImplFromJson(Map<String, dynamic> json) =>
    _$PlayingCardImpl(
      suit: $enumDecode(_$CardSuitEnumMap, json['suit']),
      rank: $enumDecode(_$CardRankEnumMap, json['rank']),
    );

Map<String, dynamic> _$$PlayingCardImplToJson(_$PlayingCardImpl instance) =>
    <String, dynamic>{
      'suit': _$CardSuitEnumMap[instance.suit]!,
      'rank': _$CardRankEnumMap[instance.rank]!,
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
