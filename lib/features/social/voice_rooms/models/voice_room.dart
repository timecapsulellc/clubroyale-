import 'package:freezed_annotation/freezed_annotation.dart';

part 'voice_room.freezed.dart';
part 'voice_room.g.dart';

/// Voice room participant status
@freezed
abstract class VoiceParticipant with _$VoiceParticipant {
  const VoiceParticipant._();

  const factory VoiceParticipant({
    required String id,
    required String name,
    String? photoUrl,
    @Default(false) bool isMuted,
    @Default(false) bool isSpeaking,
    @Default(false) bool isDeafened,
    DateTime? joinedAt,
  }) = _VoiceParticipant;

  factory VoiceParticipant.fromJson(Map<String, dynamic> json) =>
      _$VoiceParticipantFromJson(json);
}

/// Voice room model for Discord-style group voice
@freezed
abstract class VoiceRoom with _$VoiceRoom {
  const VoiceRoom._();

  const factory VoiceRoom({
    required String id,
    required String name,
    String? description,
    required String hostId,
    required String hostName,
    @Default({}) Map<String, VoiceParticipant> participants,
    @Default(8) int maxParticipants,
    required DateTime createdAt,
    @Default(true) bool isActive,
    @Default(false) bool isPrivate,
    String? linkedGameId,
    String? linkedLobbyId,
  }) = _VoiceRoom;

  factory VoiceRoom.fromJson(Map<String, dynamic> json) =>
      _$VoiceRoomFromJson(json);
}

/// Voice room type for categorization
enum VoiceRoomType {
  lobby, // General lobby voice room
  game, // In-game voice room
  friends, // Friends-only voice room
  public, // Public voice room
}
