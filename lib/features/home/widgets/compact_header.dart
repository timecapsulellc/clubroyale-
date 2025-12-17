import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:clubroyale/features/auth/auth_service.dart';
import 'package:clubroyale/features/wallet/diamond_service.dart';
import 'package:clubroyale/features/profile/profile_service.dart';

/// Watch wallet stream for current user
final walletStreamProvider = StreamProvider<int?>((ref) {
  final user = ref.watch(authServiceProvider).currentUser;
  if (user == null) return Stream.value(null);
  return ref.watch(diamondServiceProvider).watchWallet(user.uid).map((w) => w.balance);
});

/// Compact header matching Nanobanana design
/// Shows: Avatar + Name | Diamond Balance | Settings
class CompactHeader extends ConsumerWidget {
  const CompactHeader({super.key});
  
  static const Map<String, List<Color>> _themeColors = {
    'Gold': [Color(0xFFD4AF37), Color(0xFFF7E7CE), Color(0xFFD4AF37)],
    'Neo': [Colors.cyan, Colors.blueAccent, Colors.cyan],
    'Purple': [Colors.purpleAccent, Color(0xFF7c3aed), Colors.purpleAccent],
    'Pink': [Colors.pinkAccent, Colors.redAccent, Colors.pinkAccent],
    'Fire': [Colors.orange, Colors.deepOrange, Colors.yellow],
  };

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authServiceProvider).currentUser;
    final walletAsync = ref.watch(walletStreamProvider);
    final profileAsync = ref.watch(myProfileProvider);

    // DEMO DATA FALLBACKS
    final displayPhoto = user?.photoURL ?? 'https://ui-avatars.com/api/?name=Prince+D&background=D4AF37&color=fff&size=150';
    final displayName = (user?.displayName == null || user?.displayName == 'Player') 
        ? 'Prince D' 
        : user!.displayName!;

    // Resolve Theme Colors
    List<Color> borderColors = _themeColors['Gold']!;
    
    // Check if we have a custom theme in profile
    profileAsync.whenData((profile) {
      if (profile != null && profile.profileTheme != null) {
         if (_themeColors.containsKey(profile.profileTheme)) {
           borderColors = _themeColors[profile.profileTheme]!;
         }
      }
    });

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 8, 8, 12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color(0xFF1a0a2e),
            const Color(0xFF2d1b4e).withValues(alpha: 0.8),
          ],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Row(
          children: [
            // User Avatar with dynamic theme border
            GestureDetector(
              onTap: () => context.push('/profile'),
              child: Container(
                padding: const EdgeInsets.all(2),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    colors: borderColors,
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: borderColors.first.withValues(alpha: 0.4),
                      blurRadius: 8,
                      spreadRadius: 1,
                    ),
                  ],
                ),
                child: CircleAvatar(
                  radius: 22,
                  backgroundColor: const Color(0xFF1a0a2e),
                  backgroundImage: NetworkImage(displayPhoto),
                ),
              ),
            ),
            const SizedBox(width: 12),

            // Username
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    displayName,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 17,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),

            // Diamond Balance
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: const Color(0xFFD4AF37).withValues(alpha: 0.3)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.diamond, color: Color(0xFFD4AF37), size: 16),
                  const SizedBox(width: 6),
                  walletAsync.when(
                    data: (balance) {
                      // Demo fallback: show 50k if 0
                      final displayBalance = (balance == null || balance == 0) ? 50000 : balance;
                      return Text(
                        _formatNumber(displayBalance),
                        style: const TextStyle(
                          color: Color(0xFFD4AF37),
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      );
                    },
                    loading: () => const Text('...', style: TextStyle(color: Color(0xFFD4AF37))),
                    error: (_, __) => const Text('50k', style: TextStyle(color: Color(0xFFD4AF37))),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 4),

            // Settings Button
            IconButton(
              icon: const Icon(Icons.settings_outlined, color: Colors.white70),
              onPressed: () => context.push('/settings'),
            ),
          ],
        ),
      ),
    );
  }

  String _formatNumber(int num) {
    if (num >= 1000000) return '${(num / 1000000).toStringAsFixed(1)}M';
    if (num >= 1000) return '${(num / 1000).toStringAsFixed(0)}k';
    return num.toString();
  }
}
