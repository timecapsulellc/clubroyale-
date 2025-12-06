import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:taasclub/config/casino_theme.dart';

/// Animated particle background for premium casino feel
class ParticleBackground extends StatefulWidget {
  final Widget child;
  final Color primaryColor;
  final Color secondaryColor;
  final int particleCount;
  
  const ParticleBackground({
    super.key,
    required this.child,
    this.primaryColor = CasinoColors.gold,
    this.secondaryColor = CasinoColors.richPurple,
    this.particleCount = 40,
  });

  @override
  State<ParticleBackground> createState() => _ParticleBackgroundState();
}

class _ParticleBackgroundState extends State<ParticleBackground>
    with TickerProviderStateMixin {
  late AnimationController _particleController;
  late AnimationController _glowController;
  late List<_Particle> _particles;
  
  @override
  void initState() {
    super.initState();
    
    _particleController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 10),
    )..repeat();
    
    _glowController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat(reverse: true);
    
    _initParticles();
  }
  
  void _initParticles() {
    final random = math.Random();
    _particles = List.generate(widget.particleCount, (index) {
      return _Particle(
        x: random.nextDouble(),
        y: random.nextDouble(),
        size: 1 + random.nextDouble() * 3,
        speed: 0.001 + random.nextDouble() * 0.003,
        opacity: 0.1 + random.nextDouble() * 0.5,
        angle: random.nextDouble() * math.pi * 2,
        isGold: random.nextBool(),
      );
    });
  }
  
  @override
  void dispose() {
    _particleController.dispose();
    _glowController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            CasinoColors.feltGreenLight,
            CasinoColors.feltGreenMid,
            CasinoColors.feltGreenDark,
          ],
          stops: const [0.0, 0.5, 1.0],
        ),
      ),
      child: Stack(
        children: [
          // Particle layer
          AnimatedBuilder(
            animation: _particleController,
            builder: (context, _) {
              return CustomPaint(
                painter: _ParticlePainter(
                  particles: _particles,
                  animation: _particleController.value,
                  glowAnimation: _glowController.value,
                  primaryColor: widget.primaryColor,
                  secondaryColor: widget.secondaryColor,
                ),
                size: Size.infinite,
              );
            },
          ),
          
          // Ambient glow orbs
          AnimatedBuilder(
            animation: _glowController,
            builder: (context, _) {
              return CustomPaint(
                painter: _GlowOrbPainter(
                  animation: _glowController.value,
                  color: widget.secondaryColor,
                ),
                size: Size.infinite,
              );
            },
          ),
          
          // Child content
          widget.child,
        ],
      ),
    );
  }
}

class _Particle {
  double x;
  double y;
  final double size;
  final double speed;
  final double opacity;
  final double angle;
  final bool isGold;
  
  _Particle({
    required this.x,
    required this.y,
    required this.size,
    required this.speed,
    required this.opacity,
    required this.angle,
    required this.isGold,
  });
}

class _ParticlePainter extends CustomPainter {
  final List<_Particle> particles;
  final double animation;
  final double glowAnimation;
  final Color primaryColor;
  final Color secondaryColor;
  
