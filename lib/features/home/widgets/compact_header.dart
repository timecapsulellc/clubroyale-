import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:clubroyale/features/auth/auth_service.dart';
import 'package:clubroyale/features/wallet/diamond_service.dart';

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

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authServiceProvider).currentUser;
    final walletAsync = ref.watch(walletStreamProvider);

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
            // User Avatar with gold border
            Container(
              padding: const EdgeInsets.all(2),
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: [Color(0xFFD4AF37), Color(0xFFF7E7CE), Color(0xFFD4AF37)],
                ),
              ),
              child: CircleAvatar(
                radius: 22,
                backgroundColor: const Color(0xFF1a0a2e),
                backgroundImage: user?.photoURL != null
                    ? NetworkImage(user!.photoURL!)
                    : null,
                child: user?.photoURL == null
                    ? const Icon(Icons.person, size: 22, color: Colors.white70)
                    : null,
              ),
            ),
            const SizedBox(width: 12),

            // Username
            Expanded(
              child: Text(
                user?.displayName ?? 'Player',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 17,
                ),
                overflow: TextOverflow.ellipsis,
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
                    data: (balance) => Text(
                      _formatNumber(balance ?? 0),
                      style: const TextStyle(
                        color: Color(0xFFD4AF37),
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                    loading: () => const Text('...', style: TextStyle(color: Color(0xFFD4AF37))),
                    error: (_, __) => const Text('0', style: TextStyle(color: Color(0xFFD4AF37))),
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
