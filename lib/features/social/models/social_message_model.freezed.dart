// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'social_message_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$SocialMessage {

 String get id; String get chatId; String get senderId; String get senderName; String? get senderAvatarUrl; SocialMessageType get type;// Content payload
 SocialMessageContent get content;// Metadata
@JsonKey(fromJson: _timestampFromJson, toJson: _timestampToJson) DateTime get timestamp;@JsonKey(fromJson: _timestampFromJson, toJson: _timestampToJson) DateTime? get editedAt; bool get isDeleted;// Status
 List<String> get readBy; Map<String, String> get reactions;// UserId -> Emoji
// Reply
 String? get replyToMessageId; SocialMessagePreviewData? get replyToPreview;
/// Create a copy of SocialMessage
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SocialMessageCopyWith<SocialMessage> get copyWith => _$SocialMessageCopyWithImpl<SocialMessage>(this as SocialMessage, _$identity);

  /// Serializes this SocialMessage to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SocialMessage&&(identical(other.id, id) || other.id == id)&&(identical(other.chatId, chatId) || other.chatId == chatId)&&(identical(other.senderId, senderId) || other.senderId == senderId)&&(identical(other.senderName, senderName) || other.senderName == senderName)&&(identical(other.senderAvatarUrl, senderAvatarUrl) || other.senderAvatarUrl == senderAvatarUrl)&&(identical(other.type, type) || other.type == type)&&(identical(other.content, content) || other.content == content)&&(identical(other.timestamp, timestamp) || other.timestamp == timestamp)&&(identical(other.editedAt, editedAt) || other.editedAt == editedAt)&&(identical(other.isDeleted, isDeleted) || other.isDeleted == isDeleted)&&const DeepCollectionEquality().equals(other.readBy, readBy)&&const DeepCollectionEquality().equals(other.reactions, reactions)&&(identical(other.replyToMessageId, replyToMessageId) || other.replyToMessageId == replyToMessageId)&&(identical(other.replyToPreview, replyToPreview) || other.replyToPreview == replyToPreview));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,chatId,senderId,senderName,senderAvatarUrl,type,content,timestamp,editedAt,isDeleted,const DeepCollectionEquality().hash(readBy),const DeepCollectionEquality().hash(reactions),replyToMessageId,replyToPreview);

@override
String toString() {
  return 'SocialMessage(id: $id, chatId: $chatId, senderId: $senderId, senderName: $senderName, senderAvatarUrl: $senderAvatarUrl, type: $type, content: $content, timestamp: $timestamp, editedAt: $editedAt, isDeleted: $isDeleted, readBy: $readBy, reactions: $reactions, replyToMessageId: $replyToMessageId, replyToPreview: $replyToPreview)';
}


}

