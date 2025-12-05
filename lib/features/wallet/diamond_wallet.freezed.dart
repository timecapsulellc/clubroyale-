// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'diamond_wallet.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

DiamondWallet _$DiamondWalletFromJson(Map<String, dynamic> json) {
  return _DiamondWallet.fromJson(json);
}

/// @nodoc
mixin _$DiamondWallet {
  /// User ID who owns this wallet
  String get userId => throw _privateConstructorUsedError;

  /// Current diamond balance
  int get balance => throw _privateConstructorUsedError;

  /// Total diamonds purchased (lifetime)
  int get totalPurchased => throw _privateConstructorUsedError;

  /// Total diamonds spent (lifetime)
  int get totalSpent => throw _privateConstructorUsedError;

  /// Last transaction timestamp
  DateTime? get lastUpdated => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $DiamondWalletCopyWith<DiamondWallet> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $DiamondWalletCopyWith<$Res> {
  factory $DiamondWalletCopyWith(
          DiamondWallet value, $Res Function(DiamondWallet) then) =
      _$DiamondWalletCopyWithImpl<$Res, DiamondWallet>;
  @useResult
  $Res call(
      {String userId,
      int balance,
      int totalPurchased,
      int totalSpent,
      DateTime? lastUpdated});
}

/// @nodoc
class _$DiamondWalletCopyWithImpl<$Res, $Val extends DiamondWallet>
    implements $DiamondWalletCopyWith<$Res> {
  _$DiamondWalletCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? userId = null,
    Object? balance = null,
    Object? totalPurchased = null,
    Object? totalSpent = null,
    Object? lastUpdated = freezed,
  }) {
    return _then(_value.copyWith(
      userId: null == userId
          ? _value.userId
          : userId // ignore: cast_nullable_to_non_nullable
              as String,
      balance: null == balance
          ? _value.balance
          : balance // ignore: cast_nullable_to_non_nullable
              as int,
      totalPurchased: null == totalPurchased
          ? _value.totalPurchased
          : totalPurchased // ignore: cast_nullable_to_non_nullable
              as int,
      totalSpent: null == totalSpent
          ? _value.totalSpent
          : totalSpent // ignore: cast_nullable_to_non_nullable
              as int,
      lastUpdated: freezed == lastUpdated
          ? _value.lastUpdated
          : lastUpdated // ignore: cast_nullable_to_non_nullable
              as DateTime?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$DiamondWalletImplCopyWith<$Res>
    implements $DiamondWalletCopyWith<$Res> {
  factory _$$DiamondWalletImplCopyWith(
          _$DiamondWalletImpl value, $Res Function(_$DiamondWalletImpl) then) =
      __$$DiamondWalletImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String userId,
      int balance,
      int totalPurchased,
      int totalSpent,
      DateTime? lastUpdated});
}

/// @nodoc
class __$$DiamondWalletImplCopyWithImpl<$Res>
    extends _$DiamondWalletCopyWithImpl<$Res, _$DiamondWalletImpl>
    implements _$$DiamondWalletImplCopyWith<$Res> {
  __$$DiamondWalletImplCopyWithImpl(
      _$DiamondWalletImpl _value, $Res Function(_$DiamondWalletImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? userId = null,
    Object? balance = null,
    Object? totalPurchased = null,
    Object? totalSpent = null,
    Object? lastUpdated = freezed,
  }) {
    return _then(_$DiamondWalletImpl(
      userId: null == userId
          ? _value.userId
          : userId // ignore: cast_nullable_to_non_nullable
              as String,
      balance: null == balance
          ? _value.balance
          : balance // ignore: cast_nullable_to_non_nullable
              as int,
      totalPurchased: null == totalPurchased
          ? _value.totalPurchased
          : totalPurchased // ignore: cast_nullable_to_non_nullable
              as int,
      totalSpent: null == totalSpent
          ? _value.totalSpent
          : totalSpent // ignore: cast_nullable_to_non_nullable
              as int,
      lastUpdated: freezed == lastUpdated
          ? _value.lastUpdated
          : lastUpdated // ignore: cast_nullable_to_non_nullable
              as DateTime?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$DiamondWalletImpl implements _DiamondWallet {
  const _$DiamondWalletImpl(
      {required this.userId,
      this.balance = 0,
      this.totalPurchased = 0,
      this.totalSpent = 0,
      this.lastUpdated});

  factory _$DiamondWalletImpl.fromJson(Map<String, dynamic> json) =>
      _$$DiamondWalletImplFromJson(json);

  /// User ID who owns this wallet
  @override
  final String userId;

  /// Current diamond balance
  @override
  @JsonKey()
  final int balance;

  /// Total diamonds purchased (lifetime)
  @override
  @JsonKey()
  final int totalPurchased;

  /// Total diamonds spent (lifetime)
  @override
  @JsonKey()
  final int totalSpent;

  /// Last transaction timestamp
  @override
  final DateTime? lastUpdated;

  @override
  String toString() {
    return 'DiamondWallet(userId: $userId, balance: $balance, totalPurchased: $totalPurchased, totalSpent: $totalSpent, lastUpdated: $lastUpdated)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$DiamondWalletImpl &&
            (identical(other.userId, userId) || other.userId == userId) &&
            (identical(other.balance, balance) || other.balance == balance) &&
            (identical(other.totalPurchased, totalPurchased) ||
                other.totalPurchased == totalPurchased) &&
            (identical(other.totalSpent, totalSpent) ||
                other.totalSpent == totalSpent) &&
            (identical(other.lastUpdated, lastUpdated) ||
                other.lastUpdated == lastUpdated));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(
      runtimeType, userId, balance, totalPurchased, totalSpent, lastUpdated);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$DiamondWalletImplCopyWith<_$DiamondWalletImpl> get copyWith =>
      __$$DiamondWalletImplCopyWithImpl<_$DiamondWalletImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$DiamondWalletImplToJson(
      this,
    );
  }
}

abstract class _DiamondWallet implements DiamondWallet {
  const factory _DiamondWallet(
      {required final String userId,
      final int balance,
      final int totalPurchased,
      final int totalSpent,
      final DateTime? lastUpdated}) = _$DiamondWalletImpl;

  factory _DiamondWallet.fromJson(Map<String, dynamic> json) =
      _$DiamondWalletImpl.fromJson;

  @override

  /// User ID who owns this wallet
  String get userId;
  @override

  /// Current diamond balance
  int get balance;
  @override

  /// Total diamonds purchased (lifetime)
  int get totalPurchased;
  @override

  /// Total diamonds spent (lifetime)
  int get totalSpent;
  @override

  /// Last transaction timestamp
  DateTime? get lastUpdated;
  @override
  @JsonKey(ignore: true)
  _$$DiamondWalletImplCopyWith<_$DiamondWalletImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

DiamondTransaction _$DiamondTransactionFromJson(Map<String, dynamic> json) {
  return _DiamondTransaction.fromJson(json);
}

/// @nodoc
mixin _$DiamondTransaction {
  String get id => throw _privateConstructorUsedError;
  String get userId => throw _privateConstructorUsedError;
  int get amount => throw _privateConstructorUsedError;
  DiamondTransactionType get type => throw _privateConstructorUsedError;
  String? get description => throw _privateConstructorUsedError;
  String? get gameId => throw _privateConstructorUsedError;
  DateTime get createdAt => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $DiamondTransactionCopyWith<DiamondTransaction> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $DiamondTransactionCopyWith<$Res> {
  factory $DiamondTransactionCopyWith(
          DiamondTransaction value, $Res Function(DiamondTransaction) then) =
      _$DiamondTransactionCopyWithImpl<$Res, DiamondTransaction>;
  @useResult
  $Res call(
      {String id,
      String userId,
      int amount,
      DiamondTransactionType type,
      String? description,
      String? gameId,
      DateTime createdAt});
}

/// @nodoc
class _$DiamondTransactionCopyWithImpl<$Res, $Val extends DiamondTransaction>
    implements $DiamondTransactionCopyWith<$Res> {
  _$DiamondTransactionCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? userId = null,
    Object? amount = null,
    Object? type = null,
    Object? description = freezed,
    Object? gameId = freezed,
    Object? createdAt = null,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      userId: null == userId
          ? _value.userId
          : userId // ignore: cast_nullable_to_non_nullable
              as String,
      amount: null == amount
          ? _value.amount
          : amount // ignore: cast_nullable_to_non_nullable
              as int,
      type: null == type
          ? _value.type
          : type // ignore: cast_nullable_to_non_nullable
              as DiamondTransactionType,
      description: freezed == description
          ? _value.description
          : description // ignore: cast_nullable_to_non_nullable
              as String?,
      gameId: freezed == gameId
          ? _value.gameId
          : gameId // ignore: cast_nullable_to_non_nullable
              as String?,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$DiamondTransactionImplCopyWith<$Res>
    implements $DiamondTransactionCopyWith<$Res> {
  factory _$$DiamondTransactionImplCopyWith(_$DiamondTransactionImpl value,
          $Res Function(_$DiamondTransactionImpl) then) =
      __$$DiamondTransactionImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String userId,
      int amount,
      DiamondTransactionType type,
      String? description,
      String? gameId,
      DateTime createdAt});
}

/// @nodoc
class __$$DiamondTransactionImplCopyWithImpl<$Res>
    extends _$DiamondTransactionCopyWithImpl<$Res, _$DiamondTransactionImpl>
    implements _$$DiamondTransactionImplCopyWith<$Res> {
  __$$DiamondTransactionImplCopyWithImpl(_$DiamondTransactionImpl _value,
      $Res Function(_$DiamondTransactionImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? userId = null,
    Object? amount = null,
    Object? type = null,
    Object? description = freezed,
    Object? gameId = freezed,
    Object? createdAt = null,
  }) {
    return _then(_$DiamondTransactionImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      userId: null == userId
          ? _value.userId
          : userId // ignore: cast_nullable_to_non_nullable
              as String,
      amount: null == amount
          ? _value.amount
          : amount // ignore: cast_nullable_to_non_nullable
              as int,
      type: null == type
          ? _value.type
          : type // ignore: cast_nullable_to_non_nullable
              as DiamondTransactionType,
      description: freezed == description
          ? _value.description
          : description // ignore: cast_nullable_to_non_nullable
              as String?,
      gameId: freezed == gameId
          ? _value.gameId
          : gameId // ignore: cast_nullable_to_non_nullable
              as String?,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$DiamondTransactionImpl implements _DiamondTransaction {
  const _$DiamondTransactionImpl(
      {required this.id,
      required this.userId,
      required this.amount,
      required this.type,
      this.description,
      this.gameId,
      required this.createdAt});

  factory _$DiamondTransactionImpl.fromJson(Map<String, dynamic> json) =>
      _$$DiamondTransactionImplFromJson(json);

  @override
  final String id;
  @override
  final String userId;
  @override
  final int amount;
  @override
  final DiamondTransactionType type;
  @override
  final String? description;
  @override
  final String? gameId;
  @override
  final DateTime createdAt;

  @override
  String toString() {
    return 'DiamondTransaction(id: $id, userId: $userId, amount: $amount, type: $type, description: $description, gameId: $gameId, createdAt: $createdAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$DiamondTransactionImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.userId, userId) || other.userId == userId) &&
            (identical(other.amount, amount) || other.amount == amount) &&
            (identical(other.type, type) || other.type == type) &&
            (identical(other.description, description) ||
                other.description == description) &&
            (identical(other.gameId, gameId) || other.gameId == gameId) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(
      runtimeType, id, userId, amount, type, description, gameId, createdAt);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$DiamondTransactionImplCopyWith<_$DiamondTransactionImpl> get copyWith =>
      __$$DiamondTransactionImplCopyWithImpl<_$DiamondTransactionImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$DiamondTransactionImplToJson(
      this,
    );
  }
}

abstract class _DiamondTransaction implements DiamondTransaction {
  const factory _DiamondTransaction(
      {required final String id,
      required final String userId,
      required final int amount,
      required final DiamondTransactionType type,
      final String? description,
      final String? gameId,
      required final DateTime createdAt}) = _$DiamondTransactionImpl;

  factory _DiamondTransaction.fromJson(Map<String, dynamic> json) =
      _$DiamondTransactionImpl.fromJson;

  @override
  String get id;
  @override
  String get userId;
  @override
  int get amount;
  @override
  DiamondTransactionType get type;
  @override
  String? get description;
  @override
  String? get gameId;
  @override
  DateTime get createdAt;
  @override
  @JsonKey(ignore: true)
  _$$DiamondTransactionImplCopyWith<_$DiamondTransactionImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
