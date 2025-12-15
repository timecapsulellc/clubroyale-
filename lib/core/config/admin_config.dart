/// Admin Configuration for Diamond Economy
/// 
/// Defines admin emails, approval thresholds, and permissions.
library;

class AdminConfig {
  /// Primary admin emails with full permissions
  static const List<String> primaryAdmins = [
    'eonnodeai@gmail.com',
    'p2pexchange.io@gmail.com',
  ];

  /// Sub-admin emails (can be added by primary admins)
  /// Limited to grants < 500 diamonds
  static List<String> subAdmins = [];

  /// Check if email is any type of admin
  static bool isAdmin(String email) {
    return primaryAdmins.contains(email.toLowerCase()) ||
        subAdmins.contains(email.toLowerCase());
  }

  /// Check if email is a primary admin
  static bool isPrimaryAdmin(String email) {
    return primaryAdmins.contains(email.toLowerCase());
  }

  /// Get admin role
  static AdminRole getRole(String email) {
    if (primaryAdmins.contains(email.toLowerCase())) {
      return AdminRole.primary;
    }
    if (subAdmins.contains(email.toLowerCase())) {
      return AdminRole.sub;
    }
    return AdminRole.none;
  }

  // ============ APPROVAL THRESHOLDS ============

  /// Grants below this amount need only 1 admin approval
  static const int singleApprovalLimit = 999;

  /// Grants below this amount need 2 admin approvals
  static const int dualApprovalLimit = 9999;

  /// Grants >= 10000 need 2 admins + 24h cooling period
  static const int coolingPeriodThreshold = 10000;

  /// Cooling period duration for large grants
  static const Duration coolingPeriod = Duration(hours: 24);

  /// Sub-admin maximum grant limit
  static const int subAdminMaxGrant = 500;

  /// Get required approvals for an amount
  static int getRequiredApprovals(int amount) {
    if (amount < singleApprovalLimit) return 1;
    return 2;
  }

  /// Check if cooling period is required
  static bool requiresCoolingPeriod(int amount) {
    return amount >= coolingPeriodThreshold;
  }
}

/// Admin role types
enum AdminRole {
  primary, // Full permissions
  sub, // Limited permissions
  none, // Not an admin
}