/// @nodoc
abstract mixin class $SocialMessageCopyWith<$Res>  {
  factory $SocialMessageCopyWith(SocialMessage value, $Res Function(SocialMessage) _then) = _$SocialMessageCopyWithImpl;
@useResult
$Res call({
 String id, String chatId, String senderId, String senderName, String? senderAvatarUrl, SocialMessageType type, SocialMessageContent content,@JsonKey(fromJson: _timestampFromJson, toJson: _timestampToJson) DateTime timestamp,@JsonKey(fromJson: _timestampFromJson, toJson: _timestampToJson) DateTime? editedAt, bool isDeleted, List<String> readBy, Map<String, String> reactions, String? replyToMessageId, SocialMessagePreviewData? replyToPreview
});


$SocialMessageContentCopyWith<$Res> get content;$SocialMessagePreviewDataCopyWith<$Res>? get replyToPreview;

}
/// @nodoc
class _$SocialMessageCopyWithImpl<$Res>
    implements $SocialMessageCopyWith<$Res> {
  _$SocialMessageCopyWithImpl(this._self, this._then);

  final SocialMessage _self;
  final $Res Function(SocialMessage) _then;

/// Create a copy of SocialMessage
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? chatId = null,Object? senderId = null,Object? senderName = null,Object? senderAvatarUrl = freezed,Object? type = null,Object? content = null,Object? timestamp = null,Object? editedAt = freezed,Object? isDeleted = null,Object? readBy = null,Object? reactions = null,Object? replyToMessageId = freezed,Object? replyToPreview = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,chatId: null == chatId ? _self.chatId : chatId // ignore: cast_nullable_to_non_nullable
as String,senderId: null == senderId ? _self.senderId : senderId // ignore: cast_nullable_to_non_nullable
as String,senderName: null == senderName ? _self.senderName : senderName // ignore: cast_nullable_to_non_nullable
as String,senderAvatarUrl: freezed == senderAvatarUrl ? _self.senderAvatarUrl : senderAvatarUrl // ignore: cast_nullable_to_non_nullable
as String?,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as SocialMessageType,content: null == content ? _self.content : content // ignore: cast_nullable_to_non_nullable
as SocialMessageContent,timestamp: null == timestamp ? _self.timestamp : timestamp // ignore: cast_nullable_to_non_nullable
as DateTime,editedAt: freezed == editedAt ? _self.editedAt : editedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,isDeleted: null == isDeleted ? _self.isDeleted : isDeleted // ignore: cast_nullable_to_non_nullable
as bool,readBy: null == readBy ? _self.readBy : readBy // ignore: cast_nullable_to_non_nullable
as List<String>,reactions: null == reactions ? _self.reactions : reactions // ignore: cast_nullable_to_non_nullable
as Map<String, String>,replyToMessageId: freezed == replyToMessageId ? _self.replyToMessageId : replyToMessageId // ignore: cast_nullable_to_non_nullable
as String?,replyToPreview: freezed == replyToPreview ? _self.replyToPreview : replyToPreview // ignore: cast_nullable_to_non_nullable
as SocialMessagePreviewData?,
  ));
}
/// Create a copy of SocialMessage
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$SocialMessageContentCopyWith<$Res> get content {
  
  return $SocialMessageContentCopyWith<$Res>(_self.content, (value) {
    return _then(_self.copyWith(content: value));
  });
}/// Create a copy of SocialMessage
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$SocialMessagePreviewDataCopyWith<$Res>? get replyToPreview {
    if (_self.replyToPreview == null) {
    return null;
  }

  return $SocialMessagePreviewDataCopyWith<$Res>(_self.replyToPreview!, (value) {
    return _then(_self.copyWith(replyToPreview: value));
  });
}
}


