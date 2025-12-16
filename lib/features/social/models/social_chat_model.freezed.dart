// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'social_chat_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$SocialChat {

 String get id; ChatType get type;// Participants
 List<String> get participants; List<String> get admins;// Group Metadata
 String? get name; String? get description; String? get avatarUrl;// Timestamps
@JsonKey(fromJson: _timestampFromJson, toJson: _timestampToJson) DateTime get createdAt;@JsonKey(fromJson: _timestampFromJson, toJson: _timestampToJson) DateTime? get updatedAt;// Last Message Preview
 SocialMessagePreview? get lastMessage;// Unread Counts (Map<UserId, Count>)
 Map<String, int> get unreadCounts;// Settings
 bool get isMuted; bool get isArchived;// Generic Metadata (e.g. for Club ID, specific game params)
 Map<String, dynamic> get metadata;
/// Create a copy of SocialChat
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SocialChatCopyWith<SocialChat> get copyWith => _$SocialChatCopyWithImpl<SocialChat>(this as SocialChat, _$identity);

  /// Serializes this SocialChat to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SocialChat&&(identical(other.id, id) || other.id == id)&&(identical(other.type, type) || other.type == type)&&const DeepCollectionEquality().equals(other.participants, participants)&&const DeepCollectionEquality().equals(other.admins, admins)&&(identical(other.name, name) || other.name == name)&&(identical(other.description, description) || other.description == description)&&(identical(other.avatarUrl, avatarUrl) || other.avatarUrl == avatarUrl)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt)&&(identical(other.lastMessage, lastMessage) || other.lastMessage == lastMessage)&&const DeepCollectionEquality().equals(other.unreadCounts, unreadCounts)&&(identical(other.isMuted, isMuted) || other.isMuted == isMuted)&&(identical(other.isArchived, isArchived) || other.isArchived == isArchived)&&const DeepCollectionEquality().equals(other.metadata, metadata));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,type,const DeepCollectionEquality().hash(participants),const DeepCollectionEquality().hash(admins),name,description,avatarUrl,createdAt,updatedAt,lastMessage,const DeepCollectionEquality().hash(unreadCounts),isMuted,isArchived,const DeepCollectionEquality().hash(metadata));

@override
String toString() {
  return 'SocialChat(id: $id, type: $type, participants: $participants, admins: $admins, name: $name, description: $description, avatarUrl: $avatarUrl, createdAt: $createdAt, updatedAt: $updatedAt, lastMessage: $lastMessage, unreadCounts: $unreadCounts, isMuted: $isMuted, isArchived: $isArchived, metadata: $metadata)';
}


}

/// @nodoc
abstract mixin class $SocialChatCopyWith<$Res>  {
  factory $SocialChatCopyWith(SocialChat value, $Res Function(SocialChat) _then) = _$SocialChatCopyWithImpl;
@useResult
$Res call({
 String id, ChatType type, List<String> participants, List<String> admins, String? name, String? description, String? avatarUrl,@JsonKey(fromJson: _timestampFromJson, toJson: _timestampToJson) DateTime createdAt,@JsonKey(fromJson: _timestampFromJson, toJson: _timestampToJson) DateTime? updatedAt, SocialMessagePreview? lastMessage, Map<String, int> unreadCounts, bool isMuted, bool isArchived, Map<String, dynamic> metadata
});


$SocialMessagePreviewCopyWith<$Res>? get lastMessage;

}
/// @nodoc
class _$SocialChatCopyWithImpl<$Res>
    implements $SocialChatCopyWith<$Res> {
  _$SocialChatCopyWithImpl(this._self, this._then);

  final SocialChat _self;
  final $Res Function(SocialChat) _then;

/// Create a copy of SocialChat
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? type = null,Object? participants = null,Object? admins = null,Object? name = freezed,Object? description = freezed,Object? avatarUrl = freezed,Object? createdAt = null,Object? updatedAt = freezed,Object? lastMessage = freezed,Object? unreadCounts = null,Object? isMuted = null,Object? isArchived = null,Object? metadata = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as ChatType,participants: null == participants ? _self.participants : participants // ignore: cast_nullable_to_non_nullable
as List<String>,admins: null == admins ? _self.admins : admins // ignore: cast_nullable_to_non_nullable
as List<String>,name: freezed == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String?,description: freezed == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String?,avatarUrl: freezed == avatarUrl ? _self.avatarUrl : avatarUrl // ignore: cast_nullable_to_non_nullable
as String?,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: freezed == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,lastMessage: freezed == lastMessage ? _self.lastMessage : lastMessage // ignore: cast_nullable_to_non_nullable
as SocialMessagePreview?,unreadCounts: null == unreadCounts ? _self.unreadCounts : unreadCounts // ignore: cast_nullable_to_non_nullable
as Map<String, int>,isMuted: null == isMuted ? _self.isMuted : isMuted // ignore: cast_nullable_to_non_nullable
as bool,isArchived: null == isArchived ? _self.isArchived : isArchived // ignore: cast_nullable_to_non_nullable
as bool,metadata: null == metadata ? _self.metadata : metadata // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>,
  ));
}
/// Create a copy of SocialChat
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$SocialMessagePreviewCopyWith<$Res>? get lastMessage {
    if (_self.lastMessage == null) {
    return null;
  }

  return $SocialMessagePreviewCopyWith<$Res>(_self.lastMessage!, (value) {
    return _then(_self.copyWith(lastMessage: value));
  });
}
}


