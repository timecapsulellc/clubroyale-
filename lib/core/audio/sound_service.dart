/// Sound Service
/// 
/// Manages audio playback for game sounds and effects
library;

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Sound service provider - using Provider since SoundService is a ChangeNotifier
final soundServiceProvider = ChangeNotifierProvider<SoundService>((ref) => SoundService());

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
class SoundService extends ChangeNotifier {
  SoundSettings _settings = const SoundSettings();
  final AudioPlayer _player = AudioPlayer();
  
  // Cache players for overlapping sounds if needed, 
  // but for simple UI SFX single player with 'lowLatency' might suffice for now.
  // Actually, for overlapping sounds (rapid card play), we might need a pool.
  // AudioPlayers 'lowLatency' mode handles this reasonably well.
  
  SoundService() {
    // Initialize audio player
    try {
        _player.setReleaseMode(ReleaseMode.stop);
    } catch (e) {
        debugPrint('Audio Init Error: $e');
    }
  }

  SoundSettings get settings => _settings;
  
  void updateSettings(SoundSettings settings) {
    _settings = settings;
    notifyListeners();
  }
  
  void toggleSound() {
    _settings = _settings.copyWith(soundEnabled: !_settings.soundEnabled);
    notifyListeners();
  }
  
  void toggleMusic() {
    _settings = _settings.copyWith(musicEnabled: !_settings.musicEnabled);
    notifyListeners();
  }
  
  Future<void> play(GameSound sound) async {
    if (!_settings.soundEnabled) return;
    
    final soundFile = _getSoundFile(sound);
    if (soundFile == null) return;
    
    try {
      // Create a *new* player for SFX to allow overlapping sounds (important for card games)
      // Or use the shared one? Shared one cuts off previous sound.
      // For card games, overlap is better.
      // However, creating too many players is heavy.
      // 'AudioPlayer' is relatively light.
      final player = AudioPlayer();
      await player.setVolume(_settings.soundVolume);
      await player.play(AssetSource('sounds/$soundFile'), mode: PlayerMode.lowLatency);
      // Auto dispose player after completion?
      // AudioPlayers usually handles this if we don't keep reference, but we should be careful.
      // Ideally we use a pool, but for now simple 'fire & forget' with new player is common in Flutter for SFX.
      player.onPlayerComplete.listen((_) => player.dispose());
      
      if (kDebugMode) {
        print('🔊 Playing sound: $soundFile');
      }
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
  
  @override
  void dispose() {
    _player.dispose();
    super.dispose();
  }
}

/// Simple provider for sound settings
final soundSettingsProvider = Provider<SoundSettings>((ref) {
  final soundService = ref.watch(soundServiceProvider);
  return soundService.settings;
});
