import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'dart:math' as math;

/// Hero Section - "The Royal Table"
///
/// Cinematic animated hero showcasing premium gaming experience:
/// - Animated card fan cycling through 4 games
/// - Gold particle effects
/// - Premium CTAs
class HeroSection extends StatefulWidget {
  const HeroSection({super.key});

  @override
  State<HeroSection> createState() => _HeroSectionState();
}

class _HeroSectionState extends State<HeroSection>
    with TickerProviderStateMixin {
  late AnimationController _cardController;
  late AnimationController _particleController;

  @override
  void initState() {
    super.initState();
    _cardController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 8),
    )..repeat();

    _particleController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat();
  }

  @override
  void dispose() {
    _cardController.dispose();
    _particleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isDesktop = screenWidth > 800;

    return Container(
      width: double.infinity,
      height: isDesktop ? 600 : 500,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFF051A12), // Deep Forest
            Color(0xFF0D5C3D), // Royal Green
            Color(0xFF1B7A4E), // Rich Green
          ],
        ),
      ),
      child: Stack(
        children: [
          // Background Pattern (Felt Texture Effect)
          _buildFeltPattern(),

          // Gold Particle Effects
          _buildParticles(),

          // Main Content
          Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1200),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Logo/Brand
                    _buildLogo()
                        .animate()
                        .fadeIn(duration: 600.ms)
                        .slideY(begin: -0.3, end: 0),

                    const SizedBox(height: 32),

                    // Animated Card Fan
                    _buildCardFan(
                      isDesktop,
                    ).animate().scale(delay: 300.ms, duration: 800.ms),

                    const SizedBox(height: 40),

                    // Tagline
                    _buildTagline().animate().fadeIn(delay: 500.ms),

                    const SizedBox(height: 32),

                    // CTA Buttons
                    _buildCTAs(context, isDesktop)
                        .animate()
                        .fadeIn(delay: 700.ms)
                        .slideY(begin: 0.3, end: 0),

                    const SizedBox(height: 40),

                    // Stats Bar
                    _buildStatsBar(isDesktop).animate().fadeIn(delay: 900.ms),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeltPattern() {
    return Positioned.fill(child: CustomPaint(painter: _FeltPatternPainter()));
  }

  Widget _buildParticles() {
    return AnimatedBuilder(
      animation: _particleController,
      builder: (context, child) {
        return CustomPaint(
          painter: _GoldParticlePainter(_particleController.value),
          size: Size.infinite,
        );
      },
    );
  }

  Widget _buildLogo() {
    return Column(
      children: [
        // Crown Icon
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: const Color(0xFFD4AF37), width: 2),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFFD4AF37).withValues(alpha: 0.3),
                blurRadius: 20,
                spreadRadius: 5,
              ),
            ],
          ),
          child: const Icon(Icons.casino, size: 48, color: Color(0xFFD4AF37)),
        ),
        const SizedBox(height: 16),
        // Brand Name
        ShaderMask(
          shaderCallback: (bounds) => const LinearGradient(
            colors: [Color(0xFFD4AF37), Color(0xFFF7E7CE), Color(0xFFD4AF37)],
          ).createShader(bounds),
          child: const Text(
            'CLUBROYALE',
            style: TextStyle(
              fontFamily: 'Oswald',
              fontSize: 42,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              letterSpacing: 8,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCardFan(bool isDesktop) {
    final cardSize = isDesktop ? 120.0 : 80.0;
    final games = ['♠', '♥', '♦', '♣'];
    final colors = [Colors.white, Colors.red, Colors.red, Colors.white];

    return AnimatedBuilder(
      animation: _cardController,
      builder: (context, child) {
        return SizedBox(
          width: cardSize * 3,
          height: cardSize * 1.5,
          child: Stack(
            alignment: Alignment.center,
            children: List.generate(4, (index) {
              // Calculate rotation for fan effect
              final baseAngle = (index - 1.5) * 0.15;
              final wobble =
                  math.sin(_cardController.value * math.pi * 2 + index) * 0.02;
              final angle = baseAngle + wobble;

              // Calculate horizontal offset
              final xOffset = (index - 1.5) * (isDesktop ? 40 : 25);

              return Transform.translate(
                offset: Offset(xOffset, 0),
                child: Transform.rotate(
                  angle: angle,
                  child: _buildCard(games[index], colors[index], cardSize),
                ),
              );
            }),
          ),
        );
      },
    );
  }

  Widget _buildCard(String suit, Color color, double size) {
    return Container(
      width: size,
      height: size * 1.4,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.4),
            blurRadius: 15,
            offset: const Offset(5, 5),
          ),
        ],
        border: Border.all(color: const Color(0xFFD4AF37), width: 1),
      ),
      child: Center(
        child: Text(
          suit,
          style: TextStyle(
            fontSize: size * 0.6,
            color: color,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildTagline() {
    return Column(
      children: [
        const Text(
          'WHERE LEGENDS PLAY',
          style: TextStyle(
            fontFamily: 'Oswald',
            fontSize: 28,
            fontWeight: FontWeight.w600,
            color: Colors.white,
            letterSpacing: 6,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Premium Card Gaming • AI Opponents • Real Competition',
          style: TextStyle(
            fontSize: 14,
            color: Colors.white.withValues(alpha: 0.7),
            letterSpacing: 1,
          ),
        ),
      ],
    );
  }

  Widget _buildCTAs(BuildContext context, bool isDesktop) {
    return Wrap(
      spacing: 16,
      runSpacing: 12,
      alignment: WrapAlignment.center,
      children: [
        // Primary CTA - Play Now
        _PrimaryCTA(
          label: 'PLAY NOW',
          icon: Icons.play_arrow,
          onTap: () => context.go('/'),
        ),
        // Secondary CTA - Learn More
        _SecondaryCTA(
          label: 'LEARN MORE',
          icon: Icons.info_outline,
          onTap: () {
            // Scroll to game showcase
          },
        ),
      ],
    );
  }

  Widget _buildStatsBar(bool isDesktop) {
    final stats = [
      ('⭐', '50K+', 'Players'),
      ('🏆', '24/7', 'Tournaments'),
      ('💎', 'FREE', 'Entry'),
    ];

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(
          color: const Color(0xFFD4AF37).withValues(alpha: 0.3),
        ),
      ),
      child: Wrap(
        spacing: isDesktop ? 48 : 24,
        children: stats
            .map(
              (stat) => Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(stat.$1, style: const TextStyle(fontSize: 20)),
                  const SizedBox(width: 8),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        stat.$2,
                        style: const TextStyle(
                          color: Color(0xFFD4AF37),
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      Text(
                        stat.$3,
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.6),
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            )
            .toList(),
      ),
    );
  }
}

/// Primary CTA Button - Gold Gradient
class _PrimaryCTA extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback onTap;

  const _PrimaryCTA({
    required this.label,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(30),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [
                    Color(0xFFD4AF37),
                    Color(0xFFF7E7CE),
                    Color(0xFFD4AF37),
                  ],
                ),
                borderRadius: BorderRadius.circular(30),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFFD4AF37).withValues(alpha: 0.4),
                    blurRadius: 20,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(icon, color: Colors.black, size: 24),
                  const SizedBox(width: 8),
                  Text(
                    label,
                    style: const TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      letterSpacing: 2,
                    ),
                  ),
                ],
              ),
            ),
          ),
        )
        .animate(onPlay: (c) => c.repeat(reverse: true))
        .shimmer(duration: 2.seconds, delay: 1.seconds);
  }
}

