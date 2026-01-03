/// Interactive Tutorial System for Marriage Game
///
/// Step-by-step guided tutorial for first-time players.
/// Shows overlay instructions with highlighted UI elements.
library;

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Tutorial step definition
class TutorialStep {
  final String id;
  final String title;
  final String description;
  final IconData icon;
  final String? highlightElement; // ID of element to highlight
  final Alignment position; // Where to show the tooltip
  final String? actionTrigger; // What action advances to next step

  const TutorialStep({
    required this.id,
    required this.title,
    required this.description,
    required this.icon,
    this.highlightElement,
    this.position = Alignment.center,
    this.actionTrigger,
  });
}

/// Marriage Game Tutorial Steps
class MarriageTutorial {
  static const String tutorialKey = 'marriage_tutorial_completed';

  /// All tutorial steps for the game
  static const List<TutorialStep> steps = [
    TutorialStep(
      id: 'welcome',
      title: '🎴 Welcome to Marriage!',
      description: 'Marriage (Royal Meld) is a strategic card game where you collect melds to win. '
          'Let\'s learn the basics!',
      icon: Icons.waving_hand,
      position: Alignment.center,
    ),
    TutorialStep(
      id: 'objective',
      title: '🎯 Your Goal',
      description: 'Form all your cards into valid MELDS (groups of 3+ cards). '
          'A meld is either a RUN (same suit, consecutive) or a TUNNEL (same rank, different suits).',
      icon: Icons.flag,
      position: Alignment.center,
    ),
    TutorialStep(
      id: 'your_hand',
      title: '🃏 Your Hand',
      description: 'These are your cards. Arrange them into melds by drawing and discarding.',
      icon: Icons.back_hand,
      highlightElement: 'player_hand',
      position: Alignment.bottomCenter,
    ),
    TutorialStep(
      id: 'deck',
      title: '📚 The Deck',
      description: 'Tap here to draw a new card. You must draw at the start of your turn.',
      icon: Icons.layers,
      highlightElement: 'deck_pile',
      position: Alignment.center,
    ),
    TutorialStep(
      id: 'discard',
      title: '🗑️ Discard Pile',
      description: 'You can also draw the top card here (unless blocked). '
          'After drawing, you must discard one card.',
      icon: Icons.delete_outline,
      highlightElement: 'discard_pile',
      position: Alignment.center,
    ),
    TutorialStep(
      id: 'tiplu',
      title: '⭐ The Tiplu (Wild Card)',
      description: 'The TIPLU is a special wild card that can substitute any card in melds. '
          'Cards of the same rank are also valuable (Jhiplu, Poplu)!',
      icon: Icons.star,
      highlightElement: 'tiplu_indicator',
      position: Alignment.topCenter,
    ),
    TutorialStep(
      id: 'visit',
      title: '✅ Visiting',
      description: 'When you have 3 PURE sequences (no wildcards), you can VISIT. '
          'This unlocks Maal scoring and lets you use wildcards freely!',
      icon: Icons.verified,
      highlightElement: 'visit_button',
      position: Alignment.centerRight,
    ),
    TutorialStep(
      id: 'maal',
      title: '💎 Maal Points',
      description: 'After visiting, collect Maal cards (Tiplu: 4pts, Jhiplu: 3pts, Poplu: 2pts) '
          'for bonus points when you win!',
      icon: Icons.diamond,
      position: Alignment.center,
    ),
    TutorialStep(
      id: 'finish',
      title: '🏆 Finishing',
      description: 'When ALL your cards form valid melds, tap FINISH to declare and win! '
          'But you must have visited first.',
      icon: Icons.emoji_events,
      highlightElement: 'finish_button',
      position: Alignment.centerRight,
    ),
    TutorialStep(
      id: 'hints',
      title: '💡 Need Help?',
      description: 'Tap the lightbulb button anytime for AI suggestions on your next move. '
          'It will highlight recommended cards!',
      icon: Icons.lightbulb,
      highlightElement: 'hint_button',
      position: Alignment.bottomRight,
    ),
    TutorialStep(
      id: 'ready',
      title: '🎮 You\'re Ready!',
      description: 'That\'s it! Draw, discard, build melds, visit, and finish. Good luck!',
      icon: Icons.rocket_launch,
      position: Alignment.center,
    ),
  ];

  /// Check if tutorial has been completed
  static Future<bool> isCompleted() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(tutorialKey) ?? false;
  }

  /// Mark tutorial as completed
  static Future<void> markCompleted() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(tutorialKey, true);
  }

  /// Reset tutorial (for testing or replaying)
  static Future<void> reset() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(tutorialKey);
  }
}

/// Tutorial Overlay Widget
class TutorialOverlay extends StatefulWidget {
  final Widget child;
  final bool showTutorial;
  final VoidCallback onComplete;
  final Map<String, GlobalKey>? elementKeys; // Keys for highlighting elements

  const TutorialOverlay({
    super.key,
    required this.child,
    required this.showTutorial,
    required this.onComplete,
    this.elementKeys,
  });

