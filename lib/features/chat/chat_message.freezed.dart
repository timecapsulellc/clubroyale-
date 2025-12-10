// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'chat_message.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$ChatMessage {

/// Firestore document ID
 String? get id;/// Sender user ID
 String get senderId;/// Sender display name
 String get senderName;/// Message content
 String get content;/// Message type
 MessageType get type;/// Emoji reactions (userId -> emoji)
 Map<String, String> get reactions;/// Whether message was moderated/blocked
 bool get isModerated;/// Moderation reason if blocked
 String? get moderationReason;/// Timestamp when sent
 DateTime? get timestamp;/// Whether message is deleted (soft delete)
 bool get isDeleted;/// ID of message being replied to
 String? get replyToId;/// Preview of replied message
 String? get replyPreview;/// List of user IDs who have read this message
 List<String> get readBy;/// Whether message was edited
 bool get isEdited;/// Original sender photo URL for display
 String? get senderPhotoUrl;
/// Create a copy of ChatMessage
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ChatMessageCopyWith<ChatMessage> get copyWith => _$ChatMessageCopyWithImpl<ChatMessage>(this as ChatMessage, _$identity);

  /// Serializes this ChatMessage to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ChatMessage&&(identical(other.id, id) || other.id == id)&&(identical(other.senderId, senderId) || other.senderId == senderId)&&(identical(other.senderName, senderName) || other.senderName == senderName)&&(identical(other.content, content) || other.content == content)&&(identical(other.type, type) || other.type == type)&&const DeepCollectionEquality().equals(other.reactions, reactions)&&(identical(other.isModerated, isModerated) || other.isModerated == isModerated)&&(identical(other.moderationReason, moderationReason) || other.moderationReason == moderationReason)&&(identical(other.timestamp, timestamp) || other.timestamp == timestamp)&&(identical(other.isDeleted, isDeleted) || other.isDeleted == isDeleted)&&(identical(other.replyToId, replyToId) || other.replyToId == replyToId)&&(identical(other.replyPreview, replyPreview) || other.replyPreview == replyPreview)&&const DeepCollectionEquality().equals(other.readBy, readBy)&&(identical(other.isEdited, isEdited) || other.isEdited == isEdited)&&(identical(other.senderPhotoUrl, senderPhotoUrl) || other.senderPhotoUrl == senderPhotoUrl));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,senderId,senderName,content,type,const DeepCollectionEquality().hash(reactions),isModerated,moderationReason,timestamp,isDeleted,replyToId,replyPreview,const DeepCollectionEquality().hash(readBy),isEdited,senderPhotoUrl);

@override
String toString() {
  return 'ChatMessage(id: $id, senderId: $senderId, senderName: $senderName, content: $content, type: $type, reactions: $reactions, isModerated: $isModerated, moderationReason: $moderationReason, timestamp: $timestamp, isDeleted: $isDeleted, replyToId: $replyToId, replyPreview: $replyPreview, readBy: $readBy, isEdited: $isEdited, senderPhotoUrl: $senderPhotoUrl)';
}


}

