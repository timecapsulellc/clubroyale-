/// Pull-to-Refresh Utilities
///
/// Provides reusable pull-to-refresh patterns with haptic feedback
library;

import 'package:flutter/material.dart';
import 'haptic_helper.dart';

/// Simple refresh callback mixin for StatefulWidgets
mixin RefreshableMixin<T extends StatefulWidget> on State<T> {
  bool _isRefreshing = false;

  bool get isRefreshing => _isRefreshing;

  /// Handle refresh with haptic feedback and loading state
  Future<void> handleRefresh(Future<void> Function() refreshCallback) async {
    if (_isRefreshing) return;

    setState(() => _isRefreshing = true);
    HapticHelper.lightTap();

    try {
      await refreshCallback();
    } finally {
      if (mounted) {
        setState(() => _isRefreshing = false);
      }
    }
  }
}

/// Builder function for creating RefreshIndicator with haptic feedback
Widget buildHapticRefreshIndicator({
  required Future<void> Function() onRefresh,
  required Widget child,
  Color? color,
}) {
  return RefreshIndicator(
    onRefresh: () async {
      HapticHelper.lightTap();
      await onRefresh();
    },
    color: color,
    child: child,
  );
}

/// Extension for wrapping ListView with pull-to-refresh
extension RefreshableListExtension on ListView {
  Widget withPullToRefresh({
    required Future<void> Function() onRefresh,
    Color? color,
  }) {
    return RefreshIndicator(
      onRefresh: () async {
        HapticHelper.lightTap();
        await onRefresh();
      },
      color: color,
      child: this,
    );
  }
}
