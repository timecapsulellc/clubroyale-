import 'package:audioplayers/audioplayers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:clubroyale/core/services/app_logger.dart';

final soundServiceProvider = Provider((ref) => SoundService());

class SoundService {
  final AudioPlayer _player = AudioPlayer();

  // Preload sounds to reduce latency
  Future<void> init() async {
    await _player.setSource(AssetSource('sounds/card_slide.mp3'));
    await _player.setSource(AssetSource('sounds/ding.mp3'));
    await _player.setSource(AssetSource('sounds/tada.mp3'));
  }

  Future<void> playCardSlide() async {
    try {
      // Create a new player for overlapping sounds if needed, 
      // but for simple card slides, one player might suffice or be reset.
      // For better responsiveness with rapid clicks, we might want a pool,
      // but let's start simple.
      await _player.play(AssetSource('sounds/card_slide.mp3'), mode: PlayerMode.lowLatency);
    } catch (e) {
      // Ignore errors (e.g. if asset not found or audio disabled)
      AppLogger.error('Error playing sound', error: e, tag: 'Sound');
    }
  }

  Future<void> playTrickWin() async {
    try {
      await _player.play(AssetSource('sounds/ding.mp3'));
    } catch (e) {
      AppLogger.error('Error playing sound', error: e, tag: 'Sound');
    }
  }

  Future<void> playGameWin() async {
    try {
      await _player.play(AssetSource('sounds/tada.mp3'));
    } catch (e) {
      AppLogger.error('Error playing sound', error: e, tag: 'Sound');
    }
  }
}