/// @nodoc
abstract mixin class $ChatMessageCopyWith<$Res>  {
  factory $ChatMessageCopyWith(ChatMessage value, $Res Function(ChatMessage) _then) = _$ChatMessageCopyWithImpl;
@useResult
$Res call({
 String? id, String senderId, String senderName, String content, MessageType type, Map<String, String> reactions, bool isModerated, String? moderationReason, DateTime? timestamp, bool isDeleted, String? replyToId, String? replyPreview, List<String> readBy, bool isEdited, String? senderPhotoUrl
});




}
/// @nodoc
class _$ChatMessageCopyWithImpl<$Res>
    implements $ChatMessageCopyWith<$Res> {
  _$ChatMessageCopyWithImpl(this._self, this._then);

  final ChatMessage _self;
  final $Res Function(ChatMessage) _then;

/// Create a copy of ChatMessage
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = freezed,Object? senderId = null,Object? senderName = null,Object? content = null,Object? type = null,Object? reactions = null,Object? isModerated = null,Object? moderationReason = freezed,Object? timestamp = freezed,Object? isDeleted = null,Object? replyToId = freezed,Object? replyPreview = freezed,Object? readBy = null,Object? isEdited = null,Object? senderPhotoUrl = freezed,}) {
  return _then(_self.copyWith(
id: freezed == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String?,senderId: null == senderId ? _self.senderId : senderId // ignore: cast_nullable_to_non_nullable
as String,senderName: null == senderName ? _self.senderName : senderName // ignore: cast_nullable_to_non_nullable
as String,content: null == content ? _self.content : content // ignore: cast_nullable_to_non_nullable
as String,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as MessageType,reactions: null == reactions ? _self.reactions : reactions // ignore: cast_nullable_to_non_nullable
as Map<String, String>,isModerated: null == isModerated ? _self.isModerated : isModerated // ignore: cast_nullable_to_non_nullable
as bool,moderationReason: freezed == moderationReason ? _self.moderationReason : moderationReason // ignore: cast_nullable_to_non_nullable
as String?,timestamp: freezed == timestamp ? _self.timestamp : timestamp // ignore: cast_nullable_to_non_nullable
as DateTime?,isDeleted: null == isDeleted ? _self.isDeleted : isDeleted // ignore: cast_nullable_to_non_nullable
as bool,replyToId: freezed == replyToId ? _self.replyToId : replyToId // ignore: cast_nullable_to_non_nullable
as String?,replyPreview: freezed == replyPreview ? _self.replyPreview : replyPreview // ignore: cast_nullable_to_non_nullable
as String?,readBy: null == readBy ? _self.readBy : readBy // ignore: cast_nullable_to_non_nullable
as List<String>,isEdited: null == isEdited ? _self.isEdited : isEdited // ignore: cast_nullable_to_non_nullable
as bool,senderPhotoUrl: freezed == senderPhotoUrl ? _self.senderPhotoUrl : senderPhotoUrl // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [ChatMessage].
extension ChatMessagePatterns on ChatMessage {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ChatMessage value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ChatMessage() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ChatMessage value)  $default,){
final _that = this;
switch (_that) {
case _ChatMessage():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ChatMessage value)?  $default,){
final _that = this;
switch (_that) {
case _ChatMessage() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String? id,  String senderId,  String senderName,  String content,  MessageType type,  Map<String, String> reactions,  bool isModerated,  String? moderationReason,  DateTime? timestamp,  bool isDeleted,  String? replyToId,  String? replyPreview,  List<String> readBy,  bool isEdited,  String? senderPhotoUrl)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ChatMessage() when $default != null:
return $default(_that.id,_that.senderId,_that.senderName,_that.content,_that.type,_that.reactions,_that.isModerated,_that.moderationReason,_that.timestamp,_that.isDeleted,_that.replyToId,_that.replyPreview,_that.readBy,_that.isEdited,_that.senderPhotoUrl);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String? id,  String senderId,  String senderName,  String content,  MessageType type,  Map<String, String> reactions,  bool isModerated,  String? moderationReason,  DateTime? timestamp,  bool isDeleted,  String? replyToId,  String? replyPreview,  List<String> readBy,  bool isEdited,  String? senderPhotoUrl)  $default,) {final _that = this;
switch (_that) {
case _ChatMessage():
return $default(_that.id,_that.senderId,_that.senderName,_that.content,_that.type,_that.reactions,_that.isModerated,_that.moderationReason,_that.timestamp,_that.isDeleted,_that.replyToId,_that.replyPreview,_that.readBy,_that.isEdited,_that.senderPhotoUrl);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String? id,  String senderId,  String senderName,  String content,  MessageType type,  Map<String, String> reactions,  bool isModerated,  String? moderationReason,  DateTime? timestamp,  bool isDeleted,  String? replyToId,  String? replyPreview,  List<String> readBy,  bool isEdited,  String? senderPhotoUrl)?  $default,) {final _that = this;
switch (_that) {
case _ChatMessage() when $default != null:
return $default(_that.id,_that.senderId,_that.senderName,_that.content,_that.type,_that.reactions,_that.isModerated,_that.moderationReason,_that.timestamp,_that.isDeleted,_that.replyToId,_that.replyPreview,_that.readBy,_that.isEdited,_that.senderPhotoUrl);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ChatMessage extends ChatMessage {
  const _ChatMessage({this.id, required this.senderId, required this.senderName, required this.content, this.type = MessageType.text, final  Map<String, String> reactions = const {}, this.isModerated = false, this.moderationReason, this.timestamp, this.isDeleted = false, this.replyToId, this.replyPreview, final  List<String> readBy = const [], this.isEdited = false, this.senderPhotoUrl}): _reactions = reactions,_readBy = readBy,super._();
  factory _ChatMessage.fromJson(Map<String, dynamic> json) => _$ChatMessageFromJson(json);

/// Firestore document ID
@override final  String? id;
/// Sender user ID
@override final  String senderId;
/// Sender display name
@override final  String senderName;
/// Message content
@override final  String content;
/// Message type
@override@JsonKey() final  MessageType type;
/// Emoji reactions (userId -> emoji)
 final  Map<String, String> _reactions;
/// Emoji reactions (userId -> emoji)
@override@JsonKey() Map<String, String> get reactions {
  if (_reactions is EqualUnmodifiableMapView) return _reactions;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_reactions);
}

/// Whether message was moderated/blocked
@override@JsonKey() final  bool isModerated;
/// Moderation reason if blocked
@override final  String? moderationReason;
/// Timestamp when sent
@override final  DateTime? timestamp;
/// Whether message is deleted (soft delete)
@override@JsonKey() final  bool isDeleted;
/// ID of message being replied to
@override final  String? replyToId;
/// Preview of replied message
@override final  String? replyPreview;
/// List of user IDs who have read this message
 final  List<String> _readBy;
/// List of user IDs who have read this message
@override@JsonKey() List<String> get readBy {
  if (_readBy is EqualUnmodifiableListView) return _readBy;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_readBy);
}

/// Whether message was edited
@override@JsonKey() final  bool isEdited;
/// Original sender photo URL for display
@override final  String? senderPhotoUrl;

/// Create a copy of ChatMessage
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ChatMessageCopyWith<_ChatMessage> get copyWith => __$ChatMessageCopyWithImpl<_ChatMessage>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ChatMessageToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ChatMessage&&(identical(other.id, id) || other.id == id)&&(identical(other.senderId, senderId) || other.senderId == senderId)&&(identical(other.senderName, senderName) || other.senderName == senderName)&&(identical(other.content, content) || other.content == content)&&(identical(other.type, type) || other.type == type)&&const DeepCollectionEquality().equals(other._reactions, _reactions)&&(identical(other.isModerated, isModerated) || other.isModerated == isModerated)&&(identical(other.moderationReason, moderationReason) || other.moderationReason == moderationReason)&&(identical(other.timestamp, timestamp) || other.timestamp == timestamp)&&(identical(other.isDeleted, isDeleted) || other.isDeleted == isDeleted)&&(identical(other.replyToId, replyToId) || other.replyToId == replyToId)&&(identical(other.replyPreview, replyPreview) || other.replyPreview == replyPreview)&&const DeepCollectionEquality().equals(other._readBy, _readBy)&&(identical(other.isEdited, isEdited) || other.isEdited == isEdited)&&(identical(other.senderPhotoUrl, senderPhotoUrl) || other.senderPhotoUrl == senderPhotoUrl));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,senderId,senderName,content,type,const DeepCollectionEquality().hash(_reactions),isModerated,moderationReason,timestamp,isDeleted,replyToId,replyPreview,const DeepCollectionEquality().hash(_readBy),isEdited,senderPhotoUrl);

