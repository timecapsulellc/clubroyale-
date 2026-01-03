import 'package:flutter/material.dart';

/// User Tiers for Diamond Economy V5
enum UserTier {
  basic,
  verified,
  trusted,
  leader,
  ambassador;

  String get displayName {
    switch (this) {
      case UserTier.basic:
        return 'Basic';
      case UserTier.verified:
        return 'Verified';
      case UserTier.trusted:
        return 'Trusted';
      case UserTier.leader:
        return 'Leader';
      case UserTier.ambassador:
        return 'Ambassador';
    }
  }

  Color get color {
    switch (this) {
      case UserTier.basic:
        return Colors.grey;
      case UserTier.verified:
        return Colors.blue;
      case UserTier.trusted:
        return Colors.green;
      case UserTier.leader:
        return Colors.purple;
      case UserTier.ambassador:
        return Colors.orange;
    }
  }

  /// Can the user transfer diamonds to others?
  bool get canTransfer => this != UserTier.basic;

  /// Daily earning cap (-1 for unlimited)
  int get dailyEarningCap {
    switch (this) {
      case UserTier.basic:
        return 200;
      case UserTier.verified:
        return 1000;
      case UserTier.trusted:
        return 5000;
      case UserTier.leader:
        return 20000;
      case UserTier.ambassador:
        return -1;
    }
  }

  /// Daily transfer limit (-1 for unlimited)
  int get dailyTransferLimit {
    switch (this) {
      case UserTier.basic:
        return 0; // Disabled
      case UserTier.verified:
        return 500;
      case UserTier.trusted:
        return 5000;
      case UserTier.leader:
        return 50000;
      case UserTier.ambassador:
        return -1;
    }
  }
}
