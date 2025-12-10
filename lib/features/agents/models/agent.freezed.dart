// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'agent.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$AgentRequest {

 String get id; AgentType get targetAgent; String get action; Map<String, dynamic> get payload; String? get userId; String? get sessionId; AgentPriority get priority; DateTime? get createdAt; int get maxRetries;
/// Create a copy of AgentRequest
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AgentRequestCopyWith<AgentRequest> get copyWith => _$AgentRequestCopyWithImpl<AgentRequest>(this as AgentRequest, _$identity);

  /// Serializes this AgentRequest to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AgentRequest&&(identical(other.id, id) || other.id == id)&&(identical(other.targetAgent, targetAgent) || other.targetAgent == targetAgent)&&(identical(other.action, action) || other.action == action)&&const DeepCollectionEquality().equals(other.payload, payload)&&(identical(other.userId, userId) || other.userId == userId)&&(identical(other.sessionId, sessionId) || other.sessionId == sessionId)&&(identical(other.priority, priority) || other.priority == priority)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.maxRetries, maxRetries) || other.maxRetries == maxRetries));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,targetAgent,action,const DeepCollectionEquality().hash(payload),userId,sessionId,priority,createdAt,maxRetries);

@override
String toString() {
  return 'AgentRequest(id: $id, targetAgent: $targetAgent, action: $action, payload: $payload, userId: $userId, sessionId: $sessionId, priority: $priority, createdAt: $createdAt, maxRetries: $maxRetries)';
}


}

/// @nodoc
abstract mixin class $AgentRequestCopyWith<$Res>  {
  factory $AgentRequestCopyWith(AgentRequest value, $Res Function(AgentRequest) _then) = _$AgentRequestCopyWithImpl;
@useResult
$Res call({
 String id, AgentType targetAgent, String action, Map<String, dynamic> payload, String? userId, String? sessionId, AgentPriority priority, DateTime? createdAt, int maxRetries
});




}
/// @nodoc
class _$AgentRequestCopyWithImpl<$Res>
    implements $AgentRequestCopyWith<$Res> {
  _$AgentRequestCopyWithImpl(this._self, this._then);

  final AgentRequest _self;
  final $Res Function(AgentRequest) _then;

/// Create a copy of AgentRequest
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? targetAgent = null,Object? action = null,Object? payload = null,Object? userId = freezed,Object? sessionId = freezed,Object? priority = null,Object? createdAt = freezed,Object? maxRetries = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,targetAgent: null == targetAgent ? _self.targetAgent : targetAgent // ignore: cast_nullable_to_non_nullable
as AgentType,action: null == action ? _self.action : action // ignore: cast_nullable_to_non_nullable
as String,payload: null == payload ? _self.payload : payload // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>,userId: freezed == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as String?,sessionId: freezed == sessionId ? _self.sessionId : sessionId // ignore: cast_nullable_to_non_nullable
as String?,priority: null == priority ? _self.priority : priority // ignore: cast_nullable_to_non_nullable
as AgentPriority,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime?,maxRetries: null == maxRetries ? _self.maxRetries : maxRetries // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [AgentRequest].
extension AgentRequestPatterns on AgentRequest {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _AgentRequest value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _AgentRequest() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _AgentRequest value)  $default,){
final _that = this;
switch (_that) {
case _AgentRequest():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _AgentRequest value)?  $default,){
final _that = this;
switch (_that) {
case _AgentRequest() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  AgentType targetAgent,  String action,  Map<String, dynamic> payload,  String? userId,  String? sessionId,  AgentPriority priority,  DateTime? createdAt,  int maxRetries)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _AgentRequest() when $default != null:
return $default(_that.id,_that.targetAgent,_that.action,_that.payload,_that.userId,_that.sessionId,_that.priority,_that.createdAt,_that.maxRetries);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  AgentType targetAgent,  String action,  Map<String, dynamic> payload,  String? userId,  String? sessionId,  AgentPriority priority,  DateTime? createdAt,  int maxRetries)  $default,) {final _that = this;
switch (_that) {
case _AgentRequest():
return $default(_that.id,_that.targetAgent,_that.action,_that.payload,_that.userId,_that.sessionId,_that.priority,_that.createdAt,_that.maxRetries);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  AgentType targetAgent,  String action,  Map<String, dynamic> payload,  String? userId,  String? sessionId,  AgentPriority priority,  DateTime? createdAt,  int maxRetries)?  $default,) {final _that = this;
switch (_that) {
case _AgentRequest() when $default != null:
return $default(_that.id,_that.targetAgent,_that.action,_that.payload,_that.userId,_that.sessionId,_that.priority,_that.createdAt,_that.maxRetries);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _AgentRequest implements AgentRequest {
  const _AgentRequest({required this.id, required this.targetAgent, required this.action, required final  Map<String, dynamic> payload, this.userId, this.sessionId, this.priority = AgentPriority.normal, this.createdAt, this.maxRetries = 3}): _payload = payload;
  factory _AgentRequest.fromJson(Map<String, dynamic> json) => _$AgentRequestFromJson(json);

@override final  String id;
@override final  AgentType targetAgent;
@override final  String action;
 final  Map<String, dynamic> _payload;
@override Map<String, dynamic> get payload {
  if (_payload is EqualUnmodifiableMapView) return _payload;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_payload);
}

@override final  String? userId;
@override final  String? sessionId;
@override@JsonKey() final  AgentPriority priority;
@override final  DateTime? createdAt;
@override@JsonKey() final  int maxRetries;

/// Create a copy of AgentRequest
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$AgentRequestCopyWith<_AgentRequest> get copyWith => __$AgentRequestCopyWithImpl<_AgentRequest>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$AgentRequestToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _AgentRequest&&(identical(other.id, id) || other.id == id)&&(identical(other.targetAgent, targetAgent) || other.targetAgent == targetAgent)&&(identical(other.action, action) || other.action == action)&&const DeepCollectionEquality().equals(other._payload, _payload)&&(identical(other.userId, userId) || other.userId == userId)&&(identical(other.sessionId, sessionId) || other.sessionId == sessionId)&&(identical(other.priority, priority) || other.priority == priority)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.maxRetries, maxRetries) || other.maxRetries == maxRetries));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,targetAgent,action,const DeepCollectionEquality().hash(_payload),userId,sessionId,priority,createdAt,maxRetries);

