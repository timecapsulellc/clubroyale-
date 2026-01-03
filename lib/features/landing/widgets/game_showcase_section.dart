import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// Game Showcase Section - "The Four Pillars"
///
/// Premium glassmorphism cards showcasing each game with:
/// - Live player counts
/// - AI bot indicators
/// - Hover animations
class GameShowcaseSection extends ConsumerWidget {
  const GameShowcaseSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isDesktop = screenWidth > 900;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(
        horizontal: isDesktop ? 48 : 24,
        vertical: 64,
      ),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF1B7A4E), Color(0xFF0D5C3D), Color(0xFF051A12)],
        ),
      ),
      child: Column(
        children: [
          // Section Title
          _buildSectionTitle().animate().fadeIn(duration: 500.ms),

          const SizedBox(height: 48),

          // Game Cards Grid
          LayoutBuilder(
            builder: (context, constraints) {
              final cardWidth = isDesktop
                  ? (constraints.maxWidth - 72) /
                        4 // 4 columns
                  : (constraints.maxWidth - 24) / 2; // 2 columns

              return Wrap(
                spacing: 24,
                runSpacing: 24,
                alignment: WrapAlignment.center,
                children: [
                  _GameCard(
                    game: 'Marriage',
                    subtitle: 'Nepali Variant (Strict)',
                    icon: Icons.favorite,
                    accentColor: const Color(0xFFE91E63),
                    onlinePlayers: 243,
                    route: '/marriage/practice',
                    width: cardWidth,
                  ).animate().fadeIn(delay: 100.ms).slideY(begin: 0.2, end: 0),

                  _GameCard(
                    game: 'Call Break',
                    subtitle: 'Trick Taking',
                    icon: Icons.phone,
                    accentColor: const Color(0xFF2196F3),
                    onlinePlayers: 189,
                    route: '/call-break',
                    width: cardWidth,
                  ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.2, end: 0),

                  _GameCard(
                    game: 'Teen Patti',
                    subtitle: 'Indian Poker',
                    icon: Icons.casino,
                    accentColor: const Color(0xFFFF9800),
                    onlinePlayers: 421,
                    route: '/teen-patti',
                    width: cardWidth,
                  ).animate().fadeIn(delay: 300.ms).slideY(begin: 0.2, end: 0),

                  _GameCard(
                    game: 'In-Between',
                    subtitle: 'High or Low',
                    icon: Icons.swap_vert,
                    accentColor: const Color(0xFF9C27B0),
                    onlinePlayers: 156,
                    route: '/in-between',
                    width: cardWidth,
                  ).animate().fadeIn(delay: 400.ms).slideY(begin: 0.2, end: 0),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle() {
    return Column(
      children: [
        const Text(
          'CHOOSE YOUR GAME',
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
          'Four premium card games • AI opponents ready 24/7',
          style: TextStyle(
            fontSize: 14,
            color: Colors.white.withValues(alpha: 0.7),
          ),
        ),
      ],
    );
  }
}

/// Individual Game Card with Glassmorphism
class _GameCard extends StatefulWidget {
  final String game;
  final String subtitle;
  final IconData icon;
  final Color accentColor;
  final int onlinePlayers;
  final String route;
  final double width;

  const _GameCard({
    required this.game,
    required this.subtitle,
    required this.icon,
    required this.accentColor,
    required this.onlinePlayers,
    required this.route,
    required this.width,
  });

  @override
  State<_GameCard> createState() => _GameCardState();
}

class _GameCardState extends State<_GameCard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTap: () => context.go(widget.route),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          width: widget.width,
          transform: _isHovered
              ? (Matrix4.identity()..translate(0.0, -8.0))
              : Matrix4.identity(),
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              // Glassmorphism effect
              color: const Color(0xFF0A2E1F).withValues(alpha: 0.6),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: _isHovered
                    ? widget.accentColor.withValues(alpha: 0.5)
                    : const Color(0xFFD4AF37).withValues(alpha: 0.2),
                width: _isHovered ? 2 : 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: _isHovered
                      ? widget.accentColor.withValues(alpha: 0.2)
                      : Colors.black.withValues(alpha: 0.3),
                  blurRadius: _isHovered ? 30 : 15,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Icon + Badge Row
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Game Icon
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: widget.accentColor.withValues(alpha: 0.15),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: widget.accentColor.withValues(alpha: 0.3),
                        ),
                      ),
                      child: Icon(
                        widget.icon,
                        color: widget.accentColor,
                        size: 28,
                      ),
                    ),
                    // AI Badge
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.green.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: Colors.green.withValues(alpha: 0.4),
                        ),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.smart_toy, color: Colors.green, size: 14),
                          SizedBox(width: 4),
                          Text(
                            'ToT AI',
                            style: TextStyle(
                              color: Colors.green,
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 20),

                // Game Name
                Text(
                  widget.game.toUpperCase(),
                  style: const TextStyle(
                    fontFamily: 'Oswald',
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    letterSpacing: 2,
                  ),
                ),

                const SizedBox(height: 4),

                // Subtitle
                Text(
                  widget.subtitle,
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.white.withValues(alpha: 0.5),
                  ),
                ),

                const SizedBox(height: 16),

                // Divider
                Container(
                  height: 1,
                  color: Colors.white.withValues(alpha: 0.1),
                ),

                const SizedBox(height: 16),

                // Online Players
                Row(
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(
                        color: Colors.green,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '${widget.onlinePlayers} Online',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.7),
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 20),

                // Play Button
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: _isHovered
                          ? [
                              widget.accentColor,
                              widget.accentColor.withValues(alpha: 0.8),
                            ]
                          : [const Color(0xFFD4AF37), const Color(0xFFF7E7CE)],
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Center(
                    child: Text(
                      'PLAY NOW',
                      style: TextStyle(
                        color: _isHovered ? Colors.white : Colors.black,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                        letterSpacing: 2,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
