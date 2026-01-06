/// Marriage Game Sound Integration
///
/// Centralized sound triggers for all Marriage game events
/// Uses SoundService for actual playback
library;

import 'package:clubroyale/core/services/sound_service.dart';
import 'package:flutter/services.dart';

/// Sound effects wrapper specifically for Marriage game
class MarriageSoundEffects {
  /// Card Actions
  static Future<void> onCardDraw() async {
    HapticFeedback.selectionClick();
    await SoundService.playCardPickup();
  }
  
  static Future<void> onCardDiscard() async {
    HapticFeedback.lightImpact();
    await SoundService.playCardPlace();
  }
  
  static Future<void> onCardSelect() async {
    HapticFeedback.selectionClick();
    await SoundService.playCardSlide();
  }
  
  static Future<void> onCardDeselect() async {
    HapticFeedback.lightImpact();
  }
  
  /// Meld Formation
  static Future<void> onMeldFormed() async {
    HapticFeedback.mediumImpact();
    await SoundService.playTrickWon();
  }
  
  static Future<void> onMarriageFormed() async {
    HapticFeedback.heavyImpact();
    await SoundService.playMaalDeclare();
  }
  
  /// Game Progress
  static Future<void> onVisit() async {
    HapticFeedback.heavyImpact();
    await SoundService.playVisit();
  }
  
  static Future<void> onDeclare() async {
    HapticFeedback.heavyImpact();
    await SoundService.playWinSound();
  }
  
  static Future<void> onYourTurn() async {
    HapticFeedback.mediumImpact();
    await SoundService.playYourTurn();
  }
  
  static Future<void> onTurnEnd() async {
    HapticFeedback.lightImpact();
  }
  
  /// Game Events
  static Future<void> onGameStart() async {
    HapticFeedback.heavyImpact();
    await SoundService.playShuffleSound();
  }
  
  static Future<void> onDealCards() async {
    await SoundService.playCardDeal();
  }
  
  static Future<void> onRoundEnd() async {
    HapticFeedback.heavyImpact();
    await SoundService.playRoundEnd();
  }
  
  static Future<void> onGameWin() async {
    HapticFeedback.heavyImpact();
    await SoundService.playWinSound();
  }
  
  static Future<void> onGameLose() async {
    HapticFeedback.mediumImpact();
    await SoundService.playLoseSound();
  }
  
  /// Timer Warnings
  static Future<void> onTimerWarning() async {
    HapticFeedback.heavyImpact();
    // Play timer warning sound
    try {
      await SoundService.playYourTurn();
    } catch (_) {}
  }
  
  /// Joker Events
  static Future<void> onTipluRevealed() async {
    HapticFeedback.heavyImpact();
    await SoundService.playCardFlip();
  }
  
  static Future<void> onMaalCardPicked() async {
    HapticFeedback.mediumImpact();
    await SoundService.playMaalDeclare();
  }
  
  /// UI Feedback
  static Future<void> onButtonTap() async {
    HapticFeedback.selectionClick();
  }
  
  static Future<void> onError() async {
    HapticFeedback.heavyImpact();
    await SoundService.playPostSound();
  }
  
  static Future<void> onSuccess() async {
    HapticFeedback.mediumImpact();
    await SoundService.playMaalDeclare();
  }
}