/// Adds pattern-matching-related methods to [SocialMessage].
extension SocialMessagePatterns on SocialMessage {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _SocialMessage value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _SocialMessage() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _SocialMessage value)  $default,){
final _that = this;
switch (_that) {
case _SocialMessage():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _SocialMessage value)?  $default,){
final _that = this;
switch (_that) {
case _SocialMessage() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String chatId,  String senderId,  String senderName,  String? senderAvatarUrl,  SocialMessageType type,  SocialMessageContent content, @JsonKey(fromJson: _timestampFromJson, toJson: _timestampToJson)  DateTime timestamp, @JsonKey(fromJson: _timestampFromJson, toJson: _timestampToJson)  DateTime? editedAt,  bool isDeleted,  List<String> readBy,  Map<String, String> reactions,  String? replyToMessageId,  SocialMessagePreviewData? replyToPreview)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _SocialMessage() when $default != null:
return $default(_that.id,_that.chatId,_that.senderId,_that.senderName,_that.senderAvatarUrl,_that.type,_that.content,_that.timestamp,_that.editedAt,_that.isDeleted,_that.readBy,_that.reactions,_that.replyToMessageId,_that.replyToPreview);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String chatId,  String senderId,  String senderName,  String? senderAvatarUrl,  SocialMessageType type,  SocialMessageContent content, @JsonKey(fromJson: _timestampFromJson, toJson: _timestampToJson)  DateTime timestamp, @JsonKey(fromJson: _timestampFromJson, toJson: _timestampToJson)  DateTime? editedAt,  bool isDeleted,  List<String> readBy,  Map<String, String> reactions,  String? replyToMessageId,  SocialMessagePreviewData? replyToPreview)  $default,) {final _that = this;
switch (_that) {
case _SocialMessage():
return $default(_that.id,_that.chatId,_that.senderId,_that.senderName,_that.senderAvatarUrl,_that.type,_that.content,_that.timestamp,_that.editedAt,_that.isDeleted,_that.readBy,_that.reactions,_that.replyToMessageId,_that.replyToPreview);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String chatId,  String senderId,  String senderName,  String? senderAvatarUrl,  SocialMessageType type,  SocialMessageContent content, @JsonKey(fromJson: _timestampFromJson, toJson: _timestampToJson)  DateTime timestamp, @JsonKey(fromJson: _timestampFromJson, toJson: _timestampToJson)  DateTime? editedAt,  bool isDeleted,  List<String> readBy,  Map<String, String> reactions,  String? replyToMessageId,  SocialMessagePreviewData? replyToPreview)?  $default,) {final _that = this;
switch (_that) {
case _SocialMessage() when $default != null:
return $default(_that.id,_that.chatId,_that.senderId,_that.senderName,_that.senderAvatarUrl,_that.type,_that.content,_that.timestamp,_that.editedAt,_that.isDeleted,_that.readBy,_that.reactions,_that.replyToMessageId,_that.replyToPreview);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _SocialMessage extends SocialMessage {
  const _SocialMessage({required this.id, required this.chatId, required this.senderId, required this.senderName, this.senderAvatarUrl, required this.type, required this.content, @JsonKey(fromJson: _timestampFromJson, toJson: _timestampToJson) required this.timestamp, @JsonKey(fromJson: _timestampFromJson, toJson: _timestampToJson) this.editedAt, this.isDeleted = false, final  List<String> readBy = const [], final  Map<String, String> reactions = const {}, this.replyToMessageId, this.replyToPreview}): _readBy = readBy,_reactions = reactions,super._();
  factory _SocialMessage.fromJson(Map<String, dynamic> json) => _$SocialMessageFromJson(json);

@override final  String id;
@override final  String chatId;
@override final  String senderId;
@override final  String senderName;
@override final  String? senderAvatarUrl;
@override final  SocialMessageType type;
// Content payload
@override final  SocialMessageContent content;
// Metadata
@override@JsonKey(fromJson: _timestampFromJson, toJson: _timestampToJson) final  DateTime timestamp;
@override@JsonKey(fromJson: _timestampFromJson, toJson: _timestampToJson) final  DateTime? editedAt;
@override@JsonKey() final  bool isDeleted;
// Status
 final  List<String> _readBy;
// Status
@override@JsonKey() List<String> get readBy {
  if (_readBy is EqualUnmodifiableListView) return _readBy;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_readBy);
}

 final  Map<String, String> _reactions;
@override@JsonKey() Map<String, String> get reactions {
  if (_reactions is EqualUnmodifiableMapView) return _reactions;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_reactions);
}

// UserId -> Emoji
// Reply
@override final  String? replyToMessageId;
@override final  SocialMessagePreviewData? replyToPreview;

/// Create a copy of SocialMessage
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SocialMessageCopyWith<_SocialMessage> get copyWith => __$SocialMessageCopyWithImpl<_SocialMessage>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$SocialMessageToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _SocialMessage&&(identical(other.id, id) || other.id == id)&&(identical(other.chatId, chatId) || other.chatId == chatId)&&(identical(other.senderId, senderId) || other.senderId == senderId)&&(identical(other.senderName, senderName) || other.senderName == senderName)&&(identical(other.senderAvatarUrl, senderAvatarUrl) || other.senderAvatarUrl == senderAvatarUrl)&&(identical(other.type, type) || other.type == type)&&(identical(other.content, content) || other.content == content)&&(identical(other.timestamp, timestamp) || other.timestamp == timestamp)&&(identical(other.editedAt, editedAt) || other.editedAt == editedAt)&&(identical(other.isDeleted, isDeleted) || other.isDeleted == isDeleted)&&const DeepCollectionEquality().equals(other._readBy, _readBy)&&const DeepCollectionEquality().equals(other._reactions, _reactions)&&(identical(other.replyToMessageId, replyToMessageId) || other.replyToMessageId == replyToMessageId)&&(identical(other.replyToPreview, replyToPreview) || other.replyToPreview == replyToPreview));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,chatId,senderId,senderName,senderAvatarUrl,type,content,timestamp,editedAt,isDeleted,const DeepCollectionEquality().hash(_readBy),const DeepCollectionEquality().hash(_reactions),replyToMessageId,replyToPreview);

