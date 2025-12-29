import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

/// Centralized Audio Service for SFX and Background Music
/// ref: Final Pre-Release Audit - Item 3
class SoundService {
  // Separate players for SFX and Music to allow independent control
  static final AudioPlayer _sfxPlayer = AudioPlayer();
  static final AudioPlayer _bgmPlayer = AudioPlayer();
  
  static bool _soundEnabled = true;
  static bool _musicEnabled = true;

  // Initialize service settings (could be loaded from SharedPreferences)
  static Future<void> init() async {
    // AudioContext is not supported on Web and causes build failures if accessed
    if (kIsWeb) return;

    // Set default audio context if needed
    await AudioPlayer.global.setAudioContext(AudioContext(
      android: AudioContextAndroid(
        isSpeakerphoneOn: true,
        stayAwake: true,
        contentType: AndroidContentType.sonification,
        usageType: AndroidUsageType.game,
        audioFocus: AndroidAudioFocus.gain,
      ),
      iOS: AudioContextIOS(
        category: AVAudioSessionCategory.ambient,
        options: {AVAudioSessionOptions.mixWithOthers},
      ),
    ));
  }

  static void toggleSound() {
    _soundEnabled = !_soundEnabled;
    debugPrint('Sound FX: $_soundEnabled');
  }
  
  static void toggleMusic() {
    _musicEnabled = !_musicEnabled;
    debugPrint('Music: $_musicEnabled');
    if (_musicEnabled) {
      playLobbyMusic();
    } else {
      stopMusic();
    }
  }
  
  static bool get isSoundEnabled => _soundEnabled;
  static bool get isMusicEnabled => _musicEnabled;

  static void setSoundMuted(bool muted) {
    _soundEnabled = !muted;
  }

  static void setMusicMuted(bool muted) {
    _musicEnabled = !muted;
    if (_musicEnabled) {
      playLobbyMusic();
    } else {
      stopMusic();
    }
  }

  static void setMuted(bool muted) {
    setSoundMuted(muted);
    setMusicMuted(muted);
  }

  // --- Music Control ---

  static Future<void> playLobbyMusic() async {
    if (!_musicEnabled) {
      await _bgmPlayer.stop();
      return;
    }
    
    try {
      if (_bgmPlayer.state == PlayerState.playing) return;
      
      await _bgmPlayer.setReleaseMode(ReleaseMode.loop);
      // Use existing available sound as placeholder if specific bgm missing
      // Assuming 'bgm_lobby.mp3' might not exist, using a safe fallback or check
      // Ideally we would add 'assets/sounds/bgm_lobby.mp3'
      // For now, we wrap in try-catch to avoid crash if asset missing
      await _bgmPlayer.play(AssetSource('sounds/bgm_lobby.mp3'), volume: 0.3);
    } catch (e) {
      debugPrint('Error playing music (assets/sounds/bgm_lobby.mp3 might be missing): $e');
    }
  }

  static Future<void> stopMusic() async {
    try {
      await _bgmPlayer.stop();
    } catch (e) {
      debugPrint('Error stopping music: $e');
    }
  }

  // --- SFX Control ---

  static Future<void> _playSound(String assetPath, {double volume = 1.0}) async {
    if (!_soundEnabled) return;
    try {
      // For overlapping SFX, we might need OneShot player, but AudioPlayer supports it reasonably well now
      // or we creates new instance for overlapping sounds. 
      // For simple UI, one global SFX player often cuts off previous. 
      // Let's use simple play for now.
      await _sfxPlayer.play(AssetSource(assetPath), volume: volume);
    } catch (e) {
      debugPrint('Error playing sound ($assetPath): $e');
    }
  }

  static Future<void> playCardSlide() async {
    HapticFeedback.lightImpact();
    await _playSound('sounds/card_slide.mp3');
  }

  static Future<void> playTrickWon() async {
    HapticFeedback.mediumImpact();
    await _playSound('sounds/ding.mp3');
  }

  static Future<void> playRoundEnd() async {
    HapticFeedback.heavyImpact();
    await _playSound('sounds/tada.mp3');
  }

  // Alias for chip sound
  static Future<void> playChipSound() async {
    HapticFeedback.selectionClick();
    // Using subfolder path if exists, otherwise fallback
    try {
       await _sfxPlayer.play(AssetSource('sounds/chips/chip_place.ogg'), volume: 0.8);
    } catch (_) {
       await _playSound('sounds/card_slide.mp3', volume: 0.5);
    }
  }

  // Alias for shuffle sound
  static Future<void> playShuffleSound() async {
    HapticFeedback.mediumImpact();
    try {
       await _sfxPlayer.play(AssetSource('sounds/cards/card_shuffle.ogg'));
    } catch (_) {
       await playCardSlide();
    }
  }
  
  // Betting sounds
  static Future<void> playBetSound() async {
    HapticFeedback.selectionClick();
    await playChipSound();
  }
  
  static Future<void> playFoldSound() async {
    HapticFeedback.lightImpact();
    await playCardSlide();
  }
  
  static Future<void> playWinSound() async {
    HapticFeedback.heavyImpact();
    await playRoundEnd();
  }
  
  static Future<void> playLoseSound() async {
    HapticFeedback.mediumImpact();
    try {
       await _sfxPlayer.play(AssetSource('sounds/game/lose.ogg'));
    } catch (_) {
       await _playSound('sounds/ding.mp3', volume: 0.6);
    }
  }
  
  // In-Between specific: post sound (hit boundary)
  static Future<void> playPostSound() async {
    HapticFeedback.heavyImpact();
    try {
       await _sfxPlayer.play(AssetSource('sounds/game/error.ogg'));
    } catch (_) {
       await _playSound('sounds/ding.mp3');
    }
  }
  
  static Future<void> playMaalDeclare() async {
     HapticFeedback.mediumImpact();
     try {
       await _sfxPlayer.play(AssetSource('sounds/ui/success.ogg'));
     } catch (_) {
       await playRoundEnd();
     }
  }
}