@override
String toString() {
  return 'AgentRequest(id: $id, targetAgent: $targetAgent, action: $action, payload: $payload, userId: $userId, sessionId: $sessionId, priority: $priority, createdAt: $createdAt, maxRetries: $maxRetries)';
}


}

/// @nodoc
abstract mixin class _$AgentRequestCopyWith<$Res> implements $AgentRequestCopyWith<$Res> {
  factory _$AgentRequestCopyWith(_AgentRequest value, $Res Function(_AgentRequest) _then) = __$AgentRequestCopyWithImpl;
@override @useResult
$Res call({
 String id, AgentType targetAgent, String action, Map<String, dynamic> payload, String? userId, String? sessionId, AgentPriority priority, DateTime? createdAt, int maxRetries
});




}
/// @nodoc
class __$AgentRequestCopyWithImpl<$Res>
    implements _$AgentRequestCopyWith<$Res> {
  __$AgentRequestCopyWithImpl(this._self, this._then);

  final _AgentRequest _self;
  final $Res Function(_AgentRequest) _then;

/// Create a copy of AgentRequest
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? targetAgent = null,Object? action = null,Object? payload = null,Object? userId = freezed,Object? sessionId = freezed,Object? priority = null,Object? createdAt = freezed,Object? maxRetries = null,}) {
  return _then(_AgentRequest(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,targetAgent: null == targetAgent ? _self.targetAgent : targetAgent // ignore: cast_nullable_to_non_nullable
as AgentType,action: null == action ? _self.action : action // ignore: cast_nullable_to_non_nullable
as String,payload: null == payload ? _self._payload : payload // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>,userId: freezed == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as String?,sessionId: freezed == sessionId ? _self.sessionId : sessionId // ignore: cast_nullable_to_non_nullable
as String?,priority: null == priority ? _self.priority : priority // ignore: cast_nullable_to_non_nullable
as AgentPriority,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime?,maxRetries: null == maxRetries ? _self.maxRetries : maxRetries // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}


/// @nodoc
mixin _$AgentResponse {

 String get requestId; AgentType get agent; bool get success; Map<String, dynamic>? get data; String? get error; DateTime? get completedAt; int get processingTimeMs; AgentType? get delegatedTo;
/// Create a copy of AgentResponse
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AgentResponseCopyWith<AgentResponse> get copyWith => _$AgentResponseCopyWithImpl<AgentResponse>(this as AgentResponse, _$identity);

  /// Serializes this AgentResponse to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AgentResponse&&(identical(other.requestId, requestId) || other.requestId == requestId)&&(identical(other.agent, agent) || other.agent == agent)&&(identical(other.success, success) || other.success == success)&&const DeepCollectionEquality().equals(other.data, data)&&(identical(other.error, error) || other.error == error)&&(identical(other.completedAt, completedAt) || other.completedAt == completedAt)&&(identical(other.processingTimeMs, processingTimeMs) || other.processingTimeMs == processingTimeMs)&&(identical(other.delegatedTo, delegatedTo) || other.delegatedTo == delegatedTo));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,requestId,agent,success,const DeepCollectionEquality().hash(data),error,completedAt,processingTimeMs,delegatedTo);

@override
String toString() {
  return 'AgentResponse(requestId: $requestId, agent: $agent, success: $success, data: $data, error: $error, completedAt: $completedAt, processingTimeMs: $processingTimeMs, delegatedTo: $delegatedTo)';
}


}

/// @nodoc
abstract mixin class $AgentResponseCopyWith<$Res>  {
  factory $AgentResponseCopyWith(AgentResponse value, $Res Function(AgentResponse) _then) = _$AgentResponseCopyWithImpl;
@useResult
$Res call({
 String requestId, AgentType agent, bool success, Map<String, dynamic>? data, String? error, DateTime? completedAt, int processingTimeMs, AgentType? delegatedTo
});




}
/// @nodoc
class _$AgentResponseCopyWithImpl<$Res>
    implements $AgentResponseCopyWith<$Res> {
  _$AgentResponseCopyWithImpl(this._self, this._then);

  final AgentResponse _self;
  final $Res Function(AgentResponse) _then;

/// Create a copy of AgentResponse
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? requestId = null,Object? agent = null,Object? success = null,Object? data = freezed,Object? error = freezed,Object? completedAt = freezed,Object? processingTimeMs = null,Object? delegatedTo = freezed,}) {
  return _then(_self.copyWith(
requestId: null == requestId ? _self.requestId : requestId // ignore: cast_nullable_to_non_nullable
as String,agent: null == agent ? _self.agent : agent // ignore: cast_nullable_to_non_nullable
as AgentType,success: null == success ? _self.success : success // ignore: cast_nullable_to_non_nullable
as bool,data: freezed == data ? _self.data : data // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>?,error: freezed == error ? _self.error : error // ignore: cast_nullable_to_non_nullable
as String?,completedAt: freezed == completedAt ? _self.completedAt : completedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,processingTimeMs: null == processingTimeMs ? _self.processingTimeMs : processingTimeMs // ignore: cast_nullable_to_non_nullable
as int,delegatedTo: freezed == delegatedTo ? _self.delegatedTo : delegatedTo // ignore: cast_nullable_to_non_nullable
as AgentType?,
  ));
}

}


/// Adds pattern-matching-related methods to [AgentResponse].
extension AgentResponsePatterns on AgentResponse {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _AgentResponse value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _AgentResponse() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _AgentResponse value)  $default,){
final _that = this;
switch (_that) {
case _AgentResponse():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _AgentResponse value)?  $default,){
final _that = this;
switch (_that) {
case _AgentResponse() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String requestId,  AgentType agent,  bool success,  Map<String, dynamic>? data,  String? error,  DateTime? completedAt,  int processingTimeMs,  AgentType? delegatedTo)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _AgentResponse() when $default != null:
return $default(_that.requestId,_that.agent,_that.success,_that.data,_that.error,_that.completedAt,_that.processingTimeMs,_that.delegatedTo);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String requestId,  AgentType agent,  bool success,  Map<String, dynamic>? data,  String? error,  DateTime? completedAt,  int processingTimeMs,  AgentType? delegatedTo)  $default,) {final _that = this;
switch (_that) {
case _AgentResponse():
return $default(_that.requestId,_that.agent,_that.success,_that.data,_that.error,_that.completedAt,_that.processingTimeMs,_that.delegatedTo);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String requestId,  AgentType agent,  bool success,  Map<String, dynamic>? data,  String? error,  DateTime? completedAt,  int processingTimeMs,  AgentType? delegatedTo)?  $default,) {final _that = this;
switch (_that) {
case _AgentResponse() when $default != null:
return $default(_that.requestId,_that.agent,_that.success,_that.data,_that.error,_that.completedAt,_that.processingTimeMs,_that.delegatedTo);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _AgentResponse implements AgentResponse {
  const _AgentResponse({required this.requestId, required this.agent, required this.success, final  Map<String, dynamic>? data, this.error, this.completedAt, this.processingTimeMs = 0, this.delegatedTo}): _data = data;
  factory _AgentResponse.fromJson(Map<String, dynamic> json) => _$AgentResponseFromJson(json);

@override final  String requestId;
@override final  AgentType agent;
@override final  bool success;
 final  Map<String, dynamic>? _data;
@override Map<String, dynamic>? get data {
  final value = _data;
  if (value == null) return null;
  if (_data is EqualUnmodifiableMapView) return _data;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(value);
}

@override final  String? error;
@override final  DateTime? completedAt;
@override@JsonKey() final  int processingTimeMs;
@override final  AgentType? delegatedTo;

/// Create a copy of AgentResponse
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$AgentResponseCopyWith<_AgentResponse> get copyWith => __$AgentResponseCopyWithImpl<_AgentResponse>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$AgentResponseToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _AgentResponse&&(identical(other.requestId, requestId) || other.requestId == requestId)&&(identical(other.agent, agent) || other.agent == agent)&&(identical(other.success, success) || other.success == success)&&const DeepCollectionEquality().equals(other._data, _data)&&(identical(other.error, error) || other.error == error)&&(identical(other.completedAt, completedAt) || other.completedAt == completedAt)&&(identical(other.processingTimeMs, processingTimeMs) || other.processingTimeMs == processingTimeMs)&&(identical(other.delegatedTo, delegatedTo) || other.delegatedTo == delegatedTo));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,requestId,agent,success,const DeepCollectionEquality().hash(_data),error,completedAt,processingTimeMs,delegatedTo);

@override
String toString() {
  return 'AgentResponse(requestId: $requestId, agent: $agent, success: $success, data: $data, error: $error, completedAt: $completedAt, processingTimeMs: $processingTimeMs, delegatedTo: $delegatedTo)';
}


}

