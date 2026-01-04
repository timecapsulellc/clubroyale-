import 'package:flutter/material.dart';
import 'package:clubroyale/core/widgets/interactive_tutorial.dart';

/// Marriage Game Interactive Tutorial (Guided Gameplay)
/// Step-by-step walkthrough with hand gestures showing exactly what to do
class MarriageGuidedTutorial {
  /// Create tutorial steps for first gameplay
  static List<InteractiveTutorialStep> getGameplaySteps({
    GlobalKey? deckKey,
    GlobalKey? discardKey,
    GlobalKey? handKey,
    GlobalKey? visitButtonKey,
    GlobalKey? tipluIndicatorKey,
  }) {
    return [
      // Step 1: Welcome
      InteractiveTutorialStep(
        title: '🎮 Let\'s Play Marriage!',
        instruction:
            'Welcome! This guided tutorial will walk you through your first game.\n\n'
            'I\'ll show you exactly what to do with hand gestures. '
            'Follow along and you\'ll be a pro in no time!',
        gestureType: TutorialGestureType.tap,
      ),

      // Step 2: Your Hand
      InteractiveTutorialStep(
        title: '🎴 Your Cards',
        instruction:
            'These are YOUR 21 cards at the bottom.\n\n'
            '👆 You can TAP a card to select it.\n'
            '👉 SWIPE left/right to scroll through your cards.\n'
            '📌 LONG PRESS to see card details.',
        targetKey: handKey,
        gestureType: TutorialGestureType.swipeRight,
        handOffset: const Offset(0, 20),
      ),

      // Step 3: The Tiplu (Wild Card)
      InteractiveTutorialStep(
        title: '✨ The Tiplu (Wild Card)',
        instruction:
            'This glowing card is the TIPLU - the main wild card!\n\n'
            '🔴 Tiplu = 3 points\n'
            '🟡 Cards one rank ABOVE = Poplu (2 pts)\n'
            '🟢 Cards one rank BELOW = Jhiplu (2 pts)\n\n'
            'These work as WILDCARDS in your melds!',
        targetKey: tipluIndicatorKey,
        gestureType: TutorialGestureType.tap,
      ),

      // Step 4: Draw from Deck
      InteractiveTutorialStep(
        title: '📥 Step 1: DRAW',
        instruction:
            'Your turn starts by DRAWING a card.\n\n'
            '👆 TAP the deck to draw from it.\n\n'
            'You can also draw from the discard pile (if allowed), '
            'but the deck is always safe!',
        targetKey: deckKey,
        gestureType: TutorialGestureType.tap,
        waitForAction: true, // Wait for actual draw
      ),

      // Step 5: Review Your Hand
      InteractiveTutorialStep(
        title: '👀 Review Your Cards',
        instruction:
            'Great! You drew a new card.\n\n'
            'Now look at your hand and think:\n'
            '• Can you form sequences? (A-2-3 or 5-6-7)\n'
            '• Do you have sets? (three 8s)\n'
            '• Which card is least useful?\n\n'
            'TAP to select a card to discard.',
        targetKey: handKey,
        gestureType: TutorialGestureType.tap,
        handOffset: const Offset(0, 20),
      ),

      // Step 6: Select a Card
      InteractiveTutorialStep(
        title: '👆 Select a Card',
        instruction:
            'TAP on a card you want to DISCARD.\n\n'
            '💡 Tip: Discard cards that don\'t fit in any sequence or set!\n\n'
            'The selected card will be highlighted.',
        targetKey: handKey,
        gestureType: TutorialGestureType.tap,
        waitForAction: true,
      ),

      // Step 7: Discard
      InteractiveTutorialStep(
        title: '🗑️ Step 2: DISCARD',
        instruction:
            'Now TAP the discard pile to throw away your selected card.\n\n'
            '⚠️ Strategy tip:\n'
            'If you discard a JOKER or wild card, '
            'the next player can\'t pick from discard!',
        targetKey: discardKey,
        gestureType: TutorialGestureType.tap,
        waitForAction: true,
      ),

      // Step 8: Visit Button
      InteractiveTutorialStep(
        title: '🔓 The VISIT Button',
        instruction:
            'When you have 3 PURE sequences (no wildcards), '
            'you can VISIT!\n\n'
            'TAP this button to unlock your Maal points.\n\n'
            '⚠️ If you don\'t visit before someone wins, '
            'you lose ALL your Maal points!',
        targetKey: visitButtonKey,
        gestureType: TutorialGestureType.tap,
      ),

      // Step 9: Turn Summary
      InteractiveTutorialStep(
        title: '🔄 Turn Summary',
        instruction:
            'Each turn follows this pattern:\n\n'
            '1️⃣ DRAW - Take a card from deck or discard\n'
            '2️⃣ ARRANGE - Look at your melds\n'
            '3️⃣ DISCARD - Throw one card away\n'
            '4️⃣ VISIT - When you have 3 pure sequences!\n'
            '5️⃣ FINISH - When ALL cards form valid melds!',
        gestureType: TutorialGestureType.tap,
      ),

      // Step 10: Pro Tips
      InteractiveTutorialStep(
        title: '💡 Pro Tips',
        instruction:
            '🎯 VISIT early - don\'t wait too long!\n\n'
            '🃏 Jokers block the discard pile\n\n'
            '💍 Marriage combo (Jhiplu+Tiplu+Poplu) = +10 pts!\n\n'
            '💀 Not visiting = Kidnap penalty!\n\n'
            'You\'re ready to play! Good luck! 🍀',
        gestureType: TutorialGestureType.tap,
      ),
    ];
  }

  /// Create a controller for the tutorial
  static InteractiveTutorialController createController({
    GlobalKey? deckKey,
    GlobalKey? discardKey,
    GlobalKey? handKey,
    GlobalKey? visitButtonKey,
    GlobalKey? tipluIndicatorKey,
  }) {
    return InteractiveTutorialController(
      steps: getGameplaySteps(
        deckKey: deckKey,
        discardKey: discardKey,
        handKey: handKey,
        visitButtonKey: visitButtonKey,
        tipluIndicatorKey: tipluIndicatorKey,
      ),
    );
  }
}