  _ParticlePainter({
    required this.particles,
    required this.animation,
    required this.glowAnimation,
    required this.primaryColor,
    required this.secondaryColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    for (final particle in particles) {
      // Update position based on animation
      final x = (particle.x + animation * particle.speed * math.cos(particle.angle)) % 1.0;
      final y = (particle.y + animation * particle.speed * 2) % 1.0;
      
      final actualX = x * size.width;
      final actualY = y * size.height;
      
      // Pulse effect
      final pulseOpacity = particle.opacity * (0.7 + 0.3 * math.sin(glowAnimation * math.pi * 2));
      
      final paint = Paint()
        ..color = (particle.isGold ? primaryColor : Colors.white).withOpacity(pulseOpacity)
        ..style = PaintingStyle.fill;
      
      canvas.drawCircle(Offset(actualX, actualY), particle.size, paint);
      
      // Optional glow for larger particles
      if (particle.size > 2) {
        final glowPaint = Paint()
          ..color = (particle.isGold ? primaryColor : Colors.white).withOpacity(pulseOpacity * 0.3)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4);
        canvas.drawCircle(Offset(actualX, actualY), particle.size * 2, glowPaint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant _ParticlePainter oldDelegate) {
    return oldDelegate.animation != animation || oldDelegate.glowAnimation != glowAnimation;
  }
}

class _GlowOrbPainter extends CustomPainter {
  final double animation;
  final Color color;
  
  _GlowOrbPainter({required this.animation, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    // Draw 3 ambient orbs at different positions
    final positions = [
      Offset(size.width * 0.2, size.height * 0.3),
      Offset(size.width * 0.8, size.height * 0.5),
      Offset(size.width * 0.5, size.height * 0.8),
    ];
    
    for (int i = 0; i < positions.length; i++) {
      final offset = positions[i];
      final radius = 100.0 + (40 * math.sin((animation + i * 0.3) * math.pi * 2));
      
      final gradient = RadialGradient(
        colors: [
          color.withOpacity(0.15 * animation),
          color.withOpacity(0.0),
        ],
      );
      
      final paint = Paint()
        ..shader = gradient.createShader(
          Rect.fromCircle(center: offset, radius: radius),
        );
      
      canvas.drawCircle(offset, radius, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _GlowOrbPainter oldDelegate) {
    return oldDelegate.animation != animation;
  }
}

/// 3D Flip Card Widget for dealing animations
class FlipCard3D extends StatefulWidget {
  final Widget front;
  final Widget back;
  final bool showFront;
  final Duration duration;
  final VoidCallback? onFlipComplete;
  
  const FlipCard3D({
    super.key,
    required this.front,
    required this.back,
    this.showFront = true,
    this.duration = const Duration(milliseconds: 600),
    this.onFlipComplete,
  });

  @override
  State<FlipCard3D> createState() => _FlipCard3DState();
}

class _FlipCard3DState extends State<FlipCard3D>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  bool _isFrontVisible = true;

  @override
  void initState() {
    super.initState();
    _isFrontVisible = widget.showFront;
    
    _controller = AnimationController(
      vsync: this,
      duration: widget.duration,
    );
    
    _animation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOutBack),
    );
    
    _controller.addListener(() {
      if (_controller.value >= 0.5 && _isFrontVisible != widget.showFront) {
        setState(() {
          _isFrontVisible = widget.showFront;
        });
      }
    });
    
    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        widget.onFlipComplete?.call();
      }
    });
  }

  @override
  void didUpdateWidget(FlipCard3D oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.showFront != oldWidget.showFront) {
      if (widget.showFront) {
        _controller.reverse();
      } else {
        _controller.forward();
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        final angle = _animation.value * math.pi;
        final isShowingFront = angle < math.pi / 2;
        
        return Transform(
          alignment: Alignment.center,
          transform: Matrix4.identity()
            ..setEntry(3, 2, 0.001) // Perspective
            ..rotateY(angle),
          child: isShowingFront
              ? widget.front
              : Transform(
                  alignment: Alignment.center,
                  transform: Matrix4.identity()..rotateY(math.pi),
                  child: widget.back,
                ),
        );
      },
    );
  }
}

/// Card dealing animation - deals cards one by one with 3D flip
class CardDealingAnimation extends StatefulWidget {
  final int cardCount;
  final Duration staggerDelay;
  final Widget Function(int index) cardBuilder;
  
  const CardDealingAnimation({
    super.key,
    required this.cardCount,
    this.staggerDelay = const Duration(milliseconds: 100),
    required this.cardBuilder,
  });

  @override
  State<CardDealingAnimation> createState() => _CardDealingAnimationState();
}

