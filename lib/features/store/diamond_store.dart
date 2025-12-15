// Diamond Store Service & UI
//
// Google Play Billing integration via RevenueCat.
// Diamonds are platform fees only - NOT gambling chips.

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:clubroyale/core/constants/disclaimers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:clubroyale/features/wallet/diamond_wallet.dart';
import 'package:clubroyale/features/wallet/diamond_service.dart';
import 'package:clubroyale/features/auth/auth_service.dart';
import 'package:clubroyale/features/wallet/services/user_tier_service.dart';
import 'package:clubroyale/features/wallet/models/user_tier.dart';
import 'package:clubroyale/core/config/diamond_config.dart';
import 'package:clubroyale/features/auth/auth_service.dart';

/// Diamond pack definitions
class DiamondPack {
  final String id;
  final String name;
  final int diamonds;
  final String price;
  final int? bonus;
  final bool isBestValue;
  final IconData icon;
  
  const DiamondPack({
    required this.id,
    required this.name,
    required this.diamonds,
    required this.price,
    this.bonus,
    this.isBestValue = false,
    this.icon = Icons.diamond,
  });

  int get totalDiamonds => diamonds + (bonus ?? 0);
}

/// RevenueCat product IDs
class DiamondProducts {
  static const String pack50 = 'diamonds_50';
  static const String pack110 = 'diamonds_110';
  static const String pack575 = 'diamonds_575';
  static const String pack1200 = 'diamonds_1200';
  
  static const List<DiamondPack> packs = [
    DiamondPack(
      id: pack50,
      name: 'Starter',
      diamonds: 50,
      price: '\$0.99',
      icon: Icons.diamond_outlined,
    ),
    DiamondPack(
      id: pack110,
      name: 'Player',
      diamonds: 100,
      bonus: 10,
      price: '\$1.99',
      icon: Icons.diamond,
    ),
    DiamondPack(
      id: pack575,
      name: 'Pro',
      diamonds: 500,
      bonus: 75,
      price: '\$7.99',
      isBestValue: true,
      icon: Icons.star,
    ),
    DiamondPack(
      id: pack1200,
      name: 'Champion',
      diamonds: 1000,
      bonus: 200,
      price: '\$14.99',
      icon: Icons.emoji_events,
    ),
  ];
}

/// Diamond Store Service
class DiamondStoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  // TODO: Initialize RevenueCat in main.dart
  // static Future<void> initialize() async {
  //   await Purchases.setLogLevel(LogLevel.debug);
  //   final configuration = PurchasesConfiguration('YOUR_REVENUECAT_API_KEY');
  //   await Purchases.configure(configuration);
  // }
  
  /// Get user's current diamond balance
  Future<int> getDiamondBalance(String userId) async {
    final doc = await _firestore.collection('users').doc(userId).get();
    return doc.data()?['diamonds'] ?? 0;
  }

  /// Watch diamond balance changes
  Stream<int> watchDiamondBalance(String userId) {
    return _firestore
        .collection('users')
        .doc(userId)
        .snapshots()
        .map((doc) => doc.data()?['diamonds'] ?? 0);
  }
  
  /// Grant diamonds (after RevenueCat purchase verification)
  Future<void> grantDiamonds(String userId, int amount, String productId) async {
    final userRef = _firestore.collection('users').doc(userId);
    
    await _firestore.runTransaction((txn) async {
      final doc = await txn.get(userRef);
      final currentDiamonds = doc.data()?['diamonds'] ?? 0;
      
      txn.update(userRef, {
        'diamonds': currentDiamonds + amount,
        'lastPurchase': FieldValue.serverTimestamp(),
      });
      
      // Log purchase for audit
      txn.set(
        _firestore.collection('purchase_logs').doc(),
        {
          'userId': userId,
          'productId': productId,
          'diamondsGranted': amount,
          'timestamp': FieldValue.serverTimestamp(),
        },
      );
    });
  }

  /// Spend diamonds (for room creation, etc.)
  Future<bool> spendDiamonds(String userId, int amount, String reason) async {
    final userRef = _firestore.collection('users').doc(userId);
    
    return await _firestore.runTransaction<bool>((txn) async {
      final doc = await txn.get(userRef);
      final currentDiamonds = doc.data()?['diamonds'] ?? 0;
      
      if (currentDiamonds < amount) {
        return false; // Insufficient balance
      }
      
      txn.update(userRef, {
        'diamonds': currentDiamonds - amount,
      });
      
      // Log spending
      txn.set(
        _firestore.collection('diamond_spending').doc(),
        {
          'userId': userId,
          'amount': amount,
          'reason': reason,
          'timestamp': FieldValue.serverTimestamp(),
        },
      );
      
      return true;
    });
  }

  /// Get diamond cost for room creation
  static int getRoomCreationCost(String gameType, int maxPlayers) {
    // Base cost: 5 diamonds
    int cost = 5;
    
    // Extra players cost more
    if (maxPlayers > 4) cost += (maxPlayers - 4) * 2;
    
    // Premium games cost more
    if (gameType == 'marriage') cost += 3;
    
    return cost;
  }
}

