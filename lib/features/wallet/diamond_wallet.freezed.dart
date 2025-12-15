// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'diamond_wallet.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$DiamondWallet {

/// User ID
 String get userId;/// Current diamond balance
@JsonKey(name: 'diamondBalance') int get balance;/// User Tier (V5)
 UserTier get tier;/// Diamonds breakdown by origin (V5)
 Map<String, int> get diamondsByOrigin;/// Daily limits tracking
 int get dailyEarned; int get dailyTransferred; int get dailyReceived;/// Login streak tracking
 int get loginStreak;/// Last daily login claim
@JsonKey(fromJson: _nullableDateTimeFromJson, toJson: _nullableDateTimeToJson) DateTime? get lastDailyLoginClaim;/// Verification timestamps
@JsonKey(fromJson: _nullableDateTimeFromJson, toJson: _nullableDateTimeToJson) DateTime? get verifiedAt;@JsonKey(fromJson: _nullableDateTimeFromJson, toJson: _nullableDateTimeToJson) DateTime? get trustedAt;/// Legacy fields (kept for backward compatibility if needed)
 int get totalPurchased; int get totalSpent;@JsonKey(fromJson: _nullableDateTimeFromJson, toJson: _nullableDateTimeToJson) DateTime? get lastUpdated;
/// Create a copy of DiamondWallet
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$DiamondWalletCopyWith<DiamondWallet> get copyWith => _$DiamondWalletCopyWithImpl<DiamondWallet>(this as DiamondWallet, _$identity);

  /// Serializes this DiamondWallet to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is DiamondWallet&&(identical(other.userId, userId) || other.userId == userId)&&(identical(other.balance, balance) || other.balance == balance)&&(identical(other.tier, tier) || other.tier == tier)&&const DeepCollectionEquality().equals(other.diamondsByOrigin, diamondsByOrigin)&&(identical(other.dailyEarned, dailyEarned) || other.dailyEarned == dailyEarned)&&(identical(other.dailyTransferred, dailyTransferred) || other.dailyTransferred == dailyTransferred)&&(identical(other.dailyReceived, dailyReceived) || other.dailyReceived == dailyReceived)&&(identical(other.loginStreak, loginStreak) || other.loginStreak == loginStreak)&&(identical(other.lastDailyLoginClaim, lastDailyLoginClaim) || other.lastDailyLoginClaim == lastDailyLoginClaim)&&(identical(other.verifiedAt, verifiedAt) || other.verifiedAt == verifiedAt)&&(identical(other.trustedAt, trustedAt) || other.trustedAt == trustedAt)&&(identical(other.totalPurchased, totalPurchased) || other.totalPurchased == totalPurchased)&&(identical(other.totalSpent, totalSpent) || other.totalSpent == totalSpent)&&(identical(other.lastUpdated, lastUpdated) || other.lastUpdated == lastUpdated));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,userId,balance,tier,const DeepCollectionEquality().hash(diamondsByOrigin),dailyEarned,dailyTransferred,dailyReceived,loginStreak,lastDailyLoginClaim,verifiedAt,trustedAt,totalPurchased,totalSpent,lastUpdated);

@override
String toString() {
  return 'DiamondWallet(userId: $userId, balance: $balance, tier: $tier, diamondsByOrigin: $diamondsByOrigin, dailyEarned: $dailyEarned, dailyTransferred: $dailyTransferred, dailyReceived: $dailyReceived, loginStreak: $loginStreak, lastDailyLoginClaim: $lastDailyLoginClaim, verifiedAt: $verifiedAt, trustedAt: $trustedAt, totalPurchased: $totalPurchased, totalSpent: $totalSpent, lastUpdated: $lastUpdated)';
}


}

