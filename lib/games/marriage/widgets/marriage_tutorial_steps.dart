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

  /// Get the tutorial steps (comprehensive Nepali Marriage tutorial)
  static List<TutorialStep> getSteps() {
    return [
      // Step 1: Welcome
      TutorialStep(
        title: '🙏 Welcome to Marriage!',
        description:
            'Marriage is Nepal\'s most popular card game, especially during Dashain! '
            'This tutorial will teach you authentic Nepali rules.\n\n'
            'Tap "Next" to begin.',
      ),

      // Step 2: Card Setup
      TutorialStep(
        title: '🎴 The Setup',
        description:
            '• Uses 3 standard decks (156 cards)\n'
            '• Each player gets 21 cards\n'
            '• One card becomes the "Tiplu" (Wild Card)\n'
            '• Remaining cards form the Draw Pile\n'
            '• Top card starts the Discard Pile',
      ),

      // Step 3: Goal
      TutorialStep(
        title: '🎯 Your Goal',
        description:
            'Arrange ALL 21 cards into valid melds:\n\n'
            '✅ Sequences: 3+ consecutive cards of SAME suit\n'
            '   Example: 5♥ 6♥ 7♥\n\n'
            '✅ Sets (Trials): 3-4 cards of SAME rank, DIFFERENT suits\n'
            '   Example: 8♠ 8♥ 8♦\n\n'
            '✅ Tunnela: 3 IDENTICAL cards (same rank + suit)\n'
            '   Example: K♠ K♠ K♠',
      ),

      // Step 4: Maal System
      TutorialStep(
        title: '💎 The MAAL System',
        description:
            'Maal cards give you BONUS POINTS!\n\n'
            '🔴 Tiplu (3 pts): The chosen wild card\n'
            '🟡 Poplu (2 pts): One rank ABOVE Tiplu (same suit)\n'
            '🟢 Jhiplu (2 pts): One rank BELOW Tiplu (same suit)\n'
            '🔵 Alter (5 pts): Same rank + color as Tiplu\n'
            '🃏 Joker (2 pts): Printed Jokers\n\n'
            'All these cards also work as WILDCARDS!',
      ),

      // Step 5: Visiting
      TutorialStep(
        title: '🔓 Visiting (Veshow)',
        description:
            'You MUST "Visit" to unlock your Maal points!\n\n'
            'Show any of these to Visit:\n'
            '• 3 PURE Sequences (no wildcards)\n'
            '• 7 Dublees (pairs of same rank+suit)\n'
            '• 3 Tunnels (triplets of identical cards)\n\n'
            '⚠️ If you don\'t visit, your Maal = 0!',
      ),

      // Step 6: Turn Flow
      TutorialStep(
        title: '🔄 Your Turn',
        description:
            '1️⃣ DRAW: Take one card from:\n'
            '   • Draw Pile (face down deck)\n'
            '   • Discard Pile (if allowed)\n\n'
            '2️⃣ ARRANGE: Organize your cards\n\n'
            '3️⃣ DISCARD: Drop one card on discard pile\n\n'
            '💡 Tip: Visit as early as possible!',
      ),

      // Step 7: Joker Block Rule
      TutorialStep(
        title: '🚫 Joker Block Rule',
        description:
            'IMPORTANT Nepali rule:\n\n'
            'If a Joker or Wild Card is on top of the discard pile, '
            'the next player CANNOT pick from discard.\n\n'
            'They MUST draw from the deck!\n\n'
            'Use this strategically to block opponents! 🧠',
      ),

      // Step 8: Marriage Combo
      TutorialStep(
        title: '💍 Marriage Combo',
        description:
            'Special 10-point bonus!\n\n'
            'If you hold Jhiplu + Tiplu + Poplu of the SAME SUIT, '
            'you have a "Marriage" combo!\n\n'
            'Example: If Tiplu is 7♠:\n'
            '• Jhiplu: 6♠\n'
            '• Tiplu: 7♠\n'
            '• Poplu: 8♠\n'
            '= Marriage! +10 points 🎉',
      ),

      // Step 9: Kidnap Rule
      TutorialStep(
        title: '💀 Kidnap Rule',
        description:
            'Harsh penalty for not visiting!\n\n'
            'If you haven\'t visited when someone wins:\n'
            '• Your Maal points become 0\n'
            '• You pay 10 points penalty (instead of 3)\n'
            '• Winner may "steal" your Maal!\n\n'
            '⚠️ Always try to visit early!',
      ),

      // Step 10: Winning
      TutorialStep(
        title: '🏆 Winning the Game',
        description:
            'To win, arrange ALL 21 cards into valid melds and "FINISH"!\n\n'
            'You need at least ONE pure sequence (no wilds).\n\n'
            'Scoring:\n'
            '• Winner gets points from each player\n'
            '• Visited loser pays 3 points\n'
            '• Unvisited loser pays 10 points\n'
            '• Maal points are exchanged\n\n'
            'Good luck & have fun! 🎉',
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
