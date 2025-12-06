import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:taasclub/features/game/game_room.dart';
import 'package:taasclub/features/game/game_service.dart';

final ledgerServiceProvider = Provider<LedgerService>((ref) {
  return LedgerService(ref.watch(gameServiceProvider));
});

class LedgerService {
  final GameService _gameService;

  LedgerService(this._gameService);

  Future<GameRoom?> getGame(String gameId) {
    return _gameService.getGame(gameId);
  }
}