  @override
  State<TutorialOverlay> createState() => _TutorialOverlayState();
}

class _TutorialOverlayState extends State<TutorialOverlay> {
  int _currentStep = 0;

  void _nextStep() {
    if (_currentStep < MarriageTutorial.steps.length - 1) {
      setState(() => _currentStep++);
    } else {
      _completeTutorial();
    }
  }

  void _previousStep() {
    if (_currentStep > 0) {
      setState(() => _currentStep--);
    }
  }

  void _skipTutorial() {
    _completeTutorial();
  }

  void _completeTutorial() {
    MarriageTutorial.markCompleted();
    widget.onComplete();
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.showTutorial) {
      return widget.child;
    }

    final step = MarriageTutorial.steps[_currentStep];
    final isLastStep = _currentStep == MarriageTutorial.steps.length - 1;
    final isFirstStep = _currentStep == 0;

    return Stack(
      children: [
        // Game screen (dimmed)
        widget.child,

        // Dark overlay
        Positioned.fill(
          child: GestureDetector(
            onTap: _nextStep,
            child: Container(
              color: Colors.black.withValues(alpha: 0.7),
            ),
          ),
        ),

        // Highlight box for specific elements (if applicable)
        if (step.highlightElement != null && 
            widget.elementKeys?[step.highlightElement] != null)
          _buildHighlight(widget.elementKeys![step.highlightElement]!),

        // Tutorial card
        Align(
          alignment: step.position,
          child: _buildTutorialCard(step, isFirstStep, isLastStep),
        ),

        // Progress indicator
        Positioned(
          bottom: 16,
          left: 0,
          right: 0,
          child: _buildProgressIndicator(),
        ),
      ],
    );
  }

  Widget _buildHighlight(GlobalKey key) {
    final context = key.currentContext;
    if (context == null) return const SizedBox.shrink();

    final box = context.findRenderObject() as RenderBox?;
    if (box == null) return const SizedBox.shrink();

    final position = box.localToGlobal(Offset.zero);
    final size = box.size;

    return Positioned(
      left: position.dx - 8,
      top: position.dy - 8,
      child: Container(
        width: size.width + 16,
        height: size.height + 16,
        decoration: BoxDecoration(
          border: Border.all(color: Colors.amber, width: 3),
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.amber.withValues(alpha: 0.5),
              blurRadius: 20,
              spreadRadius: 5,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTutorialCard(TutorialStep step, bool isFirst, bool isLast) {
    return Container(
      margin: const EdgeInsets.all(24),
      padding: const EdgeInsets.all(20),
      constraints: const BoxConstraints(maxWidth: 400),
      decoration: BoxDecoration(
        color: Colors.grey.shade900,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.amber.withValues(alpha: 0.3)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.5),
            blurRadius: 20,
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Icon
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.amber.withValues(alpha: 0.2),
              shape: BoxShape.circle,
            ),
            child: Icon(step.icon, size: 48, color: Colors.amber),
          ),
          const SizedBox(height: 16),

          // Title
          Text(
            step.title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),

          // Description
          Text(
            step.description,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 14,
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),

          // Navigation buttons
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Back / Skip
              TextButton(
                onPressed: isFirst ? _skipTutorial : _previousStep,
                child: Text(
                  isFirst ? 'Skip' : 'Back',
                  style: const TextStyle(color: Colors.white54),
                ),
              ),

              // Step counter
              Text(
                '${_currentStep + 1}/${MarriageTutorial.steps.length}',
                style: const TextStyle(color: Colors.white38),
              ),

              // Next / Finish
              ElevatedButton(
                onPressed: _nextStep,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.amber,
                  foregroundColor: Colors.black,
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                ),
                child: Text(isLast ? 'Start Playing!' : 'Next'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildProgressIndicator() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(
        MarriageTutorial.steps.length,
        (index) => Container(
          width: 8,
          height: 8,
          margin: const EdgeInsets.symmetric(horizontal: 4),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: index == _currentStep
                ? Colors.amber
                : index < _currentStep
                    ? Colors.amber.withValues(alpha: 0.5)
                    : Colors.white24,
          ),
        ),
      ),
    );
  }
}

/// Quick tutorial button to replay tutorial
class TutorialReplayButton extends StatelessWidget {
  final VoidCallback onReplay;

  const TutorialReplayButton({super.key, required this.onReplay});

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.help_outline),
      color: Colors.white70,
      tooltip: 'Replay Tutorial',
      onPressed: () {
        showDialog(
          context: context,
          builder: (ctx) => AlertDialog(
            backgroundColor: Colors.grey.shade900,
            title: const Text('Replay Tutorial?', style: TextStyle(color: Colors.white)),
            content: const Text(
              'Would you like to see the tutorial again?',
              style: TextStyle(color: Colors.white70),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(ctx);
                  MarriageTutorial.reset().then((_) => onReplay());
                },
                style: ElevatedButton.styleFrom(backgroundColor: Colors.amber),
                child: const Text('Yes, Show Tutorial'),
              ),
            ],
          ),
        );
      },
    );
  }
}
