import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:clubroyale/config/casino_theme.dart';
import 'package:clubroyale/core/constants/disclaimers.dart';
import 'package:clubroyale/core/utils/error_helper.dart';

import 'auth_service.dart';

class AuthScreen extends ConsumerStatefulWidget {
  const AuthScreen({super.key});

  @override
  ConsumerState<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends ConsumerState<AuthScreen>
    with TickerProviderStateMixin {
  bool _isLoading = false;
  String? _errorMessage;
  late AnimationController _floatController;
  late AnimationController _pulseController;
  late AnimationController _cardController;
  late AnimationController _neonController;
  late AnimationController _spotlightController;

  @override
  void initState() {
    super.initState();
    _floatController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat(reverse: true);

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);

    _cardController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 8),
    )..repeat();

    _neonController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);

    _spotlightController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 6),
    )..repeat();
  }

  @override
  void dispose() {
    _floatController.dispose();
    _pulseController.dispose();
    _cardController.dispose();
    _neonController.dispose();
    _spotlightController.dispose();
    super.dispose();
  }

  Future<void> _signIn() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final authService = ref.read(authServiceProvider);
      final user = await authService.signInAnonymously();

      if (user != null) {
        if (!mounted) return;
        context.go('/');
      } else {
        setState(() {
          _errorMessage = 'Failed to sign in. Please try again.';
        });
      }
    } catch (e) {
      setState(() {
        // Use ErrorHelper to show friendly message
        _errorMessage = ErrorHelper.getFriendlyMessage(e);
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Animated Background with spotlights
          _buildAnimatedBackground(),

          // Spotlight beams
          _buildSpotlightEffects(),

          // Gold particle rain
          _buildGoldParticleRain(),

          // Floating Cards Background
          _buildFloatingCards(),

          // Main Content
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 32),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox(height: 40),

                    // VIP Badge
                    _buildVIPBadge(),

                    const SizedBox(height: 16),

                    // Animated Chip Logo
                    _buildChipLogo(),

                    const SizedBox(height: 24),

                    // Neon Title with Glow
                    _buildNeonTitle(),

                    const SizedBox(height: 8),

                    // Subtitle
                    _buildSubtitle(),

                    const SizedBox(height: 48),

                    // Error Message
                    if (_errorMessage != null) _buildErrorMessage(),

                    // Primary CTA Button
                    _buildPrimaryButton(),

                    const SizedBox(height: 16),

                    // Test Mode Button - Removed for Production
                    // _buildTestModeButton(),
                    const SizedBox(height: 40),

                    // Features Grid - Playing Card Style
                    _buildPlayingCardFeatures(),

                    const SizedBox(height: 24),

                    // Compliance Footer
                    _buildComplianceFooter(),

                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAnimatedBackground() {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF0a0015), // Deep black-purple
            Color(0xFF1a0a2e), // Dark purple
            Color(0xFF2d1b4e), // Rich purple
            Color(0xFF1a0a2e), // Dark purple
          ],
          stops: [0.0, 0.3, 0.7, 1.0],
        ),
      ),
      child: AnimatedBuilder(
        animation: _pulseController,
        builder: (context, child) {
          return CustomPaint(
            painter: _CasinoBackgroundPainter(
              animation: _pulseController.value,
              cardAnimation: _cardController.value,
            ),
            size: Size.infinite,
          );
        },
      ),
    );
  }

  Widget _buildSpotlightEffects() {
    return AnimatedBuilder(
      animation: _spotlightController,
      builder: (context, child) {
        return CustomPaint(
          painter: _SpotlightPainter(animation: _spotlightController.value),
          size: Size.infinite,
        );
      },
    );
  }

  Widget _buildGoldParticleRain() {
    return AnimatedBuilder(
      animation: _cardController,
      builder: (context, child) {
        return CustomPaint(
          painter: _GoldParticlePainter(animation: _cardController.value),
          size: Size.infinite,
        );
      },
    );
  }

  Widget _buildFloatingCards() {
    return AnimatedBuilder(
      animation: _cardController,
      builder: (context, child) {
        return Stack(
          children: List.generate(8, (index) {
            final angle =
                (index * math.pi / 4) + (_cardController.value * 2 * math.pi);
            final radius = 180.0 + (index * 25);
            final x =
                MediaQuery.of(context).size.width / 2 +
                math.cos(angle) * radius;
            final y =
                MediaQuery.of(context).size.height / 2 +
                math.sin(angle) * radius;

            return Positioned(
              left: x - 30,
              top: y - 40,
              child: Opacity(
                opacity: 0.12 + (index * 0.03),
                child: Transform.rotate(
                  angle: angle * 0.5,
                  child: _buildFloatingCard(index),
                ),
              ),
            );
          }),
        );
      },
    );
  }

  Widget _buildFloatingCard(int index) {
    final suits = ['♠', '♥', '♦', '♣'];
    final colors = [
      Colors.white,
      const Color(0xFFFF4444),
      CasinoColors.gold,
      Colors.white,
    ];

    return Container(
      width: 50,
      height: 70,
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: colors[index % 4].withValues(alpha: 0.3)),
      ),
      child: Center(
        child: Text(
          suits[index % 4],
          style: TextStyle(
            fontSize: 32,
            color: colors[index % 4].withValues(alpha: 0.5),
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildVIPBadge() {
    return Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                CasinoColors.gold.withValues(alpha: 0.3),
                CasinoColors.gold.withValues(alpha: 0.1),
              ],
            ),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: CasinoColors.gold.withValues(alpha: 0.5)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.diamond, size: 16, color: CasinoColors.gold),
              const SizedBox(width: 6),
              Text(
                'EXCLUSIVE CLUB',
                style: TextStyle(
                  color: CasinoColors.gold,
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 2,
                ),
              ),
              const SizedBox(width: 6),
              Icon(Icons.diamond, size: 16, color: CasinoColors.gold),
            ],
          ),
        )
        .animate()
        .fadeIn(delay: 100.ms)
        .shimmer(
          duration: 2.seconds,
          delay: 500.ms,
          color: CasinoColors.gold.withValues(alpha: 0.3),
        );
  }

  Widget _buildChipLogo() {
    return AnimatedBuilder(
          animation: Listenable.merge([_floatController, _neonController]),
          builder: (context, child) {
            final float = 8 * math.sin(_floatController.value * math.pi);
            final glow = 0.3 + (_neonController.value * 0.2);

            return Transform.translate(
              offset: Offset(0, float),
              child: Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: const RadialGradient(
                    colors: [
                      Color(0xFFffd700),
                      Color(0xFFf4a940),
                      Color(0xFFd4920a),
                    ],
                    stops: [0.0, 0.6, 1.0],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: CasinoColors.gold.withValues(alpha: glow),
                      blurRadius: 40,
                      spreadRadius: 10,
                    ),
                    BoxShadow(
                      color: CasinoColors.gold.withValues(alpha: glow * 0.5),
                      blurRadius: 80,
                      spreadRadius: 20,
                    ),
                  ],
                ),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    // Chip edge ridges
                    ...List.generate(12, (i) {
                      final angle = (i * math.pi / 6);
                      return Transform.rotate(
                        angle: angle,
                        child: Align(
                          alignment: Alignment.topCenter,
                          child: Container(
                            width: 8,
                            height: 12,
                            margin: const EdgeInsets.only(top: 4),
                            decoration: BoxDecoration(
                              color: const Color(0xFF1a0a2e),
                              borderRadius: BorderRadius.circular(2),
                            ),
                          ),
                        ),
                      );
                    }),
                    // Inner circle
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: const Color(0xFF1a0a2e),
                        border: Border.all(color: CasinoColors.gold, width: 3),
                      ),
                      child: const Center(
                        child: Text(
                          'CR',
                          style: TextStyle(
                            color: CasinoColors.gold,
                            fontSize: 28,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 2,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        )
        .animate()
        .fadeIn(duration: 600.ms)
        .scale(
          begin: const Offset(0.5, 0.5),
          end: const Offset(1, 1),
          duration: 600.ms,
        );
  }

  Widget _buildNeonTitle() {
    return AnimatedBuilder(
          animation: _neonController,
          builder: (context, child) {
            final flicker = 0.8 + (_neonController.value * 0.2);
            final randomFlicker = math.Random().nextDouble() > 0.95 ? 0.6 : 1.0;

            return ShaderMask(
              shaderCallback: (bounds) => LinearGradient(
                colors: [
                  CasinoColors.gold.withValues(alpha: flicker * randomFlicker),
                  Colors.white.withValues(alpha: flicker * randomFlicker),
                  CasinoColors.gold.withValues(alpha: flicker * randomFlicker),
                ],
              ).createShader(bounds),
              child: Text(
                'ClubRoyale',
                style: TextStyle(
                  fontSize: 48,
                  fontWeight: FontWeight.w900,
                  color: Colors.white,
                  letterSpacing: 2,
                  shadows: [
                    Shadow(
                      color: CasinoColors.gold.withValues(alpha: flicker * 0.8),
                      blurRadius: 30,
                    ),
                    Shadow(
                      color: CasinoColors.gold.withValues(alpha: flicker * 0.5),
                      blurRadius: 60,
                    ),
                    Shadow(
                      color: Colors.orange.withValues(alpha: flicker * 0.3),
                      blurRadius: 100,
                    ),
                  ],
                ),
              ),
            );
          },
        )
        .animate()
        .fadeIn(delay: 200.ms, duration: 500.ms)
        .slideY(begin: 0.3, end: 0, duration: 500.ms);
  }

  Widget _buildSubtitle() {
    return FittedBox(
      fit: BoxFit.scaleDown,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            '♠',
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.6),
              fontSize: 14,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            'The Ultimate Card Game Experience',
            style: TextStyle(
              fontSize: 15,
              color: Colors.white.withValues(alpha: 0.8),
              fontWeight: FontWeight.w500,
              letterSpacing: 1,
              fontStyle: FontStyle.italic,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            '♥',
            style: TextStyle(
              color: Colors.red.withValues(alpha: 0.6),
              fontSize: 14,
            ),
          ),
        ],
      ),
    ).animate().fadeIn(delay: 400.ms, duration: 500.ms);
  }

  Widget _buildErrorMessage() {
    return Container(
      padding: const EdgeInsets.all(12),
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.red.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.red.withValues(alpha: 0.5)),
      ),
      child: Row(
        children: [
          const Icon(Icons.error_outline, color: Colors.red),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              _errorMessage!,
              style: const TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPrimaryButton() {
    return AnimatedBuilder(
          animation: _pulseController,
          builder: (context, child) {
            final glow = 0.3 + (_pulseController.value * 0.2);

            return Container(
              width: double.infinity,
              height: 60,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                gradient: const LinearGradient(
                  colors: [CasinoColors.gold, Color(0xFFf4a940)],
                ),
                boxShadow: [
                  BoxShadow(
                    color: CasinoColors.gold.withValues(alpha: glow),
                    blurRadius: 25,
                    offset: const Offset(0, 8),
                  ),
                  BoxShadow(
                    color: CasinoColors.gold.withValues(alpha: glow * 0.5),
                    blurRadius: 50,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: _isLoading ? null : _signIn,
                  borderRadius: BorderRadius.circular(16),
                  child: Center(
                    child: _isLoading
                        ? const SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Color(0xFF1a0a2e),
                            ),
                          )
                        : const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.casino_rounded,
                                color: Color(0xFF1a0a2e),
                                size: 28,
                              ),
                              SizedBox(width: 8),
                              Text(
                                'Enter the Club',
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF1a0a2e),
                                  letterSpacing: 1,
                                ),
                              ),
                            ],
                          ),
                  ),
                ),
              ),
            );
          },
        )
        .animate()
        .fadeIn(delay: 600.ms, duration: 500.ms)
        .slideY(begin: 0.3, end: 0, duration: 500.ms);
  }

  Widget _buildTestModeButton() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.green.withValues(alpha: 0.5),
          width: 1.5,
        ),
        color: Colors.green.withValues(alpha: 0.1),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () async {
            final authService = ref.read(authServiceProvider);
            await authService.enableTestMode();
            if (!mounted) return;
            context.go('/');
          },
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('🧪', style: TextStyle(fontSize: 20)),
                const SizedBox(width: 8),
                Text(
                  'Quick Test Mode',
                  style: TextStyle(
                    color: Colors.green.shade300,
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    ).animate().fadeIn(delay: 700.ms, duration: 500.ms);
  }

  Widget _buildPlayingCardFeatures() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: CasinoColors.gold.withValues(alpha: 0.3)),
        boxShadow: [
          BoxShadow(
            color: CasinoColors.gold.withValues(alpha: 0.1),
            blurRadius: 20,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: _PlayingCardFeature(
                  suit: '♠',
                  suitColor: Colors.white,
                  title: '4 Players',
                  subtitle: 'Classic Games',
                ).animate().fadeIn(delay: 800.ms).slideX(begin: -0.2),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _PlayingCardFeature(
                  suit: '♥',
                  suitColor: Colors.red,
                  title: 'Real-time',
                  subtitle: 'Live scoring',
                ).animate().fadeIn(delay: 900.ms).slideX(begin: 0.2),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _PlayingCardFeature(
                  suit: '♦',
                  suitColor: CasinoColors.gold,
                  title: 'Bot Players',
                  subtitle: 'Practice mode',
                ).animate().fadeIn(delay: 1000.ms).slideX(begin: -0.2),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _PlayingCardFeature(
                  suit: '♣',
                  suitColor: Colors.white,
                  title: 'Leaderboard',
                  subtitle: 'Compete globally',
                ).animate().fadeIn(delay: 1100.ms).slideX(begin: 0.2),
              ),
            ],
          ),
        ],
      ),
    ).animate().fadeIn(delay: 800.ms, duration: 600.ms);
  }

  Widget _buildComplianceFooter() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.info_outline,
                size: 16,
                color: Colors.white.withValues(alpha: 0.6),
              ),
              const SizedBox(width: 8),
              Text(
                'Skill-Based Entertainment',
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.8),
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            Disclaimers.skillGameDisclaimer,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.5),
              fontSize: 11,
              height: 1.4,
            ),
          ),
        ],
      ),
    ).animate().fadeIn(delay: 1200.ms, duration: 500.ms);
  }
}

