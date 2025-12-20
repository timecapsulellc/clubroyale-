/// Game Audio Mixin - Provides audio capabilities to game widgets
///
/// Usage:
/// ```dart
/// class _MyGameScreenState extends State<MyGameScreen> with GameAudioMixin {
///   void onCardFlip() {
///     playCardFlip();
///   }
/// }
/// ```
library;

import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:clubroyale/core/services/game_audio_service.dart';

/// Mixin that provides audio playback capabilities to StatefulWidgets
mixin GameAudioMixin<T extends StatefulWidget> on State<T> {
  GameAudioService? _audioService;

  /// Initialize audio service from a WidgetRef
  void initAudio(WidgetRef ref) {
    _audioService = ref.read(gameAudioServiceProvider);
  }

  // ========== CARD SOUNDS ==========

  void playCardFlip() => _audioService?.playCardFlip();
  void playCardDeal() => _audioService?.playCardDeal();
  void playCardPlace() => _audioService?.playCardPlace();
  void playCardPickup() => _audioService?.playCardPickup();
  void playCardShuffle() => _audioService?.playCardShuffle();
  void playCardSlide() => _audioService?.playCardSlide();

  // ========== CHIP SOUNDS ==========

  void playChipStack() => _audioService?.playChipStack();
  void playChipPlace() => _audioService?.playChipPlace();
  void playChipsCollect() => _audioService?.playChipsCollect();

  // ========== UI SOUNDS ==========

  void playClick() => _audioService?.playClick();
  void playError() => _audioService?.playError();
  void playSuccess() => _audioService?.playSuccess();
  void playNotification() => _audioService?.playNotification();

  // ========== GAME SOUNDS ==========

  void playYourTurn() => _audioService?.playYourTurn();
  void playWin() => _audioService?.playWin();
  void playLose() => _audioService?.playLose();
  void playTimerWarning() => _audioService?.playTimerWarning();
  void playDing() => _audioService?.playDing();
  void playTada() => _audioService?.playTada();
  void playMarriageDeclare() => _audioService?.playMarriageDeclare();
}

/// Extension on WidgetRef for easy audio access in ConsumerWidgets
extension GameAudioExtension on WidgetRef {
  GameAudioService get audio => read(gameAudioServiceProvider);
}