@override
String toString() {
  return 'SocialMessage(id: $id, chatId: $chatId, senderId: $senderId, senderName: $senderName, senderAvatarUrl: $senderAvatarUrl, type: $type, content: $content, timestamp: $timestamp, editedAt: $editedAt, isDeleted: $isDeleted, readBy: $readBy, reactions: $reactions, replyToMessageId: $replyToMessageId, replyToPreview: $replyToPreview)';
}


}

/// @nodoc
abstract mixin class _$SocialMessageCopyWith<$Res> implements $SocialMessageCopyWith<$Res> {
  factory _$SocialMessageCopyWith(_SocialMessage value, $Res Function(_SocialMessage) _then) = __$SocialMessageCopyWithImpl;
@override @useResult
$Res call({
 String id, String chatId, String senderId, String senderName, String? senderAvatarUrl, SocialMessageType type, SocialMessageContent content,@JsonKey(fromJson: _timestampFromJson, toJson: _timestampToJson) DateTime timestamp,@JsonKey(fromJson: _timestampFromJson, toJson: _timestampToJson) DateTime? editedAt, bool isDeleted, List<String> readBy, Map<String, String> reactions, String? replyToMessageId, SocialMessagePreviewData? replyToPreview
});


@override $SocialMessageContentCopyWith<$Res> get content;@override $SocialMessagePreviewDataCopyWith<$Res>? get replyToPreview;

}
/// @nodoc
class __$SocialMessageCopyWithImpl<$Res>
    implements _$SocialMessageCopyWith<$Res> {
  __$SocialMessageCopyWithImpl(this._self, this._then);

  final _SocialMessage _self;
  final $Res Function(_SocialMessage) _then;

/// Create a copy of SocialMessage
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? chatId = null,Object? senderId = null,Object? senderName = null,Object? senderAvatarUrl = freezed,Object? type = null,Object? content = null,Object? timestamp = null,Object? editedAt = freezed,Object? isDeleted = null,Object? readBy = null,Object? reactions = null,Object? replyToMessageId = freezed,Object? replyToPreview = freezed,}) {
  return _then(_SocialMessage(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,chatId: null == chatId ? _self.chatId : chatId // ignore: cast_nullable_to_non_nullable
as String,senderId: null == senderId ? _self.senderId : senderId // ignore: cast_nullable_to_non_nullable
as String,senderName: null == senderName ? _self.senderName : senderName // ignore: cast_nullable_to_non_nullable
as String,senderAvatarUrl: freezed == senderAvatarUrl ? _self.senderAvatarUrl : senderAvatarUrl // ignore: cast_nullable_to_non_nullable
as String?,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as SocialMessageType,content: null == content ? _self.content : content // ignore: cast_nullable_to_non_nullable
as SocialMessageContent,timestamp: null == timestamp ? _self.timestamp : timestamp // ignore: cast_nullable_to_non_nullable
as DateTime,editedAt: freezed == editedAt ? _self.editedAt : editedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,isDeleted: null == isDeleted ? _self.isDeleted : isDeleted // ignore: cast_nullable_to_non_nullable
as bool,readBy: null == readBy ? _self._readBy : readBy // ignore: cast_nullable_to_non_nullable
as List<String>,reactions: null == reactions ? _self._reactions : reactions // ignore: cast_nullable_to_non_nullable
as Map<String, String>,replyToMessageId: freezed == replyToMessageId ? _self.replyToMessageId : replyToMessageId // ignore: cast_nullable_to_non_nullable
as String?,replyToPreview: freezed == replyToPreview ? _self.replyToPreview : replyToPreview // ignore: cast_nullable_to_non_nullable
as SocialMessagePreviewData?,
  ));
}

