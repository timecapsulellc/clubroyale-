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
        description:
            'This quick tutorial will teach you the basics of the Nepali variant. You can always access the full guide from the ⚙️ settings button.',
      ),
      TutorialStep(
        title: '🎴 Your Hand',
        description:
            'You are dealt 21 cards. Your goal is to arrange them into valid Sets and Sequences.',
      ),
      TutorialStep(
        title: '🎰 The MAAL (Bonus Points)',
        description:
            'Collect Maal cards for huge points:\n• Tiplu: The main Maal card\n• Poplu: One rank above Tiplu\n• Jhiplu: One rank below Tiplu\n• Alter: Same rank/color as Tiplu',
      ),
      TutorialStep(
        title: '🔓 Visiting',
        description:
            'To see Maal and score points, you must "Visit" (unlock) by showing:\n• 3 Pure Sequences\n• OR 7 Dublees (Pairs)\n• OR 3 Tunnels',
      ),
      TutorialStep(
        title: '📥 Gameplay',
        description:
            '1. Draw a card (Deck or Discard)\n2. Arrange your hand\n3. Discard one card\n4. Visit as soon as you can!',
      ),
      TutorialStep(
        title: '🏆 Winning',
        description:
            'Arrange ALL 21 cards into valid melds to declare victory. Unvisited players pay a penalty!\n\nGood luck!',
      ),
    ];
  }
}

/// Widget to show tutorial overlay with Marriage-specific steps
class MarriageTutorial extends StatelessWidget {
  final VoidCallback onComplete;
  final VoidCallback? onSkip;

  const MarriageTutorial({super.key, required this.onComplete, this.onSkip});

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