/// Secondary CTA Button - Outlined
class _SecondaryCTA extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback onTap;

  const _SecondaryCTA({
    required this.label,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(30),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
          decoration: BoxDecoration(
            color: Colors.transparent,
            borderRadius: BorderRadius.circular(30),
            border: Border.all(color: const Color(0xFFD4AF37), width: 2),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, color: const Color(0xFFD4AF37), size: 24),
              const SizedBox(width: 8),
              Text(
                label,
                style: const TextStyle(
                  color: Color(0xFFD4AF37),
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  letterSpacing: 2,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Felt Pattern Painter - Subtle texture effect
class _FeltPatternPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.black.withValues(alpha: 0.05)
      ..strokeWidth = 0.5;

    // Draw subtle grid pattern
    const spacing = 20.0;
    for (double x = 0; x < size.width; x += spacing) {
      for (double y = 0; y < size.height; y += spacing) {
        canvas.drawCircle(Offset(x, y), 0.5, paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// Gold Particle Painter - Floating dust effect
class _GoldParticlePainter extends CustomPainter {
  final double animationValue;

  _GoldParticlePainter(this.animationValue);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFFD4AF37).withValues(alpha: 0.3);

    final random = math.Random(42); // Consistent seed

    for (int i = 0; i < 30; i++) {
      final x = random.nextDouble() * size.width;
      final baseY = random.nextDouble() * size.height;
      final speed = 0.5 + random.nextDouble() * 0.5;
      final particleSize = 1.0 + random.nextDouble() * 2;

      // Animate upward
      final y = (baseY - (animationValue * size.height * speed)) % size.height;

      canvas.drawCircle(Offset(x, y), particleSize, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
