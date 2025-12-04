
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
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

  Future<void> joinGame(String gameId, Player player) async {
    try {
      final profileService = _ref.read(profileServiceProvider);
      final profile = await profileService.getProfile(player.id);
      final playerWithProfile = player.copyWith(profile: profile);

      await _db.collection('games').doc(gameId).update({
        'players': FieldValue.arrayUnion([playerWithProfile.toJson()]),
        'scores.${player.id}': 0,
      });
    } catch (e) {
      debugPrint('Error joining game: $e');
      rethrow;
    }
  }

  Future<void> leaveGame(String gameId, String playerId) async {
    try {
      final doc = await _gamesRef.doc(gameId).get();
      if (!doc.exists) return;

      final game = doc.data()!;
      final updatedPlayers = game.players.where((p) => p.id != playerId).toList();
      final updatedScores = Map<String, int>.from(game.scores)..remove(playerId);

      await _gamesRef.doc(gameId).update(
        game.copyWith(players: updatedPlayers, scores: updatedScores).toJson(),
      );
    } catch (e) {
      debugPrint('Error leaving game: $e');
      rethrow;
    }
  }
}