/// @nodoc
abstract mixin class $DiamondWalletCopyWith<$Res>  {
  factory $DiamondWalletCopyWith(DiamondWallet value, $Res Function(DiamondWallet) _then) = _$DiamondWalletCopyWithImpl;
@useResult
$Res call({
 String userId,@JsonKey(name: 'diamondBalance') int balance, UserTier tier, Map<String, int> diamondsByOrigin, int dailyEarned, int dailyTransferred, int dailyReceived, int loginStreak,@JsonKey(fromJson: _nullableDateTimeFromJson, toJson: _nullableDateTimeToJson) DateTime? lastDailyLoginClaim,@JsonKey(fromJson: _nullableDateTimeFromJson, toJson: _nullableDateTimeToJson) DateTime? verifiedAt,@JsonKey(fromJson: _nullableDateTimeFromJson, toJson: _nullableDateTimeToJson) DateTime? trustedAt, int totalPurchased, int totalSpent,@JsonKey(fromJson: _nullableDateTimeFromJson, toJson: _nullableDateTimeToJson) DateTime? lastUpdated
});




}
/// @nodoc
class _$DiamondWalletCopyWithImpl<$Res>
    implements $DiamondWalletCopyWith<$Res> {
  _$DiamondWalletCopyWithImpl(this._self, this._then);

  final DiamondWallet _self;
  final $Res Function(DiamondWallet) _then;

/// Create a copy of DiamondWallet
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? userId = null,Object? balance = null,Object? tier = null,Object? diamondsByOrigin = null,Object? dailyEarned = null,Object? dailyTransferred = null,Object? dailyReceived = null,Object? loginStreak = null,Object? lastDailyLoginClaim = freezed,Object? verifiedAt = freezed,Object? trustedAt = freezed,Object? totalPurchased = null,Object? totalSpent = null,Object? lastUpdated = freezed,}) {
  return _then(_self.copyWith(
userId: null == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as String,balance: null == balance ? _self.balance : balance // ignore: cast_nullable_to_non_nullable
as int,tier: null == tier ? _self.tier : tier // ignore: cast_nullable_to_non_nullable
as UserTier,diamondsByOrigin: null == diamondsByOrigin ? _self.diamondsByOrigin : diamondsByOrigin // ignore: cast_nullable_to_non_nullable
as Map<String, int>,dailyEarned: null == dailyEarned ? _self.dailyEarned : dailyEarned // ignore: cast_nullable_to_non_nullable
as int,dailyTransferred: null == dailyTransferred ? _self.dailyTransferred : dailyTransferred // ignore: cast_nullable_to_non_nullable
as int,dailyReceived: null == dailyReceived ? _self.dailyReceived : dailyReceived // ignore: cast_nullable_to_non_nullable
as int,loginStreak: null == loginStreak ? _self.loginStreak : loginStreak // ignore: cast_nullable_to_non_nullable
as int,lastDailyLoginClaim: freezed == lastDailyLoginClaim ? _self.lastDailyLoginClaim : lastDailyLoginClaim // ignore: cast_nullable_to_non_nullable
as DateTime?,verifiedAt: freezed == verifiedAt ? _self.verifiedAt : verifiedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,trustedAt: freezed == trustedAt ? _self.trustedAt : trustedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,totalPurchased: null == totalPurchased ? _self.totalPurchased : totalPurchased // ignore: cast_nullable_to_non_nullable
as int,totalSpent: null == totalSpent ? _self.totalSpent : totalSpent // ignore: cast_nullable_to_non_nullable
as int,lastUpdated: freezed == lastUpdated ? _self.lastUpdated : lastUpdated // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}

}


/// Adds pattern-matching-related methods to [DiamondWallet].
extension DiamondWalletPatterns on DiamondWallet {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _DiamondWallet value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _DiamondWallet() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _DiamondWallet value)  $default,){
final _that = this;
switch (_that) {
case _DiamondWallet():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _DiamondWallet value)?  $default,){
final _that = this;
switch (_that) {
case _DiamondWallet() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String userId, @JsonKey(name: 'diamondBalance')  int balance,  UserTier tier,  Map<String, int> diamondsByOrigin,  int dailyEarned,  int dailyTransferred,  int dailyReceived,  int loginStreak, @JsonKey(fromJson: _nullableDateTimeFromJson, toJson: _nullableDateTimeToJson)  DateTime? lastDailyLoginClaim, @JsonKey(fromJson: _nullableDateTimeFromJson, toJson: _nullableDateTimeToJson)  DateTime? verifiedAt, @JsonKey(fromJson: _nullableDateTimeFromJson, toJson: _nullableDateTimeToJson)  DateTime? trustedAt,  int totalPurchased,  int totalSpent, @JsonKey(fromJson: _nullableDateTimeFromJson, toJson: _nullableDateTimeToJson)  DateTime? lastUpdated)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _DiamondWallet() when $default != null:
return $default(_that.userId,_that.balance,_that.tier,_that.diamondsByOrigin,_that.dailyEarned,_that.dailyTransferred,_that.dailyReceived,_that.loginStreak,_that.lastDailyLoginClaim,_that.verifiedAt,_that.trustedAt,_that.totalPurchased,_that.totalSpent,_that.lastUpdated);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String userId, @JsonKey(name: 'diamondBalance')  int balance,  UserTier tier,  Map<String, int> diamondsByOrigin,  int dailyEarned,  int dailyTransferred,  int dailyReceived,  int loginStreak, @JsonKey(fromJson: _nullableDateTimeFromJson, toJson: _nullableDateTimeToJson)  DateTime? lastDailyLoginClaim, @JsonKey(fromJson: _nullableDateTimeFromJson, toJson: _nullableDateTimeToJson)  DateTime? verifiedAt, @JsonKey(fromJson: _nullableDateTimeFromJson, toJson: _nullableDateTimeToJson)  DateTime? trustedAt,  int totalPurchased,  int totalSpent, @JsonKey(fromJson: _nullableDateTimeFromJson, toJson: _nullableDateTimeToJson)  DateTime? lastUpdated)  $default,) {final _that = this;
switch (_that) {
case _DiamondWallet():
return $default(_that.userId,_that.balance,_that.tier,_that.diamondsByOrigin,_that.dailyEarned,_that.dailyTransferred,_that.dailyReceived,_that.loginStreak,_that.lastDailyLoginClaim,_that.verifiedAt,_that.trustedAt,_that.totalPurchased,_that.totalSpent,_that.lastUpdated);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String userId, @JsonKey(name: 'diamondBalance')  int balance,  UserTier tier,  Map<String, int> diamondsByOrigin,  int dailyEarned,  int dailyTransferred,  int dailyReceived,  int loginStreak, @JsonKey(fromJson: _nullableDateTimeFromJson, toJson: _nullableDateTimeToJson)  DateTime? lastDailyLoginClaim, @JsonKey(fromJson: _nullableDateTimeFromJson, toJson: _nullableDateTimeToJson)  DateTime? verifiedAt, @JsonKey(fromJson: _nullableDateTimeFromJson, toJson: _nullableDateTimeToJson)  DateTime? trustedAt,  int totalPurchased,  int totalSpent, @JsonKey(fromJson: _nullableDateTimeFromJson, toJson: _nullableDateTimeToJson)  DateTime? lastUpdated)?  $default,) {final _that = this;
switch (_that) {
case _DiamondWallet() when $default != null:
return $default(_that.userId,_that.balance,_that.tier,_that.diamondsByOrigin,_that.dailyEarned,_that.dailyTransferred,_that.dailyReceived,_that.loginStreak,_that.lastDailyLoginClaim,_that.verifiedAt,_that.trustedAt,_that.totalPurchased,_that.totalSpent,_that.lastUpdated);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _DiamondWallet implements DiamondWallet {
  const _DiamondWallet({required this.userId, @JsonKey(name: 'diamondBalance') this.balance = 0, this.tier = UserTier.basic, final  Map<String, int> diamondsByOrigin = const {}, this.dailyEarned = 0, this.dailyTransferred = 0, this.dailyReceived = 0, this.loginStreak = 0, @JsonKey(fromJson: _nullableDateTimeFromJson, toJson: _nullableDateTimeToJson) this.lastDailyLoginClaim, @JsonKey(fromJson: _nullableDateTimeFromJson, toJson: _nullableDateTimeToJson) this.verifiedAt, @JsonKey(fromJson: _nullableDateTimeFromJson, toJson: _nullableDateTimeToJson) this.trustedAt, this.totalPurchased = 0, this.totalSpent = 0, @JsonKey(fromJson: _nullableDateTimeFromJson, toJson: _nullableDateTimeToJson) this.lastUpdated}): _diamondsByOrigin = diamondsByOrigin;
  factory _DiamondWallet.fromJson(Map<String, dynamic> json) => _$DiamondWalletFromJson(json);

/// User ID
@override final  String userId;
/// Current diamond balance
@override@JsonKey(name: 'diamondBalance') final  int balance;
/// User Tier (V5)
@override@JsonKey() final  UserTier tier;
/// Diamonds breakdown by origin (V5)
 final  Map<String, int> _diamondsByOrigin;
/// Diamonds breakdown by origin (V5)
@override@JsonKey() Map<String, int> get diamondsByOrigin {
  if (_diamondsByOrigin is EqualUnmodifiableMapView) return _diamondsByOrigin;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_diamondsByOrigin);
}

/// Daily limits tracking
@override@JsonKey() final  int dailyEarned;
@override@JsonKey() final  int dailyTransferred;
@override@JsonKey() final  int dailyReceived;
/// Login streak tracking
@override@JsonKey() final  int loginStreak;
/// Last daily login claim
@override@JsonKey(fromJson: _nullableDateTimeFromJson, toJson: _nullableDateTimeToJson) final  DateTime? lastDailyLoginClaim;
/// Verification timestamps
@override@JsonKey(fromJson: _nullableDateTimeFromJson, toJson: _nullableDateTimeToJson) final  DateTime? verifiedAt;
@override@JsonKey(fromJson: _nullableDateTimeFromJson, toJson: _nullableDateTimeToJson) final  DateTime? trustedAt;
/// Legacy fields (kept for backward compatibility if needed)
@override@JsonKey() final  int totalPurchased;
@override@JsonKey() final  int totalSpent;
@override@JsonKey(fromJson: _nullableDateTimeFromJson, toJson: _nullableDateTimeToJson) final  DateTime? lastUpdated;

/// Create a copy of DiamondWallet
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$DiamondWalletCopyWith<_DiamondWallet> get copyWith => __$DiamondWalletCopyWithImpl<_DiamondWallet>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$DiamondWalletToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _DiamondWallet&&(identical(other.userId, userId) || other.userId == userId)&&(identical(other.balance, balance) || other.balance == balance)&&(identical(other.tier, tier) || other.tier == tier)&&const DeepCollectionEquality().equals(other._diamondsByOrigin, _diamondsByOrigin)&&(identical(other.dailyEarned, dailyEarned) || other.dailyEarned == dailyEarned)&&(identical(other.dailyTransferred, dailyTransferred) || other.dailyTransferred == dailyTransferred)&&(identical(other.dailyReceived, dailyReceived) || other.dailyReceived == dailyReceived)&&(identical(other.loginStreak, loginStreak) || other.loginStreak == loginStreak)&&(identical(other.lastDailyLoginClaim, lastDailyLoginClaim) || other.lastDailyLoginClaim == lastDailyLoginClaim)&&(identical(other.verifiedAt, verifiedAt) || other.verifiedAt == verifiedAt)&&(identical(other.trustedAt, trustedAt) || other.trustedAt == trustedAt)&&(identical(other.totalPurchased, totalPurchased) || other.totalPurchased == totalPurchased)&&(identical(other.totalSpent, totalSpent) || other.totalSpent == totalSpent)&&(identical(other.lastUpdated, lastUpdated) || other.lastUpdated == lastUpdated));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,userId,balance,tier,const DeepCollectionEquality().hash(_diamondsByOrigin),dailyEarned,dailyTransferred,dailyReceived,loginStreak,lastDailyLoginClaim,verifiedAt,trustedAt,totalPurchased,totalSpent,lastUpdated);

