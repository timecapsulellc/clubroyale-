/// RevenueCat Subscription Service and Paywall
///
/// Manages subscription state and provides paywall UI

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:clubroyale/config/revenuecat_config.dart';

/// Subscription state
class SubscriptionState {
  final bool isProUser;
  final bool isLoading;
  final CustomerInfo? customerInfo;
  final Offerings? offerings;
  final String? error;

  const SubscriptionState({
    this.isProUser = false,
    this.isLoading = false,
    this.customerInfo,
    this.offerings,
    this.error,
  });

  SubscriptionState copyWith({
    bool? isProUser,
    bool? isLoading,
    CustomerInfo? customerInfo,
    Offerings? offerings,
    String? error,
  }) {
    return SubscriptionState(
      isProUser: isProUser ?? this.isProUser,
      isLoading: isLoading ?? this.isLoading,
      customerInfo: customerInfo ?? this.customerInfo,
      offerings: offerings ?? this.offerings,
      error: error,
    );
  }
}

/// Subscription Notifier
class SubscriptionNotifier extends Notifier<SubscriptionState> {
  @override
  SubscriptionState build() {
    _initialize();
    return const SubscriptionState(isLoading: true);
  }

  Future<void> _initialize() async {
    await checkSubscriptionStatus();
    await loadOfferings();
  }

  /// Check current subscription status
  Future<void> checkSubscriptionStatus() async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final customerInfo = await RevenueCatConfig.getCustomerInfo();
      final isProUser = customerInfo?.hasProAccess ?? false;

      state = state.copyWith(
        isLoading: false,
        isProUser: isProUser,
        customerInfo: customerInfo,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  /// Load available offerings
  Future<void> loadOfferings() async {
    try {
      final offerings = await RevenueCatConfig.getOfferings();
      state = state.copyWith(offerings: offerings);
    } catch (e) {
      debugPrint('Error loading offerings: $e');
    }
  }

  /// Purchase a package
  Future<bool> purchase(Package package) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final customerInfo = await RevenueCatConfig.purchasePackage(package);

      if (customerInfo != null) {
        final isProUser = customerInfo.hasProAccess;
        state = state.copyWith(
          isLoading: false,
          isProUser: isProUser,
          customerInfo: customerInfo,
        );
        return isProUser;
      } else {
        state = state.copyWith(
          isLoading: false,
          error: 'Purchase was cancelled or failed',
        );
        return false;
      }
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
      return false;
    }
  }

  /// Restore purchases
  Future<void> restorePurchases() async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final customerInfo = await RevenueCatConfig.restorePurchases();

      if (customerInfo != null) {
        final isProUser = customerInfo.hasProAccess;
        state = state.copyWith(
          isLoading: false,
          isProUser: isProUser,
          customerInfo: customerInfo,
        );
      } else {
        state = state.copyWith(
          isLoading: false,
          error: 'No purchases to restore',
        );
      }
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }
}

/// Provider for subscription state
final subscriptionProvider =
    NotifierProvider<SubscriptionNotifier, SubscriptionState>(
        SubscriptionNotifier.new);

