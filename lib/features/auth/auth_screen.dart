import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:taasclub/config/casino_theme.dart';

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
  }

  @override
  void dispose() {
    _floatController.dispose();
    _pulseController.dispose();
    _cardController.dispose();
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
        _errorMessage = 'An error occurred. Please try again.';
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
          // Animated Background
          _buildAnimatedBackground(),
          
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
                    
                    // Animated Logo
                    _buildAnimatedLogo(),
                    
                    const SizedBox(height: 24),
                    
                    // Title with Glow
                    _buildTitle(),
                    
                    const SizedBox(height: 8),
                    
                    // Subtitle
                    _buildSubtitle(),
                    
                    const SizedBox(height: 48),
                    
                    // Error Message
                    if (_errorMessage != null) _buildErrorMessage(),
                    
                    // Primary CTA Button
                    _buildPrimaryButton(),
                    
                    const SizedBox(height: 16),
                    
                    // Test Mode Button
                    _buildTestModeButton(),
                    
                    const SizedBox(height: 40),
                    
                    // Features Grid
                    _buildFeaturesGrid(),
                    
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
            painter: _ParticlePainter(
              animation: _pulseController.value,
              cardAnimation: _cardController.value,
            ),
            size: Size.infinite,
          );
        },
      ),
    );
  }

  Widget _buildFloatingCards() {
    return AnimatedBuilder(
      animation: _cardController,
      builder: (context, child) {
        return Stack(
          children: List.generate(6, (index) {
            final angle = (index * math.pi / 3) + (_cardController.value * 2 * math.pi);
            final radius = 150.0 + (index * 30);
            final x = MediaQuery.of(context).size.width / 2 + math.cos(angle) * radius;
            final y = MediaQuery.of(context).size.height / 2 + math.sin(angle) * radius;
            
            return Positioned(
              left: x - 30,
              top: y - 40,
              child: Opacity(
                opacity: 0.15 + (index * 0.05),
                child: Transform.rotate(
                  angle: angle * 0.5,
                  child: _buildCardSuit(index),
                ),
              ),
            );
          }),
        );
      },
    );
  }

  Widget _buildCardSuit(int index) {
    final suits = ['♠', '♥', '♦', '♣'];
    final colors = [Colors.white, CasinoColors.gold, Colors.red, CasinoColors.gold];
    
    return Text(
      suits[index % 4],
      style: TextStyle(
        fontSize: 60 + (index * 10).toDouble(),
        color: colors[index % 4].withOpacity(0.3),
        fontWeight: FontWeight.bold,
      ),
    );
  }

  Widget _buildAnimatedLogo() {
    return AnimatedBuilder(
      animation: _floatController,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, 8 * math.sin(_floatController.value * math.pi)),
          child: child,
        );
      },
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFFffd700), // Gold
              Color(0xFFf4a940), // Orange-gold
              Color(0xFFffd700), // Gold
            ],
          ),
          boxShadow: [
            BoxShadow(
              color: CasinoColors.gold.withOpacity(0.4),
              blurRadius: 30,
              spreadRadius: 5,
            ),
            BoxShadow(
              color: CasinoColors.gold.withOpacity(0.2),
              blurRadius: 60,
              spreadRadius: 10,
            ),
          ],
        ),
        child: const Icon(
          Icons.style_rounded, // Playing cards icon
          size: 64,
          color: Color(0xFF1a0a2e),
        ),
      ),
    ).animate()
      .fadeIn(duration: 600.ms)
      .scale(begin: const Offset(0.5, 0.5), end: const Offset(1, 1), duration: 600.ms);
  }

  Widget _buildTitle() {
    return ShaderMask(
      shaderCallback: (bounds) => const LinearGradient(
        colors: [
          CasinoColors.gold,
          Colors.white,
          CasinoColors.gold,
        ],
      ).createShader(bounds),
      child: const Text(
        'ClubRoyale',
        style: TextStyle(

          fontSize: 48,
          fontWeight: FontWeight.w900,
          color: Colors.white,
          letterSpacing: 2,
          shadows: [
            Shadow(
              color: CasinoColors.gold,
              blurRadius: 20,
            ),
          ],
        ),
      ),
    ).animate()
      .fadeIn(delay: 200.ms, duration: 500.ms)
      .slideY(begin: 0.3, end: 0, duration: 500.ms);
  }

  Widget _buildSubtitle() {
    return Text(
      '🎴 The Ultimate Call Break Experience',
      style: TextStyle(
        fontSize: 16,
        color: Colors.white.withOpacity(0.8),
        fontWeight: FontWeight.w500,
        letterSpacing: 1,
      ),
    ).animate()
      .fadeIn(delay: 400.ms, duration: 500.ms);
  }

  Widget _buildErrorMessage() {
    return Container(
      padding: const EdgeInsets.all(12),
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.red.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.red.withOpacity(0.5)),
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
            color: CasinoColors.gold.withOpacity(0.4),
            blurRadius: 20,
            offset: const Offset(0, 8),
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
                        Icons.play_arrow_rounded,
                        color: Color(0xFF1a0a2e),
                        size: 28,
                      ),
                      SizedBox(width: 8),
                      Text(
                        'Start Playing',
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
    ).animate()
      .fadeIn(delay: 600.ms, duration: 500.ms)
      .slideY(begin: 0.3, end: 0, duration: 500.ms);
  }

  Widget _buildTestModeButton() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.green.withOpacity(0.5),
          width: 1.5,
        ),
        color: Colors.green.withOpacity(0.1),
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
    ).animate()
      .fadeIn(delay: 700.ms, duration: 500.ms);
  }

  Widget _buildFeaturesGrid() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Colors.white.withOpacity(0.1),
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: _FeatureCard(
                  icon: Icons.people_alt_rounded,
                  title: '4 Players',
                  subtitle: 'Classic Call Break',
                  color: CasinoColors.gold,
                ).animate().fadeIn(delay: 800.ms).slideX(begin: -0.2),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _FeatureCard(
                  icon: Icons.flash_on_rounded,
                  title: 'Real-time',
                  subtitle: 'Live scoring',
                  color: Colors.blue,
                ).animate().fadeIn(delay: 900.ms).slideX(begin: 0.2),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _FeatureCard(
                  icon: Icons.smart_toy_rounded,
                  title: 'Bot Players',
                  subtitle: 'Practice mode',
                  color: Colors.purple,
                ).animate().fadeIn(delay: 1000.ms).slideX(begin: -0.2),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _FeatureCard(
                  icon: Icons.emoji_events_rounded,
                  title: 'Leaderboard',
                  subtitle: 'Compete globally',
                  color: Colors.orange,
                ).animate().fadeIn(delay: 1100.ms).slideX(begin: 0.2),
              ),
            ],
          ),
        ],
      ),
    ).animate()
      .fadeIn(delay: 800.ms, duration: 600.ms);
  }
}