@override
String toString() {
  return 'ChatMessage(id: $id, senderId: $senderId, senderName: $senderName, content: $content, type: $type, reactions: $reactions, isModerated: $isModerated, moderationReason: $moderationReason, timestamp: $timestamp, isDeleted: $isDeleted, replyToId: $replyToId, replyPreview: $replyPreview, readBy: $readBy, isEdited: $isEdited, senderPhotoUrl: $senderPhotoUrl)';
}


}

/// @nodoc
abstract mixin class _$ChatMessageCopyWith<$Res> implements $ChatMessageCopyWith<$Res> {
  factory _$ChatMessageCopyWith(_ChatMessage value, $Res Function(_ChatMessage) _then) = __$ChatMessageCopyWithImpl;
@override @useResult
$Res call({
 String? id, String senderId, String senderName, String content, MessageType type, Map<String, String> reactions, bool isModerated, String? moderationReason, DateTime? timestamp, bool isDeleted, String? replyToId, String? replyPreview, List<String> readBy, bool isEdited, String? senderPhotoUrl
});




}
/// @nodoc
class __$ChatMessageCopyWithImpl<$Res>
    implements _$ChatMessageCopyWith<$Res> {
  __$ChatMessageCopyWithImpl(this._self, this._then);

  final _ChatMessage _self;
  final $Res Function(_ChatMessage) _then;

/// Create a copy of ChatMessage
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = freezed,Object? senderId = null,Object? senderName = null,Object? content = null,Object? type = null,Object? reactions = null,Object? isModerated = null,Object? moderationReason = freezed,Object? timestamp = freezed,Object? isDeleted = null,Object? replyToId = freezed,Object? replyPreview = freezed,Object? readBy = null,Object? isEdited = null,Object? senderPhotoUrl = freezed,}) {
  return _then(_ChatMessage(
id: freezed == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String?,senderId: null == senderId ? _self.senderId : senderId // ignore: cast_nullable_to_non_nullable
as String,senderName: null == senderName ? _self.senderName : senderName // ignore: cast_nullable_to_non_nullable
as String,content: null == content ? _self.content : content // ignore: cast_nullable_to_non_nullable
as String,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as MessageType,reactions: null == reactions ? _self._reactions : reactions // ignore: cast_nullable_to_non_nullable
as Map<String, String>,isModerated: null == isModerated ? _self.isModerated : isModerated // ignore: cast_nullable_to_non_nullable
as bool,moderationReason: freezed == moderationReason ? _self.moderationReason : moderationReason // ignore: cast_nullable_to_non_nullable
as String?,timestamp: freezed == timestamp ? _self.timestamp : timestamp // ignore: cast_nullable_to_non_nullable
as DateTime?,isDeleted: null == isDeleted ? _self.isDeleted : isDeleted // ignore: cast_nullable_to_non_nullable
as bool,replyToId: freezed == replyToId ? _self.replyToId : replyToId // ignore: cast_nullable_to_non_nullable
as String?,replyPreview: freezed == replyPreview ? _self.replyPreview : replyPreview // ignore: cast_nullable_to_non_nullable
as String?,readBy: null == readBy ? _self._readBy : readBy // ignore: cast_nullable_to_non_nullable
as List<String>,isEdited: null == isEdited ? _self.isEdited : isEdited // ignore: cast_nullable_to_non_nullable
as bool,senderPhotoUrl: freezed == senderPhotoUrl ? _self.senderPhotoUrl : senderPhotoUrl // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
