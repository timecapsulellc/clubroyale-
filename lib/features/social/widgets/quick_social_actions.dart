import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:clubroyale/features/social/providers/dashboard_providers.dart';

/// Nanobanana-style Quick Actions with pill buttons
/// Voice Room (filled purple), Message (outlined with badge), Post (outlined)
class QuickSocialActions extends ConsumerWidget {
  const QuickSocialActions({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final unreadCount = ref.watch(unreadChatsCountProvider).value ?? 0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section Title
        const Padding(
          padding: EdgeInsets.fromLTRB(16, 8, 16, 12),
          child: Text(
            'Quick Actions',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),

        // Pill Buttons Row
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            children: [
              // PLAY VS AI - Featured Action
              Container(
                width: double.infinity,
                margin: const EdgeInsets.only(bottom: 10),
                child:
                    _ActionPillButton(
                          icon: Icons.smart_toy,
                          label: '🎮 Play vs AI',
                          isFilled: true,
                          fillColor: const Color(0xFF16a34a), // Green
                          onTap: () => context.go('/lobby'),
                        )
                        .animate()
                        .fadeIn(delay: 50.ms)
                        .shimmer(duration: 1500.ms, color: Colors.white24),
              ),
              Row(
                children: [
                  // Voice Room Button (Filled Purple)
                  Expanded(
                    child: _ActionPillButton(
                      icon: Icons.mic,
                      label: 'Voice Room',
                      isFilled: true,
                      onTap: () => context.push('/voice-rooms'),
                    ).animate().fadeIn(delay: 100.ms).slideY(begin: 0.1),
                  ),
                  const SizedBox(width: 10),

                  // Message Button (Outlined with badge)
                  Expanded(
                    child: _ActionPillButton(
                      icon: Icons.chat_bubble_outline,
                      label: 'Message',
                      isFilled: false,
                      badge: unreadCount,
                      onTap: () => context.go('/chats'),
                    ).animate().fadeIn(delay: 150.ms).slideY(begin: 0.1),
                  ),
                  const SizedBox(width: 10),

                  // Post Button (Outlined)
                  Expanded(
                    child: _ActionPillButton(
                      icon: Icons.add,
                      label: 'Post',
                      isFilled: false,
                      onTap: () => context.push('/stories/create'),
                    ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.1),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// Nanobanana-style pill button
class _ActionPillButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isFilled;
  final int badge;
  final Color? fillColor;
  final VoidCallback onTap;

  const _ActionPillButton({
    required this.icon,
    required this.label,
    required this.isFilled,
    this.badge = 0,
    this.fillColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(25),
        child: Container(
          height: 44,
          decoration: BoxDecoration(
            color: isFilled
                ? (fillColor ?? const Color(0xFF7c3aed))
                : Colors.transparent,
            borderRadius: BorderRadius.circular(25),
            border: Border.all(
              color: isFilled
                  ? Colors.transparent
                  : const Color(0xFF7c3aed).withOpacity(0.5),
              width: 1.5,
            ),
            boxShadow: isFilled
                ? [
                    BoxShadow(
                      color: const Color(0xFF7c3aed).withOpacity(0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : null,
          ),
          child: Stack(
            children: [
              Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      icon,
                      color: isFilled ? Colors.white : const Color(0xFF7c3aed),
                      size: 18,
                    ),
                    const SizedBox(width: 6),
                    Flexible(
                      child: Text(
                        label,
                        style: TextStyle(
                          color: isFilled
                              ? Colors.white
                              : const Color(0xFF7c3aed),
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
              if (badge > 0)
                Positioned(
                  top: 6,
                  right: 12,
                  child: Container(
                    width: 18,
                    height: 18,
                    decoration: const BoxDecoration(
                      color: Color(0xFFef4444),
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(
                        badge > 9 ? '9+' : '$badge',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
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
