import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:clubroyale/features/game/game_room.dart';
import 'package:clubroyale/features/game/game_config.dart';
import 'package:clubroyale/features/game/call_break_service.dart';
import 'package:clubroyale/features/game/models/game_state.dart';
import 'package:clubroyale/features/game/engine/models/deck.dart';
import 'package:clubroyale/features/profile/profile_service.dart';
import 'package:clubroyale/features/lobby/room_code_service.dart';
import 'package:clubroyale/features/auth/auth_service.dart';
import 'package:clubroyale/features/wallet/bot_diamond_service.dart';
import 'dart:async';
import 'dart:math';

final lobbyServiceProvider = Provider<LobbyService>((ref) => LobbyService(ref));

/// In-memory storage for Test Mode games (bypasses Firestore)
class _TestModeStorage {
  static final Map<String, GameRoom> _games = {};
  static final StreamController<List<GameRoom>> _gamesController =
      StreamController<List<GameRoom>>.broadcast();

  static void addGame(String id, GameRoom game) {
    _games[id] = game.copyWith(id: id);
    _notifyListeners();
  }

  static void updateGame(String id, GameRoom game) {
    _games[id] = game.copyWith(id: id);
    _notifyListeners();
  }

  static GameRoom? getGame(String id) => _games[id];

  static List<GameRoom> getAllGames() => _games.values.toList();

  static Stream<List<GameRoom>> watchGames() {
    // Emit current state immediately for new listeners
    Future.microtask(() => _notifyListeners());
    return _gamesController.stream;
  }

  static Stream<GameRoom?> watchGame(String id) {
    return watchGames().map(
      (games) => games.firstWhere((g) => g.id == id, orElse: () => _games[id]!),
    );
  }

  static void _notifyListeners() {
    _gamesController.add(_games.values.toList());
  }

  static String generateRoomCode() {
    final random = Random();
    return (100000 + random.nextInt(899999)).toString();
  }
}

class LobbyService {
  final Ref _ref;
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  late final CollectionReference<GameRoom> _gamesRef;

  LobbyService(this._ref) {
    _gamesRef = _db
        .collection('games')
        .withConverter<GameRoom>(
          fromFirestore: (snapshots, _) => GameRoom.fromJson(snapshots.data()!),
          toFirestore: (game, _) => game.toJson(),
        );
  }

  Stream<List<GameRoom>> getGames() {
    // Use in-memory storage for Test Mode
    if (TestMode.isEnabled) {
      return _TestModeStorage.watchGames();
    }
    // Use raw collection to manually parse with error handling
    return _db.collection('games').snapshots().map((snapshot) {
      final validGames = <GameRoom>[];
      for (final doc in snapshot.docs) {
        try {
          final data = doc.data();
          // Skip documents with missing critical fields
          if (data['players'] == null) {
            debugPrint('⚠️ Skipping corrupted game ${doc.id}: missing players');
            continue;
          }
          var game = GameRoom.fromJson(data).copyWith(id: doc.id);

          // Filter out invalid players (empty IDs from corrupted data)
          final validPlayers = game.players
              .where((p) => p.id.isNotEmpty)
              .toList();
          if (validPlayers.isEmpty) {
            debugPrint(
              '⚠️ Skipping corrupted game ${doc.id}: no valid players',
            );
            continue;
          }
          game = game.copyWith(players: validPlayers);

          validGames.add(game);
        } catch (e) {
          debugPrint('⚠️ Skipping corrupted game ${doc.id}: $e');
          // Skip corrupted documents instead of crashing
        }
      }
      return validGames;
    });
  }