/// Create a copy of SocialMessage
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$SocialMessageContentCopyWith<$Res> get content {
  
  return $SocialMessageContentCopyWith<$Res>(_self.content, (value) {
    return _then(_self.copyWith(content: value));
  });
}/// Create a copy of SocialMessage
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$SocialMessagePreviewDataCopyWith<$Res>? get replyToPreview {
    if (_self.replyToPreview == null) {
    return null;
  }

  return $SocialMessagePreviewDataCopyWith<$Res>(_self.replyToPreview!, (value) {
    return _then(_self.copyWith(replyToPreview: value));
  });
}
}


/// @nodoc
mixin _$SocialMessageContent {

 String? get text; String? get mediaUrl; String? get thumbnailUrl; int? get duration;// Seconds (audio/video)
// Game Invite Data
 String? get gameRoomId; String? get gameType;// Diamond Gift Data
 int? get diamondAmount;// Location Data
 double? get latitude; double? get longitude;
/// Create a copy of SocialMessageContent
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SocialMessageContentCopyWith<SocialMessageContent> get copyWith => _$SocialMessageContentCopyWithImpl<SocialMessageContent>(this as SocialMessageContent, _$identity);

  /// Serializes this SocialMessageContent to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SocialMessageContent&&(identical(other.text, text) || other.text == text)&&(identical(other.mediaUrl, mediaUrl) || other.mediaUrl == mediaUrl)&&(identical(other.thumbnailUrl, thumbnailUrl) || other.thumbnailUrl == thumbnailUrl)&&(identical(other.duration, duration) || other.duration == duration)&&(identical(other.gameRoomId, gameRoomId) || other.gameRoomId == gameRoomId)&&(identical(other.gameType, gameType) || other.gameType == gameType)&&(identical(other.diamondAmount, diamondAmount) || other.diamondAmount == diamondAmount)&&(identical(other.latitude, latitude) || other.latitude == latitude)&&(identical(other.longitude, longitude) || other.longitude == longitude));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,text,mediaUrl,thumbnailUrl,duration,gameRoomId,gameType,diamondAmount,latitude,longitude);

@override
String toString() {
  return 'SocialMessageContent(text: $text, mediaUrl: $mediaUrl, thumbnailUrl: $thumbnailUrl, duration: $duration, gameRoomId: $gameRoomId, gameType: $gameType, diamondAmount: $diamondAmount, latitude: $latitude, longitude: $longitude)';
}


}

/// @nodoc
abstract mixin class $SocialMessageContentCopyWith<$Res>  {
  factory $SocialMessageContentCopyWith(SocialMessageContent value, $Res Function(SocialMessageContent) _then) = _$SocialMessageContentCopyWithImpl;
@useResult
$Res call({
 String? text, String? mediaUrl, String? thumbnailUrl, int? duration, String? gameRoomId, String? gameType, int? diamondAmount, double? latitude, double? longitude
});




}
/// @nodoc
class _$SocialMessageContentCopyWithImpl<$Res>
    implements $SocialMessageContentCopyWith<$Res> {
  _$SocialMessageContentCopyWithImpl(this._self, this._then);

  final SocialMessageContent _self;
  final $Res Function(SocialMessageContent) _then;

/// Create a copy of SocialMessageContent
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? text = freezed,Object? mediaUrl = freezed,Object? thumbnailUrl = freezed,Object? duration = freezed,Object? gameRoomId = freezed,Object? gameType = freezed,Object? diamondAmount = freezed,Object? latitude = freezed,Object? longitude = freezed,}) {
  return _then(_self.copyWith(
text: freezed == text ? _self.text : text // ignore: cast_nullable_to_non_nullable
as String?,mediaUrl: freezed == mediaUrl ? _self.mediaUrl : mediaUrl // ignore: cast_nullable_to_non_nullable
as String?,thumbnailUrl: freezed == thumbnailUrl ? _self.thumbnailUrl : thumbnailUrl // ignore: cast_nullable_to_non_nullable
as String?,duration: freezed == duration ? _self.duration : duration // ignore: cast_nullable_to_non_nullable
as int?,gameRoomId: freezed == gameRoomId ? _self.gameRoomId : gameRoomId // ignore: cast_nullable_to_non_nullable
as String?,gameType: freezed == gameType ? _self.gameType : gameType // ignore: cast_nullable_to_non_nullable
as String?,diamondAmount: freezed == diamondAmount ? _self.diamondAmount : diamondAmount // ignore: cast_nullable_to_non_nullable
as int?,latitude: freezed == latitude ? _self.latitude : latitude // ignore: cast_nullable_to_non_nullable
as double?,longitude: freezed == longitude ? _self.longitude : longitude // ignore: cast_nullable_to_non_nullable
as double?,
  ));
}

}


