// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'card.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

PlayingCard _$PlayingCardFromJson(Map<String, dynamic> json) {
  return _PlayingCard.fromJson(json);
}

/// @nodoc
mixin _$PlayingCard {
  CardSuit get suit => throw _privateConstructorUsedError;
  CardRank get rank => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $PlayingCardCopyWith<PlayingCard> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $PlayingCardCopyWith<$Res> {
  factory $PlayingCardCopyWith(
          PlayingCard value, $Res Function(PlayingCard) then) =
      _$PlayingCardCopyWithImpl<$Res, PlayingCard>;
  @useResult
  $Res call({CardSuit suit, CardRank rank});
}

/// @nodoc
class _$PlayingCardCopyWithImpl<$Res, $Val extends PlayingCard>
    implements $PlayingCardCopyWith<$Res> {
  _$PlayingCardCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? suit = null,
    Object? rank = null,
  }) {
    return _then(_value.copyWith(
      suit: null == suit
          ? _value.suit
          : suit // ignore: cast_nullable_to_non_nullable
              as CardSuit,
      rank: null == rank
          ? _value.rank
          : rank // ignore: cast_nullable_to_non_nullable
              as CardRank,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$PlayingCardImplCopyWith<$Res>
    implements $PlayingCardCopyWith<$Res> {
  factory _$$PlayingCardImplCopyWith(
          _$PlayingCardImpl value, $Res Function(_$PlayingCardImpl) then) =
      __$$PlayingCardImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({CardSuit suit, CardRank rank});
}

/// @nodoc
class __$$PlayingCardImplCopyWithImpl<$Res>
    extends _$PlayingCardCopyWithImpl<$Res, _$PlayingCardImpl>
    implements _$$PlayingCardImplCopyWith<$Res> {
  __$$PlayingCardImplCopyWithImpl(
      _$PlayingCardImpl _value, $Res Function(_$PlayingCardImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? suit = null,
    Object? rank = null,
  }) {
    return _then(_$PlayingCardImpl(
      suit: null == suit
          ? _value.suit
          : suit // ignore: cast_nullable_to_non_nullable
              as CardSuit,
      rank: null == rank
          ? _value.rank
          : rank // ignore: cast_nullable_to_non_nullable
              as CardRank,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$PlayingCardImpl extends _PlayingCard {
  const _$PlayingCardImpl({required this.suit, required this.rank}) : super._();

  factory _$PlayingCardImpl.fromJson(Map<String, dynamic> json) =>
      _$$PlayingCardImplFromJson(json);

  @override
  final CardSuit suit;
  @override
  final CardRank rank;

  @override
  String toString() {
    return 'PlayingCard(suit: $suit, rank: $rank)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$PlayingCardImpl &&
            (identical(other.suit, suit) || other.suit == suit) &&
            (identical(other.rank, rank) || other.rank == rank));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(runtimeType, suit, rank);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$PlayingCardImplCopyWith<_$PlayingCardImpl> get copyWith =>
      __$$PlayingCardImplCopyWithImpl<_$PlayingCardImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$PlayingCardImplToJson(
      this,
    );
  }
}

abstract class _PlayingCard extends PlayingCard {
  const factory _PlayingCard(
      {required final CardSuit suit,
      required final CardRank rank}) = _$PlayingCardImpl;
  const _PlayingCard._() : super._();

  factory _PlayingCard.fromJson(Map<String, dynamic> json) =
      _$PlayingCardImpl.fromJson;

  @override
  CardSuit get suit;
  @override
  CardRank get rank;
  @override
  @JsonKey(ignore: true)
  _$$PlayingCardImplCopyWith<_$PlayingCardImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