/// @nodoc
abstract mixin class _$AgentResponseCopyWith<$Res> implements $AgentResponseCopyWith<$Res> {
  factory _$AgentResponseCopyWith(_AgentResponse value, $Res Function(_AgentResponse) _then) = __$AgentResponseCopyWithImpl;
@override @useResult
$Res call({
 String requestId, AgentType agent, bool success, Map<String, dynamic>? data, String? error, DateTime? completedAt, int processingTimeMs, AgentType? delegatedTo
});




}
/// @nodoc
class __$AgentResponseCopyWithImpl<$Res>
    implements _$AgentResponseCopyWith<$Res> {
  __$AgentResponseCopyWithImpl(this._self, this._then);

  final _AgentResponse _self;
  final $Res Function(_AgentResponse) _then;

/// Create a copy of AgentResponse
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? requestId = null,Object? agent = null,Object? success = null,Object? data = freezed,Object? error = freezed,Object? completedAt = freezed,Object? processingTimeMs = null,Object? delegatedTo = freezed,}) {
  return _then(_AgentResponse(
requestId: null == requestId ? _self.requestId : requestId // ignore: cast_nullable_to_non_nullable
as String,agent: null == agent ? _self.agent : agent // ignore: cast_nullable_to_non_nullable
as AgentType,success: null == success ? _self.success : success // ignore: cast_nullable_to_non_nullable
as bool,data: freezed == data ? _self._data : data // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>?,error: freezed == error ? _self.error : error // ignore: cast_nullable_to_non_nullable
as String?,completedAt: freezed == completedAt ? _self.completedAt : completedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,processingTimeMs: null == processingTimeMs ? _self.processingTimeMs : processingTimeMs // ignore: cast_nullable_to_non_nullable
as int,delegatedTo: freezed == delegatedTo ? _self.delegatedTo : delegatedTo // ignore: cast_nullable_to_non_nullable
as AgentType?,
  ));
}


}