/// Playing card styled feature tile
class _PlayingCardFeature extends StatelessWidget {
  final String suit;
  final Color suitColor;
  final String title;
  final String subtitle;

  const _PlayingCardFeature({
    required this.suit,
    required this.suitColor,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF2d1b4e).withValues(alpha: 0.8),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: suitColor.withValues(alpha: 0.4)),
        boxShadow: [
          BoxShadow(color: suitColor.withValues(alpha: 0.1), blurRadius: 10),
        ],
      ),
      child: Stack(
        children: [
          // Top-left suit
          Positioned(
            top: 0,
            left: 0,
            child: Text(
              suit,
              style: TextStyle(
                color: suitColor.withValues(alpha: 0.3),
                fontSize: 12,
              ),
            ),
          ),
          // Bottom-right suit
          Positioned(
            bottom: 0,
            right: 0,
            child: Transform.rotate(
              angle: math.pi,
              child: Text(
                suit,
                style: TextStyle(
                  color: suitColor.withValues(alpha: 0.3),
                  fontSize: 12,
                ),
              ),
            ),
          ),
          // Content
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(suit, style: TextStyle(color: suitColor, fontSize: 28)),
              const SizedBox(height: 8),
              Text(
                title,
                style: TextStyle(
                  color: suitColor,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
              Text(
                subtitle,
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.6),
                  fontSize: 11,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Casino background with subtle patterns
class _CasinoBackgroundPainter extends CustomPainter {
  final double animation;
  final double cardAnimation;

  _CasinoBackgroundPainter({
    required this.animation,
    required this.cardAnimation,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final random = math.Random(42);

    // Draw sparkles
    for (int i = 0; i < 40; i++) {
      final x = random.nextDouble() * size.width;
      final y = random.nextDouble() * size.height;
      final opacity = 0.1 + (animation * 0.2) + (random.nextDouble() * 0.3);

      final paint = Paint()
        ..color = CasinoColors.gold.withValues(alpha: opacity * 0.4)
        ..style = PaintingStyle.fill;

      canvas.drawCircle(
        Offset(x, y + (math.sin(cardAnimation * math.pi * 2 + i) * 10)),
        1 + random.nextDouble() * 2,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _CasinoBackgroundPainter oldDelegate) {
    return oldDelegate.animation != animation ||
        oldDelegate.cardAnimation != cardAnimation;
  }
}

/// Spotlight beam effect
class _SpotlightPainter extends CustomPainter {
  final double animation;

  _SpotlightPainter({required this.animation});

  @override
  void paint(Canvas canvas, Size size) {
    // Top-left spotlight
    _drawSpotlight(
      canvas,
      Offset(0, 0),
      Offset(size.width * 0.4, size.height * 0.5),
      animation,
      CasinoColors.gold.withValues(alpha: 0.03),
    );

    // Top-right spotlight
    _drawSpotlight(
      canvas,
      Offset(size.width, 0),
      Offset(size.width * 0.6, size.height * 0.5),
      animation + 0.5,
      Colors.purple.withValues(alpha: 0.02),
    );
  }

  void _drawSpotlight(
    Canvas canvas,
    Offset start,
    Offset end,
    double anim,
    Color color,
  ) {
    final adjustedEnd = Offset(
      end.dx + math.sin(anim * math.pi * 2) * 50,
      end.dy + math.cos(anim * math.pi * 2) * 30,
    );

    final gradient = RadialGradient(
      center: Alignment.center,
      colors: [color, color.withValues(alpha: 0)],
    );

    final paint = Paint()
      ..shader = gradient.createShader(
        Rect.fromCircle(center: adjustedEnd, radius: 200),
      );

    canvas.drawCircle(adjustedEnd, 200, paint);
  }

  @override
  bool shouldRepaint(covariant _SpotlightPainter oldDelegate) {
    return oldDelegate.animation != animation;
  }
}

/// Falling gold particles
class _GoldParticlePainter extends CustomPainter {
  final double animation;

  _GoldParticlePainter({required this.animation});

  @override
  void paint(Canvas canvas, Size size) {
    final random = math.Random(123);

    for (int i = 0; i < 20; i++) {
      final x = random.nextDouble() * size.width;
      final baseY = random.nextDouble() * size.height;
      final y = (baseY + animation * size.height) % size.height;
      final particleSize = 1.0 + random.nextDouble() * 2;
      final opacity = 0.2 + random.nextDouble() * 0.3;

      final paint = Paint()
        ..color = CasinoColors.gold.withValues(alpha: opacity)
        ..style = PaintingStyle.fill;

      canvas.drawCircle(Offset(x, y), particleSize, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _GoldParticlePainter oldDelegate) {
    return oldDelegate.animation != animation;
  }
}
