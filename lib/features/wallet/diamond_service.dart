import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:myapp/features/wallet/diamond_wallet.dart';

final diamondServiceProvider = Provider<DiamondService>((ref) => DiamondService());

/// Service for managing diamond currency (virtual currency for monetization)
class DiamondService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  
  /// Cost in diamonds to create a room
  static const int roomCreationCost = 10;
  
  /// Default starting diamonds for new users
  static const int starterDiamonds = 50;

  /// Get user's diamond wallet
  Future<DiamondWallet> getWallet(String userId) async {
    try {
      final doc = await _db.collection('wallets').doc(userId).get();
      
      if (!doc.exists) {
        // Create new wallet with starter diamonds
        final newWallet = DiamondWallet(
          userId: userId,
          balance: starterDiamonds,
          lastUpdated: DateTime.now(),
        );
        await _db.collection('wallets').doc(userId).set(newWallet.toJson());
        return newWallet;
      }
      
      return DiamondWallet.fromJson(doc.data()!);
    } catch (e) {
      debugPrint('Error getting wallet: $e');
      rethrow;
    }
  }

  /// Stream user's wallet for real-time updates
  Stream<DiamondWallet> watchWallet(String userId) {
    return _db.collection('wallets').doc(userId).snapshots().map((doc) {
      if (!doc.exists) {
        return DiamondWallet(userId: userId, balance: 0);
      }
      return DiamondWallet.fromJson(doc.data()!);
    });
  }

  /// Check if user has enough diamonds
  Future<bool> hasEnoughDiamonds(String userId, int amount) async {
    final wallet = await getWallet(userId);
    return wallet.balance >= amount;
  }

  /// Deduct diamonds from user's wallet (for room creation, ad disable, etc.)
  Future<bool> deductDiamonds(String userId, int amount, {String? description, String? gameId}) async {
    try {
      final wallet = await getWallet(userId);
      
      if (wallet.balance < amount) {
        return false; // Insufficient balance
      }
      
      // Update wallet
      await _db.collection('wallets').doc(userId).update({
        'balance': FieldValue.increment(-amount),
        'totalSpent': FieldValue.increment(amount),
        'lastUpdated': FieldValue.serverTimestamp(),
      });
      
      // Record transaction
      await _recordTransaction(
        userId: userId,
        amount: -amount,
        type: DiamondTransactionType.roomCreation,
        description: description ?? 'Room creation',
        gameId: gameId,
      );
      
      return true;
    } catch (e) {
      debugPrint('Error deducting diamonds: $e');
      return false;
    }
  }

  /// Add diamonds to user's wallet (for purchases, bonuses, refunds)
  Future<void> addDiamonds(
    String userId, 
    int amount, 
    DiamondTransactionType type, {
    String? description,
  }) async {
    try {
      await _db.collection('wallets').doc(userId).update({
        'balance': FieldValue.increment(amount),
        'totalPurchased': type == DiamondTransactionType.purchase 
            ? FieldValue.increment(amount) 
            : FieldValue.increment(0),
        'lastUpdated': FieldValue.serverTimestamp(),
      });
      
      await _recordTransaction(
        userId: userId,
        amount: amount,
        type: type,
        description: description ?? type.name,
      );
    } catch (e) {
      debugPrint('Error adding diamonds: $e');
      rethrow;
    }
  }

  /// Record a diamond transaction for history
  Future<void> _recordTransaction({
    required String userId,
    required int amount,
    required DiamondTransactionType type,
    String? description,
    String? gameId,
  }) async {
    final transaction = DiamondTransaction(
      id: '', // Will be set by Firestore
      userId: userId,
      amount: amount,
      type: type,
      description: description,
      gameId: gameId,
      createdAt: DateTime.now(),
    );
    
    await _db.collection('transactions').add(transaction.toJson());
  }

  /// Get transaction history for a user
  Future<List<DiamondTransaction>> getTransactionHistory(String userId, {int limit = 50}) async {
    try {
      final snapshot = await _db
          .collection('transactions')
          .where('userId', isEqualTo: userId)
          .orderBy('createdAt', descending: true)
          .limit(limit)
          .get();
      
      return snapshot.docs
          .map((doc) => DiamondTransaction.fromJson(doc.data()))
          .toList();
    } catch (e) {
      debugPrint('Error getting transaction history: $e');
      return [];
    }
  }

  /// Validate and process room creation (check balance AND deduct)
  Future<bool> processRoomCreation(String userId, String gameId) async {
    return await deductDiamonds(
      userId, 
      roomCreationCost,
      description: 'Created game room',
      gameId: gameId,
    );
  }

  /// Refund diamonds (for cancelled room, etc.)
  Future<void> refundDiamonds(String userId, int amount, String reason) async {
    await addDiamonds(
      userId,
      amount,
      DiamondTransactionType.refund,
      description: reason,
    );
  }
}
