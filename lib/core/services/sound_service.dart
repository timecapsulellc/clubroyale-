import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

class SoundService {
  static final AudioPlayer _player = AudioPlayer();
  static bool _muted = false;

  static void toggleMute() {
    _muted = !_muted;
  }
  
  static void setMuted(bool muted) {
    _muted = muted;
  }
  
  static bool get isMuted => _muted;

  static Future<void> playCardSlide() async {
    // Haptics should play even if audio is muted (optional design choice, usually better)
    HapticFeedback.lightImpact();
    
    if (_muted) return;
    try {
      await _player.play(AssetSource('sounds/card_slide.mp3'));
      debugPrint('Playing sound: card_slide');
    } catch (e) {
      debugPrint('Error playing sound: $e');
    }
  }

  static Future<void> playTrickWon() async {
    HapticFeedback.mediumImpact();
    
    if (_muted) return;
    try {
      await _player.play(AssetSource('sounds/ding.mp3'));
      debugPrint('Playing sound: trick_won');
    } catch (e) {
      debugPrint('Error playing sound: $e');
    }
  }

  static Future<void> playRoundEnd() async {
    HapticFeedback.heavyImpact();
    
    if (_muted) return;
    try {
      await _player.play(AssetSource('sounds/tada.mp3'));
      debugPrint('Playing sound: round_end');
    } catch (e) {
      debugPrint('Error playing sound: $e');
    }
  }

  // Alias for chip sound
  static Future<void> playChipSound() async {
    HapticFeedback.selectionClick(); // Different feeling for chips
    if (_muted) return;
    try {
      await _player.play(AssetSource('sounds/card_slide.mp3')); // Using placeholder
    } catch (e) { debugPrint('Error playing sound: $e'); }
  }

  // Alias for shuffle sound
  static Future<void> playShuffleSound() async {
    HapticFeedback.mediumImpact();
    await playCardSlide();
  }
  
  // Betting sounds
  static Future<void> playBetSound() async {
    HapticFeedback.selectionClick();
    if (_muted) return;
    try {
      await _player.play(AssetSource('sounds/card_slide.mp3')); // Placeholder
      debugPrint('Playing sound: bet');
    } catch (e) { debugPrint('Error playing sound: $e'); }
  }
  
  static Future<void> playFoldSound() async {
    HapticFeedback.lightImpact();
    if (_muted) return;
    try {
      await _player.play(AssetSource('sounds/card_slide.mp3')); // Placeholder
      debugPrint('Playing sound: fold');
    } catch (e) { debugPrint('Error playing sound: $e'); }
  }
  
  static Future<void> playWinSound() async {
    HapticFeedback.heavyImpact();
    if (_muted) return;
    try {
      await _player.play(AssetSource('sounds/tada.mp3'));
      debugPrint('Playing sound: win');
    } catch (e) { debugPrint('Error playing sound: $e'); }
  }
  
  static Future<void> playLoseSound() async {
    HapticFeedback.mediumImpact();
    if (_muted) return;
    try {
      await _player.play(AssetSource('sounds/ding.mp3')); // Placeholder
      debugPrint('Playing sound: lose');
    } catch (e) { debugPrint('Error playing sound: $e'); }
  }
  
  // In-Between specific: post sound (hit boundary)
  static Future<void> playPostSound() async {
    HapticFeedback.heavyImpact();
    if (_muted) return;
    try {
      await _player.play(AssetSource('sounds/ding.mp3')); // Dramatic loss
      debugPrint('Playing sound: post');
    } catch (e) { debugPrint('Error playing sound: $e'); }
  }
}

