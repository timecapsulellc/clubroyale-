import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';

class SoundService {
  static final AudioPlayer _player = AudioPlayer();
  static bool _muted = false;

  static void toggleMute() {
    _muted = !_muted;
  }

  static Future<void> playCardSlide() async {
    if (_muted) return;
    try {
      // await _player.play(AssetSource('sounds/card_slide.mp3'));
      debugPrint('Playing sound: card_slide');
    } catch (e) {
      debugPrint('Error playing sound: $e');
    }
  }

  static Future<void> playTrickWon() async {
    if (_muted) return;
    try {
      // await _player.play(AssetSource('sounds/ding.mp3'));
      debugPrint('Playing sound: trick_won');
    } catch (e) {
      debugPrint('Error playing sound: $e');
    }
  }

  static Future<void> playRoundEnd() async {
    if (_muted) return;
    try {
      // await _player.play(AssetSource('sounds/tada.mp3'));
      debugPrint('Playing sound: round_end');
    } catch (e) {
      debugPrint('Error playing sound: $e');
    }
  }
}
