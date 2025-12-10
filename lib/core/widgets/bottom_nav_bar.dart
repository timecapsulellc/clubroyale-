import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// Modern bottom navigation bar for the Super App
class ClubRoyaleBottomNav extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  const ClubRoyaleBottomNav({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _NavItem(
                icon: Icons.home_outlined,
                activeIcon: Icons.home,
                label: 'Home',
                isActive: currentIndex == 0,
                onTap: () => onTap(0),
              ),
              _NavItem(
                icon: Icons.sports_esports_outlined,
                activeIcon: Icons.sports_esports,
                label: 'Games',
                isActive: currentIndex == 1,
                onTap: () => onTap(1),
              ),
              _NavItem(
                icon: Icons.chat_bubble_outline,
                activeIcon: Icons.chat_bubble,
                label: 'Social',
                isActive: currentIndex == 2,
                onTap: () => onTap(2),
                badge: 3, // Example badge count
              ),
              _NavItem(
                icon: Icons.person_outline,
                activeIcon: Icons.person,
                label: 'Profile',
                isActive: currentIndex == 3,
                onTap: () => onTap(3),
              ),
              _NavItem(
                icon: Icons.diamond_outlined,
                activeIcon: Icons.diamond,
                label: 'Wallet',
                isActive: currentIndex == 4,
                onTap: () => onTap(4),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final IconData activeIcon;
  final String label;
  final bool isActive;
  final VoidCallback onTap;
  final int? badge;

  const _NavItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
    required this.isActive,
    required this.onTap,
    this.badge,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isActive
              ? colorScheme.primaryContainer.withOpacity(0.4)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 200),
                  child: Icon(
                    isActive ? activeIcon : icon,
                    key: ValueKey(isActive),
                    color: isActive
                        ? colorScheme.primary
                        : colorScheme.onSurface.withOpacity(0.6),
                    size: 24,
                  ),
                ),
                if (badge != null && badge! > 0)
                  Positioned(
                    top: -4,
                    right: -8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 5,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: colorScheme.error,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        badge! > 99 ? '99+' : '$badge',
                        style: TextStyle(
                          color: colorScheme.onError,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 4),
            AnimatedDefaultTextStyle(
              duration: const Duration(milliseconds: 200),
              style: theme.textTheme.labelSmall!.copyWith(
                color: isActive
                    ? colorScheme.primary
                    : colorScheme.onSurface.withOpacity(0.6),
                fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
              ),
              child: Text(label),
            ),
          ],
        ),
      ),
    );
  }
}

/// Provider for bottom nav state
class BottomNavController extends ChangeNotifier {
  int _currentIndex = 0;

  int get currentIndex => _currentIndex;

  void setIndex(int index) {
    if (_currentIndex != index) {
      _currentIndex = index;
      notifyListeners();
    }
  }

  /// Get route for index
  String getRouteForIndex(int index) {
    switch (index) {
      case 0:
        return '/';
      case 1:
        return '/games';
      case 2:
        return '/social';
      case 3:
        return '/profile';
      case 4:
        return '/wallet';
      default:
        return '/';
    }
  }

  /// Update index from route
  void updateFromRoute(String route) {
    if (route == '/' || route.startsWith('/home')) {
      _currentIndex = 0;
    } else if (route.startsWith('/games') || route.startsWith('/lobby')) {
      _currentIndex = 1;
    } else if (route.startsWith('/social') || route.startsWith('/chat') || route.startsWith('/friends')) {
      _currentIndex = 2;
    } else if (route.startsWith('/profile') || route.startsWith('/account')) {
      _currentIndex = 3;
    } else if (route.startsWith('/wallet') || route.startsWith('/store')) {
      _currentIndex = 4;
    }
    notifyListeners();
  }
}
