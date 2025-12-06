// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'game_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$Bid {

 String get playerId; int get amount;
/// Create a copy of Bid
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$BidCopyWith<Bid> get copyWith => _$BidCopyWithImpl<Bid>(this as Bid, _$identity);

  /// Serializes this Bid to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Bid&&(identical(other.playerId, playerId) || other.playerId == playerId)&&(identical(other.amount, amount) || other.amount == amount));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,playerId,amount);

@override
String toString() {
  return 'Bid(playerId: $playerId, amount: $amount)';
}


}

/// @nodoc
abstract mixin class $BidCopyWith<$Res>  {
  factory $BidCopyWith(Bid value, $Res Function(Bid) _then) = _$BidCopyWithImpl;
@useResult
$Res call({
 String playerId, int amount
});




}
/// @nodoc
class _$BidCopyWithImpl<$Res>
    implements $BidCopyWith<$Res> {
  _$BidCopyWithImpl(this._self, this._then);

  final Bid _self;
  final $Res Function(Bid) _then;

/// Create a copy of Bid
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? playerId = null,Object? amount = null,}) {
  return _then(_self.copyWith(
playerId: null == playerId ? _self.playerId : playerId // ignore: cast_nullable_to_non_nullable
as String,amount: null == amount ? _self.amount : amount // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [Bid].
extension BidPatterns on Bid {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Bid value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Bid() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Bid value)  $default,){
final _that = this;
switch (_that) {
case _Bid():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Bid value)?  $default,){
final _that = this;
switch (_that) {
case _Bid() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String playerId,  int amount)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Bid() when $default != null:
return $default(_that.playerId,_that.amount);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String playerId,  int amount)  $default,) {final _that = this;
switch (_that) {
case _Bid():
return $default(_that.playerId,_that.amount);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String playerId,  int amount)?  $default,) {final _that = this;
switch (_that) {
case _Bid() when $default != null:
return $default(_that.playerId,_that.amount);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _Bid implements Bid {
  const _Bid({required this.playerId, required this.amount});
  factory _Bid.fromJson(Map<String, dynamic> json) => _$BidFromJson(json);

@override final  String playerId;
@override final  int amount;

/// Create a copy of Bid
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$BidCopyWith<_Bid> get copyWith => __$BidCopyWithImpl<_Bid>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$BidToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Bid&&(identical(other.playerId, playerId) || other.playerId == playerId)&&(identical(other.amount, amount) || other.amount == amount));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,playerId,amount);

@override
String toString() {
  return 'Bid(playerId: $playerId, amount: $amount)';
}


}

/// @nodoc
abstract mixin class _$BidCopyWith<$Res> implements $BidCopyWith<$Res> {
  factory _$BidCopyWith(_Bid value, $Res Function(_Bid) _then) = __$BidCopyWithImpl;
@override @useResult
$Res call({
 String playerId, int amount
});




}
/// @nodoc
class __$BidCopyWithImpl<$Res>
    implements _$BidCopyWith<$Res> {
  __$BidCopyWithImpl(this._self, this._then);

  final _Bid _self;
  final $Res Function(_Bid) _then;

/// Create a copy of Bid
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? playerId = null,Object? amount = null,}) {
  return _then(_Bid(
playerId: null == playerId ? _self.playerId : playerId // ignore: cast_nullable_to_non_nullable
as String,amount: null == amount ? _self.amount : amount // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}


/// @nodoc
mixin _$PlayedCard {

 String get playerId; PlayingCard get card;
/// Create a copy of PlayedCard
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PlayedCardCopyWith<PlayedCard> get copyWith => _$PlayedCardCopyWithImpl<PlayedCard>(this as PlayedCard, _$identity);

  /// Serializes this PlayedCard to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PlayedCard&&(identical(other.playerId, playerId) || other.playerId == playerId)&&(identical(other.card, card) || other.card == card));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,playerId,card);

@override
String toString() {
  return 'PlayedCard(playerId: $playerId, card: $card)';
}


}

/// @nodoc
abstract mixin class $PlayedCardCopyWith<$Res>  {
  factory $PlayedCardCopyWith(PlayedCard value, $Res Function(PlayedCard) _then) = _$PlayedCardCopyWithImpl;
@useResult
$Res call({
 String playerId, PlayingCard card
});


$PlayingCardCopyWith<$Res> get card;

}
/// @nodoc
class _$PlayedCardCopyWithImpl<$Res>
    implements $PlayedCardCopyWith<$Res> {
  _$PlayedCardCopyWithImpl(this._self, this._then);

  final PlayedCard _self;
  final $Res Function(PlayedCard) _then;

/// Create a copy of PlayedCard
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? playerId = null,Object? card = null,}) {
  return _then(_self.copyWith(
playerId: null == playerId ? _self.playerId : playerId // ignore: cast_nullable_to_non_nullable
as String,card: null == card ? _self.card : card // ignore: cast_nullable_to_non_nullable
as PlayingCard,
  ));
}
/// Create a copy of PlayedCard
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$PlayingCardCopyWith<$Res> get card {
  
  return $PlayingCardCopyWith<$Res>(_self.card, (value) {
    return _then(_self.copyWith(card: value));
  });
}
}


/// Adds pattern-matching-related methods to [PlayedCard].
extension PlayedCardPatterns on PlayedCard {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _PlayedCard value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _PlayedCard() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _PlayedCard value)  $default,){
final _that = this;
switch (_that) {
case _PlayedCard():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _PlayedCard value)?  $default,){
final _that = this;
switch (_that) {
case _PlayedCard() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String playerId,  PlayingCard card)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _PlayedCard() when $default != null:
return $default(_that.playerId,_that.card);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String playerId,  PlayingCard card)  $default,) {final _that = this;
switch (_that) {
case _PlayedCard():
return $default(_that.playerId,_that.card);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String playerId,  PlayingCard card)?  $default,) {final _that = this;
switch (_that) {
case _PlayedCard() when $default != null:
return $default(_that.playerId,_that.card);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _PlayedCard implements PlayedCard {
  const _PlayedCard({required this.playerId, required this.card});
  factory _PlayedCard.fromJson(Map<String, dynamic> json) => _$PlayedCardFromJson(json);

@override final  String playerId;
@override final  PlayingCard card;

/// Create a copy of PlayedCard
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PlayedCardCopyWith<_PlayedCard> get copyWith => __$PlayedCardCopyWithImpl<_PlayedCard>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$PlayedCardToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _PlayedCard&&(identical(other.playerId, playerId) || other.playerId == playerId)&&(identical(other.card, card) || other.card == card));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,playerId,card);

@override
String toString() {
  return 'PlayedCard(playerId: $playerId, card: $card)';
}


}

