import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';

class GameModesSection extends StatelessWidget {
  const GameModesSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            children: [
              Container(
                width: 3, height: 16,
                decoration: BoxDecoration(
                  color: const Color(0xFFD4AF37),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                'GAME MODES',
                style: TextStyle(
                  color: const Color(0xFFD4AF37),
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.5,
                ),
              ),
            ],
          ),
        ),
        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 16),
          crossAxisCount: 2,
          mainAxisSpacing: 16,
          crossAxisSpacing: 16,
          childAspectRatio: 1.3,
          children: [
            _ModeCard(
              title: 'SOLO',
              subtitle: 'Practice vs AI',
              icon: Icons.person,
              accentColor: const Color(0xFFD4AF37), // Gold
              bgGradient: LinearGradient(
                colors: [const Color(0xFF2d1b4e), const Color(0xFF1a0a2e)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              onTap: () => _showGameSelector(context),
            ),
            _ModeCard(
              title: 'PUBLIC',
              subtitle: 'Ranked Match',
              icon: Icons.public,
              accentColor: const Color(0xFF22C55E), // Green
              bgGradient: LinearGradient(
                colors: [const Color(0xFF2d1b4e), const Color(0xFF1a0a2e)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              isFeatured: true, // Gold glow
              onTap: () => context.go('/lobby'),
            ),
            _ModeCard(
              title: 'PRIVATE',
              subtitle: 'Table Code',
              icon: Icons.lock,
              accentColor: const Color(0xFFA855F7), // Purple
              bgGradient: LinearGradient(
                colors: [const Color(0xFF2d1b4e), const Color(0xFF1a0a2e)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              onTap: () => _showJoinPrivateDialog(context),
            ),
            _ModeCard(
              title: 'LOCAL',
              subtitle: 'WiFi Host',
              icon: Icons.wifi,
              accentColor: const Color(0xFF3B82F6), // Blue
              bgGradient: LinearGradient(
                colors: [const Color(0xFF2d1b4e), const Color(0xFF1a0a2e)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Local Multiplayer coming in v1.3!'),
                    backgroundColor: Color(0xFF1a0a2e),
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              },
            ),
          ],
        ),
      ],
    );
  }

  void _showGameSelector(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(
          color: Color(0xFF1a0a2e),
          borderRadius: BorderRadius.only(topLeft: Radius.circular(30), topRight: Radius.circular(30)),
          border: Border(top: BorderSide(color: Color(0xFFD4AF37), width: 2)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Select Game',
              style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            _GameOption(name: 'Marriage', icon: '♦️', onTap: () { Navigator.pop(context); context.push('/marriage/practice'); }),
            _GameOption(name: 'Call Break', icon: '♠️', onTap: () { Navigator.pop(context); context.push('/call-break'); }),
            _GameOption(name: 'Teen Patti', icon: '♥️', onTap: () { Navigator.pop(context); context.push('/teen_patti/practice'); }), // Placeholder route
            _GameOption(name: 'In-Between', icon: '♣️', onTap: () { Navigator.pop(context); context.push('/in_between/practice'); }), // Placeholder
          ],
        ),
      ),
    );
  }

  void _showJoinPrivateDialog(BuildContext context) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1a0a2e),
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
            side: const BorderSide(color: Color(0xFFD4AF37), width: 1)
        ),
        title: const Row(
          children: [
            Icon(Icons.lock_open, color: Color(0xFFD4AF37)),
            SizedBox(width: 8),
            Text('Join Private Table', style: TextStyle(color: Colors.white)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Enter the code shared by your friend to join their table.',
              style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 13),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: controller,
              style: const TextStyle(color: Colors.white, fontSize: 18, letterSpacing: 2),
              textAlign: TextAlign.center,
              decoration: InputDecoration(
                hintText: 'CODE',
                hintStyle: TextStyle(color: Colors.white.withValues(alpha: 0.3)),
                filled: true,
                fillColor: const Color(0xFF2d1b4e),
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none
                ),
                focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Color(0xFFD4AF37))
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
          ),
          FilledButton(
            onPressed: () {
              if (controller.text.isNotEmpty) {
                 Navigator.pop(context);
                 context.push('/lobby/${controller.text}');
              }
            },
            style: FilledButton.styleFrom(
                backgroundColor: const Color(0xFFD4AF37),
                foregroundColor: Colors.black,
            ),
            child: const Text('Join Table', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }
}

class _GameOption extends StatelessWidget {
  final String name;
  final String icon;
  final VoidCallback onTap;

  const _GameOption({required this.name, required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onTap,
      leading: Container(
        width: 40, height: 40,
        alignment: Alignment.center,
        decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.1), shape: BoxShape.circle),
        child: Text(icon, style: const TextStyle(fontSize: 20)),
      ),
      title: Text(name, style: const TextStyle(color: Colors.white)),
      trailing: const Icon(Icons.arrow_forward_ios, color: Colors.white54, size: 16),
      contentPadding: EdgeInsets.zero,
    );
  }
}

class _ModeCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color accentColor;
  final Gradient bgGradient;
  final VoidCallback onTap;
  final bool isFeatured;

  const _ModeCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.accentColor,
    required this.bgGradient,
    required this.onTap,
    this.isFeatured = false,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(24),
        child: Container(
          decoration: BoxDecoration(
            gradient: bgGradient,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: isFeatured ? const Color(0xFFD4AF37) : Colors.white.withValues(alpha: 0.1),
              width: isFeatured ? 1.5 : 1,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.3),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
              if (isFeatured)
                BoxShadow(
                  color: const Color(0xFFD4AF37).withValues(alpha: 0.15),
                  blurRadius: 16,
                  spreadRadius: 2,
                ),
            ],
          ),
          child: Stack(
            children: [
              // Decorative Background Icon (Watermark)
              Positioned(
                right: -20,
                bottom: -20,
                child: Transform.rotate(
                  angle: -0.2, // Tilted
                  child: Icon(
                    icon, // Uses the mode icon as the watermark
                    size: 100, // Large
                    color: accentColor.withValues(alpha: 0.1), // Subtle
                  ),
                ),
              ),
              
              // Main Content
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: accentColor.withValues(alpha: 0.15),
                            shape: BoxShape.circle,
                            border: Border.all(color: accentColor.withValues(alpha: 0.3), width: 1),
                          ),
                          child: Icon(icon, color: accentColor, size: 22),
                        ),
                        if (isFeatured)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: const Color(0xFFD4AF37),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Text('LIVE', style: TextStyle(color: Colors.black, fontSize: 10, fontWeight: FontWeight.bold)),
                          ).animate(onPlay: (c) => c.repeat()).shimmer(duration: 2.seconds, delay: 1.seconds),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: TextStyle(
                            color: isFeatured ? const Color(0xFFD4AF37) : Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          subtitle,
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.5),
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    ).animate().scale(duration: 200.ms, curve: Curves.easeOut);
  }
}
