// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'card.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$PlayingCard {

 CardSuit get suit; CardRank get rank;
/// Create a copy of PlayingCard
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PlayingCardCopyWith<PlayingCard> get copyWith => _$PlayingCardCopyWithImpl<PlayingCard>(this as PlayingCard, _$identity);

  /// Serializes this PlayingCard to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PlayingCard&&(identical(other.suit, suit) || other.suit == suit)&&(identical(other.rank, rank) || other.rank == rank));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,suit,rank);

@override
String toString() {
  return 'PlayingCard(suit: $suit, rank: $rank)';
}


}

/// @nodoc
abstract mixin class $PlayingCardCopyWith<$Res>  {
  factory $PlayingCardCopyWith(PlayingCard value, $Res Function(PlayingCard) _then) = _$PlayingCardCopyWithImpl;
@useResult
$Res call({
 CardSuit suit, CardRank rank
});




}
/// @nodoc
class _$PlayingCardCopyWithImpl<$Res>
    implements $PlayingCardCopyWith<$Res> {
  _$PlayingCardCopyWithImpl(this._self, this._then);

  final PlayingCard _self;
  final $Res Function(PlayingCard) _then;

/// Create a copy of PlayingCard
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? suit = null,Object? rank = null,}) {
  return _then(_self.copyWith(
suit: null == suit ? _self.suit : suit // ignore: cast_nullable_to_non_nullable
as CardSuit,rank: null == rank ? _self.rank : rank // ignore: cast_nullable_to_non_nullable
as CardRank,
  ));
}

}


/// Adds pattern-matching-related methods to [PlayingCard].
extension PlayingCardPatterns on PlayingCard {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _PlayingCard value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _PlayingCard() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _PlayingCard value)  $default,){
final _that = this;
switch (_that) {
case _PlayingCard():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _PlayingCard value)?  $default,){
final _that = this;
switch (_that) {
case _PlayingCard() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( CardSuit suit,  CardRank rank)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _PlayingCard() when $default != null:
return $default(_that.suit,_that.rank);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( CardSuit suit,  CardRank rank)  $default,) {final _that = this;
switch (_that) {
case _PlayingCard():
return $default(_that.suit,_that.rank);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( CardSuit suit,  CardRank rank)?  $default,) {final _that = this;
switch (_that) {
case _PlayingCard() when $default != null:
return $default(_that.suit,_that.rank);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _PlayingCard extends PlayingCard {
  const _PlayingCard({required this.suit, required this.rank}): super._();
  factory _PlayingCard.fromJson(Map<String, dynamic> json) => _$PlayingCardFromJson(json);

@override final  CardSuit suit;
@override final  CardRank rank;

/// Create a copy of PlayingCard
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PlayingCardCopyWith<_PlayingCard> get copyWith => __$PlayingCardCopyWithImpl<_PlayingCard>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$PlayingCardToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _PlayingCard&&(identical(other.suit, suit) || other.suit == suit)&&(identical(other.rank, rank) || other.rank == rank));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,suit,rank);

@override
String toString() {
  return 'PlayingCard(suit: $suit, rank: $rank)';
}


}

/// @nodoc
abstract mixin class _$PlayingCardCopyWith<$Res> implements $PlayingCardCopyWith<$Res> {
  factory _$PlayingCardCopyWith(_PlayingCard value, $Res Function(_PlayingCard) _then) = __$PlayingCardCopyWithImpl;
@override @useResult
$Res call({
 CardSuit suit, CardRank rank
});




}
/// @nodoc
class __$PlayingCardCopyWithImpl<$Res>
    implements _$PlayingCardCopyWith<$Res> {
  __$PlayingCardCopyWithImpl(this._self, this._then);

  final _PlayingCard _self;
  final $Res Function(_PlayingCard) _then;

/// Create a copy of PlayingCard
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? suit = null,Object? rank = null,}) {
  return _then(_PlayingCard(
suit: null == suit ? _self.suit : suit // ignore: cast_nullable_to_non_nullable
as CardSuit,rank: null == rank ? _self.rank : rank // ignore: cast_nullable_to_non_nullable
as CardRank,
  ));
}


}

// dart format on