/// @nodoc
abstract mixin class _$PlayedCardCopyWith<$Res> implements $PlayedCardCopyWith<$Res> {
  factory _$PlayedCardCopyWith(_PlayedCard value, $Res Function(_PlayedCard) _then) = __$PlayedCardCopyWithImpl;
@override @useResult
$Res call({
 String playerId, PlayingCard card
});


@override $PlayingCardCopyWith<$Res> get card;

}
/// @nodoc
class __$PlayedCardCopyWithImpl<$Res>
    implements _$PlayedCardCopyWith<$Res> {
  __$PlayedCardCopyWithImpl(this._self, this._then);

  final _PlayedCard _self;
  final $Res Function(_PlayedCard) _then;

/// Create a copy of PlayedCard
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? playerId = null,Object? card = null,}) {
  return _then(_PlayedCard(
playerId: null == playerId ? _self.playerId : playerId // ignore: cast_nullable_to_non_nullable
as String,card: null == card ? _self.card : card // ignore: cast_nullable_to_non_nullable
as PlayingCard,
  ));
}

/// Create a copy of PlayedCard
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$PlayingCardCopyWith<$Res> get card {
  
  return $PlayingCardCopyWith<$Res>(_self.card, (value) {
    return _then(_self.copyWith(card: value));
  });
}
}


/// @nodoc
mixin _$Trick {

 CardSuit get ledSuit; List<PlayedCard> get cards; String? get winnerId;
/// Create a copy of Trick
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$TrickCopyWith<Trick> get copyWith => _$TrickCopyWithImpl<Trick>(this as Trick, _$identity);

  /// Serializes this Trick to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Trick&&(identical(other.ledSuit, ledSuit) || other.ledSuit == ledSuit)&&const DeepCollectionEquality().equals(other.cards, cards)&&(identical(other.winnerId, winnerId) || other.winnerId == winnerId));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,ledSuit,const DeepCollectionEquality().hash(cards),winnerId);

@override
String toString() {
  return 'Trick(ledSuit: $ledSuit, cards: $cards, winnerId: $winnerId)';
}


}

