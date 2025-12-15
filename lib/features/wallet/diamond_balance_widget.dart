import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:clubroyale/features/wallet/diamond_service.dart';
import 'package:clubroyale/features/auth/auth_service.dart';

/// Widget to display user's diamond balance with shimmer effect
class DiamondBalanceWidget extends ConsumerWidget {
  final bool showPurchaseButton;
  final VoidCallback? onTap;

  const DiamondBalanceWidget({
    super.key,
    this.showPurchaseButton = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authService = ref.watch(authServiceProvider);
    final userId = authService.currentUser?.uid;
    
    if (userId == null) {
      return const SizedBox.shrink();
    }

    final diamondService = ref.watch(diamondServiceProvider);
    final walletStream = diamondService.watchWallet(userId);

    return StreamBuilder(
      stream: walletStream,
      builder: (context, snapshot) {
        final balance = snapshot.data?.balance ?? 0;
        final theme = Theme.of(context);
        final colorScheme = theme.colorScheme;

        return GestureDetector(
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.purple.shade300,
                  Colors.blue.shade300,
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.purple.withValues(alpha: 0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Diamond icon
                const Icon(
                  Icons.diamond,
                  color: Colors.white,
                  size: 18,
                ),
                const SizedBox(width: 6),
                // Balance
                Text(
                  '$balance',
                  style: theme.textTheme.titleSmall?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (showPurchaseButton) ...[
                  const SizedBox(width: 4),
                  const Icon(
                    Icons.add_circle,
                    color: Colors.white,
                    size: 16,
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }
}

/// Compact diamond balance for app bar
class DiamondBalanceBadge extends ConsumerWidget {
  const DiamondBalanceBadge({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authService = ref.watch(authServiceProvider);
    final userId = authService.currentUser?.uid;
    
    if (userId == null) return const SizedBox.shrink();

    final diamondService = ref.watch(diamondServiceProvider);
    final walletStream = diamondService.watchWallet(userId);

    return StreamBuilder(
      stream: walletStream,
      builder: (context, snapshot) {
        final balance = snapshot.data?.balance ?? 0;

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Chip(
            avatar: const Icon(Icons.diamond, size: 16, color: Colors.amber),
            label: Text(
              '$balance',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            backgroundColor: Colors.amber.withValues(alpha: 0.2),
            visualDensity: VisualDensity.compact,
          ),
        );
      },
    );
  }
}
