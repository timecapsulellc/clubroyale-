import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:taasclub/core/config/admin_config.dart';

/// Provider for admin diamond service
final adminDiamondServiceProvider = Provider<AdminDiamondService>(
  (ref) => AdminDiamondService(),
);

/// Service for admin diamond grant management
class AdminDiamondService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  /// Create a new grant request
  Future<String> createGrantRequest({
    required String adminEmail,
    required String targetUserId,
    required String targetUserEmail,
    required int amount,
    required String reason,
  }) async {
    // Validate admin
    if (!AdminConfig.isAdmin(adminEmail)) {
      throw Exception('Not authorized as admin');
    }

    // Sub-admins have limits
    if (AdminConfig.getRole(adminEmail) == AdminRole.sub &&
        amount > AdminConfig.subAdminMaxGrant) {
      throw Exception('Sub-admins can only grant up to ${AdminConfig.subAdminMaxGrant} diamonds');
    }

    final docRef = await _db.collection('diamond_requests').add({
      'targetUserId': targetUserId,
      'targetUserEmail': targetUserEmail,
      'amount': amount,
      'reason': reason,
      'requestedBy': adminEmail,
      'approvals': [adminEmail], // Creator auto-approves
      'rejections': <String>[],
      'status': _getInitialStatus(adminEmail, amount),
      'createdAt': FieldValue.serverTimestamp(),
      'coolingPeriodEnds': AdminConfig.requiresCoolingPeriod(amount)
          ? Timestamp.fromDate(DateTime.now().add(AdminConfig.coolingPeriod))
          : null,
      'executedAt': null,
    });

    // If single approval is enough and creator is primary admin, execute immediately
    if (AdminConfig.getRequiredApprovals(amount) == 1 &&
        AdminConfig.isPrimaryAdmin(adminEmail)) {
      await _executeGrant(docRef.id);
    }

    return docRef.id;
  }

  String _getInitialStatus(String adminEmail, int amount) {
    final requiredApprovals = AdminConfig.getRequiredApprovals(amount);
    
    if (requiredApprovals == 1 && AdminConfig.isPrimaryAdmin(adminEmail)) {
      return 'approved';
    }
    return 'pending';
  }

  /// Approve a grant request (different admin required for 2+ approval)
  Future<bool> approveRequest(String requestId, String adminEmail) async {
    if (!AdminConfig.isAdmin(adminEmail)) {
      throw Exception('Not authorized as admin');
    }

    final doc = await _db.collection('diamond_requests').doc(requestId).get();
    if (!doc.exists) throw Exception('Request not found');

    final data = doc.data()!;
    final approvals = List<String>.from(data['approvals'] ?? []);
    final amount = data['amount'] as int;
    final requestedBy = data['requestedBy'] as String;

    // Cannot approve own request for dual-approval amounts
    if (AdminConfig.getRequiredApprovals(amount) > 1 && requestedBy == adminEmail) {
      throw Exception('Cannot approve your own request for this amount');
    }

    // Already approved by this admin
    if (approvals.contains(adminEmail)) {
      throw Exception('Already approved by this admin');
    }

    approvals.add(adminEmail);

    final isFullyApproved = approvals.length >= AdminConfig.getRequiredApprovals(amount);
    final hasCoolingPeriod = AdminConfig.requiresCoolingPeriod(amount);
    
    String newStatus = 'pending';
    if (isFullyApproved) {
      newStatus = hasCoolingPeriod ? 'cooling_period' : 'approved';
    }

    await _db.collection('diamond_requests').doc(requestId).update({
      'approvals': approvals,
      'status': newStatus,
    });

    // Execute if approved and no cooling period
    if (newStatus == 'approved') {
      await _executeGrant(requestId);
    }

    return true;
  }

  /// Reject a grant request
  Future<bool> rejectRequest(String requestId, String adminEmail, String reason) async {
    if (!AdminConfig.isAdmin(adminEmail)) {
      throw Exception('Not authorized as admin');
    }

    await _db.collection('diamond_requests').doc(requestId).update({
      'status': 'rejected',
      'rejectedBy': adminEmail,
      'rejectionReason': reason,
      'rejectedAt': FieldValue.serverTimestamp(),
    });

    return true;
  }

  /// Get all pending requests
  Stream<List<DiamondRequest>> watchPendingRequests() {
    return _db
        .collection('diamond_requests')
        .where('status', whereIn: ['pending', 'cooling_period'])
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => DiamondRequest.fromFirestore(doc)).toList());
  }

  /// Get requests that a specific admin can approve
  Stream<List<DiamondRequest>> watchRequestsForAdmin(String adminEmail) {
    return watchPendingRequests().map((requests) => requests
        .where((r) => !r.approvals.contains(adminEmail))
        .where((r) => r.requestedBy != adminEmail || 
                      AdminConfig.getRequiredApprovals(r.amount) == 1)
        .toList());
  }

  /// Execute a grant (credit diamonds to user)
  Future<void> _executeGrant(String requestId) async {
    final doc = await _db.collection('diamond_requests').doc(requestId).get();
    if (!doc.exists) throw Exception('Request not found');

    final data = doc.data()!;
    final targetUserId = data['targetUserId'] as String;
    final amount = data['amount'] as int;

    // Use batch for atomicity
    final batch = _db.batch();

    // Update wallet balance
    final walletRef = _db.collection('wallets').doc(targetUserId);
    batch.update(walletRef, {
      'balance': FieldValue.increment(amount),
      'totalPurchased': FieldValue.increment(amount),
      'lastUpdated': FieldValue.serverTimestamp(),
    });

    // Record transaction
    final txRef = _db.collection('transactions').doc();
    batch.set(txRef, {
      'userId': targetUserId,
      'amount': amount,
      'type': 'admin_grant',
      'description': 'Admin diamond grant',
      'grantRequestId': requestId,
      'createdAt': FieldValue.serverTimestamp(),
    });

    // Update request status
    final requestRef = _db.collection('diamond_requests').doc(requestId);
    batch.update(requestRef, {
      'status': 'executed',
      'executedAt': FieldValue.serverTimestamp(),
    });

    await batch.commit();
    debugPrint('Grant executed: $amount diamonds to $targetUserId');
  }

  /// Execute grants that have passed cooling period (called by Cloud Function)
  Future<void> executeCooledGrants() async {
    final now = Timestamp.now();
    final snapshot = await _db
        .collection('diamond_requests')
        .where('status', isEqualTo: 'cooling_period')
        .where('coolingPeriodEnds', isLessThan: now)
        .get();

    for (final doc in snapshot.docs) {
      await _executeGrant(doc.id);
    }
  }
}