@override
String toString() {
  return 'DiamondWallet(userId: $userId, balance: $balance, tier: $tier, diamondsByOrigin: $diamondsByOrigin, dailyEarned: $dailyEarned, dailyTransferred: $dailyTransferred, dailyReceived: $dailyReceived, loginStreak: $loginStreak, lastDailyLoginClaim: $lastDailyLoginClaim, verifiedAt: $verifiedAt, trustedAt: $trustedAt, totalPurchased: $totalPurchased, totalSpent: $totalSpent, lastUpdated: $lastUpdated)';
}


}

/// @nodoc
abstract mixin class _$DiamondWalletCopyWith<$Res> implements $DiamondWalletCopyWith<$Res> {
  factory _$DiamondWalletCopyWith(_DiamondWallet value, $Res Function(_DiamondWallet) _then) = __$DiamondWalletCopyWithImpl;
@override @useResult
$Res call({
 String userId,@JsonKey(name: 'diamondBalance') int balance, UserTier tier, Map<String, int> diamondsByOrigin, int dailyEarned, int dailyTransferred, int dailyReceived, int loginStreak,@JsonKey(fromJson: _nullableDateTimeFromJson, toJson: _nullableDateTimeToJson) DateTime? lastDailyLoginClaim,@JsonKey(fromJson: _nullableDateTimeFromJson, toJson: _nullableDateTimeToJson) DateTime? verifiedAt,@JsonKey(fromJson: _nullableDateTimeFromJson, toJson: _nullableDateTimeToJson) DateTime? trustedAt, int totalPurchased, int totalSpent,@JsonKey(fromJson: _nullableDateTimeFromJson, toJson: _nullableDateTimeToJson) DateTime? lastUpdated
});




}
/// @nodoc
class __$DiamondWalletCopyWithImpl<$Res>
    implements _$DiamondWalletCopyWith<$Res> {
  __$DiamondWalletCopyWithImpl(this._self, this._then);

  final _DiamondWallet _self;
  final $Res Function(_DiamondWallet) _then;

/// Create a copy of DiamondWallet
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? userId = null,Object? balance = null,Object? tier = null,Object? diamondsByOrigin = null,Object? dailyEarned = null,Object? dailyTransferred = null,Object? dailyReceived = null,Object? loginStreak = null,Object? lastDailyLoginClaim = freezed,Object? verifiedAt = freezed,Object? trustedAt = freezed,Object? totalPurchased = null,Object? totalSpent = null,Object? lastUpdated = freezed,}) {
  return _then(_DiamondWallet(
userId: null == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as String,balance: null == balance ? _self.balance : balance // ignore: cast_nullable_to_non_nullable
as int,tier: null == tier ? _self.tier : tier // ignore: cast_nullable_to_non_nullable
as UserTier,diamondsByOrigin: null == diamondsByOrigin ? _self._diamondsByOrigin : diamondsByOrigin // ignore: cast_nullable_to_non_nullable
as Map<String, int>,dailyEarned: null == dailyEarned ? _self.dailyEarned : dailyEarned // ignore: cast_nullable_to_non_nullable
as int,dailyTransferred: null == dailyTransferred ? _self.dailyTransferred : dailyTransferred // ignore: cast_nullable_to_non_nullable
as int,dailyReceived: null == dailyReceived ? _self.dailyReceived : dailyReceived // ignore: cast_nullable_to_non_nullable
as int,loginStreak: null == loginStreak ? _self.loginStreak : loginStreak // ignore: cast_nullable_to_non_nullable
as int,lastDailyLoginClaim: freezed == lastDailyLoginClaim ? _self.lastDailyLoginClaim : lastDailyLoginClaim // ignore: cast_nullable_to_non_nullable
as DateTime?,verifiedAt: freezed == verifiedAt ? _self.verifiedAt : verifiedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,trustedAt: freezed == trustedAt ? _self.trustedAt : trustedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,totalPurchased: null == totalPurchased ? _self.totalPurchased : totalPurchased // ignore: cast_nullable_to_non_nullable
as int,totalSpent: null == totalSpent ? _self.totalSpent : totalSpent // ignore: cast_nullable_to_non_nullable
as int,lastUpdated: freezed == lastUpdated ? _self.lastUpdated : lastUpdated // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}


}


/// @nodoc
mixin _$DiamondTransaction {

 String get id; String get userId; int get amount; DiamondTransactionType get type; String? get description; String? get gameId;@JsonKey(fromJson: _dateTimeFromJson, toJson: _dateTimeToJson) DateTime get createdAt;
/// Create a copy of DiamondTransaction
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$DiamondTransactionCopyWith<DiamondTransaction> get copyWith => _$DiamondTransactionCopyWithImpl<DiamondTransaction>(this as DiamondTransaction, _$identity);

  /// Serializes this DiamondTransaction to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is DiamondTransaction&&(identical(other.id, id) || other.id == id)&&(identical(other.userId, userId) || other.userId == userId)&&(identical(other.amount, amount) || other.amount == amount)&&(identical(other.type, type) || other.type == type)&&(identical(other.description, description) || other.description == description)&&(identical(other.gameId, gameId) || other.gameId == gameId)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,userId,amount,type,description,gameId,createdAt);

@override
String toString() {
  return 'DiamondTransaction(id: $id, userId: $userId, amount: $amount, type: $type, description: $description, gameId: $gameId, createdAt: $createdAt)';
}


}

/// @nodoc
abstract mixin class $DiamondTransactionCopyWith<$Res>  {
  factory $DiamondTransactionCopyWith(DiamondTransaction value, $Res Function(DiamondTransaction) _then) = _$DiamondTransactionCopyWithImpl;
@useResult
$Res call({
 String id, String userId, int amount, DiamondTransactionType type, String? description, String? gameId,@JsonKey(fromJson: _dateTimeFromJson, toJson: _dateTimeToJson) DateTime createdAt
});




}
/// @nodoc
class _$DiamondTransactionCopyWithImpl<$Res>
    implements $DiamondTransactionCopyWith<$Res> {
  _$DiamondTransactionCopyWithImpl(this._self, this._then);

  final DiamondTransaction _self;
  final $Res Function(DiamondTransaction) _then;

/// Create a copy of DiamondTransaction
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? userId = null,Object? amount = null,Object? type = null,Object? description = freezed,Object? gameId = freezed,Object? createdAt = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,userId: null == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as String,amount: null == amount ? _self.amount : amount // ignore: cast_nullable_to_non_nullable
as int,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as DiamondTransactionType,description: freezed == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String?,gameId: freezed == gameId ? _self.gameId : gameId // ignore: cast_nullable_to_non_nullable
as String?,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}

}


/// Adds pattern-matching-related methods to [DiamondTransaction].
extension DiamondTransactionPatterns on DiamondTransaction {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _DiamondTransaction value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _DiamondTransaction() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _DiamondTransaction value)  $default,){
final _that = this;
switch (_that) {
case _DiamondTransaction():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _DiamondTransaction value)?  $default,){
final _that = this;
switch (_that) {
case _DiamondTransaction() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String userId,  int amount,  DiamondTransactionType type,  String? description,  String? gameId, @JsonKey(fromJson: _dateTimeFromJson, toJson: _dateTimeToJson)  DateTime createdAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _DiamondTransaction() when $default != null:
return $default(_that.id,_that.userId,_that.amount,_that.type,_that.description,_that.gameId,_that.createdAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String userId,  int amount,  DiamondTransactionType type,  String? description,  String? gameId, @JsonKey(fromJson: _dateTimeFromJson, toJson: _dateTimeToJson)  DateTime createdAt)  $default,) {final _that = this;
switch (_that) {
case _DiamondTransaction():
return $default(_that.id,_that.userId,_that.amount,_that.type,_that.description,_that.gameId,_that.createdAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String userId,  int amount,  DiamondTransactionType type,  String? description,  String? gameId, @JsonKey(fromJson: _dateTimeFromJson, toJson: _dateTimeToJson)  DateTime createdAt)?  $default,) {final _that = this;
switch (_that) {
case _DiamondTransaction() when $default != null:
return $default(_that.id,_that.userId,_that.amount,_that.type,_that.description,_that.gameId,_that.createdAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _DiamondTransaction implements DiamondTransaction {
  const _DiamondTransaction({required this.id, required this.userId, required this.amount, required this.type, this.description, this.gameId, @JsonKey(fromJson: _dateTimeFromJson, toJson: _dateTimeToJson) required this.createdAt});
  factory _DiamondTransaction.fromJson(Map<String, dynamic> json) => _$DiamondTransactionFromJson(json);

@override final  String id;
@override final  String userId;
@override final  int amount;
@override final  DiamondTransactionType type;
@override final  String? description;
@override final  String? gameId;
@override@JsonKey(fromJson: _dateTimeFromJson, toJson: _dateTimeToJson) final  DateTime createdAt;

/// Create a copy of DiamondTransaction
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$DiamondTransactionCopyWith<_DiamondTransaction> get copyWith => __$DiamondTransactionCopyWithImpl<_DiamondTransaction>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$DiamondTransactionToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _DiamondTransaction&&(identical(other.id, id) || other.id == id)&&(identical(other.userId, userId) || other.userId == userId)&&(identical(other.amount, amount) || other.amount == amount)&&(identical(other.type, type) || other.type == type)&&(identical(other.description, description) || other.description == description)&&(identical(other.gameId, gameId) || other.gameId == gameId)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,userId,amount,type,description,gameId,createdAt);

@override
String toString() {
  return 'DiamondTransaction(id: $id, userId: $userId, amount: $amount, type: $type, description: $description, gameId: $gameId, createdAt: $createdAt)';
}


}

/// @nodoc
abstract mixin class _$DiamondTransactionCopyWith<$Res> implements $DiamondTransactionCopyWith<$Res> {
  factory _$DiamondTransactionCopyWith(_DiamondTransaction value, $Res Function(_DiamondTransaction) _then) = __$DiamondTransactionCopyWithImpl;
@override @useResult
$Res call({
 String id, String userId, int amount, DiamondTransactionType type, String? description, String? gameId,@JsonKey(fromJson: _dateTimeFromJson, toJson: _dateTimeToJson) DateTime createdAt
});




}
/// @nodoc
class __$DiamondTransactionCopyWithImpl<$Res>
    implements _$DiamondTransactionCopyWith<$Res> {
  __$DiamondTransactionCopyWithImpl(this._self, this._then);

  final _DiamondTransaction _self;
  final $Res Function(_DiamondTransaction) _then;

/// Create a copy of DiamondTransaction
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? userId = null,Object? amount = null,Object? type = null,Object? description = freezed,Object? gameId = freezed,Object? createdAt = null,}) {
  return _then(_DiamondTransaction(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,userId: null == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as String,amount: null == amount ? _self.amount : amount // ignore: cast_nullable_to_non_nullable
as int,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as DiamondTransactionType,description: freezed == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String?,gameId: freezed == gameId ? _self.gameId : gameId // ignore: cast_nullable_to_non_nullable
as String?,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}


}

// dart format on
