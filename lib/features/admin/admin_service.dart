import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:taasclub/core/config/admin_config.dart';

/// Provider for admin service
final adminServiceProvider = Provider<AdminService>((ref) => AdminService());

/// Service for admin authentication and permissions
class AdminService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  /// Check if a user email is an admin
  bool isAdmin(String email) {
    return AdminConfig.isAdmin(email);
  }

  /// Check if a user email is a primary admin
  bool isPrimaryAdmin(String email) {
    return AdminConfig.isPrimaryAdmin(email);
  }

  /// Get admin role for an email
  AdminRole getAdminRole(String email) {
    return AdminConfig.getRole(email);
  }

  /// Check if admin can approve a grant of given amount
  bool canApproveGrant(String email, int amount) {
    final role = AdminConfig.getRole(email);
    
    if (role == AdminRole.none) return false;
    
    if (role == AdminRole.sub) {
      return amount <= AdminConfig.subAdminMaxGrant;
    }
    
    return true; // Primary admin can approve any amount
  }

  /// Get all admins from Firestore (for dynamic admin list)
  Future<List<AdminUser>> getAllAdmins() async {
    final snapshot = await _db.collection('admins').get();
    return snapshot.docs.map((doc) => AdminUser.fromFirestore(doc)).toList();
  }

  /// Add a sub-admin (primary admins only)
  Future<bool> addSubAdmin(String primaryAdminEmail, String newAdminEmail) async {
    if (!AdminConfig.isPrimaryAdmin(primaryAdminEmail)) {
      return false;
    }

    await _db.collection('admins').doc(newAdminEmail).set({
      'email': newAdminEmail,
      'role': 'sub',
      'addedBy': primaryAdminEmail,
      'addedAt': FieldValue.serverTimestamp(),
      'permissions': ['grant_small'],
    });

    return true;
  }

  /// Remove a sub-admin (primary admins only)
  Future<bool> removeSubAdmin(String primaryAdminEmail, String adminEmail) async {
    if (!AdminConfig.isPrimaryAdmin(primaryAdminEmail)) {
      return false;
    }

    await _db.collection('admins').doc(adminEmail).delete();
    return true;
  }
}

/// Admin user model
class AdminUser {
  final String email;
  final String role;
  final String addedBy;
  final DateTime? addedAt;
  final List<String> permissions;

  AdminUser({
    required this.email,
    required this.role,
    required this.addedBy,
    this.addedAt,
    required this.permissions,
  });

  factory AdminUser.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return AdminUser(
      email: data['email'] ?? '',
      role: data['role'] ?? 'sub',
      addedBy: data['addedBy'] ?? '',
      addedAt: (data['addedAt'] as Timestamp?)?.toDate(),
      permissions: List<String>.from(data['permissions'] ?? []),
    );
  }
}
