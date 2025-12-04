
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:myapp/features/profile/user_profile.dart';

part 'game_room.freezed.dart';
part 'game_room.g.dart';

@freezed
class GameRoom with _$GameRoom {
  const factory GameRoom({
    String? id,
    required String name,
    required List<Player> players,
    required Map<String, int> scores,
    @Default(false) bool isFinished,
    DateTime? createdAt,
  }) = _GameRoom;

  factory GameRoom.fromJson(Map<String, dynamic> json) => _$GameRoomFromJson(json);
}

@freezed
class Player with _$Player {
  const factory Player({
    required String id,
    required String name,
    UserProfile? profile,
  }) = _Player;

  factory Player.fromJson(Map<String, dynamic> json) => _$PlayerFromJson(json);
}
