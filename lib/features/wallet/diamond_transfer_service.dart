import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:taasclub/core/config/diamond_config.dart';

/// Provider for diamond transfer service
final diamondTransferServiceProvider = Provider<DiamondTransferService>(
  (ref) => DiamondTransferService(),
);

/// Service for peer-to-peer diamond transfers
class DiamondTransferService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  /// Initiate a transfer (diamonds go to escrow)
  Future<TransferResult> initiateTransfer({
    required String fromUserId,
    required String fromUserName,
    required String toUserId,
    required String toUserName,
    required int amount,
    String? note,
  }) async {
    // Validate amount
    if (amount < DiamondConfig.minTransferAmount) {
      return TransferResult(
        success: false,
        reason: 'Minimum transfer is ${DiamondConfig.minTransferAmount} diamonds',
      );
    }

    if (amount > DiamondConfig.maxTransferAmount) {
      return TransferResult(
        success: false,
        reason: 'Maximum transfer is ${DiamondConfig.maxTransferAmount} diamonds',
      );
    }

    // Check sender balance
    final walletDoc = await _db.collection('wallets').doc(fromUserId).get();
    if (!walletDoc.exists) {
      return TransferResult(success: false, reason: 'Wallet not found');
    }

    final balance = walletDoc.data()!['balance'] as int? ?? 0;
    if (balance < amount) {
      return TransferResult(success: false, reason: 'Insufficient balance');
    }

    // Cannot transfer to self
    if (fromUserId == toUserId) {
      return TransferResult(success: false, reason: 'Cannot transfer to yourself');
    }

    // Create transfer and deduct from sender in a batch
    final batch = _db.batch();

    // Create transfer record
    final transferRef = _db.collection('diamond_transfers').doc();
    final expiresAt = DateTime.now().add(
      Duration(hours: DiamondConfig.transferExpiryHours),
    );

    batch.set(transferRef, {
      'fromUserId': fromUserId,
      'fromUserName': fromUserName,
      'toUserId': toUserId,
      'toUserName': toUserName,
      'amount': amount,
      'note': note,
      'status': 'pending',
      'senderConfirmed': true, // Sender confirms by initiating
      'receiverConfirmed': false,
      'createdAt': FieldValue.serverTimestamp(),
      'expiresAt': Timestamp.fromDate(expiresAt),
    });

    // Deduct from sender (escrow)
    batch.update(_db.collection('wallets').doc(fromUserId), {
      'balance': FieldValue.increment(-amount),
      'escrowedBalance': FieldValue.increment(amount),
      'lastUpdated': FieldValue.serverTimestamp(),
    });

    await batch.commit();

    return TransferResult(success: true, transferId: transferRef.id);
  }

  /// Confirm receiving a transfer (receiver action)
  Future<TransferResult> confirmAsReceiver(String transferId, String userId) async {
    final doc = await _db.collection('diamond_transfers').doc(transferId).get();
    if (!doc.exists) {
      return TransferResult(success: false, reason: 'Transfer not found');
    }

    final data = doc.data()!;
    
    if (data['toUserId'] != userId) {
      return TransferResult(success: false, reason: 'Not the receiver of this transfer');
    }

    if (data['status'] != 'pending') {
      return TransferResult(success: false, reason: 'Transfer is not pending');
    }

    // Check expiry
    final expiresAt = (data['expiresAt'] as Timestamp).toDate();
    if (DateTime.now().isAfter(expiresAt)) {
      return TransferResult(success: false, reason: 'Transfer has expired');
    }

    // Update receiver confirmation
    await _db.collection('diamond_transfers').doc(transferId).update({
      'receiverConfirmed': true,
    });

    // Complete the transfer
    return _completeTransfer(transferId);
  }

  /// Complete a transfer (both confirmed)
  Future<TransferResult> _completeTransfer(String transferId) async {
    final doc = await _db.collection('diamond_transfers').doc(transferId).get();
    if (!doc.exists) {
      return TransferResult(success: false, reason: 'Transfer not found');
    }

    final data = doc.data()!;
    final fromUserId = data['fromUserId'] as String;
    final toUserId = data['toUserId'] as String;
    final amount = data['amount'] as int;

    final batch = _db.batch();

    // Remove from sender's escrow
    batch.update(_db.collection('wallets').doc(fromUserId), {
      'escrowedBalance': FieldValue.increment(-amount),
      'totalTransferredOut': FieldValue.increment(amount),
      'lastUpdated': FieldValue.serverTimestamp(),
    });

    // Credit to receiver
    batch.update(_db.collection('wallets').doc(toUserId), {
      'balance': FieldValue.increment(amount),
      'totalTransferredIn': FieldValue.increment(amount),
      'lastUpdated': FieldValue.serverTimestamp(),
    });

    // Update transfer status
    batch.update(_db.collection('diamond_transfers').doc(transferId), {
      'status': 'completed',
      'completedAt': FieldValue.serverTimestamp(),
    });

    // Record transactions for both parties
    final senderTxRef = _db.collection('transactions').doc();
    batch.set(senderTxRef, {
      'userId': fromUserId,
      'amount': -amount,
      'type': 'transfer_out',
      'description': 'Sent to ${data['toUserName']}',
      'transferId': transferId,
      'createdAt': FieldValue.serverTimestamp(),
    });

    final receiverTxRef = _db.collection('transactions').doc();
    batch.set(receiverTxRef, {
      'userId': toUserId,
      'amount': amount,
      'type': 'transfer_in',
      'description': 'Received from ${data['fromUserName']}',
      'transferId': transferId,
      'createdAt': FieldValue.serverTimestamp(),
    });

    await batch.commit();
    debugPrint('Transfer completed: $amount diamonds from $fromUserId to $toUserId');

    return TransferResult(success: true, transferId: transferId);
  }

  /// Cancel a pending transfer (sender can cancel)
  Future<TransferResult> cancelTransfer(String transferId, String userId) async {
    final doc = await _db.collection('diamond_transfers').doc(transferId).get();
    if (!doc.exists) {
      return TransferResult(success: false, reason: 'Transfer not found');
    }

    final data = doc.data()!;
    
    if (data['fromUserId'] != userId) {
      return TransferResult(success: false, reason: 'Only sender can cancel');
    }

    if (data['status'] != 'pending') {
      return TransferResult(success: false, reason: 'Transfer is not pending');
    }

    final amount = data['amount'] as int;

    final batch = _db.batch();

    // Return from escrow to balance
    batch.update(_db.collection('wallets').doc(userId), {
      'balance': FieldValue.increment(amount),
      'escrowedBalance': FieldValue.increment(-amount),
      'lastUpdated': FieldValue.serverTimestamp(),
    });

    // Update transfer status
    batch.update(_db.collection('diamond_transfers').doc(transferId), {
      'status': 'cancelled',
      'cancelledAt': FieldValue.serverTimestamp(),
    });

    await batch.commit();

    return TransferResult(success: true, transferId: transferId);
  }

  /// Get pending incoming transfers for a user
  Stream<List<DiamondTransfer>> watchIncomingTransfers(String userId) {
    return _db
        .collection('diamond_transfers')
        .where('toUserId', isEqualTo: userId)
        .where('status', isEqualTo: 'pending')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => DiamondTransfer.fromFirestore(doc)).toList());
  }

  /// Get pending outgoing transfers for a user
  Stream<List<DiamondTransfer>> watchOutgoingTransfers(String userId) {
    return _db
        .collection('diamond_transfers')
        .where('fromUserId', isEqualTo: userId)
        .where('status', isEqualTo: 'pending')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => DiamondTransfer.fromFirestore(doc)).toList());
  }

  /// Get transfer history for a user
  Stream<List<DiamondTransfer>> watchTransferHistory(String userId, {int limit = 50}) {
    return _db
        .collection('diamond_transfers')
        .where('participantIds', arrayContains: userId)
        .orderBy('createdAt', descending: true)
        .limit(limit)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => DiamondTransfer.fromFirestore(doc)).toList());
  }

  /// Expire stale transfers (called by Cloud Function)
  Future<int> expireStaleTransfers() async {
    final now = Timestamp.now();
    final staleTransfers = await _db
        .collection('diamond_transfers')
        .where('status', isEqualTo: 'pending')
        .where('expiresAt', isLessThan: now)
        .get();

    int expiredCount = 0;

    for (final doc in staleTransfers.docs) {
      final data = doc.data();
      final fromUserId = data['fromUserId'] as String;
      final amount = data['amount'] as int;

      final batch = _db.batch();

      // Return from escrow
      batch.update(_db.collection('wallets').doc(fromUserId), {
        'balance': FieldValue.increment(amount),
        'escrowedBalance': FieldValue.increment(-amount),
        'lastUpdated': FieldValue.serverTimestamp(),
      });

      // Update status
      batch.update(doc.reference, {
        'status': 'expired',
        'expiredAt': FieldValue.serverTimestamp(),
      });

      await batch.commit();
      expiredCount++;
    }

    debugPrint('Expired $expiredCount stale transfers');
    return expiredCount;
  }

  /// Search for a user to transfer to
  Future<List<TransferRecipient>> searchUsers(String query) async {
    if (query.length < 2) return [];

    // Search by display name (case-insensitive requires additional setup)
    final snapshot = await _db
        .collection('users')
        .where('displayName', isGreaterThanOrEqualTo: query)
        .where('displayName', isLessThanOrEqualTo: '$query\uf8ff')
        .limit(10)
        .get();

    return snapshot.docs.map((doc) {
      final data = doc.data();
      return TransferRecipient(
        userId: doc.id,
        displayName: data['displayName'] ?? 'Unknown',
        photoUrl: data['photoUrl'],
      );
    }).toList();
  }
}