class _FeatureCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;

  const _FeatureCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(height: 8),
          Text(
            title,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
          Text(
            subtitle,
            style: TextStyle(
              color: Colors.white.withOpacity(0.6),
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }
}

class _ParticlePainter extends CustomPainter {
  final double animation;
  final double cardAnimation;

  _ParticlePainter({required this.animation, required this.cardAnimation});

  @override
  void paint(Canvas canvas, Size size) {
    final random = math.Random(42);
    
    // Draw subtle sparkles
    for (int i = 0; i < 30; i++) {
      final x = random.nextDouble() * size.width;
      final y = random.nextDouble() * size.height;
      final opacity = 0.1 + (animation * 0.2) + (random.nextDouble() * 0.3);
      
      final paint = Paint()
        ..color = CasinoColors.gold.withOpacity(opacity * 0.5)
        ..style = PaintingStyle.fill;
      
      canvas.drawCircle(
        Offset(x, y + (math.sin(cardAnimation * math.pi * 2 + i) * 10)),
        1 + random.nextDouble() * 2,
        paint,
      );
    }
    
    // Draw glowing orbs
    for (int i = 0; i < 5; i++) {
      final x = (size.width / 5) * i + (size.width / 10);
      final y = size.height * 0.2 + (math.sin(cardAnimation * math.pi * 2 + i) * 50);
      
      final gradient = RadialGradient(
        colors: [
          CasinoColors.richPurple.withOpacity(0.15),
          CasinoColors.richPurple.withOpacity(0.0),
        ],
      );
      
      final paint = Paint()
        ..shader = gradient.createShader(Rect.fromCircle(center: Offset(x, y), radius: 80));
      
      canvas.drawCircle(Offset(x, y), 80, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _ParticlePainter oldDelegate) {
    return oldDelegate.animation != animation || oldDelegate.cardAnimation != cardAnimation;
  }
}
