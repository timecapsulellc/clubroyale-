// Diamond Service (FREE - No Purchases)
//
// Diamonds are FREE platform credits earned through:
// - Sign up bonus
// - Daily login
// - Game completion
// - Referrals
// - Watching optional ads
//
// Diamonds have NO real-world value and CANNOT be purchased.

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Diamond reward types
enum DiamondRewardType {
  signUpBonus,
  dailyLogin,
  gameComplete,
  referral,
  weeklyBonus,
  watchAd,
}

/// Diamond reward amounts
class DiamondRewards {
  static const int signUpBonus = 100;
  static const int dailyLogin = 10;
  static const int gameComplete = 5;
  static const int referralBonus = 50;
  static const int weeklyBonus = 50;
  static const int watchAd = 20;
  
  // Spending costs
  static const int createRoom = 10;
  static const int extendRoom = 5;
  static const int rematch = 5;
}

/// Diamond Service - Manages FREE diamond balance
class DiamondService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  // ============ GET BALANCE ============
  
  /// Get user's current diamond balance
  Future<int> getBalance(String userId) async {
    final doc = await _firestore.collection('users').doc(userId).get();
    return doc.data()?['diamonds'] ?? 0;
  }

  /// Watch balance changes
  Stream<int> watchBalance(String userId) {
    return _firestore
        .collection('users')
        .doc(userId)
        .snapshots()
        .map((doc) => doc.data()?['diamonds'] ?? 0);
  }
  
  // ============ EARN DIAMONDS (FREE) ============
  
  /// Grant sign up bonus (one-time)
  Future<bool> grantSignUpBonus(String userId) async {
    final userRef = _firestore.collection('users').doc(userId);
    
    return await _firestore.runTransaction<bool>((txn) async {
      final doc = await txn.get(userRef);
      final data = doc.data() ?? {};
      
      // Check if already claimed
      if (data['signUpBonusClaimed'] == true) {
        return false;
      }
      
      txn.update(userRef, {
        'diamonds': FieldValue.increment(DiamondRewards.signUpBonus),
        'signUpBonusClaimed': true,
        'signUpBonusAt': FieldValue.serverTimestamp(),
      });
      
      await _logReward(userId, DiamondRewardType.signUpBonus, DiamondRewards.signUpBonus);
      return true;
    });
  }
  
  /// Claim daily login bonus
  Future<bool> claimDailyLogin(String userId) async {
    final prefs = await SharedPreferences.getInstance();
    final lastClaimKey = 'daily_login_$userId';
    final lastClaim = prefs.getString(lastClaimKey);
    
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day).toIso8601String();
    
    // Check if already claimed today
    if (lastClaim == today) {
      return false;
    }
    
    // Grant diamonds
    await _addDiamonds(userId, DiamondRewards.dailyLogin, DiamondRewardType.dailyLogin);
    
    // Mark as claimed
    await prefs.setString(lastClaimKey, today);
    
    return true;
  }
  
  /// Check if daily login is available
  Future<bool> isDailyLoginAvailable(String userId) async {
    final prefs = await SharedPreferences.getInstance();
    final lastClaimKey = 'daily_login_$userId';
    final lastClaim = prefs.getString(lastClaimKey);
    
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day).toIso8601String();
    
    return lastClaim != today;
  }
  
  /// Grant game completion bonus
  Future<void> grantGameComplete(String userId) async {
    await _addDiamonds(userId, DiamondRewards.gameComplete, DiamondRewardType.gameComplete);
  }
  
  /// Grant referral bonus
  Future<void> grantReferralBonus(String referrerId, String newUserId) async {
    // Grant to referrer
    await _addDiamonds(referrerId, DiamondRewards.referralBonus, DiamondRewardType.referral);
    
    // Log referral
    await _firestore.collection('referrals').add({
      'referrerId': referrerId,
      'newUserId': newUserId,
      'diamondsGranted': DiamondRewards.referralBonus,
      'timestamp': FieldValue.serverTimestamp(),
    });
  }
  
  /// Grant weekly bonus (call from scheduled function)
  Future<void> grantWeeklyBonus(String userId) async {
    await _addDiamonds(userId, DiamondRewards.weeklyBonus, DiamondRewardType.weeklyBonus);
  }
  
  /// Grant ad watch reward
  Future<void> grantAdReward(String userId) async {
    await _addDiamonds(userId, DiamondRewards.watchAd, DiamondRewardType.watchAd);
  }
  
  // ============ SPEND DIAMONDS ============
  
  /// Spend diamonds (for room creation, etc.)
  Future<bool> spend(String userId, int amount, String reason) async {
    final userRef = _firestore.collection('users').doc(userId);
    
    try {
      return await _firestore.runTransaction<bool>((txn) async {
        final doc = await txn.get(userRef);
        
        // If user document doesn't exist, create it with signup bonus
        if (!doc.exists) {
          txn.set(userRef, {
            'diamonds': DiamondRewards.signUpBonus - amount,
            'signUpBonusClaimed': true,
            'createdAt': FieldValue.serverTimestamp(),
          });
          
          // Log spending (using separate write, not in transaction)
          await _firestore.collection('diamond_spending').add({
            'userId': userId,
            'amount': amount,
            'reason': reason,
            'timestamp': FieldValue.serverTimestamp(),
          });
          
          return true; // Success - created with bonus minus spent amount
        }
        
        final currentBalance = doc.data()?['diamonds'] ?? 0;
        
        if (currentBalance < amount) {
          return false; // Insufficient balance
        }
        
        txn.update(userRef, {
          'diamonds': currentBalance - amount,
        });
        
        return true;
      });
    } catch (e) {
      // If transaction fails, try simpler approach
      debugPrint('Transaction failed, trying direct approach: $e');
      try {
        await userRef.set({
          'diamonds': FieldValue.increment(-amount),
        }, SetOptions(merge: true));
        
        await _firestore.collection('diamond_spending').add({
          'userId': userId,
          'amount': amount,
          'reason': reason,
          'timestamp': FieldValue.serverTimestamp(),
        });
        
        return true;
      } catch (e2) {
        debugPrint('Direct approach also failed: $e2');
        return false;
      }
    }
  }
  
  /// Check if user can afford action
  Future<bool> canAfford(String userId, int cost) async {
    final balance = await getBalance(userId);
    return balance >= cost;
  }
  
  // ============ HELPERS ============
  
  Future<void> _addDiamonds(String userId, int amount, DiamondRewardType type) async {
    await _firestore.collection('users').doc(userId).update({
      'diamonds': FieldValue.increment(amount),
    });
    
    await _logReward(userId, type, amount);
  }
  
  Future<void> _logReward(String userId, DiamondRewardType type, int amount) async {
    await _firestore.collection('diamond_rewards').add({
      'userId': userId,
      'type': type.name,
      'amount': amount,
      'timestamp': FieldValue.serverTimestamp(),
    });
  }
  
  /// Get reward history
  Future<List<Map<String, dynamic>>> getRewardHistory(String userId) async {
    final snapshot = await _firestore
        .collection('diamond_rewards')
        .where('userId', isEqualTo: userId)
        .orderBy('timestamp', descending: true)
        .limit(50)
        .get();
    
    return snapshot.docs.map((d) => d.data()).toList();
  }
  
  // ============ TEST MODE ============
  
  /// Grant test diamonds for development/testing (10,000 diamonds)
  /// This should be removed or disabled in production
  Future<void> grantTestDiamonds(String userId, {int amount = 10000}) async {
    await _firestore.collection('users').doc(userId).set({
      'diamonds': FieldValue.increment(amount),
      'testDiamondsGranted': true,
      'testDiamondsAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
    
    await _firestore.collection('diamond_rewards').add({
      'userId': userId,
      'type': 'test_grant',
      'amount': amount,
      'timestamp': FieldValue.serverTimestamp(),
    });
    
    debugPrint('💎 Test diamonds granted: $amount to $userId');
  }
  
  /// Reset test diamonds (remove all diamonds from user)
  Future<void> resetTestDiamonds(String userId) async {
    await _firestore.collection('users').doc(userId).update({
      'diamonds': 0,
      'testDiamondsGranted': false,
    });
    
    debugPrint('💎 Test diamonds reset for $userId');
  }
}
