
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:myapp/features/game/game_room.dart';
import 'package:myapp/features/game/game_config.dart';
import 'package:myapp/features/game/call_break_service.dart';
import 'package:myapp/features/profile/profile_service.dart';
import 'package:myapp/features/lobby/room_code_service.dart';

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

  /// Creates a new game room with a unique 6-digit code
  /// [hostId] - The user ID of the host creating the room
  /// [config] - Optional game configuration (defaults will be used if not provided)
  Future<String> createGame(GameRoom room) async {
    final roomCodeService = _ref.read(roomCodeServiceProvider);
    final profileService = _ref.read(profileServiceProvider);
    
    // Generate unique 6-digit room code
    final roomCode = await roomCodeService.generateUniqueCode();
    
    // Fetch profiles for all players
    final playersWithProfiles = await Future.wait(room.players.map((player) async {
      final profile = await profileService.getProfile(player.id);
      return player.copyWith(profile: profile);
    }));

    // Create room with host info, code, and config
    final newRoom = room.copyWith(
      players: playersWithProfiles,
      roomCode: roomCode,
      status: GameStatus.waiting,
      createdAt: DateTime.now(),
    );
    
    final newGame = await _gamesRef.add(newRoom);
    return newGame.id;
  }

  /// Joins a game using its Firestore document ID
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

  /// Joins a game using the 6-digit room code
  Future<String?> joinByCode(String roomCode, Player player) async {
    try {
      final roomCodeService = _ref.read(roomCodeServiceProvider);
      
      // Validate code format
      if (!roomCodeService.isValidCodeFormat(roomCode)) {
        throw Exception('Invalid room code format. Enter 6 digits.');
      }
      
      // Find room by code
      final roomDoc = await roomCodeService.findRoomByCode(roomCode);
      if (roomDoc == null) {
        throw Exception('Room not found. Check the code and try again.');
      }
      
      final gameId = roomDoc.id;
      final data = roomDoc.data() as Map<String, dynamic>;
      final game = GameRoom.fromJson(data).copyWith(id: gameId);
      
      // Check if room is full
      if (game.players.length >= game.config.maxPlayers) {
        throw Exception('Room is full. Maximum ${game.config.maxPlayers} players allowed.');
      }
      
      // Check if player is already in the room
      if (game.players.any((p) => p.id == player.id)) {
        // Already in room, just return the game ID
        return gameId;
      }
      
      // Check if game is still accepting players
      if (game.status != GameStatus.waiting) {
        throw Exception('Game has already started. Cannot join now.');
      }
      
      // Join the game
      await joinGame(gameId, player);
      return gameId;
    } catch (e) {
      debugPrint('Error joining by code: $e');
      rethrow;
    }
  }

  /// Get a specific game room by ID
  Future<GameRoom?> getGame(String gameId) async {
    try {
      final doc = await _gamesRef.doc(gameId).get();
      if (doc.exists) {
        return doc.data()?.copyWith(id: doc.id);
      }
      return null;
    } catch (e) {
      debugPrint('Error getting game: $e');
      return null;
    }
  }

  /// Start the game (host only - changes status from waiting to playing)
  /// Initializes Call Break game with card dealing and bidding phase
  Future<void> startGame(String gameId) async {
    try {
      final doc = await _gamesRef.doc(gameId).get();
      if (!doc.exists) {
        throw Exception('Game not found');
      }
      
      final game = doc.data()!.copyWith(id: doc.id);
      final playerIds = game.players.map((p) => p.id).toList();
      
      // Require exactly 4 players for Call Break
      if (playerIds.length != 4) {
        throw Exception('Call Break requires exactly 4 players');
      }
      
      // Use CallBreakService to initialize the game with dealt cards
      final callBreakService = _ref.read(callBreakServiceProvider);
      await callBreakService.startNewRound(gameId, playerIds);
      
      // Update status to playing
      await _db.collection('games').doc(gameId).update({
        'status': GameStatus.playing.name,
      });
    } catch (e) {
      debugPrint('Error starting game: $e');
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

  /// Watch a specific game room for real-time updates
  Stream<GameRoom?> watchRoom(String gameId) {
    return _gamesRef.doc(gameId).snapshots().map((snapshot) {
      if (!snapshot.exists) return null;
      return snapshot.data()?.copyWith(id: snapshot.id);
    });
  }

  /// Set a player's ready status in a game room
  Future<void> setPlayerReady(String gameId, String playerId, bool isReady) async {
    try {
      final doc = await _gamesRef.doc(gameId).get();
      if (!doc.exists) {
        throw Exception('Game room not found');
      }

      final game = doc.data()!.copyWith(id: doc.id);
      
      // Find and update the player's ready status
      final updatedPlayers = game.players.map((player) {
        if (player.id == playerId) {
          return player.copyWith(isReady: isReady);
        }
        return player;
      }).toList();

      // Validate player exists in room
      if (!updatedPlayers.any((p) => p.id == playerId)) {
        throw Exception('Player not in this room');
      }

      await _gamesRef.doc(gameId).update({
        'players': updatedPlayers.map((p) => p.toJson()).toList(),
      });
    } catch (e) {
      debugPrint('Error setting player ready status: $e');
      rethrow;
    }
  }

  /// Add a bot player to the game (for testing)
  Future<void> addBot(String gameId) async {
    try {
      final doc = await _gamesRef.doc(gameId).get();
      if (!doc.exists) return;
      
      final game = doc.data()!;
      if (game.players.length >= 4) {
        throw Exception('Room is full');
      }
      
      final botId = 'bot_${DateTime.now().millisecondsSinceEpoch}';
      final botPlayer = Player(
        id: botId,
        name: 'Bot ${game.players.length + 1}',
        isReady: true, // Bots are always ready
      );
      
      await _db.collection('games').doc(gameId).update({
        'players': FieldValue.arrayUnion([botPlayer.toJson()]),
        'scores.$botId': 0,
      });
    } catch (e) {
      debugPrint('Error adding bot: $e');
      rethrow;
    }
  }

  /// Check if the game can be started (all players ready, minimum count)
  bool canStartGame(GameRoom room, String userId) {
    // Must be the host
    if (room.hostId != userId) {
      return false;
    }
    
    // Must have at least 2 players
    if (room.players.length < 2) {
      return false;
    }
    
    // All players must be ready
    return room.allPlayersReady;
  }
}