/// Adds pattern-matching-related methods to [SocialMessageContent].
extension SocialMessageContentPatterns on SocialMessageContent {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _SocialMessageContent value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _SocialMessageContent() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _SocialMessageContent value)  $default,){
final _that = this;
switch (_that) {
case _SocialMessageContent():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _SocialMessageContent value)?  $default,){
final _that = this;
switch (_that) {
case _SocialMessageContent() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String? text,  String? mediaUrl,  String? thumbnailUrl,  int? duration,  String? gameRoomId,  String? gameType,  int? diamondAmount,  double? latitude,  double? longitude)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _SocialMessageContent() when $default != null:
return $default(_that.text,_that.mediaUrl,_that.thumbnailUrl,_that.duration,_that.gameRoomId,_that.gameType,_that.diamondAmount,_that.latitude,_that.longitude);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String? text,  String? mediaUrl,  String? thumbnailUrl,  int? duration,  String? gameRoomId,  String? gameType,  int? diamondAmount,  double? latitude,  double? longitude)  $default,) {final _that = this;
switch (_that) {
case _SocialMessageContent():
return $default(_that.text,_that.mediaUrl,_that.thumbnailUrl,_that.duration,_that.gameRoomId,_that.gameType,_that.diamondAmount,_that.latitude,_that.longitude);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String? text,  String? mediaUrl,  String? thumbnailUrl,  int? duration,  String? gameRoomId,  String? gameType,  int? diamondAmount,  double? latitude,  double? longitude)?  $default,) {final _that = this;
switch (_that) {
case _SocialMessageContent() when $default != null:
return $default(_that.text,_that.mediaUrl,_that.thumbnailUrl,_that.duration,_that.gameRoomId,_that.gameType,_that.diamondAmount,_that.latitude,_that.longitude);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _SocialMessageContent extends SocialMessageContent {
  const _SocialMessageContent({this.text, this.mediaUrl, this.thumbnailUrl, this.duration, this.gameRoomId, this.gameType, this.diamondAmount, this.latitude, this.longitude}): super._();
  factory _SocialMessageContent.fromJson(Map<String, dynamic> json) => _$SocialMessageContentFromJson(json);

@override final  String? text;
@override final  String? mediaUrl;
@override final  String? thumbnailUrl;
@override final  int? duration;
// Seconds (audio/video)
// Game Invite Data
@override final  String? gameRoomId;
@override final  String? gameType;
// Diamond Gift Data
@override final  int? diamondAmount;
// Location Data
@override final  double? latitude;
@override final  double? longitude;

/// Create a copy of SocialMessageContent
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SocialMessageContentCopyWith<_SocialMessageContent> get copyWith => __$SocialMessageContentCopyWithImpl<_SocialMessageContent>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$SocialMessageContentToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _SocialMessageContent&&(identical(other.text, text) || other.text == text)&&(identical(other.mediaUrl, mediaUrl) || other.mediaUrl == mediaUrl)&&(identical(other.thumbnailUrl, thumbnailUrl) || other.thumbnailUrl == thumbnailUrl)&&(identical(other.duration, duration) || other.duration == duration)&&(identical(other.gameRoomId, gameRoomId) || other.gameRoomId == gameRoomId)&&(identical(other.gameType, gameType) || other.gameType == gameType)&&(identical(other.diamondAmount, diamondAmount) || other.diamondAmount == diamondAmount)&&(identical(other.latitude, latitude) || other.latitude == latitude)&&(identical(other.longitude, longitude) || other.longitude == longitude));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,text,mediaUrl,thumbnailUrl,duration,gameRoomId,gameType,diamondAmount,latitude,longitude);

@override
String toString() {
  return 'SocialMessageContent(text: $text, mediaUrl: $mediaUrl, thumbnailUrl: $thumbnailUrl, duration: $duration, gameRoomId: $gameRoomId, gameType: $gameType, diamondAmount: $diamondAmount, latitude: $latitude, longitude: $longitude)';
}


}

