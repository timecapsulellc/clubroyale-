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

/// User ID who owns this wallet
 String get userId;/// Current diamond balance
 int get balance;/// Total diamonds purchased (lifetime)
 int get totalPurchased;/// Total diamonds spent (lifetime)
 int get totalSpent;/// Last transaction timestamp
 DateTime? get lastUpdated;
/// Create a copy of DiamondWallet
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$DiamondWalletCopyWith<DiamondWallet> get copyWith => _$DiamondWalletCopyWithImpl<DiamondWallet>(this as DiamondWallet, _$identity);

  /// Serializes this DiamondWallet to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is DiamondWallet&&(identical(other.userId, userId) || other.userId == userId)&&(identical(other.balance, balance) || other.balance == balance)&&(identical(other.totalPurchased, totalPurchased) || other.totalPurchased == totalPurchased)&&(identical(other.totalSpent, totalSpent) || other.totalSpent == totalSpent)&&(identical(other.lastUpdated, lastUpdated) || other.lastUpdated == lastUpdated));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,userId,balance,totalPurchased,totalSpent,lastUpdated);

@override
String toString() {
  return 'DiamondWallet(userId: $userId, balance: $balance, totalPurchased: $totalPurchased, totalSpent: $totalSpent, lastUpdated: $lastUpdated)';
}


}

/// @nodoc
abstract mixin class $DiamondWalletCopyWith<$Res>  {
  factory $DiamondWalletCopyWith(DiamondWallet value, $Res Function(DiamondWallet) _then) = _$DiamondWalletCopyWithImpl;
@useResult
$Res call({
 String userId, int balance, int totalPurchased, int totalSpent, DateTime? lastUpdated
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
@pragma('vm:prefer-inline') @override $Res call({Object? userId = null,Object? balance = null,Object? totalPurchased = null,Object? totalSpent = null,Object? lastUpdated = freezed,}) {
  return _then(_self.copyWith(
userId: null == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as String,balance: null == balance ? _self.balance : balance // ignore: cast_nullable_to_non_nullable
as int,totalPurchased: null == totalPurchased ? _self.totalPurchased : totalPurchased // ignore: cast_nullable_to_non_nullable
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String userId,  int balance,  int totalPurchased,  int totalSpent,  DateTime? lastUpdated)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _DiamondWallet() when $default != null:
return $default(_that.userId,_that.balance,_that.totalPurchased,_that.totalSpent,_that.lastUpdated);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String userId,  int balance,  int totalPurchased,  int totalSpent,  DateTime? lastUpdated)  $default,) {final _that = this;
switch (_that) {
case _DiamondWallet():
return $default(_that.userId,_that.balance,_that.totalPurchased,_that.totalSpent,_that.lastUpdated);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String userId,  int balance,  int totalPurchased,  int totalSpent,  DateTime? lastUpdated)?  $default,) {final _that = this;
switch (_that) {
case _DiamondWallet() when $default != null:
return $default(_that.userId,_that.balance,_that.totalPurchased,_that.totalSpent,_that.lastUpdated);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _DiamondWallet implements DiamondWallet {
  const _DiamondWallet({required this.userId, this.balance = 0, this.totalPurchased = 0, this.totalSpent = 0, this.lastUpdated});
  factory _DiamondWallet.fromJson(Map<String, dynamic> json) => _$DiamondWalletFromJson(json);

/// User ID who owns this wallet
@override final  String userId;
/// Current diamond balance
@override@JsonKey() final  int balance;
/// Total diamonds purchased (lifetime)
@override@JsonKey() final  int totalPurchased;
/// Total diamonds spent (lifetime)
@override@JsonKey() final  int totalSpent;
/// Last transaction timestamp
@override final  DateTime? lastUpdated;

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
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _DiamondWallet&&(identical(other.userId, userId) || other.userId == userId)&&(identical(other.balance, balance) || other.balance == balance)&&(identical(other.totalPurchased, totalPurchased) || other.totalPurchased == totalPurchased)&&(identical(other.totalSpent, totalSpent) || other.totalSpent == totalSpent)&&(identical(other.lastUpdated, lastUpdated) || other.lastUpdated == lastUpdated));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,userId,balance,totalPurchased,totalSpent,lastUpdated);

@override
String toString() {
  return 'DiamondWallet(userId: $userId, balance: $balance, totalPurchased: $totalPurchased, totalSpent: $totalSpent, lastUpdated: $lastUpdated)';
}


}

/// @nodoc
abstract mixin class _$DiamondWalletCopyWith<$Res> implements $DiamondWalletCopyWith<$Res> {
  factory _$DiamondWalletCopyWith(_DiamondWallet value, $Res Function(_DiamondWallet) _then) = __$DiamondWalletCopyWithImpl;
@override @useResult
$Res call({
 String userId, int balance, int totalPurchased, int totalSpent, DateTime? lastUpdated
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
@override @pragma('vm:prefer-inline') $Res call({Object? userId = null,Object? balance = null,Object? totalPurchased = null,Object? totalSpent = null,Object? lastUpdated = freezed,}) {
  return _then(_DiamondWallet(
userId: null == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as String,balance: null == balance ? _self.balance : balance // ignore: cast_nullable_to_non_nullable
as int,totalPurchased: null == totalPurchased ? _self.totalPurchased : totalPurchased // ignore: cast_nullable_to_non_nullable
as int,totalSpent: null == totalSpent ? _self.totalSpent : totalSpent // ignore: cast_nullable_to_non_nullable
as int,lastUpdated: freezed == lastUpdated ? _self.lastUpdated : lastUpdated // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}


}


/// @nodoc
mixin _$DiamondTransaction {

 String get id; String get userId; int get amount; DiamondTransactionType get type; String? get description; String? get gameId; DateTime get createdAt;
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
 String id, String userId, int amount, DiamondTransactionType type, String? description, String? gameId, DateTime createdAt
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String userId,  int amount,  DiamondTransactionType type,  String? description,  String? gameId,  DateTime createdAt)?  $default,{required TResult orElse(),}) {final _that = this;
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String userId,  int amount,  DiamondTransactionType type,  String? description,  String? gameId,  DateTime createdAt)  $default,) {final _that = this;
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String userId,  int amount,  DiamondTransactionType type,  String? description,  String? gameId,  DateTime createdAt)?  $default,) {final _that = this;
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
  const _DiamondTransaction({required this.id, required this.userId, required this.amount, required this.type, this.description, this.gameId, required this.createdAt});
  factory _DiamondTransaction.fromJson(Map<String, dynamic> json) => _$DiamondTransactionFromJson(json);

@override final  String id;
@override final  String userId;
@override final  int amount;
@override final  DiamondTransactionType type;
@override final  String? description;
@override final  String? gameId;
@override final  DateTime createdAt;

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
 String id, String userId, int amount, DiamondTransactionType type, String? description, String? gameId, DateTime createdAt
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
