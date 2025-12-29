import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:clubroyale/core/widgets/tutorial_overlay.dart';

/// Marriage Game Tutorial Steps
/// Shows first-time players how to play step by step
class MarriageTutorialSteps {
  static const String _tutorialCompletedKey = 'marriage_tutorial_completed';
  
  /// Check if tutorial has been completed
  static Future<bool> hasCompletedTutorial() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_tutorialCompletedKey) ?? false;
  }
  
  /// Mark tutorial as completed
  static Future<void> completeTutorial() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_tutorialCompletedKey, true);
  }
  
  /// Reset tutorial (for testing)
  static Future<void> resetTutorial() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tutorialCompletedKey);
  }
  
  /// Get the tutorial steps (no GlobalKeys - general modal tutorial)
  static List<TutorialStep> getSteps() {
    return [
      TutorialStep(
        title: '👋 Welcome to Royal Meld!',
        description: 'This quick tutorial will teach you the basics. You can always access the full guide from the ⚙️ settings button.',
      ),
      TutorialStep(
        title: '🎴 Your Hand',
        description: 'Your cards are at the bottom. You have 21 cards to arrange into SETS and SEQUENCES.',
      ),
      TutorialStep(
        title: '📥 Drawing Cards',
        description: 'On your turn, DRAW a card from:\n• DECK (closed pile) - Always available\n• DISCARD (open pile) - Only after visiting',
      ),
      TutorialStep(
        title: '📤 Discarding Cards',
        description: 'After drawing, you MUST discard one card. Tap a card to select it, then tap DISCARD or drag it to the discard pile.',
      ),
      TutorialStep(
        title: '🔓 Visiting',
        description: 'To unlock MAAL (bonus points), you must VISIT by showing:\n• 3 Pure Sequences, OR\n• 7 Pairs (Dublees), OR\n• 3 Tunnels',
      ),
      TutorialStep(
        title: '🏆 Winning',
        description: 'Arrange ALL cards into valid melds, then tap "GO ROYALE" to declare victory!\n\nGood luck!',
      ),
    ];
  }
}

/// Widget to show tutorial overlay with Marriage-specific steps
class MarriageTutorial extends StatelessWidget {
  final VoidCallback onComplete;
  final VoidCallback? onSkip;
  
  const MarriageTutorial({
    super.key,
    required this.onComplete,
    this.onSkip,
  });

  @override
  Widget build(BuildContext context) {
    return TutorialOverlay(
      steps: MarriageTutorialSteps.getSteps(),
      onComplete: () async {
        await MarriageTutorialSteps.completeTutorial();
        onComplete();
      },
      onSkip: () async {
        await MarriageTutorialSteps.completeTutorial();
        onSkip?.call();
      },
    );
  }
}