/// @nodoc
abstract mixin class _$SocialMessageContentCopyWith<$Res> implements $SocialMessageContentCopyWith<$Res> {
  factory _$SocialMessageContentCopyWith(_SocialMessageContent value, $Res Function(_SocialMessageContent) _then) = __$SocialMessageContentCopyWithImpl;
@override @useResult
$Res call({
 String? text, String? mediaUrl, String? thumbnailUrl, int? duration, String? gameRoomId, String? gameType, int? diamondAmount, double? latitude, double? longitude
});




}
/// @nodoc
class __$SocialMessageContentCopyWithImpl<$Res>
    implements _$SocialMessageContentCopyWith<$Res> {
  __$SocialMessageContentCopyWithImpl(this._self, this._then);

  final _SocialMessageContent _self;
  final $Res Function(_SocialMessageContent) _then;

/// Create a copy of SocialMessageContent
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? text = freezed,Object? mediaUrl = freezed,Object? thumbnailUrl = freezed,Object? duration = freezed,Object? gameRoomId = freezed,Object? gameType = freezed,Object? diamondAmount = freezed,Object? latitude = freezed,Object? longitude = freezed,}) {
  return _then(_SocialMessageContent(
text: freezed == text ? _self.text : text // ignore: cast_nullable_to_non_nullable
as String?,mediaUrl: freezed == mediaUrl ? _self.mediaUrl : mediaUrl // ignore: cast_nullable_to_non_nullable
as String?,thumbnailUrl: freezed == thumbnailUrl ? _self.thumbnailUrl : thumbnailUrl // ignore: cast_nullable_to_non_nullable
as String?,duration: freezed == duration ? _self.duration : duration // ignore: cast_nullable_to_non_nullable
as int?,gameRoomId: freezed == gameRoomId ? _self.gameRoomId : gameRoomId // ignore: cast_nullable_to_non_nullable
as String?,gameType: freezed == gameType ? _self.gameType : gameType // ignore: cast_nullable_to_non_nullable
as String?,diamondAmount: freezed == diamondAmount ? _self.diamondAmount : diamondAmount // ignore: cast_nullable_to_non_nullable
as int?,latitude: freezed == latitude ? _self.latitude : latitude // ignore: cast_nullable_to_non_nullable
as double?,longitude: freezed == longitude ? _self.longitude : longitude // ignore: cast_nullable_to_non_nullable
as double?,
  ));
}


}


/// @nodoc
mixin _$SocialMessagePreviewData {

 String get id; String get senderName; String get contentPreview;
/// Create a copy of SocialMessagePreviewData
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SocialMessagePreviewDataCopyWith<SocialMessagePreviewData> get copyWith => _$SocialMessagePreviewDataCopyWithImpl<SocialMessagePreviewData>(this as SocialMessagePreviewData, _$identity);

  /// Serializes this SocialMessagePreviewData to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SocialMessagePreviewData&&(identical(other.id, id) || other.id == id)&&(identical(other.senderName, senderName) || other.senderName == senderName)&&(identical(other.contentPreview, contentPreview) || other.contentPreview == contentPreview));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,senderName,contentPreview);

@override
String toString() {
  return 'SocialMessagePreviewData(id: $id, senderName: $senderName, contentPreview: $contentPreview)';
}


}

