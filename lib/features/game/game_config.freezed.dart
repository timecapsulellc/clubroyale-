// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'game_config.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$GameConfig {

/// Point value in units (user mentally maps to currency)
/// e.g., 1 point = 10 units
 double get pointValue;/// Maximum players allowed in the room
 int get maxPlayers;/// Whether guests see ads (host can pay to disable)
 bool get allowAds;/// Total rounds in the game
 int get totalRounds;/// Entry fee in chips/units (optional boot amount)
 int get bootAmount;
/// Create a copy of GameConfig
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$GameConfigCopyWith<GameConfig> get copyWith => _$GameConfigCopyWithImpl<GameConfig>(this as GameConfig, _$identity);

  /// Serializes this GameConfig to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is GameConfig&&(identical(other.pointValue, pointValue) || other.pointValue == pointValue)&&(identical(other.maxPlayers, maxPlayers) || other.maxPlayers == maxPlayers)&&(identical(other.allowAds, allowAds) || other.allowAds == allowAds)&&(identical(other.totalRounds, totalRounds) || other.totalRounds == totalRounds)&&(identical(other.bootAmount, bootAmount) || other.bootAmount == bootAmount));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,pointValue,maxPlayers,allowAds,totalRounds,bootAmount);

@override
String toString() {
  return 'GameConfig(pointValue: $pointValue, maxPlayers: $maxPlayers, allowAds: $allowAds, totalRounds: $totalRounds, bootAmount: $bootAmount)';
}


}

/// @nodoc
abstract mixin class $GameConfigCopyWith<$Res>  {
  factory $GameConfigCopyWith(GameConfig value, $Res Function(GameConfig) _then) = _$GameConfigCopyWithImpl;
@useResult
$Res call({
 double pointValue, int maxPlayers, bool allowAds, int totalRounds, int bootAmount
});




}
/// @nodoc
class _$GameConfigCopyWithImpl<$Res>
    implements $GameConfigCopyWith<$Res> {
  _$GameConfigCopyWithImpl(this._self, this._then);

  final GameConfig _self;
  final $Res Function(GameConfig) _then;

/// Create a copy of GameConfig
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? pointValue = null,Object? maxPlayers = null,Object? allowAds = null,Object? totalRounds = null,Object? bootAmount = null,}) {
  return _then(_self.copyWith(
pointValue: null == pointValue ? _self.pointValue : pointValue // ignore: cast_nullable_to_non_nullable
as double,maxPlayers: null == maxPlayers ? _self.maxPlayers : maxPlayers // ignore: cast_nullable_to_non_nullable
as int,allowAds: null == allowAds ? _self.allowAds : allowAds // ignore: cast_nullable_to_non_nullable
as bool,totalRounds: null == totalRounds ? _self.totalRounds : totalRounds // ignore: cast_nullable_to_non_nullable
as int,bootAmount: null == bootAmount ? _self.bootAmount : bootAmount // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [GameConfig].
extension GameConfigPatterns on GameConfig {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _GameConfig value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _GameConfig() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _GameConfig value)  $default,){
final _that = this;
switch (_that) {
case _GameConfig():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _GameConfig value)?  $default,){
final _that = this;
switch (_that) {
case _GameConfig() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( double pointValue,  int maxPlayers,  bool allowAds,  int totalRounds,  int bootAmount)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _GameConfig() when $default != null:
return $default(_that.pointValue,_that.maxPlayers,_that.allowAds,_that.totalRounds,_that.bootAmount);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( double pointValue,  int maxPlayers,  bool allowAds,  int totalRounds,  int bootAmount)  $default,) {final _that = this;
switch (_that) {
case _GameConfig():
return $default(_that.pointValue,_that.maxPlayers,_that.allowAds,_that.totalRounds,_that.bootAmount);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( double pointValue,  int maxPlayers,  bool allowAds,  int totalRounds,  int bootAmount)?  $default,) {final _that = this;
switch (_that) {
case _GameConfig() when $default != null:
return $default(_that.pointValue,_that.maxPlayers,_that.allowAds,_that.totalRounds,_that.bootAmount);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _GameConfig implements GameConfig {
  const _GameConfig({this.pointValue = 10, this.maxPlayers = 8, this.allowAds = true, this.totalRounds = 5, this.bootAmount = 0});
  factory _GameConfig.fromJson(Map<String, dynamic> json) => _$GameConfigFromJson(json);

/// Point value in units (user mentally maps to currency)
/// e.g., 1 point = 10 units
@override@JsonKey() final  double pointValue;
/// Maximum players allowed in the room
@override@JsonKey() final  int maxPlayers;
/// Whether guests see ads (host can pay to disable)
@override@JsonKey() final  bool allowAds;
/// Total rounds in the game
@override@JsonKey() final  int totalRounds;
/// Entry fee in chips/units (optional boot amount)
@override@JsonKey() final  int bootAmount;

/// Create a copy of GameConfig
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$GameConfigCopyWith<_GameConfig> get copyWith => __$GameConfigCopyWithImpl<_GameConfig>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$GameConfigToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _GameConfig&&(identical(other.pointValue, pointValue) || other.pointValue == pointValue)&&(identical(other.maxPlayers, maxPlayers) || other.maxPlayers == maxPlayers)&&(identical(other.allowAds, allowAds) || other.allowAds == allowAds)&&(identical(other.totalRounds, totalRounds) || other.totalRounds == totalRounds)&&(identical(other.bootAmount, bootAmount) || other.bootAmount == bootAmount));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,pointValue,maxPlayers,allowAds,totalRounds,bootAmount);

@override
String toString() {
  return 'GameConfig(pointValue: $pointValue, maxPlayers: $maxPlayers, allowAds: $allowAds, totalRounds: $totalRounds, bootAmount: $bootAmount)';
}


}

/// @nodoc
abstract mixin class _$GameConfigCopyWith<$Res> implements $GameConfigCopyWith<$Res> {
  factory _$GameConfigCopyWith(_GameConfig value, $Res Function(_GameConfig) _then) = __$GameConfigCopyWithImpl;
@override @useResult
$Res call({
 double pointValue, int maxPlayers, bool allowAds, int totalRounds, int bootAmount
});




}
/// @nodoc
class __$GameConfigCopyWithImpl<$Res>
    implements _$GameConfigCopyWith<$Res> {
  __$GameConfigCopyWithImpl(this._self, this._then);

  final _GameConfig _self;
  final $Res Function(_GameConfig) _then;

/// Create a copy of GameConfig
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? pointValue = null,Object? maxPlayers = null,Object? allowAds = null,Object? totalRounds = null,Object? bootAmount = null,}) {
  return _then(_GameConfig(
pointValue: null == pointValue ? _self.pointValue : pointValue // ignore: cast_nullable_to_non_nullable
as double,maxPlayers: null == maxPlayers ? _self.maxPlayers : maxPlayers // ignore: cast_nullable_to_non_nullable
as int,allowAds: null == allowAds ? _self.allowAds : allowAds // ignore: cast_nullable_to_non_nullable
as bool,totalRounds: null == totalRounds ? _self.totalRounds : totalRounds // ignore: cast_nullable_to_non_nullable
as int,bootAmount: null == bootAmount ? _self.bootAmount : bootAmount // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}

// dart format on
