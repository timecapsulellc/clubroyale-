import 'package:flutter_test/flutter_test.dart';
import 'package:clubroyale/features/game/game_room.dart';
import 'package:clubroyale/features/profile/user_profile.dart';

void main() {
  group('GameRoom Model Tests', () {
    test('should create GameRoom from JSON with player ready status', () {
      final json = {
        'id': 'room1',
        'name': 'Test Room',
        'hostId': 'user1',
        'roomCode': '123456',
        'status': 'waiting',
        'config': {
          'pointValue': 10.0,
          'maxPlayers': 4,
          'allowAds': true,
          'totalRounds': 5,
          'bootAmount': 0,
        },
        'players': [
          {
            'id': 'user1',
            'name': 'Player 1',
            'profile': null,
            'isReady': true,
          },
          {
            'id': 'user2',
            'name': 'Player 2',
            'profile': null,
            'isReady': false,
          },
        ],
        'scores': {'user1': 0, 'user2': 0},
        'isFinished': false,
        'currentRound': 1,
      };

      final room = GameRoom.fromJson(json);

      expect(room.name, 'Test Room');
      expect(room.players.length, 2);
      expect(room.players[0].isReady, true);
      expect(room.players[1].isReady, false);
    });

    test('should convert GameRoom with ready status to JSON', () {
      final room = GameRoom(
        name: 'Test Room',
        hostId: 'user1',
        players: [
          const Player(id: 'user1', name: 'Player 1', isReady: true),
          const Player(id: 'user2', name: 'Player 2', isReady: false),
        ],
        scores: {'user1': 0, 'user2': 0},
      );

      final json = room.toJson();

      expect(json['players'], isA<List>());
      final playerList = json['players'] as List;
      // Players are serialized as Player objects by freezed
      // Access them through toJson or check the original Player properties
      expect(room.players[0].isReady, true);
      expect(room.players[1].isReady, false);
    });

    test('allPlayersReady should return true when all players are ready', () {
      final room = GameRoom(
        name: 'Test Room',
        hostId: 'user1',
        players: [
          const Player(id: 'user1', name: 'Player 1', isReady: true),
          const Player(id: 'user2', name: 'Player 2', isReady: true),
        ],
        scores: {'user1': 0, 'user2': 0},
      );

      expect(room.allPlayersReady, true);
    });

    test('allPlayersReady should return false when some players not ready', () {
      final room = GameRoom(
        name: 'Test Room',
        hostId: 'user1',
        players: [
          const Player(id: 'user1', name: 'Player 1', isReady: true),
          const Player(id: 'user2', name: 'Player 2', isReady: false),
        ],
        scores: {'user1': 0, 'user2': 0},
      );

      expect(room.allPlayersReady, false);
    });

    test('allPlayersReady should return false when room is empty', () {
      final room = GameRoom(
        name: 'Test Room',
        hostId: 'user1',
        players: [],
        scores: {},
      );

      expect(room.allPlayersReady, false);
    });

    test('canStart should return true when minimum players and all ready', () {
      final room = GameRoom(
        name: 'Test Room',
        hostId: 'user1',
        players: [
          const Player(id: 'user1', name: 'Player 1', isReady: true),
          const Player(id: 'user2', name: 'Player 2', isReady: true),
        ],
        scores: {'user1': 0, 'user2': 0},
      );

      expect(room.canStart, true);
    });

    test('canStart should return false when only one player', () {
      final room = GameRoom(
        name: 'Test Room',
        hostId: 'user1',
        players: [
          const Player(id: 'user1', name: 'Player 1', isReady: true),
        ],
        scores: {'user1': 0},
      );

      expect(room.canStart, false);
    });

    test('canStart should return false when not all ready', () {
      final room = GameRoom(
        name: 'Test Room',
        hostId: 'user1',
        players: [
          const Player(id: 'user1', name: 'Player 1', isReady: true),
          const Player(id: 'user2', name: 'Player 2', isReady: false),
        ],
        scores: {'user1': 0, 'user2': 0},
      );

      expect(room.canStart, false);
    });
  });

  group('Player Model Tests', () {
    test('should create Player with default isReady false', () {
      const player = Player(id: 'user1', name: 'Player 1');

      expect(player.isReady, false);
    });

    test('should create Player with explicit isReady true', () {
      const player = Player(id: 'user1', name: 'Player 1', isReady: true);

      expect(player.isReady, true);
    });

    test('should create Player from JSON with isReady', () {
      final json = {
        'id': 'user1',
        'name': 'Player 1',
        'profile': null,
        'isReady': true,
      };

      final player = Player.fromJson(json);

      expect(player.id, 'user1');
      expect(player.name, 'Player 1');
      expect(player.isReady, true);
    });

    test('should handle missing isReady in JSON (defaults to false)', () {
      final json = {
        'id': 'user1',
        'name': 'Player 1',
      };

      final player = Player.fromJson(json);

      expect(player.isReady, false);
    });

    test('should convert Player to JSON with isReady', () {
      const player = Player(id: 'user1', name: 'Player 1', isReady: true);

      final json = player.toJson();

      expect(json['isReady'], true);
    });

    test('should update isReady with copyWith', () {
      const player = Player(id: 'user1', name: 'Player 1', isReady: false);

      final updatedPlayer = player.copyWith(isReady: true);

      expect(updatedPlayer.isReady, true);
      expect(player.isReady, false); // Original unchanged
    });

    test('should create player with profile and ready status', () {
      const profile = UserProfile(
        id: 'user1',
        displayName: 'John Doe',
        avatarUrl: 'https://example.com/avatar.jpg',
      );

      const player = Player(
        id: 'user1',
        name: 'Player 1',
        profile: profile,
        isReady: true,
      );

      expect(player.profile, profile);
      expect(player.isReady, true);
    });
  });
}
