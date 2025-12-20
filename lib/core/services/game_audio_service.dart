/// Game Audio Service - Centralized sound management
/// 
/// Features:
/// - Card sounds (shuffle, deal, flip, place)
/// - Chip sounds (stack, place, collect)
/// - UI sounds (click, error, success)
/// - Game feedback (your turn, win, lose)
/// - Volume and enable/disable controls
library;

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Provider for game audio service
final gameAudioServiceProvider = Provider((ref) => GameAudioService());

/// All available game sounds
enum GameSound {
  // Cards
  cardShuffle,
  cardDeal,
  cardFlip,
  cardPlace,
  cardPickup,
  cardSlide,
  
  // Chips
  chipStack,
  chipPlace,
  chipsCollect,
  
  // UI
  click,
  error,
  success,
  notification,
  
  // Game
  yourTurn,
  win,
  lose,
  timerWarning,
  ding,
  tada,
  marriageDeclare, // New sound for declaration
}

/// Centralized game audio management
class GameAudioService {
  final AudioPlayer _sfxPlayer = AudioPlayer();
  final AudioPlayer _musicPlayer = AudioPlayer();
  
  bool _soundEnabled = true;
  bool _musicEnabled = true;
  double _sfxVolume = 1.0;
  double _musicVolume = 0.5;
  
  /// Sound file paths mapped to enum
  /// NOTE: Some paths are placeholders - download from Kenney.nl
  static const Map<GameSound, String> _soundPaths = {
    // Cards - Download from https://kenney.nl/assets/casino-audio
    GameSound.cardShuffle: 'sounds/cards/card_shuffle.ogg',
    GameSound.cardDeal: 'sounds/cards/card_deal.ogg',
    GameSound.cardFlip: 'sounds/cards/card_flip.ogg',
    GameSound.cardPlace: 'sounds/cards/card_place.ogg',
    GameSound.cardPickup: 'sounds/cards/card_pickup.ogg',
    GameSound.cardSlide: 'sounds/card_slide.mp3', // EXISTING ✅
    
    // Chips - Download from https://kenney.nl/assets/casino-audio
    GameSound.chipStack: 'sounds/chips/chip_stack.ogg',
    GameSound.chipPlace: 'sounds/chips/chip_place.ogg',
    GameSound.chipsCollect: 'sounds/chips/chips_collect.ogg',
    
    // UI - Download from https://kenney.nl/assets/ui-audio
    GameSound.click: 'sounds/ui/click.ogg',
    GameSound.error: 'sounds/ui/error.ogg',
    GameSound.success: 'sounds/ui/success.ogg',
    GameSound.notification: 'sounds/ui/notification.ogg',
    
    // Game
    GameSound.yourTurn: 'sounds/game/your_turn.ogg',
    GameSound.win: 'sounds/tada.mp3', // EXISTING ✅
    GameSound.lose: 'sounds/game/lose.ogg',
    GameSound.timerWarning: 'sounds/game/timer_warning.ogg',
    GameSound.ding: 'sounds/ding.mp3', // EXISTING ✅
    GameSound.tada: 'sounds/tada.mp3', // EXISTING ✅
    GameSound.marriageDeclare: 'sounds/tada.mp3', // Reusing tada for now
  };
  
  // ========== PLAYBACK METHODS ==========
  
  /// Play a sound effect
  Future<void> play(GameSound sound) async {
    if (!_soundEnabled) return;
    
    try {
      final path = _soundPaths[sound];
      if (path != null) {
        await _sfxPlayer.setVolume(_sfxVolume);
        await _sfxPlayer.play(AssetSource(path));
      }
    } catch (e) {
      debugPrint('GameAudioService: Error playing $sound - $e');
    }
  }
  
  /// Play multiple sounds in sequence with delay
  Future<void> playSequence(List<GameSound> sounds, {Duration delay = const Duration(milliseconds: 100)}) async {
    for (final sound in sounds) {
      await play(sound);
      await Future.delayed(delay);
    }
  }
  
  // ========== CARD SOUNDS ==========
  
  /// Play card shuffle sound
  Future<void> playCardShuffle() => play(GameSound.cardShuffle);
  
  /// Play card deal sound
  Future<void> playCardDeal() => play(GameSound.cardDeal);
  
  /// Play card flip sound
  Future<void> playCardFlip() => play(GameSound.cardFlip);
  
  /// Play card place sound
  Future<void> playCardPlace() => play(GameSound.cardPlace);
  
  /// Play card pickup sound
  Future<void> playCardPickup() => play(GameSound.cardPickup);
  
  /// Play card slide sound (existing asset)
  Future<void> playCardSlide() => play(GameSound.cardSlide);
  
  // ========== CHIP SOUNDS ==========
  
  /// Play chip stack sound
  Future<void> playChipStack() => play(GameSound.chipStack);
  
  /// Play chip place sound
  Future<void> playChipPlace() => play(GameSound.chipPlace);
  
  /// Play chips collect sound
  Future<void> playChipsCollect() => play(GameSound.chipsCollect);
  
  // ========== UI SOUNDS ==========
  
  /// Play click sound
  Future<void> playClick() => play(GameSound.click);
  
  /// Play error sound
  Future<void> playError() => play(GameSound.error);
  
  /// Play success sound
  Future<void> playSuccess() => play(GameSound.success);
  
  /// Play notification sound
  Future<void> playNotification() => play(GameSound.notification);
  
  // ========== GAME FEEDBACK ==========
  
  /// Play "your turn" indicator
  Future<void> playYourTurn() => play(GameSound.yourTurn);
  
  /// Play win celebration
  Future<void> playWin() => play(GameSound.win);
  
  /// Play lose sound
  Future<void> playLose() => play(GameSound.lose);
  
  /// Play timer warning
  Future<void> playTimerWarning() => play(GameSound.timerWarning);
  
  /// Play ding (existing asset)
  Future<void> playDing() => play(GameSound.ding);
  
  /// Play tada (existing asset)
  Future<void> playTada() => play(GameSound.tada);

  /// Play marriage declare sound
  Future<void> playMarriageDeclare() => play(GameSound.marriageDeclare);
  
  // ========== SETTINGS ==========
  
  /// Enable or disable sound effects
  void setSoundEnabled(bool enabled) {
    _soundEnabled = enabled;
    if (!enabled) {
      _sfxPlayer.stop();
    }
  }
  
  /// Enable or disable background music
  void setMusicEnabled(bool enabled) {
    _musicEnabled = enabled;
    if (!enabled) {
      _musicPlayer.stop();
    }
  }
  
  /// Set sound effects volume (0.0 - 1.0)
  void setSfxVolume(double volume) {
    _sfxVolume = volume.clamp(0.0, 1.0);
  }
  
  /// Set music volume (0.0 - 1.0)
  void setMusicVolume(double volume) {
    _musicVolume = volume.clamp(0.0, 1.0);
  }
  
  /// Get current sound enabled state
  bool get isSoundEnabled => _soundEnabled;
  
  /// Get current music enabled state
  bool get isMusicEnabled => _musicEnabled;
  
  /// Get current SFX volume
  double get sfxVolume => _sfxVolume;
  
  /// Get current music volume
  double get musicVolume => _musicVolume;
  
  // ========== LIFECYCLE ==========
  
  /// Dispose audio players
  void dispose() {
    _sfxPlayer.dispose();
    _musicPlayer.dispose();
  }
}
