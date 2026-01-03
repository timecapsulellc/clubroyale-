import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:clubroyale/features/wallet/diamond_wallet.dart';

final diamondServiceProvider = Provider<DiamondService>(
  (ref) => DiamondService(),
);

/// Service for managing diamond currency (virtual currency for monetization)
class DiamondService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseFunctions _functions = FirebaseFunctions.instance;

  /// Get user's diamond wallet (now from 'users' collection)
  Future<DiamondWallet> getWallet(String userId) async {
    try {
      final doc = await _db.collection('users').doc(userId).get();

      if (!doc.exists) {
        // In V5, user document should exist.
        // If not, we return a default wallet (safe fallback)
        return DiamondWallet(userId: userId);
      }

      // Map 'users' fields to DiamondWallet
      // We assume data has been migrated or new user created correctly
      final data = doc.data()!;
      // Handle legacy 'balance' vs new 'diamondBalance'
      final balance = data['diamondBalance'] ?? data['balance'] ?? 0;

      return DiamondWallet.fromJson({
        ...data,
        'userId': userId,
        'balance': balance,
      });
    } catch (e) {
      debugPrint('Error getting wallet: $e');
      rethrow;
    }
  }

  /// Stream user's wallet for real-time updates
  Stream<DiamondWallet> watchWallet(String userId) {
    return _db.collection('users').doc(userId).snapshots().map((doc) {
      if (!doc.exists) {
        return DiamondWallet(userId: userId);
      }
      final data = doc.data()!;
      final balance = data['diamondBalance'] ?? data['balance'] ?? 0;
      return DiamondWallet.fromJson({
        ...data,
        'userId': userId,
        'balance': balance,
      });
    });
  }

  /// Check if user has enough diamonds
  Future<bool> hasEnoughDiamonds(String userId, int amount) async {
    final wallet = await getWallet(userId);
    return wallet.balance >= amount;
  }

  // ============ CLIENT-SIDE ACTIONS (Legacy/Simple) ============

  /// Deduct diamonds locally (for Room Creation)
  /// Note: Ideally this should also be a Cloud Function to enforce limits strictly,
  /// but for V5 Phase A we keep it client-side with 'users' collection update.
  Future<bool> deductDiamonds(
    String userId,
    int amount, {
    String? description,
    String? gameId,
  }) async {
    try {
      // Validate amount is positive (prevent exploits)
      if (amount <= 0) {
        debugPrint('Invalid deduction amount: $amount (must be positive)');
        return false;
      }

      final wallet = await getWallet(userId);

      if (wallet.balance < amount) {
        return false; // Insufficient balance
      }

      // Update users collection
      await _db.collection('users').doc(userId).update({
        'diamondBalance': FieldValue.increment(-amount),
        'diamondsByOrigin.spent': FieldValue.increment(
          amount,
        ), // Track spending
        'lastActive': FieldValue.serverTimestamp(),
      });

      // Record transaction (Legacy collection for client-side history)
      // V5 Main ledger is processed by Cloud Functions, but we can keep 'transactions' for UI history
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

  /// Grant development diamonds for testing (DEBUG ONLY)
  /// This sets the user's diamond balance to the specified amount
  /// IMPORTANT: This should ONLY be used in development/testing environments
  Future<bool> grantDevDiamonds(String userId, {int amount = 10000}) async {
    // Safety check - only allow in debug mode
    if (!kDebugMode) {
      debugPrint('⚠️ grantDevDiamonds blocked - not in debug mode');
      return false;
    }

    try {
      debugPrint('💎 Granting $amount dev diamonds to user: $userId');

      await _db.collection('users').doc(userId).set({
        'diamondBalance': amount,
        'diamondsByOrigin': {'signup': amount, 'spent': 0},
        'lastActive': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      // Record transaction for transparency
      await _recordTransaction(
        userId: userId,
        amount: amount,
        type: DiamondTransactionType.signup,
        description: 'Dev Testing Grant',
      );

      debugPrint('✅ Successfully granted $amount diamonds to $userId');
      return true;
    } catch (e) {
      debugPrint('❌ Error granting dev diamonds: $e');
      return false;
    }
  }

  // ============ CLOUD FUNCTIONS (V5) ============

  /// Upgrade to Verified Tier (Calls Cloud Function)
  Future<void> upgradeToVerified() async {
    try {
      final callable = _functions.httpsCallable('upgradeToVerified');
      await callable.call();
      // Success means no exception thrown
    } catch (e) {
      debugPrint('Error upgrading tier: $e');
      rethrow;
    }
  }

  /// Transfer Diamonds P2P (Calls Cloud Function)
  Future<void> transferDiamonds(
    String toUserId,
    int amount, {
    String? message,
  }) async {
    try {
      final callable = _functions.httpsCallable('validateTransfer');
      await callable.call({
        'receiverId': toUserId,
        'amount': amount,
        'message': message,
      });
    } catch (e) {
      debugPrint('Error transferring diamonds: $e');
      rethrow;
    }
  }

  /// Claim Daily Login (Calls Cloud Function)
  Future<Map<String, dynamic>> claimDailyLogin() async {
    try {
      final callable = _functions.httpsCallable('claimDailyLogin');
      final result = await callable.call();
      return Map<String, dynamic>.from(result.data as Map);
    } catch (e) {
      debugPrint('Error claiming daily login: $e');
      rethrow;
    }
  }

  /// Grant Gameplay Reward (Calls Cloud Function)
  /// [result] e.g., 'win', 'second', 'participation'
  Future<void> grantGameplayReward(
    String gameType,
    String result,
    String gameId,
  ) async {
    try {
      final callable = _functions.httpsCallable('grantGameplayReward');
      await callable.call({
        'gameType': gameType,
        'result': result,
        'gameId': gameId,
      });
    } catch (e) {
      debugPrint('Error granting reward: $e');
      // Warning: Don't rethrow indiscriminately for gameplay to avoid blocking UI flow,
      // but maybe log it remotely.
    }
  }

  // ============ HELPERS ============

  /// Record a diamond transaction for history (Client-side mirror)
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
  Future<List<DiamondTransaction>> getTransactionHistory(
    String userId, {
    int limit = 50,
  }) async {
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
}
