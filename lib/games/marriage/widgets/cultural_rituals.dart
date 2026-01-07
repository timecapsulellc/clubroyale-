import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// PhD Audit Finding #7: Cultural Rituals Integration
/// Traditional Nepali card game social practices

/// Pre-game ritual: Lucky deck cut
class LuckyDeckCutRitual extends StatefulWidget {
  final VoidCallback onComplete;
  final String playerName;
  
  const LuckyDeckCutRitual({
    super.key,
    required this.onComplete,
    required this.playerName,
  });
  
  @override
  State<LuckyDeckCutRitual> createState() => _LuckyDeckCutRitualState();
}

class _LuckyDeckCutRitualState extends State<LuckyDeckCutRitual>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  double _cutPosition = 0.5;
  bool _hasCut = false;
  String? _luckyMessage;
  
  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
  }
  
  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
  
  void _performCut() {
    HapticFeedback.mediumImpact();
    
    setState(() {
      _hasCut = true;
      // Generate luck message based on cut position
      if (_cutPosition < 0.3) {
        _luckyMessage = '🍀 Lucky cut! Good cards coming your way!';
      } else if (_cutPosition > 0.7) {
        _luckyMessage = '✨ Auspicious cut! Marriage might be near!';
      } else {
        _luckyMessage = '🎴 Balanced cut! Play wisely!';
      }
    });
    
    _controller.forward().then((_) {
      Future.delayed(const Duration(seconds: 2), widget.onComplete);
    });
  }
  
  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black87,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              '🎴 Lucky Cut',
              style: TextStyle(
                color: Colors.amber,
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'काटा (Kata) - ${widget.playerName}\'s turn',
              style: const TextStyle(color: Colors.white70, fontSize: 16),
            ),
            const SizedBox(height: 32),
            
            // Deck visualization
            SizedBox(
              height: 200,
              width: 300,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // Bottom deck
                  Positioned(
                    bottom: 0,
                    child: Container(
                      width: 120,
                      height: 170,
                      decoration: BoxDecoration(
                        color: const Color(0xFF2D1B4E),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.amber.withValues(alpha: 0.5)),
                      ),
                      child: const Center(
                        child: Text('🃏', style: TextStyle(fontSize: 40)),
                      ),
                    ),
                  ),
                  
                  // Cut indicator
                  if (!_hasCut)
                    Positioned(
                      left: 0,
                      right: 0,
                      top: 80,
                      child: GestureDetector(
                        onVerticalDragUpdate: (details) {
                          setState(() {
                            _cutPosition = (details.localPosition.dy / 100)
                                .clamp(0.0, 1.0);
                          });
                        },
                        onVerticalDragEnd: (_) => _performCut(),
                        child: Container(
                          height: 4,
                          margin: EdgeInsets.only(top: _cutPosition * 100),
                          color: Colors.amber,
                          child: const Center(
                            child: Text(
                              '↕️ Drag to cut',
                              style: TextStyle(color: Colors.white, fontSize: 12),
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
            
            const SizedBox(height: 24),
            
            if (_hasCut && _luckyMessage != null)
              AnimatedOpacity(
                opacity: _hasCut ? 1.0 : 0.0,
                duration: const Duration(milliseconds: 300),
                child: Text(
                  _luckyMessage!,
                  style: const TextStyle(
                    color: Colors.green,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              )
            else
              const Text(
                'Drag to cut the deck for luck!',
                style: TextStyle(color: Colors.white54),
              ),
          ],
        ),
      ),
    );
  }
}

/// Quick chat phrases for cultural etiquette
class CulturalChatPhrases {
  static const List<ChatPhrase> phrases = [
    ChatPhrase(
      nepali: 'माफ गर्नुहोस्',
      english: 'Sorry (slow connection)',
      emoji: '🙏',
    ),
    ChatPhrase(
      nepali: 'राम्रो खेल!',
      english: 'Good game!',
      emoji: '👏',
    ),
    ChatPhrase(
      nepali: 'चाँडो गर्नुहोस्',
      english: 'Please hurry',
      emoji: '⏰',
    ),
    ChatPhrase(
      nepali: 'चै पिउँदै छु',
      english: 'Taking chai break',
      emoji: '☕',
    ),
    ChatPhrase(
      nepali: 'शुभकामना!',
      english: 'Good luck!',
      emoji: '🍀',
    ),
    ChatPhrase(
      nepali: 'अर्को राउन्ड?',
      english: 'Another round?',
      emoji: '🔄',
    ),
    ChatPhrase(
      nepali: 'म्यारिज भयो!',
      english: 'Got Marriage!',
      emoji: '💍',
    ),
    ChatPhrase(
      nepali: 'मज्जा आयो!',
      english: 'That was fun!',
      emoji: '🎉',
    ),
  ];
}

class ChatPhrase {
  final String nepali;
  final String english;
  final String emoji;
  
  const ChatPhrase({
    required this.nepali,
    required this.english,
    required this.emoji,
  });
}

/// Quick chat widget
class QuickChatWidget extends StatelessWidget {
  final Function(String message, String nepali) onSend;
  
  const QuickChatWidget({super.key, required this.onSend});
  
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.black54,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        children: CulturalChatPhrases.phrases.map((phrase) {
          return GestureDetector(
            onTap: () {
              HapticFeedback.lightImpact();
              onSend(phrase.english, phrase.nepali);
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.white24),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(phrase.emoji, style: const TextStyle(fontSize: 16)),
                  const SizedBox(width: 4),
                  Text(
                    phrase.english,
                    style: const TextStyle(color: Colors.white, fontSize: 12),
                  ),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

/// Pause/Resume for long games (chai break)
class GamePauseOverlay extends StatelessWidget {
  final String pausedBy;
  final Duration pauseTimeRemaining;
  final VoidCallback onResume;
  
  const GamePauseOverlay({
    super.key,
    required this.pausedBy,
    required this.pauseTimeRemaining,
    required this.onResume,
  });
  
  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black87,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              '☕ Chai Break',
              style: TextStyle(
                color: Colors.amber,
                fontSize: 32,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              '$pausedBy is taking a break',
              style: const TextStyle(color: Colors.white70, fontSize: 18),
            ),
            const SizedBox(height: 24),
            Text(
              'Resuming in ${pauseTimeRemaining.inMinutes}:${(pauseTimeRemaining.inSeconds % 60).toString().padLeft(2, '0')}',
              style: const TextStyle(color: Colors.white, fontSize: 24),
            ),
            const SizedBox(height: 32),
            FilledButton.icon(
              onPressed: onResume,
              icon: const Icon(Icons.play_arrow),
              label: const Text('Resume Early'),
              style: FilledButton.styleFrom(
                backgroundColor: Colors.green,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