/// Adds pattern-matching-related methods to [SocialChat].
extension SocialChatPatterns on SocialChat {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _SocialChat value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _SocialChat() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _SocialChat value)  $default,){
final _that = this;
switch (_that) {
case _SocialChat():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _SocialChat value)?  $default,){
final _that = this;
switch (_that) {
case _SocialChat() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  ChatType type,  List<String> participants,  List<String> admins,  String? name,  String? description,  String? avatarUrl, @JsonKey(fromJson: _timestampFromJson, toJson: _timestampToJson)  DateTime createdAt, @JsonKey(fromJson: _timestampFromJson, toJson: _timestampToJson)  DateTime? updatedAt,  SocialMessagePreview? lastMessage,  Map<String, int> unreadCounts,  bool isMuted,  bool isArchived,  Map<String, dynamic> metadata)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _SocialChat() when $default != null:
return $default(_that.id,_that.type,_that.participants,_that.admins,_that.name,_that.description,_that.avatarUrl,_that.createdAt,_that.updatedAt,_that.lastMessage,_that.unreadCounts,_that.isMuted,_that.isArchived,_that.metadata);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  ChatType type,  List<String> participants,  List<String> admins,  String? name,  String? description,  String? avatarUrl, @JsonKey(fromJson: _timestampFromJson, toJson: _timestampToJson)  DateTime createdAt, @JsonKey(fromJson: _timestampFromJson, toJson: _timestampToJson)  DateTime? updatedAt,  SocialMessagePreview? lastMessage,  Map<String, int> unreadCounts,  bool isMuted,  bool isArchived,  Map<String, dynamic> metadata)  $default,) {final _that = this;
switch (_that) {
case _SocialChat():
return $default(_that.id,_that.type,_that.participants,_that.admins,_that.name,_that.description,_that.avatarUrl,_that.createdAt,_that.updatedAt,_that.lastMessage,_that.unreadCounts,_that.isMuted,_that.isArchived,_that.metadata);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  ChatType type,  List<String> participants,  List<String> admins,  String? name,  String? description,  String? avatarUrl, @JsonKey(fromJson: _timestampFromJson, toJson: _timestampToJson)  DateTime createdAt, @JsonKey(fromJson: _timestampFromJson, toJson: _timestampToJson)  DateTime? updatedAt,  SocialMessagePreview? lastMessage,  Map<String, int> unreadCounts,  bool isMuted,  bool isArchived,  Map<String, dynamic> metadata)?  $default,) {final _that = this;
switch (_that) {
case _SocialChat() when $default != null:
return $default(_that.id,_that.type,_that.participants,_that.admins,_that.name,_that.description,_that.avatarUrl,_that.createdAt,_that.updatedAt,_that.lastMessage,_that.unreadCounts,_that.isMuted,_that.isArchived,_that.metadata);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _SocialChat extends SocialChat {
  const _SocialChat({required this.id, required this.type, required final  List<String> participants, final  List<String> admins = const [], this.name, this.description, this.avatarUrl, @JsonKey(fromJson: _timestampFromJson, toJson: _timestampToJson) required this.createdAt, @JsonKey(fromJson: _timestampFromJson, toJson: _timestampToJson) this.updatedAt, this.lastMessage, final  Map<String, int> unreadCounts = const {}, this.isMuted = false, this.isArchived = false, final  Map<String, dynamic> metadata = const {}}): _participants = participants,_admins = admins,_unreadCounts = unreadCounts,_metadata = metadata,super._();
  factory _SocialChat.fromJson(Map<String, dynamic> json) => _$SocialChatFromJson(json);

@override final  String id;
@override final  ChatType type;
// Participants
 final  List<String> _participants;
// Participants
@override List<String> get participants {
  if (_participants is EqualUnmodifiableListView) return _participants;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_participants);
}

 final  List<String> _admins;
@override@JsonKey() List<String> get admins {
  if (_admins is EqualUnmodifiableListView) return _admins;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_admins);
}

// Group Metadata
@override final  String? name;
@override final  String? description;
@override final  String? avatarUrl;
// Timestamps
@override@JsonKey(fromJson: _timestampFromJson, toJson: _timestampToJson) final  DateTime createdAt;
@override@JsonKey(fromJson: _timestampFromJson, toJson: _timestampToJson) final  DateTime? updatedAt;
// Last Message Preview
@override final  SocialMessagePreview? lastMessage;
// Unread Counts (Map<UserId, Count>)
 final  Map<String, int> _unreadCounts;
// Unread Counts (Map<UserId, Count>)
@override@JsonKey() Map<String, int> get unreadCounts {
  if (_unreadCounts is EqualUnmodifiableMapView) return _unreadCounts;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_unreadCounts);
}

