
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:myapp/features/game/game_room.dart';
import 'package:myapp/features/profile/profile_service.dart';

final lobbyServiceProvider = Provider<LobbyService>((ref) => LobbyService(ref));

class LobbyService {
  final Ref _ref;
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  late final CollectionReference<GameRoom> _gamesRef;

  LobbyService(this._ref) {
    _gamesRef = _db.collection('games').withConverter<GameRoom>(
          fromFirestore: (snapshots, _) => GameRoom.fromJson(snapshots.data()!),
          toFirestore: (game, _) => game.toJson(),
        );
  }

  Stream<List<GameRoom>> getGames() {
    return _gamesRef.snapshots().map((snapshot) {
      return snapshot.docs.map((doc) => doc.data().copyWith(id: doc.id)).toList();
    });
  }

  Future<String> createGame(GameRoom room) async {
    final profileService = _ref.read(profileServiceProvider);
    final playersWithProfiles = await Future.wait(room.players.map((player) async {
      final profile = await profileService.getProfile(player.id);
      return player.copyWith(profile: profile);
    }));

    final newRoom = room.copyWith(players: playersWithProfiles);
    final newGame = await _gamesRef.add(newRoom);
    return newGame.id;
  }
}