/// @nodoc
abstract mixin class $SocialMessagePreviewDataCopyWith<$Res>  {
  factory $SocialMessagePreviewDataCopyWith(SocialMessagePreviewData value, $Res Function(SocialMessagePreviewData) _then) = _$SocialMessagePreviewDataCopyWithImpl;
@useResult
$Res call({
 String id, String senderName, String contentPreview
});




}
/// @nodoc
class _$SocialMessagePreviewDataCopyWithImpl<$Res>
    implements $SocialMessagePreviewDataCopyWith<$Res> {
  _$SocialMessagePreviewDataCopyWithImpl(this._self, this._then);

  final SocialMessagePreviewData _self;
  final $Res Function(SocialMessagePreviewData) _then;

/// Create a copy of SocialMessagePreviewData
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? senderName = null,Object? contentPreview = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,senderName: null == senderName ? _self.senderName : senderName // ignore: cast_nullable_to_non_nullable
as String,contentPreview: null == contentPreview ? _self.contentPreview : contentPreview // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [SocialMessagePreviewData].
extension SocialMessagePreviewDataPatterns on SocialMessagePreviewData {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _SocialMessagePreviewData value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _SocialMessagePreviewData() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _SocialMessagePreviewData value)  $default,){
final _that = this;
switch (_that) {
case _SocialMessagePreviewData():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _SocialMessagePreviewData value)?  $default,){
final _that = this;
switch (_that) {
case _SocialMessagePreviewData() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String senderName,  String contentPreview)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _SocialMessagePreviewData() when $default != null:
return $default(_that.id,_that.senderName,_that.contentPreview);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String senderName,  String contentPreview)  $default,) {final _that = this;
switch (_that) {
case _SocialMessagePreviewData():
return $default(_that.id,_that.senderName,_that.contentPreview);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String senderName,  String contentPreview)?  $default,) {final _that = this;
switch (_that) {
case _SocialMessagePreviewData() when $default != null:
return $default(_that.id,_that.senderName,_that.contentPreview);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _SocialMessagePreviewData extends SocialMessagePreviewData {
  const _SocialMessagePreviewData({required this.id, required this.senderName, required this.contentPreview}): super._();
  factory _SocialMessagePreviewData.fromJson(Map<String, dynamic> json) => _$SocialMessagePreviewDataFromJson(json);

@override final  String id;
@override final  String senderName;
@override final  String contentPreview;

/// Create a copy of SocialMessagePreviewData
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SocialMessagePreviewDataCopyWith<_SocialMessagePreviewData> get copyWith => __$SocialMessagePreviewDataCopyWithImpl<_SocialMessagePreviewData>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$SocialMessagePreviewDataToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _SocialMessagePreviewData&&(identical(other.id, id) || other.id == id)&&(identical(other.senderName, senderName) || other.senderName == senderName)&&(identical(other.contentPreview, contentPreview) || other.contentPreview == contentPreview));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,senderName,contentPreview);

@override
String toString() {
  return 'SocialMessagePreviewData(id: $id, senderName: $senderName, contentPreview: $contentPreview)';
}


}

/// @nodoc
abstract mixin class _$SocialMessagePreviewDataCopyWith<$Res> implements $SocialMessagePreviewDataCopyWith<$Res> {
  factory _$SocialMessagePreviewDataCopyWith(_SocialMessagePreviewData value, $Res Function(_SocialMessagePreviewData) _then) = __$SocialMessagePreviewDataCopyWithImpl;
@override @useResult
$Res call({
 String id, String senderName, String contentPreview
});




}
/// @nodoc
class __$SocialMessagePreviewDataCopyWithImpl<$Res>
    implements _$SocialMessagePreviewDataCopyWith<$Res> {
  __$SocialMessagePreviewDataCopyWithImpl(this._self, this._then);

  final _SocialMessagePreviewData _self;
  final $Res Function(_SocialMessagePreviewData) _then;

/// Create a copy of SocialMessagePreviewData
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? senderName = null,Object? contentPreview = null,}) {
  return _then(_SocialMessagePreviewData(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,senderName: null == senderName ? _self.senderName : senderName // ignore: cast_nullable_to_non_nullable
as String,contentPreview: null == contentPreview ? _self.contentPreview : contentPreview // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on