/// Transfer result
class TransferResult {
  final bool success;
  final String? transferId;
  final String? reason;

  TransferResult({
    required this.success,
    this.transferId,
    this.reason,
  });
}

/// Diamond transfer model
class DiamondTransfer {
  final String id;
  final String fromUserId;
  final String fromUserName;
  final String toUserId;
  final String toUserName;
  final int amount;
  final String? note;
  final String status;
  final bool senderConfirmed;
  final bool receiverConfirmed;
  final DateTime? createdAt;
  final DateTime? expiresAt;

  DiamondTransfer({
    required this.id,
    required this.fromUserId,
    required this.fromUserName,
    required this.toUserId,
    required this.toUserName,
    required this.amount,
    this.note,
    required this.status,
    required this.senderConfirmed,
    required this.receiverConfirmed,
    this.createdAt,
    this.expiresAt,
  });

  factory DiamondTransfer.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return DiamondTransfer(
      id: doc.id,
      fromUserId: data['fromUserId'] ?? '',
      fromUserName: data['fromUserName'] ?? '',
      toUserId: data['toUserId'] ?? '',
      toUserName: data['toUserName'] ?? '',
      amount: data['amount'] ?? 0,
      note: data['note'],
      status: data['status'] ?? 'pending',
      senderConfirmed: data['senderConfirmed'] ?? false,
      receiverConfirmed: data['receiverConfirmed'] ?? false,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate(),
      expiresAt: (data['expiresAt'] as Timestamp?)?.toDate(),
    );
  }

  String get timeRemaining {
    if (expiresAt == null) return 'Unknown';
    final remaining = expiresAt!.difference(DateTime.now());
    if (remaining.isNegative) return 'Expired';
    if (remaining.inHours > 24) return '${remaining.inDays}d remaining';
    if (remaining.inHours > 0) return '${remaining.inHours}h remaining';
    return '${remaining.inMinutes}m remaining';
  }
}

/// Transfer recipient for search results
class TransferRecipient {
  final String userId;
  final String displayName;
  final String? photoUrl;

  TransferRecipient({
    required this.userId,
    required this.displayName,
    this.photoUrl,
  });
}