/// Diamond Store Screen
class DiamondStoreScreen extends ConsumerStatefulWidget {
  const DiamondStoreScreen({super.key});

  @override
  ConsumerState<DiamondStoreScreen> createState() => _DiamondStoreScreenState();
}

class _DiamondStoreScreenState extends ConsumerState<DiamondStoreScreen> {
  final DiamondStoreService _storeService = DiamondStoreService();
  String? _purchasingProductId;
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Diamond Store'),
        centerTitle: true,
        actions: [
          // Current balance
          Consumer(
            builder: (context, ref, child) {
              final currentUser = ref.watch(authServiceProvider).currentUser;
              if (currentUser == null) return const SizedBox();
              
              final diamondService = ref.watch(diamondServiceProvider);
              
              return StreamBuilder<DiamondWallet>(
                stream: diamondService.watchWallet(currentUser.uid),
                builder: (context, snapshot) {
                  final balance = snapshot.data?.balance ?? 0;
                  return Container(
                    margin: const EdgeInsets.only(right: 12),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.amber.shade100,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.diamond, size: 18, color: Colors.amber),
                    const SizedBox(width: 4),
                    Text(
                      '$balance',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                  ],
                ),
              );
                },
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Disclaimer banner
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            color: Colors.blue.shade50,
            child: Row(
              children: [
                Icon(Icons.info_outline, size: 18, color: Colors.blue.shade700),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    Disclaimers.storeDisclaimer,
                    style: TextStyle(fontSize: 12, color: Colors.blue.shade700),
                  ),
                ),
              ],
            ),
          ),
          
          // What are diamonds for?
          Container(
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.deepPurple.shade400, Colors.deepPurple.shade700],
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  children: [
                    Icon(Icons.help_outline, color: Colors.white),
                    SizedBox(width: 8),
                    Text(
                      'What are Diamonds?',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                _buildUsageRow(Icons.meeting_room, 'Create Private Rooms'),
                _buildUsageRow(Icons.access_time, 'Extend Room Time'),
                _buildUsageRow(Icons.emoji_events, 'Host Tournaments'),
              ],
            ),
          ),
          
          // Diamond packs
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: DiamondProducts.packs.length,
              itemBuilder: (context, index) {
                final pack = DiamondProducts.packs[index];
                return _DiamondPackCard(
                  pack: pack,
                  isPurchasing: _purchasingProductId == pack.id,
                  onPurchase: () => _purchasePack(pack),
                );
              },
            ),
          ),
          
          // Restore purchases
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextButton.icon(
              onPressed: _restorePurchases,
              icon: const Icon(Icons.restore),
              label: const Text('Restore Purchases'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUsageRow(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(icon, color: Colors.white70, size: 18),
          const SizedBox(width: 8),
          Text(text, style: const TextStyle(color: Colors.white)),
        ],
      ),
    );
  }
  
  Future<void> _purchasePack(DiamondPack pack) async {
    setState(() => _purchasingProductId = pack.id);
    
    try {
      // TODO: Integrate RevenueCat purchase flow
      // For now, show placeholder
      await Future.delayed(const Duration(seconds: 1));
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('RevenueCat integration required for purchases'),
            backgroundColor: Colors.orange,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _purchasingProductId = null);
      }
    }
  }
  
  Future<void> _restorePurchases() async {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Checking for previous purchases...')),
    );
    // TODO: Implement restore with RevenueCat
  }
}

class _DiamondPackCard extends StatelessWidget {
  final DiamondPack pack;
  final bool isPurchasing;
  final VoidCallback onPurchase;
  
  const _DiamondPackCard({
    required this.pack,
    required this.isPurchasing,
    required this.onPurchase,
  });
  
  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: pack.isBestValue 
            ? const BorderSide(color: Colors.amber, width: 2)
            : BorderSide.none,
      ),
      child: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                // Icon
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: pack.isBestValue
                          ? [Colors.amber.shade300, Colors.orange.shade400]
                          : [Colors.cyan.shade300, Colors.blue.shade400],
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(pack.icon, color: Colors.white, size: 28),
                ),
                const SizedBox(width: 16),
                
                // Details
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        pack.name,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          const Icon(Icons.diamond, size: 14, color: Colors.cyan),
                          const SizedBox(width: 4),
                          Text(
                            '${pack.diamonds}',
                            style: TextStyle(color: Colors.grey.shade600),
                          ),
                          if (pack.bonus != null) ...[
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.green.shade100,
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                '+${pack.bonus} Bonus',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: Colors.green.shade700,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),
                
                // Price button
                FilledButton(
                  onPressed: isPurchasing ? null : onPurchase,
                  style: FilledButton.styleFrom(
                    backgroundColor: Colors.deepPurple,
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  ),
                  child: isPurchasing
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : Text(pack.price),
                ),
              ],
            ),
          ),
          
          // Best value badge
          if (pack.isBestValue)
            Positioned(
              top: 0,
              right: 16,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: const BoxDecoration(
                  color: Colors.amber,
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(8),
                    bottomRight: Radius.circular(8),
                  ),
                ),
                child: const Text(
                  'BEST VALUE',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