/// @nodoc
mixin _$AgentConfig {

 AgentType get type; String get name; String get description; List<AgentCapability> get capabilities; bool get isEnabled; int get maxConcurrentRequests; int get timeoutMs; String? get modelId; Map<String, dynamic>? get customConfig;
/// Create a copy of AgentConfig
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AgentConfigCopyWith<AgentConfig> get copyWith => _$AgentConfigCopyWithImpl<AgentConfig>(this as AgentConfig, _$identity);

  /// Serializes this AgentConfig to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AgentConfig&&(identical(other.type, type) || other.type == type)&&(identical(other.name, name) || other.name == name)&&(identical(other.description, description) || other.description == description)&&const DeepCollectionEquality().equals(other.capabilities, capabilities)&&(identical(other.isEnabled, isEnabled) || other.isEnabled == isEnabled)&&(identical(other.maxConcurrentRequests, maxConcurrentRequests) || other.maxConcurrentRequests == maxConcurrentRequests)&&(identical(other.timeoutMs, timeoutMs) || other.timeoutMs == timeoutMs)&&(identical(other.modelId, modelId) || other.modelId == modelId)&&const DeepCollectionEquality().equals(other.customConfig, customConfig));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,type,name,description,const DeepCollectionEquality().hash(capabilities),isEnabled,maxConcurrentRequests,timeoutMs,modelId,const DeepCollectionEquality().hash(customConfig));

@override
String toString() {
  return 'AgentConfig(type: $type, name: $name, description: $description, capabilities: $capabilities, isEnabled: $isEnabled, maxConcurrentRequests: $maxConcurrentRequests, timeoutMs: $timeoutMs, modelId: $modelId, customConfig: $customConfig)';
}


}