// Settings
@override@JsonKey() final  bool isMuted;
@override@JsonKey() final  bool isArchived;
// Generic Metadata (e.g. for Club ID, specific game params)
 final  Map<String, dynamic> _metadata;
// Generic Metadata (e.g. for Club ID, specific game params)
@override@JsonKey() Map<String, dynamic> get metadata {
  if (_metadata is EqualUnmodifiableMapView) return _metadata;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_metadata);
}


/// Create a copy of SocialChat
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SocialChatCopyWith<_SocialChat> get copyWith => __$SocialChatCopyWithImpl<_SocialChat>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$SocialChatToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _SocialChat&&(identical(other.id, id) || other.id == id)&&(identical(other.type, type) || other.type == type)&&const DeepCollectionEquality().equals(other._participants, _participants)&&const DeepCollectionEquality().equals(other._admins, _admins)&&(identical(other.name, name) || other.name == name)&&(identical(other.description, description) || other.description == description)&&(identical(other.avatarUrl, avatarUrl) || other.avatarUrl == avatarUrl)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt)&&(identical(other.lastMessage, lastMessage) || other.lastMessage == lastMessage)&&const DeepCollectionEquality().equals(other._unreadCounts, _unreadCounts)&&(identical(other.isMuted, isMuted) || other.isMuted == isMuted)&&(identical(other.isArchived, isArchived) || other.isArchived == isArchived)&&const DeepCollectionEquality().equals(other._metadata, _metadata));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,type,const DeepCollectionEquality().hash(_participants),const DeepCollectionEquality().hash(_admins),name,description,avatarUrl,createdAt,updatedAt,lastMessage,const DeepCollectionEquality().hash(_unreadCounts),isMuted,isArchived,const DeepCollectionEquality().hash(_metadata));

@override
String toString() {
  return 'SocialChat(id: $id, type: $type, participants: $participants, admins: $admins, name: $name, description: $description, avatarUrl: $avatarUrl, createdAt: $createdAt, updatedAt: $updatedAt, lastMessage: $lastMessage, unreadCounts: $unreadCounts, isMuted: $isMuted, isArchived: $isArchived, metadata: $metadata)';
}


}

/// @nodoc
abstract mixin class _$SocialChatCopyWith<$Res> implements $SocialChatCopyWith<$Res> {
  factory _$SocialChatCopyWith(_SocialChat value, $Res Function(_SocialChat) _then) = __$SocialChatCopyWithImpl;
@override @useResult
$Res call({
 String id, ChatType type, List<String> participants, List<String> admins, String? name, String? description, String? avatarUrl,@JsonKey(fromJson: _timestampFromJson, toJson: _timestampToJson) DateTime createdAt,@JsonKey(fromJson: _timestampFromJson, toJson: _timestampToJson) DateTime? updatedAt, SocialMessagePreview? lastMessage, Map<String, int> unreadCounts, bool isMuted, bool isArchived, Map<String, dynamic> metadata
});


@override $SocialMessagePreviewCopyWith<$Res>? get lastMessage;

}
/// @nodoc
class __$SocialChatCopyWithImpl<$Res>
    implements _$SocialChatCopyWith<$Res> {
  __$SocialChatCopyWithImpl(this._self, this._then);

  final _SocialChat _self;
  final $Res Function(_SocialChat) _then;

/// Create a copy of SocialChat
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? type = null,Object? participants = null,Object? admins = null,Object? name = freezed,Object? description = freezed,Object? avatarUrl = freezed,Object? createdAt = null,Object? updatedAt = freezed,Object? lastMessage = freezed,Object? unreadCounts = null,Object? isMuted = null,Object? isArchived = null,Object? metadata = null,}) {
  return _then(_SocialChat(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as ChatType,participants: null == participants ? _self._participants : participants // ignore: cast_nullable_to_non_nullable
as List<String>,admins: null == admins ? _self._admins : admins // ignore: cast_nullable_to_non_nullable
as List<String>,name: freezed == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String?,description: freezed == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String?,avatarUrl: freezed == avatarUrl ? _self.avatarUrl : avatarUrl // ignore: cast_nullable_to_non_nullable
as String?,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: freezed == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,lastMessage: freezed == lastMessage ? _self.lastMessage : lastMessage // ignore: cast_nullable_to_non_nullable
as SocialMessagePreview?,unreadCounts: null == unreadCounts ? _self._unreadCounts : unreadCounts // ignore: cast_nullable_to_non_nullable
as Map<String, int>,isMuted: null == isMuted ? _self.isMuted : isMuted // ignore: cast_nullable_to_non_nullable
as bool,isArchived: null == isArchived ? _self.isArchived : isArchived // ignore: cast_nullable_to_non_nullable
as bool,metadata: null == metadata ? _self._metadata : metadata // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>,
  ));
}

