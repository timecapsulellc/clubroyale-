/// Sound Service
/// 
/// Manages audio playback for game sounds and effects

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Sound service provider
final soundServiceProvider = Provider((ref) => SoundService());

/// Sound types available in the game
enum GameSound {
  cardPlay,
  cardSlide,
  cardFlip,
  yourTurn,
  win,
  lose,
  bidSuccess,
  bidFail,
  buttonTap,
  matchFound,
  diamond,
  notification,
}

/// Settings for sound preferences
class SoundSettings {
  final bool soundEnabled;
  final bool musicEnabled;
  final double soundVolume;
  final double musicVolume;
  
  const SoundSettings({
    this.soundEnabled = true,
    this.musicEnabled = true,
    this.soundVolume = 0.8,
    this.musicVolume = 0.5,
  });
  
  SoundSettings copyWith({
    bool? soundEnabled,
    bool? musicEnabled,
    double? soundVolume,
    double? musicVolume,
  }) {
    return SoundSettings(
      soundEnabled: soundEnabled ?? this.soundEnabled,
      musicEnabled: musicEnabled ?? this.musicEnabled,
      soundVolume: soundVolume ?? this.soundVolume,
      musicVolume: musicVolume ?? this.musicVolume,
    );
  }
}

/// Sound service for game audio
class SoundService {
  SoundSettings _settings = const SoundSettings();
  
  SoundSettings get settings => _settings;
  
  void updateSettings(SoundSettings settings) {
    _settings = settings;
  }
  
  void toggleSound() {
    _settings = _settings.copyWith(soundEnabled: !_settings.soundEnabled);
  }
  
  void toggleMusic() {
    _settings = _settings.copyWith(musicEnabled: !_settings.musicEnabled);
  }
  
  Future<void> play(GameSound sound) async {
    if (!_settings.soundEnabled) return;
    
    final soundFile = _getSoundFile(sound);
    if (soundFile == null) return;
    
    try {
      if (kDebugMode) {
        print('🔊 Playing sound: $sound');
      }
      // TODO: Implement actual audio playback
    } catch (e) {
      if (kDebugMode) {
        print('Sound error: $e');
      }
    }
  }
  
  Future<void> playCardSound({bool isPlay = false, bool isSlide = false}) async {
    if (isPlay) {
      await play(GameSound.cardPlay);
    } else if (isSlide) {
      await play(GameSound.cardSlide);
    }
  }
  
  Future<void> playTurnSound() async {
    await play(GameSound.yourTurn);
  }
  
  Future<void> playResultSound(bool isWin) async {
    await play(isWin ? GameSound.win : GameSound.lose);
  }
  
  String? _getSoundFile(GameSound sound) {
    switch (sound) {
      case GameSound.cardPlay:
      case GameSound.cardFlip:
        return 'card_slide.mp3';
      case GameSound.cardSlide:
        return 'card_slide.mp3';
      case GameSound.yourTurn:
      case GameSound.notification:
        return 'ding.mp3';
      case GameSound.win:
      case GameSound.bidSuccess:
      case GameSound.matchFound:
        return 'tada.mp3';
      case GameSound.lose:
      case GameSound.bidFail:
        return 'ding.mp3';
      case GameSound.buttonTap:
        return 'ding.mp3';
      case GameSound.diamond:
        return 'ding.mp3';
    }
  }
}

/// Simple provider for sound settings
final soundSettingsProvider = Provider<SoundSettings>((ref) {
  final soundService = ref.watch(soundServiceProvider);
  return soundService.settings;
});