/// Paywall Screen
class PaywallScreen extends ConsumerWidget {
  const PaywallScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final subscriptionState = ref.watch(subscriptionProvider);
    final theme = Theme.of(context);

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              theme.colorScheme.primary.withOpacity(0.8),
              theme.colorScheme.surface,
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Header with close button
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.close, color: Colors.white),
                      onPressed: () => Navigator.pop(context),
                    ),
                    TextButton(
                      onPressed: subscriptionState.isLoading
                          ? null
                          : () => ref
                              .read(subscriptionProvider.notifier)
                              .restorePurchases(),
                      child: const Text(
                        'Restore',
                        style: TextStyle(color: Colors.white70),
                      ),
                    ),
                  ],
                ),
              ),

              // Title
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  children: [
                    Text(
                      '👑',
                      style: TextStyle(fontSize: 64),
                    ),
                    SizedBox(height: 16),
                    Text(
                      'ClubRoyale Pro',
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Unlock Premium Features',
                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.white70,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 32),

              // Features list
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    children: [
                      _buildFeatureItem(Icons.block, 'Ad-Free Experience'),
                      _buildFeatureItem(Icons.diamond, 'Bonus Diamonds Daily'),
                      _buildFeatureItem(Icons.emoji_events, 'Exclusive Tournaments'),
                      _buildFeatureItem(Icons.palette, 'All Theme Presets'),
                      _buildFeatureItem(Icons.videocam, 'HD Video Calls'),
                      _buildFeatureItem(Icons.analytics, 'Advanced Stats'),
                    ],
                  ),
                ),
              ),

              // Packages/Products
              if (subscriptionState.isLoading)
                const Padding(
                  padding: EdgeInsets.all(32),
                  child: CircularProgressIndicator(color: Colors.white),
                )
              else if (subscriptionState.offerings?.current != null)
                _buildPackagesList(
                  context,
                  ref,
                  subscriptionState.offerings!.current!,
                )
              else
                const Padding(
                  padding: EdgeInsets.all(32),
                  child: Text(
                    'No subscription plans available',
                    style: TextStyle(color: Colors.white70),
                  ),
                ),

              // Error message
              if (subscriptionState.error != null)
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text(
                    subscriptionState.error!,
                    style: const TextStyle(color: Colors.redAccent),
                    textAlign: TextAlign.center,
                  ),
                ),

              // Terms
              Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  'Subscription auto-renews unless cancelled 24 hours before the end of the current period. '
                  'Manage in App Store settings.',
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.white.withOpacity(0.5),
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFeatureItem(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, color: Colors.amber, size: 24),
          const SizedBox(width: 16),
          Text(
            text,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPackagesList(
    BuildContext context,
    WidgetRef ref,
    Offering offering,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Column(
        children: offering.availablePackages.map((package) {
          return _buildPackageCard(context, ref, package);
        }).toList(),
      ),
    );
  }

  Widget _buildPackageCard(
    BuildContext context,
    WidgetRef ref,
    Package package,
  ) {
    final isPopular = package.packageType == PackageType.annual;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: isPopular ? Colors.amber : Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isPopular ? Colors.amber : Colors.white24,
          width: 2,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () async {
            final success =
                await ref.read(subscriptionProvider.notifier).purchase(package);
            if (success && context.mounted) {
              Navigator.pop(context, true);
            }
          },
          borderRadius: BorderRadius.circular(14),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            _getPackageTitle(package),
                            style: TextStyle(
                              color: isPopular ? Colors.black : Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          if (isPopular) ...[
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.green,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Text(
                                'BEST VALUE',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        package.storeProduct.description,
                        style: TextStyle(
                          color: isPopular ? Colors.black54 : Colors.white54,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
                Text(
                  package.storeProduct.priceString,
                  style: TextStyle(
                    color: isPopular ? Colors.black : Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _getPackageTitle(Package package) {
    switch (package.packageType) {
      case PackageType.monthly:
        return 'Monthly';
      case PackageType.annual:
        return 'Yearly';
      case PackageType.lifetime:
        return 'Lifetime';
      case PackageType.weekly:
        return 'Weekly';
      case PackageType.sixMonth:
        return '6 Months';
      case PackageType.threeMonth:
        return '3 Months';
      case PackageType.twoMonth:
        return '2 Months';
      default:
        return package.identifier;
    }
  }
}

/// Customer Center Screen (for managing subscriptions)
class CustomerCenterScreen extends ConsumerWidget {
  const CustomerCenterScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final subscriptionState = ref.watch(subscriptionProvider);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Subscription'),
      ),
      body: subscriptionState.isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                // Current Status Card
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      children: [
                        Icon(
                          subscriptionState.isProUser
                              ? Icons.verified
                              : Icons.star_border,
                          size: 64,
                          color: subscriptionState.isProUser
                              ? Colors.amber
                              : theme.colorScheme.outline,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          subscriptionState.isProUser
                              ? 'ClubRoyale Pro'
                              : 'Free User',
                          style: theme.textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          subscriptionState.isProUser
                              ? 'You have access to all premium features!'
                              : 'Upgrade to unlock all features',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.outline,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                // Actions
                if (!subscriptionState.isProUser) ...[
                  FilledButton.icon(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const PaywallScreen(),
                        ),
                      );
                    },
                    icon: const Icon(Icons.upgrade),
                    label: const Text('Upgrade to Pro'),
                  ),
                  const SizedBox(height: 12),
                ],

                OutlinedButton.icon(
                  onPressed: () => ref
                      .read(subscriptionProvider.notifier)
                      .restorePurchases(),
                  icon: const Icon(Icons.restore),
                  label: const Text('Restore Purchases'),
                ),

                const SizedBox(height: 24),

                // Info
                if (subscriptionState.customerInfo != null) ...[
                  Text(
                    'Customer ID',
                    style: theme.textTheme.labelSmall,
                  ),
                  Text(
                    subscriptionState.customerInfo!.originalAppUserId,
                    style: theme.textTheme.bodySmall,
                  ),
                ],
              ],
            ),
    );
  }
}