  /// Creates a new game room with a unique 6-digit code
  /// [hostId] - The user ID of the host creating the room
  /// [config] - Optional game configuration (defaults will be used if not provided)
  Future<String> createGame(GameRoom room) async {
    // Use in-memory storage for Test Mode
    if (TestMode.isEnabled) {
      final roomCode = _TestModeStorage.generateRoomCode();
      final gameId = 'test_game_${DateTime.now().millisecondsSinceEpoch}';

      final newRoom = room.copyWith(
        roomCode: roomCode,
        status: GameStatus.waiting,
        createdAt: DateTime.now(),
      );

      _TestModeStorage.addGame(gameId, newRoom);
      debugPrint('🧪 Test Mode: Created room $gameId with code $roomCode');
      return gameId;
    }

    final roomCodeService = _ref.read(roomCodeServiceProvider);
    final profileService = _ref.read(profileServiceProvider);

    // Generate unique 6-digit room code
    final roomCode = await roomCodeService.generateUniqueCode();

    // Fetch profiles for all players
    final playersWithProfiles = await Future.wait(
      room.players.map((player) async {
        final profile = await profileService.getProfile(player.id);
        return player.copyWith(profile: profile);
      }),
    );

    // Create Firestore-safe map with explicit toJson calls on nested objects
    final firestoreData = <String, dynamic>{
      'name': room.name,
      'hostId': room.hostId,
      'roomCode': roomCode,
      'status': GameStatus.waiting.name,
      'gameType': room.gameType,
      'config': {
        'pointValue': room.config.pointValue,
        'maxPlayers': room.config.maxPlayers,
        'allowAds': room.config.allowAds,
        'totalRounds': room.config.totalRounds,
        'bootAmount': room.config.bootAmount,
      },
      'players': playersWithProfiles
          .map(
            (p) => {
              'id': p.id,
              'name': p.name,
              'isReady': p.isReady,
              'isBot': p.isBot,
              'profile': p.profile?.toJson(),
            },
          )
          .toList(),
      'scores': room.scores,
      'isFinished': false,
      'isPublic': room.isPublic,
      'createdAt': FieldValue.serverTimestamp(),
      'currentRound': 1,
    };

    final newGame = await _db.collection('games').add(firestoreData);
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
      // Test Mode: Search in-memory storage
      if (TestMode.isEnabled) {
        final games = _TestModeStorage.getAllGames();
        final matchingGame = games
            .where((g) => g.roomCode == roomCode)
            .firstOrNull;

        if (matchingGame == null) {
          throw Exception('Room not found. Check the code and try again.');
        }

        // Check if room is full
        if (matchingGame.players.length >= matchingGame.config.maxPlayers) {
          throw Exception(
            'Room is full. Maximum ${matchingGame.config.maxPlayers} players allowed.',
          );
        }

        // Check if player is already in the room
        if (matchingGame.players.any((p) => p.id == player.id)) {
          return matchingGame.id;
        }

        // Check if game is still accepting players
        if (matchingGame.status != GameStatus.waiting) {
          throw Exception('Game has already started. Cannot join now.');
        }

        // Add player to the game
        final updatedPlayers = [...matchingGame.players, player];
        final updatedScores = Map<String, int>.from(matchingGame.scores)
          ..[player.id] = 0;

        _TestModeStorage.updateGame(
          matchingGame.id!,
          matchingGame.copyWith(players: updatedPlayers, scores: updatedScores),
        );

        debugPrint(
          '🧪 Test Mode: Player ${player.name} joined room ${matchingGame.id}',
        );
        return matchingGame.id;
      }

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
        throw Exception(
          'Room is full. Maximum ${game.config.maxPlayers} players allowed.',
        );
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
    // Test Mode: Use in-memory storage
    if (TestMode.isEnabled) {
      final game = _TestModeStorage.getGame(gameId);
      if (game == null) {
        throw Exception('Game not found');
      }

      final playerIds = game.players.map((p) => p.id).toList();

      // Update game state
      _TestModeStorage.updateGame(
        gameId,
        game.copyWith(
          status: GameStatus.playing,
          // Only init Call Break specific fields if needed
          gamePhase: game.gameType == 'call_break' ? GamePhase.bidding : null,
          playerHands: game.gameType == 'call_break'
              ? Deck.dealHands(playerIds)
              : {},
          bids: <String, Bid>{},
          tricksWon: {for (var id in playerIds) id: 0},
          currentTrick: null,
          trickHistory: [],
          currentTurn: playerIds.first,
        ),
      );

      debugPrint('🧪 Test Mode: Game started with ${playerIds.length} players');
      return;
    }

    try {
      final doc = await _gamesRef.doc(gameId).get();
      if (!doc.exists) {
        throw Exception('Game not found');
      }

      final game = doc.data()!.copyWith(id: doc.id);
      final playerIds = game.players.map((p) => p.id).toList();

      // Game-specific initialization
      if (game.gameType == 'call_break') {
        // Require exactly 4 players for Call Break
        if (playerIds.length != 4) {
          throw Exception('Call Break requires exactly 4 players');
        }

        // Use CallBreakService to initialize the game with dealt cards
        final callBreakService = _ref.read(callBreakServiceProvider);
        await callBreakService.startNewRound(gameId, playerIds);
      }

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
      // Remove player from list
      final updatedPlayers = game.players
          .where((p) => p.id != playerId)
          .toList();
      // Remove player from scores
      final updatedScores = Map<String, int>.from(game.scores)
        ..remove(playerId);

      // Perform partial update to avoid serialization issues with nested objects
      await _gamesRef.doc(gameId).update({
        'players': updatedPlayers.map((p) => p.toJson()).toList(),
        'scores': updatedScores,
      });
    } catch (e) {
      debugPrint('Error leaving game: $e');
      rethrow;
    }
  }