/// @nodoc
abstract mixin class $AgentConfigCopyWith<$Res>  {
  factory $AgentConfigCopyWith(AgentConfig value, $Res Function(AgentConfig) _then) = _$AgentConfigCopyWithImpl;
@useResult
$Res call({
 AgentType type, String name, String description, List<AgentCapability> capabilities, bool isEnabled, int maxConcurrentRequests, int timeoutMs, String? modelId, Map<String, dynamic>? customConfig
});




}
/// @nodoc
class _$AgentConfigCopyWithImpl<$Res>
    implements $AgentConfigCopyWith<$Res> {
  _$AgentConfigCopyWithImpl(this._self, this._then);

  final AgentConfig _self;
  final $Res Function(AgentConfig) _then;

/// Create a copy of AgentConfig
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? type = null,Object? name = null,Object? description = null,Object? capabilities = null,Object? isEnabled = null,Object? maxConcurrentRequests = null,Object? timeoutMs = null,Object? modelId = freezed,Object? customConfig = freezed,}) {
  return _then(_self.copyWith(
type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as AgentType,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,description: null == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String,capabilities: null == capabilities ? _self.capabilities : capabilities // ignore: cast_nullable_to_non_nullable
as List<AgentCapability>,isEnabled: null == isEnabled ? _self.isEnabled : isEnabled // ignore: cast_nullable_to_non_nullable
as bool,maxConcurrentRequests: null == maxConcurrentRequests ? _self.maxConcurrentRequests : maxConcurrentRequests // ignore: cast_nullable_to_non_nullable
as int,timeoutMs: null == timeoutMs ? _self.timeoutMs : timeoutMs // ignore: cast_nullable_to_non_nullable
as int,modelId: freezed == modelId ? _self.modelId : modelId // ignore: cast_nullable_to_non_nullable
as String?,customConfig: freezed == customConfig ? _self.customConfig : customConfig // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>?,
  ));
}

}