/// Create a copy of SocialChat
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$SocialMessagePreviewCopyWith<$Res>? get lastMessage {
    if (_self.lastMessage == null) {
    return null;
  }

  return $SocialMessagePreviewCopyWith<$Res>(_self.lastMessage!, (value) {
    return _then(_self.copyWith(lastMessage: value));
  });
}
}


/// @nodoc
mixin _$SocialMessagePreview {

 String get messageId; String get senderId; String get senderName; String get content; String get type;// 'text', 'image', etc.
@JsonKey(fromJson: _timestampFromJson, toJson: _timestampToJson) DateTime get timestamp;
/// Create a copy of SocialMessagePreview
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SocialMessagePreviewCopyWith<SocialMessagePreview> get copyWith => _$SocialMessagePreviewCopyWithImpl<SocialMessagePreview>(this as SocialMessagePreview, _$identity);

  /// Serializes this SocialMessagePreview to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SocialMessagePreview&&(identical(other.messageId, messageId) || other.messageId == messageId)&&(identical(other.senderId, senderId) || other.senderId == senderId)&&(identical(other.senderName, senderName) || other.senderName == senderName)&&(identical(other.content, content) || other.content == content)&&(identical(other.type, type) || other.type == type)&&(identical(other.timestamp, timestamp) || other.timestamp == timestamp));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,messageId,senderId,senderName,content,type,timestamp);

@override
String toString() {
  return 'SocialMessagePreview(messageId: $messageId, senderId: $senderId, senderName: $senderName, content: $content, type: $type, timestamp: $timestamp)';
}


}