  /// Watch a specific game room for real-time updates
  Stream<GameRoom?> watchRoom(String gameId) {
    // Use in-memory storage for Test Mode
    if (TestMode.isEnabled) {
      return _TestModeStorage.watchGame(gameId);
    }
    return _gamesRef.doc(gameId).snapshots().map((snapshot) {
      if (!snapshot.exists) return null;
      return snapshot.data()?.copyWith(id: snapshot.id);
    });
  }

  /// Watch public rooms (isPublic = true, status = waiting)
  Stream<List<GameRoom>> watchPublicRooms() {
    // Test Mode: Return empty for now
    if (TestMode.isEnabled) {
      return _TestModeStorage.watchGames().map(
        (games) => games
            .where((g) => g.isPublic && g.status == GameStatus.waiting)
            .toList(),
      );
    }

    return _db
        .collection('games')
        .where('isPublic', isEqualTo: true)
        .where('status', isEqualTo: GameStatus.waiting.name)
        .orderBy('createdAt', descending: true)
        .limit(20)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs
              .map((doc) => GameRoom.fromJson(doc.data()).copyWith(id: doc.id))
              .toList();
        });
  }

  /// Join a room by ID (used by public rooms list)
  Future<void> joinRoom(String gameId, Player player) async {
    await joinGame(gameId, player);
  }

  /// Set a player's ready status in a game room
  Future<void> setPlayerReady(
    String gameId,
    String playerId,
    bool isReady,
  ) async {
    // Test Mode: Use in-memory storage
    if (TestMode.isEnabled) {
      final game = _TestModeStorage.getGame(gameId);
      if (game == null) {
        throw Exception('Game room not found');
      }

      final updatedPlayers = game.players.map((player) {
        if (player.id == playerId) {
          return player.copyWith(isReady: isReady);
        }
        return player;
      }).toList();

      _TestModeStorage.updateGame(
        gameId,
        game.copyWith(players: updatedPlayers),
      );
      debugPrint('🧪 Test Mode: Player $playerId ready=$isReady');
      return;
    }

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
        debugPrint(
          'ERROR: Player $playerId not found in room $gameId. Players: ${game.players.map((p) => p.id).toList()}',
        );
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
  /// Bots are automatically funded with diamonds
  Future<void> addBot(String gameId) async {
    // Use in-memory storage for Test Mode
    if (TestMode.isEnabled) {
      final game = _TestModeStorage.getGame(gameId);
      if (game == null) return;

      if (game.players.length >= game.config.maxPlayers) {
        throw Exception('Room is full (max ${game.config.maxPlayers} players)');
      }

      final botId = 'bot_${DateTime.now().millisecondsSinceEpoch}';
      final botPlayer = Player(
        id: botId,
        name: 'Bot ${game.players.length + 1}',
        isReady: true,
        isBot: true,
      );

      final updatedPlayers = [...game.players, botPlayer];
      final updatedScores = Map<String, int>.from(game.scores)..[botId] = 0;

      _TestModeStorage.updateGame(
        gameId,
        game.copyWith(players: updatedPlayers, scores: updatedScores),
      );
      debugPrint('🧪 Test Mode: Added bot $botId to game $gameId');
      return;
    }

    try {
      final doc = await _gamesRef.doc(gameId).get();
      if (!doc.exists) return;

      final game = doc.data()!;
      if (game.players.length >= game.config.maxPlayers) {
        throw Exception('Room is full (max ${game.config.maxPlayers} players)');
      }

      final botId = 'bot_${DateTime.now().millisecondsSinceEpoch}';
      final botPlayer = Player(
        id: botId,
        name: 'Bot ${game.players.length + 1}',
        isReady: true, // Bots are always ready
        isBot: true, // Mark as bot for tracking
      );

      // Fund the bot with diamonds
      try {
        final botDiamondService = _ref.read(botDiamondServiceProvider);
        await botDiamondService.ensureBotFunded(botId);
        debugPrint('💎 Bot $botId funded and ready to play');
      } catch (e) {
        debugPrint('Warning: Could not fund bot $botId: $e');
        // Continue anyway - bot can still play in test scenarios
      }

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
