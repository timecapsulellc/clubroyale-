/// Bot Diamond Management Service
///
/// Handles automatic diamond funding for bots and agents, and sweeps
/// profits back to the admin account after games.
library;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Provider for BotDiamondService
final botDiamondServiceProvider = Provider<BotDiamondService>((ref) {
  return BotDiamondService();
});

/// Configuration for bot diamond management
class BotDiamondConfig {
  /// Minimum diamonds a bot should have to play
  static const int minimumBalance = 1000;

  /// Amount to top-up when bot is low on diamonds
  static const int topUpAmount = 5000;

  /// Admin user ID that receives bot profits
  static const String adminUserId = 'admin_treasury';

  /// Threshold above which profits are swept to admin
  static const int profitSweepThreshold = 10000;

  /// Bot ID prefixes for identification
  static const List<String> botPrefixes = ['bot_', 'agent_', 'ai_'];

  /// Check if a userId belongs to a bot
  static bool isBot(String userId) {
    return botPrefixes.any((prefix) => userId.startsWith(prefix));
  }
}

/// Service for managing bot/agent diamond balances
class BotDiamondService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // ========== BOT BALANCE MANAGEMENT ==========

  /// Get bot's current diamond balance
  Future<int> getBotBalance(String botId) async {
    final doc = await _db.collection('bot_wallets').doc(botId).get();
    return doc.data()?['diamonds'] ?? 0;
  }

  /// Ensure bot has enough diamonds to play
  /// Returns true if bot was funded, false if already had enough
  Future<bool> ensureBotFunded(String botId, {int? requiredAmount}) async {
    final required = requiredAmount ?? BotDiamondConfig.minimumBalance;

    try {
      return await _db.runTransaction<bool>((txn) async {
        final botRef = _db.collection('bot_wallets').doc(botId);
        final doc = await txn.get(botRef);

        final currentBalance = doc.data()?['diamonds'] ?? 0;

        if (currentBalance >= required) {
          return false; // Already has enough
        }

        // Top up the bot
        final topUp = BotDiamondConfig.topUpAmount;
        final newBalance = currentBalance + topUp;

        txn.set(botRef, {
          'diamonds': newBalance,
          'lastFunded': FieldValue.serverTimestamp(),
          'isBot': true,
          'createdAt': doc.exists
              ? (doc.data()?['createdAt'] ?? FieldValue.serverTimestamp())
              : FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));

        // Record the funding transaction
        final txRef = _db.collection('bot_transactions').doc();
        txn.set(txRef, {
          'botId': botId,
          'type': 'funding',
          'amount': topUp,
          'previousBalance': currentBalance,
          'newBalance': newBalance,
          'source': 'system_top_up',
          'timestamp': FieldValue.serverTimestamp(),
        });

        debugPrint(
          '💎 Bot $botId funded: +$topUp diamonds (new balance: $newBalance)',
        );
        return true;
      });
    } catch (e) {
      debugPrint('Error funding bot $botId: $e');
      return false;
    }
  }

  /// Add diamonds to bot (after winning)
  Future<void> addBotDiamonds(String botId, int amount, String reason) async {
    if (amount <= 0) return;

    try {
      final botRef = _db.collection('bot_wallets').doc(botId);

      await _db.runTransaction((txn) async {
        final doc = await txn.get(botRef);
        final currentBalance = doc.data()?['diamonds'] ?? 0;
        final newBalance = currentBalance + amount;

        txn.set(botRef, {
          'diamonds': newBalance,
          'lastWin': FieldValue.serverTimestamp(),
          'totalWinnings': FieldValue.increment(amount),
        }, SetOptions(merge: true));

        // Record transaction
        final txRef = _db.collection('bot_transactions').doc();
        txn.set(txRef, {
          'botId': botId,
          'type': 'win',
          'amount': amount,
          'reason': reason,
          'previousBalance': currentBalance,
          'newBalance': newBalance,
          'timestamp': FieldValue.serverTimestamp(),
        });
      });

      debugPrint('💎 Bot $botId won: +$amount diamonds');

      // Check if profit sweep is needed
      await _checkAndSweepProfits(botId);
    } catch (e) {
      debugPrint('Error adding diamonds to bot $botId: $e');
    }
  }

  /// Deduct diamonds from bot (for game entry, losses)
  Future<bool> deductBotDiamonds(
    String botId,
    int amount,
    String reason,
  ) async {
    if (amount <= 0) return true;

    try {
      return await _db.runTransaction<bool>((txn) async {
        final botRef = _db.collection('bot_wallets').doc(botId);
        final doc = await txn.get(botRef);
        final currentBalance = doc.data()?['diamonds'] ?? 0;

        if (currentBalance < amount) {
          // Not enough - try to fund first
          return false;
        }

        final newBalance = currentBalance - amount;

        txn.update(botRef, {
          'diamonds': newBalance,
          'lastSpend': FieldValue.serverTimestamp(),
        });

        // Record transaction
        final txRef = _db.collection('bot_transactions').doc();
        txn.set(txRef, {
          'botId': botId,
          'type': 'spend',
          'amount': -amount,
          'reason': reason,
          'previousBalance': currentBalance,
          'newBalance': newBalance,
          'timestamp': FieldValue.serverTimestamp(),
        });

        return true;
      });
    } catch (e) {
      debugPrint('Error deducting diamonds from bot $botId: $e');
      return false;
    }
  }

  // ========== PROFIT SWEEPING ==========

  /// Check if bot has excess profits and sweep to admin
  Future<void> _checkAndSweepProfits(String botId) async {
    try {
      final doc = await _db.collection('bot_wallets').doc(botId).get();
      final balance = doc.data()?['diamonds'] ?? 0;

      if (balance > BotDiamondConfig.profitSweepThreshold) {
        // Keep minimum, sweep the rest to admin
        final sweepAmount = balance - BotDiamondConfig.minimumBalance;
        await sweepProfitsToAdmin(botId, sweepAmount);
      }
    } catch (e) {
      debugPrint('Error checking profits for bot $botId: $e');
    }
  }

  /// Sweep profits from bot to admin treasury
  Future<void> sweepProfitsToAdmin(String botId, int amount) async {
    if (amount <= 0) return;

    try {
      await _db.runTransaction((txn) async {
        final botRef = _db.collection('bot_wallets').doc(botId);
        final adminRef = _db
            .collection('users')
            .doc(BotDiamondConfig.adminUserId);

        // Deduct from bot
        final botDoc = await txn.get(botRef);
        final botBalance = botDoc.data()?['diamonds'] ?? 0;

        if (botBalance < amount) {
          throw Exception('Bot has insufficient balance for sweep');
        }

        txn.update(botRef, {
          'diamonds': botBalance - amount,
          'lastSweep': FieldValue.serverTimestamp(),
          'totalSwept': FieldValue.increment(amount),
        });

        // Add to admin
        txn.set(adminRef, {
          'diamonds': FieldValue.increment(amount),
          'lastBotSweep': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));

        // Record the sweep transaction
        final txRef = _db.collection('bot_profit_sweeps').doc();
        txn.set(txRef, {
          'botId': botId,
          'amount': amount,
          'adminId': BotDiamondConfig.adminUserId,
          'timestamp': FieldValue.serverTimestamp(),
        });
      });

      debugPrint('💎 Swept $amount diamonds from bot $botId to admin treasury');
    } catch (e) {
      debugPrint('Error sweeping profits from bot $botId: $e');
    }
  }

  // ========== BATCH OPERATIONS ==========

  /// Fund all bots in a game room
  Future<void> fundBotsInRoom(List<String> playerIds) async {
    for (final playerId in playerIds) {
      if (BotDiamondConfig.isBot(playerId)) {
        await ensureBotFunded(playerId);
      }
    }
  }

  /// Process game results for bots (add winnings, deduct losses)
  Future<void> processGameResultsForBots(Map<String, int> playerResults) async {
    for (final entry in playerResults.entries) {
      if (BotDiamondConfig.isBot(entry.key)) {
        if (entry.value > 0) {
          await addBotDiamonds(entry.key, entry.value, 'game_winnings');
        } else if (entry.value < 0) {
          // Losses are already deducted during game, just log
          debugPrint('💎 Bot ${entry.key} lost ${entry.value.abs()} diamonds');
        }
      }
    }
  }

  /// Manually sweep all bot profits (for admin use)
  Future<Map<String, int>> sweepAllBotProfits() async {
    final results = <String, int>{};

    try {
      final botsSnapshot = await _db
          .collection('bot_wallets')
          .where(
            'diamonds',
            isGreaterThan: BotDiamondConfig.profitSweepThreshold,
          )
          .get();

      for (final doc in botsSnapshot.docs) {
        final botId = doc.id;
        final balance = doc.data()['diamonds'] as int? ?? 0;
        final sweepAmount = balance - BotDiamondConfig.minimumBalance;

        if (sweepAmount > 0) {
          await sweepProfitsToAdmin(botId, sweepAmount);
          results[botId] = sweepAmount;
        }
      }

      debugPrint('💎 Swept profits from ${results.length} bots');
    } catch (e) {
      debugPrint('Error sweeping all bot profits: $e');
    }

    return results;
  }

  // ========== STATS & REPORTING ==========

  /// Get total diamonds held by all bots
  Future<int> getTotalBotDiamonds() async {
    try {
      final snapshot = await _db.collection('bot_wallets').get();
      int total = 0;
      for (final doc in snapshot.docs) {
        total += (doc.data()['diamonds'] as int?) ?? 0;
      }
      return total;
    } catch (e) {
      debugPrint('Error getting total bot diamonds: $e');
      return 0;
    }
  }

  /// Get bot wallet details
  Future<Map<String, dynamic>?> getBotWalletDetails(String botId) async {
    try {
      final doc = await _db.collection('bot_wallets').doc(botId).get();
      return doc.data();
    } catch (e) {
      debugPrint('Error getting bot wallet: $e');
      return null;
    }
  }
}
