import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

/// AI Rivals Section - "Meet Your Rivals"
///
/// Showcase the 5 cognitive bot personalities as character cards:
/// - TrickMaster, CardShark, LuckyDice, DeepThink, RoyalAce
class AIRivalsSection extends StatelessWidget {
  const AIRivalsSection({super.key});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isDesktop = screenWidth > 800;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(
        horizontal: isDesktop ? 48 : 24,
        vertical: 64,
      ),
      decoration: const BoxDecoration(color: Color(0xFF051A12)),
      child: Column(
        children: [
          // Section Title
          _buildSectionTitle().animate().fadeIn(duration: 500.ms),

          const SizedBox(height: 48),

          // Bot Cards
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _BotCard(
                  name: 'TrickMaster',
                  emoji: '🎭',
                  title: 'The Bluffer',
                  difficulty: 'HARD',
                  difficultyColor: Colors.red,
                  traits: ['Aggressive', 'Bluffs often', 'Targets weak'],
                ).animate().fadeIn(delay: 100.ms).slideX(begin: -0.2, end: 0),

                _BotCard(
                  name: 'CardShark',
                  emoji: '🃏',
                  title: 'The Cautious',
                  difficulty: 'MEDIUM',
                  difficultyColor: Colors.orange,
                  traits: [
                    'Conservative',
                    'Safe plays',
                    'Preserves high cards',
                  ],
                ).animate().fadeIn(delay: 200.ms).slideX(begin: -0.2, end: 0),

                _BotCard(
                  name: 'LuckyDice',
                  emoji: '🎲',
                  title: 'The Wildcard',
                  difficulty: 'EASY',
                  difficultyColor: Colors.green,
                  traits: ['Unpredictable', 'Fun mistakes', 'Chaotic plays'],
                ).animate().fadeIn(delay: 300.ms).slideX(begin: -0.2, end: 0),

                _BotCard(
                  name: 'DeepThink',
                  emoji: '🧠',
                  title: 'The Genius',
                  difficulty: 'EXPERT',
                  difficultyColor: Colors.purple,
                  traits: ['Analytical', 'ToT Reasoning', 'Optimal strategy'],
                ).animate().fadeIn(delay: 400.ms).slideX(begin: -0.2, end: 0),

                _BotCard(
                  name: 'RoyalAce',
                  emoji: '💎',
                  title: 'The Royal',
                  difficulty: 'MEDIUM',
                  difficultyColor: Colors.orange,
                  traits: ['Balanced', 'Adaptive', 'Human-like timing'],
                ).animate().fadeIn(delay: 500.ms).slideX(begin: -0.2, end: 0),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle() {
    return Column(
      children: [
        const Text(
          'MEET YOUR RIVALS',
          style: TextStyle(
            fontFamily: 'Oswald',
            fontSize: 32,
            fontWeight: FontWeight.bold,
            color: Color(0xFFD4AF37),
            letterSpacing: 4,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          width: 60,
          height: 3,
          decoration: BoxDecoration(
            color: const Color(0xFFD4AF37),
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(height: 16),
        Text(
          '5 unique AI personalities • Available 24/7 • No waiting',
          style: TextStyle(
            fontSize: 14,
            color: Colors.white.withValues(alpha: 0.7),
          ),
        ),
      ],
    );
  }
}

/// Individual Bot Character Card
class _BotCard extends StatefulWidget {
  final String name;
  final String emoji;
  final String title;
  final String difficulty;
  final Color difficultyColor;
  final List<String> traits;

  const _BotCard({
    required this.name,
    required this.emoji,
    required this.title,
    required this.difficulty,
    required this.difficultyColor,
    required this.traits,
  });

  @override
  State<_BotCard> createState() => _BotCardState();
}

class _BotCardState extends State<_BotCard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.symmetric(horizontal: 12),
        width: 200,
        transform: _isHovered
            ? (Matrix4.identity()..scale(1.05))
            : Matrix4.identity(),
        transformAlignment: Alignment.center,
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                const Color(0xFF0A2E1F),
                const Color(0xFF0D5C3D).withValues(alpha: 0.5),
              ],
            ),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: _isHovered
                  ? widget.difficultyColor.withValues(alpha: 0.6)
                  : const Color(0xFFD4AF37).withValues(alpha: 0.2),
              width: _isHovered ? 2 : 1,
            ),
            boxShadow: [
              BoxShadow(
                color: _isHovered
                    ? widget.difficultyColor.withValues(alpha: 0.2)
                    : Colors.black.withValues(alpha: 0.3),
                blurRadius: _isHovered ? 25 : 10,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            children: [
              // Emoji Avatar
              Container(
                width: 70,
                height: 70,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: widget.difficultyColor.withValues(alpha: 0.15),
                  border: Border.all(
                    color: widget.difficultyColor.withValues(alpha: 0.4),
                    width: 2,
                  ),
                ),
                child: Center(
                  child: Text(
                    widget.emoji,
                    style: const TextStyle(fontSize: 36),
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Name
              Text(
                widget.name,
                style: const TextStyle(
                  fontFamily: 'Oswald',
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  letterSpacing: 1,
                ),
              ),

              const SizedBox(height: 4),

              // Title
              Text(
                widget.title,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.white.withValues(alpha: 0.5),
                  fontStyle: FontStyle.italic,
                ),
              ),

              const SizedBox(height: 12),

              // Difficulty Badge
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: widget.difficultyColor.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: widget.difficultyColor.withValues(alpha: 0.5),
                  ),
                ),
                child: Text(
                  widget.difficulty,
                  style: TextStyle(
                    color: widget.difficultyColor,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1,
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Traits
              ...widget.traits.map(
                (trait) => Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.check_circle_outline,
                        size: 12,
                        color: Colors.white.withValues(alpha: 0.4),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        trait,
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.white.withValues(alpha: 0.6),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Challenge Button
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  color: _isHovered
                      ? widget.difficultyColor
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: _isHovered
                        ? widget.difficultyColor
                        : const Color(0xFFD4AF37).withValues(alpha: 0.5),
                  ),
                ),
                child: Center(
                  child: Text(
                    'CHALLENGE',
                    style: TextStyle(
                      color: _isHovered
                          ? Colors.white
                          : const Color(0xFFD4AF37),
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                      letterSpacing: 1,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
