// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'game_config.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

GameConfig _$GameConfigFromJson(Map<String, dynamic> json) {
  return _GameConfig.fromJson(json);
}

/// @nodoc
mixin _$GameConfig {
  /// Point value in units (user mentally maps to currency)
  /// e.g., 1 point = 10 units
  double get pointValue => throw _privateConstructorUsedError;

  /// Maximum players allowed in the room
  int get maxPlayers => throw _privateConstructorUsedError;

  /// Whether guests see ads (host can pay to disable)
  bool get allowAds => throw _privateConstructorUsedError;

  /// Total rounds in the game
  int get totalRounds => throw _privateConstructorUsedError;

  /// Entry fee in chips/units (optional boot amount)
  int get bootAmount => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $GameConfigCopyWith<GameConfig> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $GameConfigCopyWith<$Res> {
  factory $GameConfigCopyWith(
          GameConfig value, $Res Function(GameConfig) then) =
      _$GameConfigCopyWithImpl<$Res, GameConfig>;
  @useResult
  $Res call(
      {double pointValue,
      int maxPlayers,
      bool allowAds,
      int totalRounds,
      int bootAmount});
}

/// @nodoc
class _$GameConfigCopyWithImpl<$Res, $Val extends GameConfig>
    implements $GameConfigCopyWith<$Res> {
  _$GameConfigCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? pointValue = null,
    Object? maxPlayers = null,
    Object? allowAds = null,
    Object? totalRounds = null,
    Object? bootAmount = null,
  }) {
    return _then(_value.copyWith(
      pointValue: null == pointValue
          ? _value.pointValue
          : pointValue // ignore: cast_nullable_to_non_nullable
              as double,
      maxPlayers: null == maxPlayers
          ? _value.maxPlayers
          : maxPlayers // ignore: cast_nullable_to_non_nullable
              as int,
      allowAds: null == allowAds
          ? _value.allowAds
          : allowAds // ignore: cast_nullable_to_non_nullable
              as bool,
      totalRounds: null == totalRounds
          ? _value.totalRounds
          : totalRounds // ignore: cast_nullable_to_non_nullable
              as int,
      bootAmount: null == bootAmount
          ? _value.bootAmount
          : bootAmount // ignore: cast_nullable_to_non_nullable
              as int,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$GameConfigImplCopyWith<$Res>
    implements $GameConfigCopyWith<$Res> {
  factory _$$GameConfigImplCopyWith(
          _$GameConfigImpl value, $Res Function(_$GameConfigImpl) then) =
      __$$GameConfigImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {double pointValue,
      int maxPlayers,
      bool allowAds,
      int totalRounds,
      int bootAmount});
}

/// @nodoc
class __$$GameConfigImplCopyWithImpl<$Res>
    extends _$GameConfigCopyWithImpl<$Res, _$GameConfigImpl>
    implements _$$GameConfigImplCopyWith<$Res> {
  __$$GameConfigImplCopyWithImpl(
      _$GameConfigImpl _value, $Res Function(_$GameConfigImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? pointValue = null,
    Object? maxPlayers = null,
    Object? allowAds = null,
    Object? totalRounds = null,
    Object? bootAmount = null,
  }) {
    return _then(_$GameConfigImpl(
      pointValue: null == pointValue
          ? _value.pointValue
          : pointValue // ignore: cast_nullable_to_non_nullable
              as double,
      maxPlayers: null == maxPlayers
          ? _value.maxPlayers
          : maxPlayers // ignore: cast_nullable_to_non_nullable
              as int,
      allowAds: null == allowAds
          ? _value.allowAds
          : allowAds // ignore: cast_nullable_to_non_nullable
              as bool,
      totalRounds: null == totalRounds
          ? _value.totalRounds
          : totalRounds // ignore: cast_nullable_to_non_nullable
              as int,
      bootAmount: null == bootAmount
          ? _value.bootAmount
          : bootAmount // ignore: cast_nullable_to_non_nullable
              as int,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$GameConfigImpl implements _GameConfig {
  const _$GameConfigImpl(
      {this.pointValue = 10,
      this.maxPlayers = 4,
      this.allowAds = true,
      this.totalRounds = 5,
      this.bootAmount = 0});

  factory _$GameConfigImpl.fromJson(Map<String, dynamic> json) =>
      _$$GameConfigImplFromJson(json);

  /// Point value in units (user mentally maps to currency)
  /// e.g., 1 point = 10 units
  @override
  @JsonKey()
  final double pointValue;

  /// Maximum players allowed in the room
  @override
  @JsonKey()
  final int maxPlayers;

  /// Whether guests see ads (host can pay to disable)
  @override
  @JsonKey()
  final bool allowAds;

  /// Total rounds in the game
  @override
  @JsonKey()
  final int totalRounds;

  /// Entry fee in chips/units (optional boot amount)
  @override
  @JsonKey()
  final int bootAmount;

  @override
  String toString() {
    return 'GameConfig(pointValue: $pointValue, maxPlayers: $maxPlayers, allowAds: $allowAds, totalRounds: $totalRounds, bootAmount: $bootAmount)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$GameConfigImpl &&
            (identical(other.pointValue, pointValue) ||
                other.pointValue == pointValue) &&
            (identical(other.maxPlayers, maxPlayers) ||
                other.maxPlayers == maxPlayers) &&
            (identical(other.allowAds, allowAds) ||
                other.allowAds == allowAds) &&
            (identical(other.totalRounds, totalRounds) ||
                other.totalRounds == totalRounds) &&
            (identical(other.bootAmount, bootAmount) ||
                other.bootAmount == bootAmount));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(
      runtimeType, pointValue, maxPlayers, allowAds, totalRounds, bootAmount);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$GameConfigImplCopyWith<_$GameConfigImpl> get copyWith =>
      __$$GameConfigImplCopyWithImpl<_$GameConfigImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$GameConfigImplToJson(
      this,
    );
  }
}

abstract class _GameConfig implements GameConfig {
  const factory _GameConfig(
      {final double pointValue,
      final int maxPlayers,
      final bool allowAds,
      final int totalRounds,
      final int bootAmount}) = _$GameConfigImpl;

  factory _GameConfig.fromJson(Map<String, dynamic> json) =
      _$GameConfigImpl.fromJson;

  @override

  /// Point value in units (user mentally maps to currency)
  /// e.g., 1 point = 10 units
  double get pointValue;
  @override

  /// Maximum players allowed in the room
  int get maxPlayers;
  @override

  /// Whether guests see ads (host can pay to disable)
  bool get allowAds;
  @override

  /// Total rounds in the game
  int get totalRounds;
  @override

  /// Entry fee in chips/units (optional boot amount)
  int get bootAmount;
  @override
  @JsonKey(ignore: true)
  _$$GameConfigImplCopyWith<_$GameConfigImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