class _CardDealingAnimationState extends State<CardDealingAnimation>
    with TickerProviderStateMixin {
  late List<AnimationController> _controllers;
  late List<Animation<Offset>> _slideAnimations;
  late List<Animation<double>> _scaleAnimations;
  
  @override
  void initState() {
    super.initState();
    
    _controllers = List.generate(widget.cardCount, (index) {
      return AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 500),
      );
    });
    
    _slideAnimations = _controllers.map((controller) {
      return Tween<Offset>(
        begin: const Offset(0, -2),
        end: Offset.zero,
      ).animate(CurvedAnimation(
        parent: controller,
        curve: Curves.easeOutBack,
      ));
    }).toList();
    
    _scaleAnimations = _controllers.map((controller) {
      return Tween<double>(begin: 0.5, end: 1.0).animate(CurvedAnimation(
        parent: controller,
        curve: Curves.easeOutBack,
      ));
    }).toList();
    
    _startAnimations();
  }
  
  void _startAnimations() async {
    for (int i = 0; i < widget.cardCount; i++) {
      await Future.delayed(widget.staggerDelay);
      if (mounted) {
        _controllers[i].forward();
      }
    }
  }
  
  @override
  void dispose() {
    for (final controller in _controllers) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(widget.cardCount, (index) {
        return AnimatedBuilder(
          animation: _controllers[index],
          builder: (context, child) {
            return SlideTransition(
              position: _slideAnimations[index],
              child: ScaleTransition(
                scale: _scaleAnimations[index],
                child: widget.cardBuilder(index),
              ),
            );
          },
        );
      }),
    );
  }
}

/// Win celebration particles
class WinCelebration extends StatefulWidget {
  final Widget child;
  final bool celebrate;
  
  const WinCelebration({
    super.key,
    required this.child,
    this.celebrate = false,
  });

  @override
  State<WinCelebration> createState() => _WinCelebrationState();
}

class _WinCelebrationState extends State<WinCelebration>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late List<_ConfettiParticle> _confetti;
  
  @override
  void initState() {
    super.initState();
    
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    );
    
    _initConfetti();
    
    if (widget.celebrate) {
      _controller.forward();
    }
  }
  
  void _initConfetti() {
    final random = math.Random();
    _confetti = List.generate(50, (index) {
      return _ConfettiParticle(
        x: random.nextDouble(),
        y: -0.1 - random.nextDouble() * 0.5,
        size: 4 + random.nextDouble() * 6,
        speed: 0.3 + random.nextDouble() * 0.4,
        rotation: random.nextDouble() * math.pi * 2,
        rotationSpeed: (random.nextDouble() - 0.5) * 0.5,
        color: [CasinoColors.gold, Colors.red, Colors.blue, Colors.green, CasinoColors.richPurple][random.nextInt(5)],
      );
    });
  }
  
  @override
  void didUpdateWidget(WinCelebration oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.celebrate && !oldWidget.celebrate) {
      _controller.reset();
      _initConfetti();
      _controller.forward();
    }
  }
  
  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        widget.child,
        if (widget.celebrate)
          AnimatedBuilder(
            animation: _controller,
            builder: (context, _) {
              return CustomPaint(
                painter: _ConfettiPainter(
                  confetti: _confetti,
                  animation: _controller.value,
                ),
                size: Size.infinite,
              );
            },
          ),
      ],
    );
  }
}

class _ConfettiParticle {
  final double x;
  double y;
  final double size;
  final double speed;
  double rotation;
  final double rotationSpeed;
  final Color color;
  
  _ConfettiParticle({
    required this.x,
    required this.y,
    required this.size,
    required this.speed,
    required this.rotation,
    required this.rotationSpeed,
    required this.color,
  });
}

class _ConfettiPainter extends CustomPainter {
  final List<_ConfettiParticle> confetti;
  final double animation;
  
  _ConfettiPainter({required this.confetti, required this.animation});

  @override
  void paint(Canvas canvas, Size size) {
    for (final particle in confetti) {
      final y = particle.y + animation * particle.speed * 1.5;
      if (y > 1.0) continue;
      
      final actualX = particle.x * size.width;
      final actualY = y * size.height;
      final rotation = particle.rotation + animation * particle.rotationSpeed * math.pi * 4;
      
      canvas.save();
      canvas.translate(actualX, actualY);
      canvas.rotate(rotation);
      
      final paint = Paint()
        ..color = particle.color.withOpacity(1.0 - animation * 0.5)
        ..style = PaintingStyle.fill;
      
      canvas.drawRect(
        Rect.fromCenter(center: Offset.zero, width: particle.size, height: particle.size * 0.6),
        paint,
      );
      
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(covariant _ConfettiPainter oldDelegate) {
    return oldDelegate.animation != animation;
  }
}
