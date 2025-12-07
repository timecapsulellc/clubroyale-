/// Sound Service
/// 
/// Manages audio playback for game sounds and effects

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Sound service provider
final soundServiceProvider = Provider((ref) => SoundService());

/// Sound types available in the game
enum GameSound {
  cardPlay,      // Card being played
  cardSlide,     // Card sliding/dealing
  cardFlip,      // Card flipping over
  yourTurn,      // Player's turn notification
  win,           // Victory sound
  lose,          // Loss sound
  bidSuccess,    // Successful bid
  bidFail,       // Failed bid
  buttonTap,     // UI button tap
  matchFound,    // Matchmaking success
  diamond,       // Diamond transaction
  notification,  // General notification
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
  
  /// Get current settings
  SoundSettings get settings => _settings;
  
  /// Update settings
  void updateSettings(SoundSettings settings) {
    _settings = settings;
  }
  
  /// Toggle sound on/off
  void toggleSound() {
    _settings = _settings.copyWith(soundEnabled: !_settings.soundEnabled);
  }
  
  /// Toggle music on/off
  void toggleMusic() {
    _settings = _settings.copyWith(musicEnabled: !_settings.musicEnabled);
  }
  
  /// Play a game sound
  Future<void> play(GameSound sound) async {
    if (!_settings.soundEnabled) return;
    
    // Map sound to file
    final soundFile = _getSoundFile(sound);
    if (soundFile == null) return;
    
    try {
      // Note: In production, use audioplayers package
      // For now, we'll use a simple approach that works on web and mobile
      if (kDebugMode) {
        print('🔊 Playing sound: $sound');
      }
      
      // TODO: Implement actual audio playback with audioplayers package
      // final player = AudioPlayer();
      // await player.play(AssetSource('sounds/$soundFile'));
      // await player.setVolume(_settings.soundVolume);
    } catch (e) {
      if (kDebugMode) {
        print('Sound error: $e');
      }
    }
  }
  
  /// Play card sound based on action
  Future<void> playCardSound({bool isPlay = false, bool isSlide = false}) async {
    if (isPlay) {
      await play(GameSound.cardPlay);
    } else if (isSlide) {
      await play(GameSound.cardSlide);
    }
  }
  
  /// Play turn notification
  Future<void> playTurnSound() async {
    await play(GameSound.yourTurn);
  }
  
  /// Play win/lose based on result
  Future<void> playResultSound(bool isWin) async {
    await play(isWin ? GameSound.win : GameSound.lose);
  }
  
  /// Get sound file name
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
        return 'ding.mp3'; // Use ding for now
      case GameSound.buttonTap:
        return 'ding.mp3';
      case GameSound.diamond:
        return 'ding.mp3';
    }
  }
}

/// Sound settings notifier for UI
class SoundSettingsNotifier extends StateNotifier<SoundSettings> {
  final SoundService _soundService;
  
  SoundSettingsNotifier(this._soundService) : super(const SoundSettings());
  
  void toggleSound() {
    _soundService.toggleSound();
    state = _soundService.settings;
  }
  
  void toggleMusic() {
    _soundService.toggleMusic();
    state = _soundService.settings;
  }
  
  void setVolume(double volume) {
    _soundService.updateSettings(
      _soundService.settings.copyWith(soundVolume: volume),
    );
    state = _soundService.settings;
  }
}

/// Provider for sound settings UI
final soundSettingsProvider = StateNotifierProvider<SoundSettingsNotifier, SoundSettings>((ref) {
  final soundService = ref.watch(soundServiceProvider);
  return SoundSettingsNotifier(soundService);
});