/// @nodoc
abstract mixin class $SocialMessagePreviewCopyWith<$Res>  {
  factory $SocialMessagePreviewCopyWith(SocialMessagePreview value, $Res Function(SocialMessagePreview) _then) = _$SocialMessagePreviewCopyWithImpl;
@useResult
$Res call({
 String messageId, String senderId, String senderName, String content, String type,@JsonKey(fromJson: _timestampFromJson, toJson: _timestampToJson) DateTime timestamp
});




}
/// @nodoc
class _$SocialMessagePreviewCopyWithImpl<$Res>
    implements $SocialMessagePreviewCopyWith<$Res> {
  _$SocialMessagePreviewCopyWithImpl(this._self, this._then);

  final SocialMessagePreview _self;
  final $Res Function(SocialMessagePreview) _then;

/// Create a copy of SocialMessagePreview
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? messageId = null,Object? senderId = null,Object? senderName = null,Object? content = null,Object? type = null,Object? timestamp = null,}) {
  return _then(_self.copyWith(
messageId: null == messageId ? _self.messageId : messageId // ignore: cast_nullable_to_non_nullable
as String,senderId: null == senderId ? _self.senderId : senderId // ignore: cast_nullable_to_non_nullable
as String,senderName: null == senderName ? _self.senderName : senderName // ignore: cast_nullable_to_non_nullable
as String,content: null == content ? _self.content : content // ignore: cast_nullable_to_non_nullable
as String,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as String,timestamp: null == timestamp ? _self.timestamp : timestamp // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}

}


/// Adds pattern-matching-related methods to [SocialMessagePreview].
extension SocialMessagePreviewPatterns on SocialMessagePreview {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _SocialMessagePreview value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _SocialMessagePreview() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _SocialMessagePreview value)  $default,){
final _that = this;
switch (_that) {
case _SocialMessagePreview():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _SocialMessagePreview value)?  $default,){
final _that = this;
switch (_that) {
case _SocialMessagePreview() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String messageId,  String senderId,  String senderName,  String content,  String type, @JsonKey(fromJson: _timestampFromJson, toJson: _timestampToJson)  DateTime timestamp)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _SocialMessagePreview() when $default != null:
return $default(_that.messageId,_that.senderId,_that.senderName,_that.content,_that.type,_that.timestamp);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String messageId,  String senderId,  String senderName,  String content,  String type, @JsonKey(fromJson: _timestampFromJson, toJson: _timestampToJson)  DateTime timestamp)  $default,) {final _that = this;
switch (_that) {
case _SocialMessagePreview():
return $default(_that.messageId,_that.senderId,_that.senderName,_that.content,_that.type,_that.timestamp);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String messageId,  String senderId,  String senderName,  String content,  String type, @JsonKey(fromJson: _timestampFromJson, toJson: _timestampToJson)  DateTime timestamp)?  $default,) {final _that = this;
switch (_that) {
case _SocialMessagePreview() when $default != null:
return $default(_that.messageId,_that.senderId,_that.senderName,_that.content,_that.type,_that.timestamp);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _SocialMessagePreview extends SocialMessagePreview {
  const _SocialMessagePreview({required this.messageId, required this.senderId, required this.senderName, required this.content, required this.type, @JsonKey(fromJson: _timestampFromJson, toJson: _timestampToJson) required this.timestamp}): super._();
  factory _SocialMessagePreview.fromJson(Map<String, dynamic> json) => _$SocialMessagePreviewFromJson(json);

@override final  String messageId;
@override final  String senderId;
@override final  String senderName;
@override final  String content;
@override final  String type;
// 'text', 'image', etc.
@override@JsonKey(fromJson: _timestampFromJson, toJson: _timestampToJson) final  DateTime timestamp;

/// Create a copy of SocialMessagePreview
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SocialMessagePreviewCopyWith<_SocialMessagePreview> get copyWith => __$SocialMessagePreviewCopyWithImpl<_SocialMessagePreview>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$SocialMessagePreviewToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _SocialMessagePreview&&(identical(other.messageId, messageId) || other.messageId == messageId)&&(identical(other.senderId, senderId) || other.senderId == senderId)&&(identical(other.senderName, senderName) || other.senderName == senderName)&&(identical(other.content, content) || other.content == content)&&(identical(other.type, type) || other.type == type)&&(identical(other.timestamp, timestamp) || other.timestamp == timestamp));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,messageId,senderId,senderName,content,type,timestamp);

@override
String toString() {
  return 'SocialMessagePreview(messageId: $messageId, senderId: $senderId, senderName: $senderName, content: $content, type: $type, timestamp: $timestamp)';
}


}

/// @nodoc
abstract mixin class _$SocialMessagePreviewCopyWith<$Res> implements $SocialMessagePreviewCopyWith<$Res> {
  factory _$SocialMessagePreviewCopyWith(_SocialMessagePreview value, $Res Function(_SocialMessagePreview) _then) = __$SocialMessagePreviewCopyWithImpl;
@override @useResult
$Res call({
 String messageId, String senderId, String senderName, String content, String type,@JsonKey(fromJson: _timestampFromJson, toJson: _timestampToJson) DateTime timestamp
});




}
/// @nodoc
class __$SocialMessagePreviewCopyWithImpl<$Res>
    implements _$SocialMessagePreviewCopyWith<$Res> {
  __$SocialMessagePreviewCopyWithImpl(this._self, this._then);

  final _SocialMessagePreview _self;
  final $Res Function(_SocialMessagePreview) _then;

/// Create a copy of SocialMessagePreview
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? messageId = null,Object? senderId = null,Object? senderName = null,Object? content = null,Object? type = null,Object? timestamp = null,}) {
  return _then(_SocialMessagePreview(
messageId: null == messageId ? _self.messageId : messageId // ignore: cast_nullable_to_non_nullable
as String,senderId: null == senderId ? _self.senderId : senderId // ignore: cast_nullable_to_non_nullable
as String,senderName: null == senderName ? _self.senderName : senderName // ignore: cast_nullable_to_non_nullable
as String,content: null == content ? _self.content : content // ignore: cast_nullable_to_non_nullable
as String,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as String,timestamp: null == timestamp ? _self.timestamp : timestamp // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}


}

// dart format on