/// Diamond grant request model
class DiamondRequest {
  final String id;
  final String targetUserId;
  final String targetUserEmail;
  final int amount;
  final String reason;
  final String requestedBy;
  final List<String> approvals;
  final String status;
  final DateTime? createdAt;
  final DateTime? coolingPeriodEnds;

  DiamondRequest({
    required this.id,
    required this.targetUserId,
    required this.targetUserEmail,
    required this.amount,
    required this.reason,
    required this.requestedBy,
    required this.approvals,
    required this.status,
    this.createdAt,
    this.coolingPeriodEnds,
  });

  factory DiamondRequest.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return DiamondRequest(
      id: doc.id,
      targetUserId: data['targetUserId'] ?? '',
      targetUserEmail: data['targetUserEmail'] ?? '',
      amount: data['amount'] ?? 0,
      reason: data['reason'] ?? '',
      requestedBy: data['requestedBy'] ?? '',
      approvals: List<String>.from(data['approvals'] ?? []),
      status: data['status'] ?? 'pending',
      createdAt: (data['createdAt'] as Timestamp?)?.toDate(),
      coolingPeriodEnds: (data['coolingPeriodEnds'] as Timestamp?)?.toDate(),
    );
  }

  int get approvalsRemaining =>
      AdminConfig.getRequiredApprovals(amount) - approvals.length;
}
