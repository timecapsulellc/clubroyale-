// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'game_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

Bid _$BidFromJson(Map<String, dynamic> json) {
  return _Bid.fromJson(json);
}

/// @nodoc
mixin _$Bid {
  String get playerId => throw _privateConstructorUsedError;
  int get amount => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $BidCopyWith<Bid> get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $BidCopyWith<$Res> {
  factory $BidCopyWith(Bid value, $Res Function(Bid) then) =
      _$BidCopyWithImpl<$Res, Bid>;
  @useResult
  $Res call({String playerId, int amount});
}

/// @nodoc
class _$BidCopyWithImpl<$Res, $Val extends Bid> implements $BidCopyWith<$Res> {
  _$BidCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? playerId = null,
    Object? amount = null,
  }) {
    return _then(_value.copyWith(
      playerId: null == playerId
          ? _value.playerId
          : playerId // ignore: cast_nullable_to_non_nullable
              as String,
      amount: null == amount
          ? _value.amount
          : amount // ignore: cast_nullable_to_non_nullable
              as int,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$BidImplCopyWith<$Res> implements $BidCopyWith<$Res> {
  factory _$$BidImplCopyWith(_$BidImpl value, $Res Function(_$BidImpl) then) =
      __$$BidImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String playerId, int amount});
}

/// @nodoc
class __$$BidImplCopyWithImpl<$Res> extends _$BidCopyWithImpl<$Res, _$BidImpl>
    implements _$$BidImplCopyWith<$Res> {
  __$$BidImplCopyWithImpl(_$BidImpl _value, $Res Function(_$BidImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? playerId = null,
    Object? amount = null,
  }) {
    return _then(_$BidImpl(
      playerId: null == playerId
          ? _value.playerId
          : playerId // ignore: cast_nullable_to_non_nullable
              as String,
      amount: null == amount
          ? _value.amount
          : amount // ignore: cast_nullable_to_non_nullable
              as int,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$BidImpl implements _Bid {
  const _$BidImpl({required this.playerId, required this.amount});

  factory _$BidImpl.fromJson(Map<String, dynamic> json) =>
      _$$BidImplFromJson(json);

  @override
  final String playerId;
  @override
  final int amount;

  @override
  String toString() {
    return 'Bid(playerId: $playerId, amount: $amount)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$BidImpl &&
            (identical(other.playerId, playerId) ||
                other.playerId == playerId) &&
            (identical(other.amount, amount) || other.amount == amount));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(runtimeType, playerId, amount);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$BidImplCopyWith<_$BidImpl> get copyWith =>
      __$$BidImplCopyWithImpl<_$BidImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$BidImplToJson(
      this,
    );
  }
}

abstract class _Bid implements Bid {
  const factory _Bid(
      {required final String playerId, required final int amount}) = _$BidImpl;

  factory _Bid.fromJson(Map<String, dynamic> json) = _$BidImpl.fromJson;

  @override
  String get playerId;
  @override
  int get amount;
  @override
  @JsonKey(ignore: true)
  _$$BidImplCopyWith<_$BidImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

PlayedCard _$PlayedCardFromJson(Map<String, dynamic> json) {
  return _PlayedCard.fromJson(json);
}

/// @nodoc
mixin _$PlayedCard {
  String get playerId => throw _privateConstructorUsedError;
  PlayingCard get card => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $PlayedCardCopyWith<PlayedCard> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $PlayedCardCopyWith<$Res> {
  factory $PlayedCardCopyWith(
          PlayedCard value, $Res Function(PlayedCard) then) =
      _$PlayedCardCopyWithImpl<$Res, PlayedCard>;
  @useResult
  $Res call({String playerId, PlayingCard card});

  $PlayingCardCopyWith<$Res> get card;
}

/// @nodoc
class _$PlayedCardCopyWithImpl<$Res, $Val extends PlayedCard>
    implements $PlayedCardCopyWith<$Res> {
  _$PlayedCardCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? playerId = null,
    Object? card = null,
  }) {
    return _then(_value.copyWith(
      playerId: null == playerId
          ? _value.playerId
          : playerId // ignore: cast_nullable_to_non_nullable
              as String,
      card: null == card
          ? _value.card
          : card // ignore: cast_nullable_to_non_nullable
              as PlayingCard,
    ) as $Val);
  }

  @override
  @pragma('vm:prefer-inline')
  $PlayingCardCopyWith<$Res> get card {
    return $PlayingCardCopyWith<$Res>(_value.card, (value) {
      return _then(_value.copyWith(card: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$PlayedCardImplCopyWith<$Res>
    implements $PlayedCardCopyWith<$Res> {
  factory _$$PlayedCardImplCopyWith(
          _$PlayedCardImpl value, $Res Function(_$PlayedCardImpl) then) =
      __$$PlayedCardImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String playerId, PlayingCard card});

  @override
  $PlayingCardCopyWith<$Res> get card;
}

/// @nodoc
class __$$PlayedCardImplCopyWithImpl<$Res>
    extends _$PlayedCardCopyWithImpl<$Res, _$PlayedCardImpl>
    implements _$$PlayedCardImplCopyWith<$Res> {
  __$$PlayedCardImplCopyWithImpl(
      _$PlayedCardImpl _value, $Res Function(_$PlayedCardImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? playerId = null,
    Object? card = null,
  }) {
    return _then(_$PlayedCardImpl(
      playerId: null == playerId
          ? _value.playerId
          : playerId // ignore: cast_nullable_to_non_nullable
              as String,
      card: null == card
          ? _value.card
          : card // ignore: cast_nullable_to_non_nullable
              as PlayingCard,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$PlayedCardImpl implements _PlayedCard {
  const _$PlayedCardImpl({required this.playerId, required this.card});

  factory _$PlayedCardImpl.fromJson(Map<String, dynamic> json) =>
      _$$PlayedCardImplFromJson(json);

  @override
  final String playerId;
  @override
  final PlayingCard card;

  @override
  String toString() {
    return 'PlayedCard(playerId: $playerId, card: $card)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$PlayedCardImpl &&
            (identical(other.playerId, playerId) ||
                other.playerId == playerId) &&
            (identical(other.card, card) || other.card == card));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(runtimeType, playerId, card);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$PlayedCardImplCopyWith<_$PlayedCardImpl> get copyWith =>
      __$$PlayedCardImplCopyWithImpl<_$PlayedCardImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$PlayedCardImplToJson(
      this,
    );
  }
}

abstract class _PlayedCard implements PlayedCard {
  const factory _PlayedCard(
      {required final String playerId,
      required final PlayingCard card}) = _$PlayedCardImpl;

  factory _PlayedCard.fromJson(Map<String, dynamic> json) =
      _$PlayedCardImpl.fromJson;

  @override
  String get playerId;
  @override
  PlayingCard get card;
  @override
  @JsonKey(ignore: true)
  _$$PlayedCardImplCopyWith<_$PlayedCardImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

Trick _$TrickFromJson(Map<String, dynamic> json) {
  return _Trick.fromJson(json);
}

/// @nodoc
mixin _$Trick {
  CardSuit get ledSuit => throw _privateConstructorUsedError;
  List<PlayedCard> get cards => throw _privateConstructorUsedError;
  String? get winnerId => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $TrickCopyWith<Trick> get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $TrickCopyWith<$Res> {
  factory $TrickCopyWith(Trick value, $Res Function(Trick) then) =
      _$TrickCopyWithImpl<$Res, Trick>;
  @useResult
  $Res call({CardSuit ledSuit, List<PlayedCard> cards, String? winnerId});
}

/// @nodoc
class _$TrickCopyWithImpl<$Res, $Val extends Trick>
    implements $TrickCopyWith<$Res> {
  _$TrickCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? ledSuit = null,
    Object? cards = null,
    Object? winnerId = freezed,
  }) {
    return _then(_value.copyWith(
      ledSuit: null == ledSuit
          ? _value.ledSuit
          : ledSuit // ignore: cast_nullable_to_non_nullable
              as CardSuit,
      cards: null == cards
          ? _value.cards
          : cards // ignore: cast_nullable_to_non_nullable
              as List<PlayedCard>,
      winnerId: freezed == winnerId
          ? _value.winnerId
          : winnerId // ignore: cast_nullable_to_non_nullable
              as String?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$TrickImplCopyWith<$Res> implements $TrickCopyWith<$Res> {
  factory _$$TrickImplCopyWith(
          _$TrickImpl value, $Res Function(_$TrickImpl) then) =
      __$$TrickImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({CardSuit ledSuit, List<PlayedCard> cards, String? winnerId});
}

/// @nodoc
class __$$TrickImplCopyWithImpl<$Res>
    extends _$TrickCopyWithImpl<$Res, _$TrickImpl>
    implements _$$TrickImplCopyWith<$Res> {
  __$$TrickImplCopyWithImpl(
      _$TrickImpl _value, $Res Function(_$TrickImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? ledSuit = null,
    Object? cards = null,
    Object? winnerId = freezed,
  }) {
    return _then(_$TrickImpl(
      ledSuit: null == ledSuit
          ? _value.ledSuit
          : ledSuit // ignore: cast_nullable_to_non_nullable
              as CardSuit,
      cards: null == cards
          ? _value._cards
          : cards // ignore: cast_nullable_to_non_nullable
              as List<PlayedCard>,
      winnerId: freezed == winnerId
          ? _value.winnerId
          : winnerId // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$TrickImpl extends _Trick {
  const _$TrickImpl(
      {required this.ledSuit,
      required final List<PlayedCard> cards,
      this.winnerId})
      : _cards = cards,
        super._();

  factory _$TrickImpl.fromJson(Map<String, dynamic> json) =>
      _$$TrickImplFromJson(json);

  @override
  final CardSuit ledSuit;
  final List<PlayedCard> _cards;
  @override
  List<PlayedCard> get cards {
    if (_cards is EqualUnmodifiableListView) return _cards;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_cards);
  }

  @override
  final String? winnerId;

  @override
  String toString() {
    return 'Trick(ledSuit: $ledSuit, cards: $cards, winnerId: $winnerId)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$TrickImpl &&
            (identical(other.ledSuit, ledSuit) || other.ledSuit == ledSuit) &&
            const DeepCollectionEquality().equals(other._cards, _cards) &&
            (identical(other.winnerId, winnerId) ||
                other.winnerId == winnerId));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(runtimeType, ledSuit,
      const DeepCollectionEquality().hash(_cards), winnerId);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$TrickImplCopyWith<_$TrickImpl> get copyWith =>
      __$$TrickImplCopyWithImpl<_$TrickImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$TrickImplToJson(
      this,
    );
  }
}

abstract class _Trick extends Trick {
  const factory _Trick(
      {required final CardSuit ledSuit,
      required final List<PlayedCard> cards,
      final String? winnerId}) = _$TrickImpl;
  const _Trick._() : super._();

  factory _Trick.fromJson(Map<String, dynamic> json) = _$TrickImpl.fromJson;

  @override
  CardSuit get ledSuit;
  @override
  List<PlayedCard> get cards;
  @override
  String? get winnerId;
  @override
  @JsonKey(ignore: true)
  _$$TrickImplCopyWith<_$TrickImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

PlayerTricks _$PlayerTricksFromJson(Map<String, dynamic> json) {
  return _PlayerTricks.fromJson(json);
}

/// @nodoc
mixin _$PlayerTricks {
  String get playerId => throw _privateConstructorUsedError;
  int get tricksWon => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $PlayerTricksCopyWith<PlayerTricks> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $PlayerTricksCopyWith<$Res> {
  factory $PlayerTricksCopyWith(
          PlayerTricks value, $Res Function(PlayerTricks) then) =
      _$PlayerTricksCopyWithImpl<$Res, PlayerTricks>;
  @useResult
  $Res call({String playerId, int tricksWon});
}

/// @nodoc
class _$PlayerTricksCopyWithImpl<$Res, $Val extends PlayerTricks>
    implements $PlayerTricksCopyWith<$Res> {
  _$PlayerTricksCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? playerId = null,
    Object? tricksWon = null,
  }) {
    return _then(_value.copyWith(
      playerId: null == playerId
          ? _value.playerId
          : playerId // ignore: cast_nullable_to_non_nullable
              as String,
      tricksWon: null == tricksWon
          ? _value.tricksWon
          : tricksWon // ignore: cast_nullable_to_non_nullable
              as int,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$PlayerTricksImplCopyWith<$Res>
    implements $PlayerTricksCopyWith<$Res> {
  factory _$$PlayerTricksImplCopyWith(
          _$PlayerTricksImpl value, $Res Function(_$PlayerTricksImpl) then) =
      __$$PlayerTricksImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String playerId, int tricksWon});
}

/// @nodoc
class __$$PlayerTricksImplCopyWithImpl<$Res>
    extends _$PlayerTricksCopyWithImpl<$Res, _$PlayerTricksImpl>
    implements _$$PlayerTricksImplCopyWith<$Res> {
  __$$PlayerTricksImplCopyWithImpl(
      _$PlayerTricksImpl _value, $Res Function(_$PlayerTricksImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? playerId = null,
    Object? tricksWon = null,
  }) {
    return _then(_$PlayerTricksImpl(
      playerId: null == playerId
          ? _value.playerId
          : playerId // ignore: cast_nullable_to_non_nullable
              as String,
      tricksWon: null == tricksWon
          ? _value.tricksWon
          : tricksWon // ignore: cast_nullable_to_non_nullable
              as int,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$PlayerTricksImpl implements _PlayerTricks {
  const _$PlayerTricksImpl({required this.playerId, this.tricksWon = 0});

  factory _$PlayerTricksImpl.fromJson(Map<String, dynamic> json) =>
      _$$PlayerTricksImplFromJson(json);

  @override
  final String playerId;
  @override
  @JsonKey()
  final int tricksWon;

  @override
  String toString() {
    return 'PlayerTricks(playerId: $playerId, tricksWon: $tricksWon)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$PlayerTricksImpl &&
            (identical(other.playerId, playerId) ||
                other.playerId == playerId) &&
            (identical(other.tricksWon, tricksWon) ||
                other.tricksWon == tricksWon));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(runtimeType, playerId, tricksWon);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$PlayerTricksImplCopyWith<_$PlayerTricksImpl> get copyWith =>
      __$$PlayerTricksImplCopyWithImpl<_$PlayerTricksImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$PlayerTricksImplToJson(
      this,
    );
  }
}

abstract class _PlayerTricks implements PlayerTricks {
  const factory _PlayerTricks(
      {required final String playerId,
      final int tricksWon}) = _$PlayerTricksImpl;

  factory _PlayerTricks.fromJson(Map<String, dynamic> json) =
      _$PlayerTricksImpl.fromJson;

  @override
  String get playerId;
  @override
  int get tricksWon;
  @override
  @JsonKey(ignore: true)
  _$$PlayerTricksImplCopyWith<_$PlayerTricksImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