/// Adds pattern-matching-related methods to [AgentConfig].
extension AgentConfigPatterns on AgentConfig {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _AgentConfig value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _AgentConfig() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _AgentConfig value)  $default,){
final _that = this;
switch (_that) {
case _AgentConfig():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _AgentConfig value)?  $default,){
final _that = this;
switch (_that) {
case _AgentConfig() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( AgentType type,  String name,  String description,  List<AgentCapability> capabilities,  bool isEnabled,  int maxConcurrentRequests,  int timeoutMs,  String? modelId,  Map<String, dynamic>? customConfig)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _AgentConfig() when $default != null:
return $default(_that.type,_that.name,_that.description,_that.capabilities,_that.isEnabled,_that.maxConcurrentRequests,_that.timeoutMs,_that.modelId,_that.customConfig);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( AgentType type,  String name,  String description,  List<AgentCapability> capabilities,  bool isEnabled,  int maxConcurrentRequests,  int timeoutMs,  String? modelId,  Map<String, dynamic>? customConfig)  $default,) {final _that = this;
switch (_that) {
case _AgentConfig():
return $default(_that.type,_that.name,_that.description,_that.capabilities,_that.isEnabled,_that.maxConcurrentRequests,_that.timeoutMs,_that.modelId,_that.customConfig);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( AgentType type,  String name,  String description,  List<AgentCapability> capabilities,  bool isEnabled,  int maxConcurrentRequests,  int timeoutMs,  String? modelId,  Map<String, dynamic>? customConfig)?  $default,) {final _that = this;
switch (_that) {
case _AgentConfig() when $default != null:
return $default(_that.type,_that.name,_that.description,_that.capabilities,_that.isEnabled,_that.maxConcurrentRequests,_that.timeoutMs,_that.modelId,_that.customConfig);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _AgentConfig implements AgentConfig {
  const _AgentConfig({required this.type, required this.name, required this.description, final  List<AgentCapability> capabilities = const [], this.isEnabled = true, this.maxConcurrentRequests = 5, this.timeoutMs = 30000, this.modelId, final  Map<String, dynamic>? customConfig}): _capabilities = capabilities,_customConfig = customConfig;
  factory _AgentConfig.fromJson(Map<String, dynamic> json) => _$AgentConfigFromJson(json);

@override final  AgentType type;
@override final  String name;
@override final  String description;
 final  List<AgentCapability> _capabilities;
@override@JsonKey() List<AgentCapability> get capabilities {
  if (_capabilities is EqualUnmodifiableListView) return _capabilities;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_capabilities);
}

@override@JsonKey() final  bool isEnabled;
@override@JsonKey() final  int maxConcurrentRequests;
@override@JsonKey() final  int timeoutMs;
@override final  String? modelId;
 final  Map<String, dynamic>? _customConfig;
@override Map<String, dynamic>? get customConfig {
  final value = _customConfig;
  if (value == null) return null;
  if (_customConfig is EqualUnmodifiableMapView) return _customConfig;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(value);
}


/// Create a copy of AgentConfig
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$AgentConfigCopyWith<_AgentConfig> get copyWith => __$AgentConfigCopyWithImpl<_AgentConfig>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$AgentConfigToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _AgentConfig&&(identical(other.type, type) || other.type == type)&&(identical(other.name, name) || other.name == name)&&(identical(other.description, description) || other.description == description)&&const DeepCollectionEquality().equals(other._capabilities, _capabilities)&&(identical(other.isEnabled, isEnabled) || other.isEnabled == isEnabled)&&(identical(other.maxConcurrentRequests, maxConcurrentRequests) || other.maxConcurrentRequests == maxConcurrentRequests)&&(identical(other.timeoutMs, timeoutMs) || other.timeoutMs == timeoutMs)&&(identical(other.modelId, modelId) || other.modelId == modelId)&&const DeepCollectionEquality().equals(other._customConfig, _customConfig));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,type,name,description,const DeepCollectionEquality().hash(_capabilities),isEnabled,maxConcurrentRequests,timeoutMs,modelId,const DeepCollectionEquality().hash(_customConfig));

@override
String toString() {
  return 'AgentConfig(type: $type, name: $name, description: $description, capabilities: $capabilities, isEnabled: $isEnabled, maxConcurrentRequests: $maxConcurrentRequests, timeoutMs: $timeoutMs, modelId: $modelId, customConfig: $customConfig)';
}


}

/// @nodoc
abstract mixin class _$AgentConfigCopyWith<$Res> implements $AgentConfigCopyWith<$Res> {
  factory _$AgentConfigCopyWith(_AgentConfig value, $Res Function(_AgentConfig) _then) = __$AgentConfigCopyWithImpl;
@override @useResult
$Res call({
 AgentType type, String name, String description, List<AgentCapability> capabilities, bool isEnabled, int maxConcurrentRequests, int timeoutMs, String? modelId, Map<String, dynamic>? customConfig
});




}
/// @nodoc
class __$AgentConfigCopyWithImpl<$Res>
    implements _$AgentConfigCopyWith<$Res> {
  __$AgentConfigCopyWithImpl(this._self, this._then);

  final _AgentConfig _self;
  final $Res Function(_AgentConfig) _then;

/// Create a copy of AgentConfig
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? type = null,Object? name = null,Object? description = null,Object? capabilities = null,Object? isEnabled = null,Object? maxConcurrentRequests = null,Object? timeoutMs = null,Object? modelId = freezed,Object? customConfig = freezed,}) {
  return _then(_AgentConfig(
type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as AgentType,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,description: null == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String,capabilities: null == capabilities ? _self._capabilities : capabilities // ignore: cast_nullable_to_non_nullable
as List<AgentCapability>,isEnabled: null == isEnabled ? _self.isEnabled : isEnabled // ignore: cast_nullable_to_non_nullable
as bool,maxConcurrentRequests: null == maxConcurrentRequests ? _self.maxConcurrentRequests : maxConcurrentRequests // ignore: cast_nullable_to_non_nullable
as int,timeoutMs: null == timeoutMs ? _self.timeoutMs : timeoutMs // ignore: cast_nullable_to_non_nullable
as int,modelId: freezed == modelId ? _self.modelId : modelId // ignore: cast_nullable_to_non_nullable
as String?,customConfig: freezed == customConfig ? _self._customConfig : customConfig // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>?,
  ));
}


}


/// @nodoc
mixin _$AgentMetrics {

 AgentType get agent; int get totalRequests; int get successfulRequests; int get failedRequests; double get avgResponseTimeMs; DateTime? get lastRequestAt; DateTime? get lastErrorAt; String? get lastError;
/// Create a copy of AgentMetrics
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AgentMetricsCopyWith<AgentMetrics> get copyWith => _$AgentMetricsCopyWithImpl<AgentMetrics>(this as AgentMetrics, _$identity);

  /// Serializes this AgentMetrics to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AgentMetrics&&(identical(other.agent, agent) || other.agent == agent)&&(identical(other.totalRequests, totalRequests) || other.totalRequests == totalRequests)&&(identical(other.successfulRequests, successfulRequests) || other.successfulRequests == successfulRequests)&&(identical(other.failedRequests, failedRequests) || other.failedRequests == failedRequests)&&(identical(other.avgResponseTimeMs, avgResponseTimeMs) || other.avgResponseTimeMs == avgResponseTimeMs)&&(identical(other.lastRequestAt, lastRequestAt) || other.lastRequestAt == lastRequestAt)&&(identical(other.lastErrorAt, lastErrorAt) || other.lastErrorAt == lastErrorAt)&&(identical(other.lastError, lastError) || other.lastError == lastError));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,agent,totalRequests,successfulRequests,failedRequests,avgResponseTimeMs,lastRequestAt,lastErrorAt,lastError);

@override
String toString() {
  return 'AgentMetrics(agent: $agent, totalRequests: $totalRequests, successfulRequests: $successfulRequests, failedRequests: $failedRequests, avgResponseTimeMs: $avgResponseTimeMs, lastRequestAt: $lastRequestAt, lastErrorAt: $lastErrorAt, lastError: $lastError)';
}


}