/// @nodoc
abstract mixin class $TrickCopyWith<$Res>  {
  factory $TrickCopyWith(Trick value, $Res Function(Trick) _then) = _$TrickCopyWithImpl;
@useResult
$Res call({
 CardSuit ledSuit, List<PlayedCard> cards, String? winnerId
});




}
/// @nodoc
class _$TrickCopyWithImpl<$Res>
    implements $TrickCopyWith<$Res> {
  _$TrickCopyWithImpl(this._self, this._then);

  final Trick _self;
  final $Res Function(Trick) _then;

/// Create a copy of Trick
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? ledSuit = null,Object? cards = null,Object? winnerId = freezed,}) {
  return _then(_self.copyWith(
ledSuit: null == ledSuit ? _self.ledSuit : ledSuit // ignore: cast_nullable_to_non_nullable
as CardSuit,cards: null == cards ? _self.cards : cards // ignore: cast_nullable_to_non_nullable
as List<PlayedCard>,winnerId: freezed == winnerId ? _self.winnerId : winnerId // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [Trick].
extension TrickPatterns on Trick {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Trick value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Trick() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Trick value)  $default,){
final _that = this;
switch (_that) {
case _Trick():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Trick value)?  $default,){
final _that = this;
switch (_that) {
case _Trick() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( CardSuit ledSuit,  List<PlayedCard> cards,  String? winnerId)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Trick() when $default != null:
return $default(_that.ledSuit,_that.cards,_that.winnerId);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( CardSuit ledSuit,  List<PlayedCard> cards,  String? winnerId)  $default,) {final _that = this;
switch (_that) {
case _Trick():
return $default(_that.ledSuit,_that.cards,_that.winnerId);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( CardSuit ledSuit,  List<PlayedCard> cards,  String? winnerId)?  $default,) {final _that = this;
switch (_that) {
case _Trick() when $default != null:
return $default(_that.ledSuit,_that.cards,_that.winnerId);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _Trick extends Trick {
  const _Trick({required this.ledSuit, required final  List<PlayedCard> cards, this.winnerId}): _cards = cards,super._();
  factory _Trick.fromJson(Map<String, dynamic> json) => _$TrickFromJson(json);

@override final  CardSuit ledSuit;
 final  List<PlayedCard> _cards;
@override List<PlayedCard> get cards {
  if (_cards is EqualUnmodifiableListView) return _cards;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_cards);
}

@override final  String? winnerId;

/// Create a copy of Trick
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$TrickCopyWith<_Trick> get copyWith => __$TrickCopyWithImpl<_Trick>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$TrickToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Trick&&(identical(other.ledSuit, ledSuit) || other.ledSuit == ledSuit)&&const DeepCollectionEquality().equals(other._cards, _cards)&&(identical(other.winnerId, winnerId) || other.winnerId == winnerId));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,ledSuit,const DeepCollectionEquality().hash(_cards),winnerId);

@override
String toString() {
  return 'Trick(ledSuit: $ledSuit, cards: $cards, winnerId: $winnerId)';
}


}

/// @nodoc
abstract mixin class _$TrickCopyWith<$Res> implements $TrickCopyWith<$Res> {
  factory _$TrickCopyWith(_Trick value, $Res Function(_Trick) _then) = __$TrickCopyWithImpl;
@override @useResult
$Res call({
 CardSuit ledSuit, List<PlayedCard> cards, String? winnerId
});




}
/// @nodoc
class __$TrickCopyWithImpl<$Res>
    implements _$TrickCopyWith<$Res> {
  __$TrickCopyWithImpl(this._self, this._then);

  final _Trick _self;
  final $Res Function(_Trick) _then;

/// Create a copy of Trick
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? ledSuit = null,Object? cards = null,Object? winnerId = freezed,}) {
  return _then(_Trick(
ledSuit: null == ledSuit ? _self.ledSuit : ledSuit // ignore: cast_nullable_to_non_nullable
as CardSuit,cards: null == cards ? _self._cards : cards // ignore: cast_nullable_to_non_nullable
as List<PlayedCard>,winnerId: freezed == winnerId ? _self.winnerId : winnerId // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}


/// @nodoc
mixin _$PlayerTricks {

 String get playerId; int get tricksWon;
/// Create a copy of PlayerTricks
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PlayerTricksCopyWith<PlayerTricks> get copyWith => _$PlayerTricksCopyWithImpl<PlayerTricks>(this as PlayerTricks, _$identity);

  /// Serializes this PlayerTricks to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PlayerTricks&&(identical(other.playerId, playerId) || other.playerId == playerId)&&(identical(other.tricksWon, tricksWon) || other.tricksWon == tricksWon));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,playerId,tricksWon);

@override
String toString() {
  return 'PlayerTricks(playerId: $playerId, tricksWon: $tricksWon)';
}


}

/// @nodoc
abstract mixin class $PlayerTricksCopyWith<$Res>  {
  factory $PlayerTricksCopyWith(PlayerTricks value, $Res Function(PlayerTricks) _then) = _$PlayerTricksCopyWithImpl;
@useResult
$Res call({
 String playerId, int tricksWon
});




}
/// @nodoc
class _$PlayerTricksCopyWithImpl<$Res>
    implements $PlayerTricksCopyWith<$Res> {
  _$PlayerTricksCopyWithImpl(this._self, this._then);

  final PlayerTricks _self;
  final $Res Function(PlayerTricks) _then;

/// Create a copy of PlayerTricks
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? playerId = null,Object? tricksWon = null,}) {
  return _then(_self.copyWith(
playerId: null == playerId ? _self.playerId : playerId // ignore: cast_nullable_to_non_nullable
as String,tricksWon: null == tricksWon ? _self.tricksWon : tricksWon // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [PlayerTricks].
extension PlayerTricksPatterns on PlayerTricks {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _PlayerTricks value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _PlayerTricks() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _PlayerTricks value)  $default,){
final _that = this;
switch (_that) {
case _PlayerTricks():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _PlayerTricks value)?  $default,){
final _that = this;
switch (_that) {
case _PlayerTricks() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String playerId,  int tricksWon)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _PlayerTricks() when $default != null:
return $default(_that.playerId,_that.tricksWon);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String playerId,  int tricksWon)  $default,) {final _that = this;
switch (_that) {
case _PlayerTricks():
return $default(_that.playerId,_that.tricksWon);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String playerId,  int tricksWon)?  $default,) {final _that = this;
switch (_that) {
case _PlayerTricks() when $default != null:
return $default(_that.playerId,_that.tricksWon);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _PlayerTricks implements PlayerTricks {
  const _PlayerTricks({required this.playerId, this.tricksWon = 0});
  factory _PlayerTricks.fromJson(Map<String, dynamic> json) => _$PlayerTricksFromJson(json);

@override final  String playerId;
@override@JsonKey() final  int tricksWon;

/// Create a copy of PlayerTricks
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PlayerTricksCopyWith<_PlayerTricks> get copyWith => __$PlayerTricksCopyWithImpl<_PlayerTricks>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$PlayerTricksToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _PlayerTricks&&(identical(other.playerId, playerId) || other.playerId == playerId)&&(identical(other.tricksWon, tricksWon) || other.tricksWon == tricksWon));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,playerId,tricksWon);

@override
String toString() {
  return 'PlayerTricks(playerId: $playerId, tricksWon: $tricksWon)';
}


}

/// @nodoc
abstract mixin class _$PlayerTricksCopyWith<$Res> implements $PlayerTricksCopyWith<$Res> {
  factory _$PlayerTricksCopyWith(_PlayerTricks value, $Res Function(_PlayerTricks) _then) = __$PlayerTricksCopyWithImpl;
@override @useResult
$Res call({
 String playerId, int tricksWon
});




}
/// @nodoc
class __$PlayerTricksCopyWithImpl<$Res>
    implements _$PlayerTricksCopyWith<$Res> {
  __$PlayerTricksCopyWithImpl(this._self, this._then);

  final _PlayerTricks _self;
  final $Res Function(_PlayerTricks) _then;

/// Create a copy of PlayerTricks
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? playerId = null,Object? tricksWon = null,}) {
  return _then(_PlayerTricks(
playerId: null == playerId ? _self.playerId : playerId // ignore: cast_nullable_to_non_nullable
as String,tricksWon: null == tricksWon ? _self.tricksWon : tricksWon // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}

// dart format on
