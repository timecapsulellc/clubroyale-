import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:myapp/features/wallet/diamond_service.dart';
import 'package:myapp/features/wallet/diamond_wallet.dart';
import 'package:myapp/features/auth/auth_service.dart';

/// Screen for purchasing diamonds via RevenueCat IAP
/// Placeholder implementation - requires RevenueCat configuration
class DiamondPurchaseScreen extends ConsumerStatefulWidget {
  const DiamondPurchaseScreen({super.key});

  @override
  ConsumerState<DiamondPurchaseScreen> createState() => _DiamondPurchaseScreenState();
}

class _DiamondPurchaseScreenState extends ConsumerState<DiamondPurchaseScreen> {
  bool _isPurchasing = false;

  // Diamond packages (placeholder)
  final List<DiamondPackage> packages = [
    DiamondPackage(diamonds: 50, price: '₹100', productId: 'diamonds_50'),
    DiamondPackage(diamonds: 120, price: '₹200', productId: 'diamonds_120', bonus: 20),
    DiamondPackage(diamonds: 300, price: '₹500', productId: 'diamonds_300', bonus: 50, popular: true),
    DiamondPackage(diamonds: 650, price: '₹1000', productId: 'diamonds_650', bonus: 150),
  ];

  Future<void> _purchasePackage(DiamondPackage package) async {
    setState(() => _isPurchasing = true);

    try {
      // TODO: Integrate with RevenueCat
      // final offerings = await Purchases.getOfferings();
      // final package = offerings.current?.availablePackages.firstWhere(...)
      // await Purchases.purchasePackage(package);
      
      // Placeholder: Simulate purchase success
      await Future.delayed(const Duration(seconds: 1));
      
      // For demo purposes, add diamonds directly
      final authService = ref.read(authServiceProvider);
      final userId = authService.currentUser?.uid;
      
      if (userId != null && mounted) {
        final diamondService = ref.read(diamondServiceProvider);
        await diamondService.addDiamonds(
          userId,
          package.diamonds,
          DiamondTransactionType.purchase,
          description: 'Purchased ${package.diamonds} diamonds',
        );

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('✨ Successfully purchased ${package.diamonds} diamonds!'),
              backgroundColor: Colors.green,
            ),
          );
          Navigator.pop(context);
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Purchase failed: $e'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isPurchasing = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final authService = ref.watch(authServiceProvider);
    final userId = authService.currentUser?.uid;

    if (userId == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Get Diamonds')),
        body: const Center(child: Text('Please sign in to purchase diamonds')),
      );
    }

    final diamondService = ref.watch(diamondServiceProvider);
    final walletStream = diamondService.watchWallet(userId);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Get Diamonds'),
        centerTitle: true,
      ),
      body: StreamBuilder(
        stream: walletStream,
        builder: (context, snapshot) {
          final currentBalance = snapshot.data?.balance ?? 0;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Current balance card
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Colors.purple.shade400, Colors.blue.shade400],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    children: [
                      const Icon(Icons.diamond, size: 64, color: Colors.white),
                      const SizedBox(height: 12),
                      Text(
                        'Current Balance',
                        style: theme.textTheme.titleMedium?.copyWith(
                          color: Colors.white.withOpacity(0.9),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '$currentBalance',
                        style: theme.textTheme.displayMedium?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'Diamonds',
                        style: theme.textTheme.bodyLarge?.copyWith(
                          color: Colors.white.withOpacity(0.8),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // Info banner
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: colorScheme.primaryContainer.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: colorScheme.outline.withOpacity(0.2)),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.info_outline, color: colorScheme.primary),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Use diamonds to create rooms and unlock premium features!',
                          style: theme.textTheme.bodyMedium,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // Package list
                Text(
                  'Choose a Package',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),

                ...packages.map((package) => _PackageCard(
                  package: package,
                  onPurchase: () => _purchasePackage(package),
                  isPurchasing: _isPurchasing,
                )),

                const SizedBox(height: 24),

                // Disclaimer
                Text(
                  '💎 RevenueCat IAP integration required for production',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                    fontStyle: FontStyle.italic,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class DiamondPackage {
  final int diamonds;
  final String price;
  final String productId;
  final int bonus;
  final bool popular;

  DiamondPackage({
    required this.diamonds,
    required this.price,
    required this.productId,
    this.bonus = 0,
    this.popular = false,
  });

  int get totalDiamonds => diamonds + bonus;
}

class _PackageCard extends StatelessWidget {
  final DiamondPackage package;
  final VoidCallback onPurchase;
  final bool isPurchasing;

  const _PackageCard({
    required this.package,
    required this.onPurchase,
    required this.isPurchasing,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: package.popular
            ? colorScheme.primaryContainer.withOpacity(0.5)
            : colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: package.popular
              ? colorScheme.primary
              : colorScheme.outline.withOpacity(0.2),
          width: package.popular ? 2 : 1,
        ),
      ),
      child: Stack(
        children: [
          if (package.popular)
            Positioned(
              top: 0,
              right: 16,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: colorScheme.primary,
                  borderRadius: const BorderRadius.vertical(bottom: Radius.circular(8)),
                ),
                child: Text(
                  'POPULAR',
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: colorScheme.onPrimary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                // Diamond icon
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.amber.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.diamond, size: 32, color: Colors.amber),
                ),
                const SizedBox(width: 16),
                // Details
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            '${package.diamonds}',
                            style: theme.textTheme.headlineSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          if (package.bonus > 0) ...[
                            const SizedBox(width: 4),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: Colors.green,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                '+${package.bonus}',
                                style: theme.textTheme.labelSmall?.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                          const SizedBox(width: 4),
                          const Text('Diamonds'),
                        ],
                      ),
                      if (package.bonus > 0)
                        Text(
                          '${package.bonus} bonus diamonds!',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: Colors.green,
                          ),
                        ),
                    ],
                  ),
                ),
                // Purchase button
                FilledButton(
                  onPressed: isPurchasing ? null : onPurchase,
                  child: Text(package.price),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
