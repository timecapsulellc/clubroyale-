
import 'package:flutter_test/flutter_test.dart';
import 'package:myapp/features/game/game_room.dart';

void main() {
  group('GameRoom Model Tests', () {
    test('should create GameRoom from JSON', () {
      final json = {
        'name': 'Test Game',
        'players': [
          {'id': 'player1', 'name': 'Alice'},
          {'id': 'player2', 'name': 'Bob'},
        ],
        'scores': {'player1': 10, 'player2': 5},
        'isFinished': false,
        'createdAt': '2024-01-01T00:00:00.000Z',
      };

      final gameRoom = GameRoom.fromJson(json);

      expect(gameRoom.name, 'Test Game');
      expect(gameRoom.players.length, 2);
      expect(gameRoom.players[0].name, 'Alice');
      expect(gameRoom.players[1].name, 'Bob');
      expect(gameRoom.scores['player1'], 10);
      expect(gameRoom.scores['player2'], 5);
      expect(gameRoom.isFinished, false);
    });

    test('should convert GameRoom to JSON', () {
      final gameRoom = GameRoom(
        id: 'game1',
        name: 'Test Game',
        players: [
          const Player(id: 'player1', name: 'Alice'),
          const Player(id: 'player2', name: 'Bob'),
        ],
        scores: {'player1': 10, 'player2': 5},
        isFinished: false,
        createdAt: DateTime(2024, 1, 1),
      );

      final json = gameRoom.toJson();

      expect(json['name'], 'Test Game');
      expect(json['players'].length, 2);
      expect(json['scores']['player1'], 10);
      expect(json['isFinished'], false);
    });

    test('should create copy with modified fields', () {
      final original = GameRoom(
        name: 'Original',
        players: [const Player(id: 'p1', name: 'Player 1')],
        scores: {'p1': 0},
        createdAt: DateTime.now(),
      );

      final modified = original.copyWith(
        id: 'new-id',
        name: 'Modified',
        scores: {'p1': 100},
      );

      expect(modified.id, 'new-id');
      expect(modified.name, 'Modified');
      expect(modified.scores['p1'], 100);
      // Original should be unchanged
      expect(original.name, 'Original');
      expect(original.scores['p1'], 0);
    });

    test('isFinished should default to false', () {
      final gameRoom = GameRoom(
        name: 'Test',
        players: [],
        scores: {},
        createdAt: DateTime.now(),
      );

      expect(gameRoom.isFinished, false);
    });
  });

  group('Player Model Tests', () {
    test('should create Player from JSON', () {
      final json = {
        'id': 'player1',
        'name': 'Alice',
      };

      final player = Player.fromJson(json);

      expect(player.id, 'player1');
      expect(player.name, 'Alice');
      expect(player.profile, null);
    });

    test('should create Player with profile', () {
      final json = {
        'id': 'player1',
        'name': 'Alice',
        'profile': {
          'id': 'player1',
          'displayName': 'Alice Smith',
          'avatarUrl': 'https://example.com/avatar.jpg',
        },
      };

      final player = Player.fromJson(json);

      expect(player.id, 'player1');
      expect(player.name, 'Alice');
      expect(player.profile?.displayName, 'Alice Smith');
      expect(player.profile?.avatarUrl, 'https://example.com/avatar.jpg');
    });

    test('should convert Player to JSON', () {
      const player = Player(id: 'player1', name: 'Alice');
      final json = player.toJson();

      expect(json['id'], 'player1');
      expect(json['name'], 'Alice');
    });

    test('should create copy with profile', () {
      const original = Player(id: 'p1', name: 'Player');

      // Note: This test assumes copyWith exists on Player
      // If using Freezed, this should work
      final withId = original.copyWith(name: 'New Name');

      expect(withId.id, 'p1');
      expect(withId.name, 'New Name');
    });
  });
}
