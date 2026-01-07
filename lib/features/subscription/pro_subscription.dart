import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// PhD Audit Finding #19: Pro Subscription Model
/// Premium features for monetization

class ClubRoyalePro {
  static const double monthlyPrice = 4.99;
  static const double yearlyPrice = 39.99; // ~33% discount
  
  static const List<ProFeature> features = [
    ProFeature(
      icon: Icons.block,
      title: 'Ad-Free Experience',
      description: 'No interruptions, pure gameplay',
    ),
    ProFeature(
      icon: Icons.palette,
      title: 'Exclusive Card Themes',
      description: '10+ premium card backs and table designs',
    ),
    ProFeature(
      icon: Icons.speed,
      title: 'Priority Matchmaking',
      description: 'Find games 50% faster',
    ),
    ProFeature(
      icon: Icons.verified,
      title: 'Pro Badge',
      description: 'Show off your status to other players',
    ),
    ProFeature(
      icon: Icons.analytics,
      title: 'Advanced Statistics',
      description: 'Detailed game history and win rate analytics',
    ),
    ProFeature(
      icon: Icons.replay,
      title: 'Game Replays',
      description: 'Review past games move by move',
    ),
    ProFeature(
      icon: Icons.support_agent,
      title: 'Priority Support',
      description: '24/7 dedicated support channel',
    ),
  ];
}

class ProFeature {
  final IconData icon;
  final String title;
  final String description;
  
  const ProFeature({
    required this.icon,
    required this.title,
    required this.description,
  });
}

/// Pro status provider
final isProUserProvider = StateProvider<bool>((ref) => false);

/// Pro subscription screen
class ProSubscriptionScreen extends ConsumerWidget {
  const ProSubscriptionScreen({super.key});
  
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isPro = ref.watch(isProUserProvider);
    
    return Scaffold(
      backgroundColor: const Color(0xFF1a0a2e),
      appBar: AppBar(
        title: const Text('ClubRoyale Pro'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Pro badge
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: const LinearGradient(
                  colors: [Colors.amber, Colors.orange],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.amber.withValues(alpha: 0.5),
                    blurRadius: 20,
                    spreadRadius: 5,
                  ),
                ],
              ),
              child: const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.workspace_premium, size: 50, color: Colors.white),
                    Text(
                      'PRO',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Title
            const Text(
              'Upgrade to Pro',
              style: TextStyle(
                color: Colors.white,
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Unlock the full ClubRoyale experience',
              style: TextStyle(color: Colors.white70, fontSize: 16),
            ),
            
            const SizedBox(height: 32),
            
            // Features list
            ...ClubRoyalePro.features.map((feature) => _FeatureRow(feature: feature)),
            
            const SizedBox(height: 32),
            
            // Pricing cards
            Row(
              children: [
                Expanded(
                  child: _PricingCard(
                    title: 'Monthly',
                    price: '\$${ClubRoyalePro.monthlyPrice.toStringAsFixed(2)}',
                    period: '/month',
                    isPopular: false,
                    onTap: () => _subscribe(context, ref, 'monthly'),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _PricingCard(
                    title: 'Yearly',
                    price: '\$${ClubRoyalePro.yearlyPrice.toStringAsFixed(2)}',
                    period: '/year',
                    isPopular: true,
                    savings: 'Save 33%',
                    onTap: () => _subscribe(context, ref, 'yearly'),
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 24),
            
            // Restore purchases
            TextButton(
              onPressed: () => _restorePurchases(context, ref),
              child: const Text(
                'Restore Purchases',
                style: TextStyle(color: Colors.white70),
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Terms
            const Text(
              'Cancel anytime. No hidden fees.',
              style: TextStyle(color: Colors.white38, fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }
  
  void _subscribe(BuildContext context, WidgetRef ref, String plan) {
    // TODO: Integrate with in-app purchases
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Subscribing to $plan plan...'),
        backgroundColor: Colors.green,
      ),
    );
  }
  
  void _restorePurchases(BuildContext context, WidgetRef ref) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Restoring purchases...'),
        backgroundColor: Colors.blue,
      ),
    );
  }
}

class _FeatureRow extends StatelessWidget {
  final ProFeature feature;
  
  const _FeatureRow({required this.feature});
  
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: Colors.amber.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(feature.icon, color: Colors.amber, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  feature.title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  feature.description,
                  style: const TextStyle(color: Colors.white70, fontSize: 12),
                ),
              ],
            ),
          ),
          const Icon(Icons.check_circle, color: Colors.green, size: 20),
        ],
      ),
    );
  }
}

class _PricingCard extends StatelessWidget {
  final String title;
  final String price;
  final String period;
  final bool isPopular;
  final String? savings;
  final VoidCallback onTap;
  
  const _PricingCard({
    required this.title,
    required this.price,
    required this.period,
    required this.isPopular,
    this.savings,
    required this.onTap,
  });
  
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: isPopular 
              ? const LinearGradient(
                  colors: [Color(0xFFD4AF37), Color(0xFFB8860B)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                )
              : null,
          color: isPopular ? null : Colors.white.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isPopular ? Colors.amber : Colors.white24,
            width: isPopular ? 2 : 1,
          ),
        ),
        child: Column(
          children: [
            if (isPopular) ...[
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: const Text(
                  'BEST VALUE',
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 8),
            ],
            Text(
              title,
              style: TextStyle(
                color: isPopular ? Colors.white : Colors.white70,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              price,
              style: TextStyle(
                color: isPopular ? Colors.white : Colors.amber,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              period,
              style: TextStyle(
                color: isPopular ? Colors.white70 : Colors.white54,
                fontSize: 12,
              ),
            ),
            if (savings != null) ...[
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.green,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  savings!,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
