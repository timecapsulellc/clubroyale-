import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:clubroyale/features/social/providers/dashboard_providers.dart';
import 'dart:ui';

/// Nanobanana-style Bottom Navigation with prominent gold Play button
/// 5 items: Home, Chats (badge), Play (center gold), Clubs, Profile
class SocialBottomNav extends ConsumerWidget {
  final int currentIndex;
  final bool isFloating;

  const SocialBottomNav({
    super.key,
    required this.currentIndex,
    this.isFloating = false,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final unreadChats = ref.watch(unreadChatsCountProvider).value ?? 0;
    
    final navContent = ClipRRect(
      borderRadius: isFloating ? BorderRadius.circular(30) : BorderRadius.zero,
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          height: 75,
          decoration: BoxDecoration(
            color: const Color(0xFF1a0a2e).withOpacity(0.95),
            borderRadius: isFloating ? BorderRadius.circular(30) : null,
            border: Border(
              top: BorderSide(
                color: const Color(0xFF7c3aed).withOpacity(0.3),
                width: 1,
              ),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.3),
                blurRadius: 20,
                offset: const Offset(0, -5),
              ),
            ],
          ),
          child: SafeArea(
            top: false,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Home
                _NavItem(
                  icon: Icons.home_outlined,
                  activeIcon: Icons.home,
                  label: 'Home',
                  isActive: currentIndex == 0,
                  onTap: () => context.go('/'),
                ),

                // Chats with badge
                _NavItem(
                  icon: Icons.chat_bubble_outline,
                  activeIcon: Icons.chat_bubble,
                  label: 'Chats',
                  isActive: currentIndex == 1,
                  badge: unreadChats,
                  onTap: () => context.go('/chats'),
                ),

                // Center Play Button (Prominent Gold)
                _CenterPlayButton(
                  onTap: () => context.go('/lobby'),
                ),

                // Clubs
                _NavItem(
                  icon: Icons.people_outline,
                  activeIcon: Icons.people,
                  label: 'Clubs',
                  isActive: currentIndex == 3,
                  onTap: () => context.go('/clubs'),
                ),

                // Profile
                _NavItem(
                  icon: Icons.person_outline,
                  activeIcon: Icons.person,
                  label: 'Profile',
                  isActive: currentIndex == 4,
                  onTap: () => context.go('/profile'),
                ),
              ],
            ),
          ),
        ),
      ),
    );

    if (isFloating) {
      return Container(
        margin: const EdgeInsets.fromLTRB(24, 0, 24, 16),
        child: navContent,
      );
    }

    return navContent;
  }
}

/// Prominent gold Play button in center
class _CenterPlayButton extends StatelessWidget {
  final VoidCallback onTap;

  const _CenterPlayButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 60,
        height: 60,
        margin: const EdgeInsets.only(bottom: 10),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFFD4AF37), Color(0xFFF7E7CE), Color(0xFFD4AF37)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: const Color(0xFFD4AF37).withOpacity(0.5),
              blurRadius: 15,
              spreadRadius: 2,
              offset: const Offset(0, 4),
            ),
            // Inner glow effect
            BoxShadow(
              color: const Color(0xFFD4AF37).withOpacity(0.3),
              blurRadius: 25,
              spreadRadius: 4,
            ),
          ],
        ),
        child: const Icon(
          Icons.play_arrow_rounded,
          color: Color(0xFF1a0a2e),
          size: 32,
        ),
      ),
    );
  }
}

/// Individual nav item
class _NavItem extends StatelessWidget {
  final IconData icon;
  final IconData activeIcon;
  final String label;
  final bool isActive;
  final int badge;
  final VoidCallback onTap;

  const _NavItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
    required this.isActive,
    this.badge = 0,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        width: 60,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                Icon(
                  isActive ? activeIcon : icon,
                  color: isActive ? Colors.white : Colors.white54,
                  size: 24,
                ),
                if (badge > 0)
                  Positioned(
                    top: -5,
                    right: -8,
                    child: Container(
                      width: 16,
                      height: 16,
                      decoration: const BoxDecoration(
                        color: Color(0xFFef4444),
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Text(
                          badge > 9 ? '9+' : '$badge',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 9,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                color: isActive ? Colors.white : Colors.white54,
                fontSize: 11,
                fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