/// @nodoc
abstract mixin class $AgentMetricsCopyWith<$Res>  {
  factory $AgentMetricsCopyWith(AgentMetrics value, $Res Function(AgentMetrics) _then) = _$AgentMetricsCopyWithImpl;
@useResult
$Res call({
 AgentType agent, int totalRequests, int successfulRequests, int failedRequests, double avgResponseTimeMs, DateTime? lastRequestAt, DateTime? lastErrorAt, String? lastError
});




}
/// @nodoc
class _$AgentMetricsCopyWithImpl<$Res>
    implements $AgentMetricsCopyWith<$Res> {
  _$AgentMetricsCopyWithImpl(this._self, this._then);

  final AgentMetrics _self;
  final $Res Function(AgentMetrics) _then;

/// Create a copy of AgentMetrics
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? agent = null,Object? totalRequests = null,Object? successfulRequests = null,Object? failedRequests = null,Object? avgResponseTimeMs = null,Object? lastRequestAt = freezed,Object? lastErrorAt = freezed,Object? lastError = freezed,}) {
  return _then(_self.copyWith(
agent: null == agent ? _self.agent : agent // ignore: cast_nullable_to_non_nullable
as AgentType,totalRequests: null == totalRequests ? _self.totalRequests : totalRequests // ignore: cast_nullable_to_non_nullable
as int,successfulRequests: null == successfulRequests ? _self.successfulRequests : successfulRequests // ignore: cast_nullable_to_non_nullable
as int,failedRequests: null == failedRequests ? _self.failedRequests : failedRequests // ignore: cast_nullable_to_non_nullable
as int,avgResponseTimeMs: null == avgResponseTimeMs ? _self.avgResponseTimeMs : avgResponseTimeMs // ignore: cast_nullable_to_non_nullable
as double,lastRequestAt: freezed == lastRequestAt ? _self.lastRequestAt : lastRequestAt // ignore: cast_nullable_to_non_nullable
as DateTime?,lastErrorAt: freezed == lastErrorAt ? _self.lastErrorAt : lastErrorAt // ignore: cast_nullable_to_non_nullable
as DateTime?,lastError: freezed == lastError ? _self.lastError : lastError // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [AgentMetrics].
extension AgentMetricsPatterns on AgentMetrics {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _AgentMetrics value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _AgentMetrics() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _AgentMetrics value)  $default,){
final _that = this;
switch (_that) {
case _AgentMetrics():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _AgentMetrics value)?  $default,){
final _that = this;
switch (_that) {
case _AgentMetrics() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( AgentType agent,  int totalRequests,  int successfulRequests,  int failedRequests,  double avgResponseTimeMs,  DateTime? lastRequestAt,  DateTime? lastErrorAt,  String? lastError)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _AgentMetrics() when $default != null:
return $default(_that.agent,_that.totalRequests,_that.successfulRequests,_that.failedRequests,_that.avgResponseTimeMs,_that.lastRequestAt,_that.lastErrorAt,_that.lastError);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( AgentType agent,  int totalRequests,  int successfulRequests,  int failedRequests,  double avgResponseTimeMs,  DateTime? lastRequestAt,  DateTime? lastErrorAt,  String? lastError)  $default,) {final _that = this;
switch (_that) {
case _AgentMetrics():
return $default(_that.agent,_that.totalRequests,_that.successfulRequests,_that.failedRequests,_that.avgResponseTimeMs,_that.lastRequestAt,_that.lastErrorAt,_that.lastError);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( AgentType agent,  int totalRequests,  int successfulRequests,  int failedRequests,  double avgResponseTimeMs,  DateTime? lastRequestAt,  DateTime? lastErrorAt,  String? lastError)?  $default,) {final _that = this;
switch (_that) {
case _AgentMetrics() when $default != null:
return $default(_that.agent,_that.totalRequests,_that.successfulRequests,_that.failedRequests,_that.avgResponseTimeMs,_that.lastRequestAt,_that.lastErrorAt,_that.lastError);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _AgentMetrics implements AgentMetrics {
  const _AgentMetrics({required this.agent, this.totalRequests = 0, this.successfulRequests = 0, this.failedRequests = 0, this.avgResponseTimeMs = 0, this.lastRequestAt, this.lastErrorAt, this.lastError});
  factory _AgentMetrics.fromJson(Map<String, dynamic> json) => _$AgentMetricsFromJson(json);

@override final  AgentType agent;
@override@JsonKey() final  int totalRequests;
@override@JsonKey() final  int successfulRequests;
@override@JsonKey() final  int failedRequests;
@override@JsonKey() final  double avgResponseTimeMs;
@override final  DateTime? lastRequestAt;
@override final  DateTime? lastErrorAt;
@override final  String? lastError;

/// Create a copy of AgentMetrics
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$AgentMetricsCopyWith<_AgentMetrics> get copyWith => __$AgentMetricsCopyWithImpl<_AgentMetrics>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$AgentMetricsToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _AgentMetrics&&(identical(other.agent, agent) || other.agent == agent)&&(identical(other.totalRequests, totalRequests) || other.totalRequests == totalRequests)&&(identical(other.successfulRequests, successfulRequests) || other.successfulRequests == successfulRequests)&&(identical(other.failedRequests, failedRequests) || other.failedRequests == failedRequests)&&(identical(other.avgResponseTimeMs, avgResponseTimeMs) || other.avgResponseTimeMs == avgResponseTimeMs)&&(identical(other.lastRequestAt, lastRequestAt) || other.lastRequestAt == lastRequestAt)&&(identical(other.lastErrorAt, lastErrorAt) || other.lastErrorAt == lastErrorAt)&&(identical(other.lastError, lastError) || other.lastError == lastError));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,agent,totalRequests,successfulRequests,failedRequests,avgResponseTimeMs,lastRequestAt,lastErrorAt,lastError);

@override
String toString() {
  return 'AgentMetrics(agent: $agent, totalRequests: $totalRequests, successfulRequests: $successfulRequests, failedRequests: $failedRequests, avgResponseTimeMs: $avgResponseTimeMs, lastRequestAt: $lastRequestAt, lastErrorAt: $lastErrorAt, lastError: $lastError)';
}


}

/// @nodoc
abstract mixin class _$AgentMetricsCopyWith<$Res> implements $AgentMetricsCopyWith<$Res> {
  factory _$AgentMetricsCopyWith(_AgentMetrics value, $Res Function(_AgentMetrics) _then) = __$AgentMetricsCopyWithImpl;
@override @useResult
$Res call({
 AgentType agent, int totalRequests, int successfulRequests, int failedRequests, double avgResponseTimeMs, DateTime? lastRequestAt, DateTime? lastErrorAt, String? lastError
});




}
/// @nodoc
class __$AgentMetricsCopyWithImpl<$Res>
    implements _$AgentMetricsCopyWith<$Res> {
  __$AgentMetricsCopyWithImpl(this._self, this._then);

  final _AgentMetrics _self;
  final $Res Function(_AgentMetrics) _then;

/// Create a copy of AgentMetrics
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? agent = null,Object? totalRequests = null,Object? successfulRequests = null,Object? failedRequests = null,Object? avgResponseTimeMs = null,Object? lastRequestAt = freezed,Object? lastErrorAt = freezed,Object? lastError = freezed,}) {
  return _then(_AgentMetrics(
agent: null == agent ? _self.agent : agent // ignore: cast_nullable_to_non_nullable
as AgentType,totalRequests: null == totalRequests ? _self.totalRequests : totalRequests // ignore: cast_nullable_to_non_nullable
as int,successfulRequests: null == successfulRequests ? _self.successfulRequests : successfulRequests // ignore: cast_nullable_to_non_nullable
as int,failedRequests: null == failedRequests ? _self.failedRequests : failedRequests // ignore: cast_nullable_to_non_nullable
as int,avgResponseTimeMs: null == avgResponseTimeMs ? _self.avgResponseTimeMs : avgResponseTimeMs // ignore: cast_nullable_to_non_nullable
as double,lastRequestAt: freezed == lastRequestAt ? _self.lastRequestAt : lastRequestAt // ignore: cast_nullable_to_non_nullable
as DateTime?,lastErrorAt: freezed == lastErrorAt ? _self.lastErrorAt : lastErrorAt // ignore: cast_nullable_to_non_nullable
as DateTime?,lastError: freezed == lastError ? _self.lastError : lastError // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
