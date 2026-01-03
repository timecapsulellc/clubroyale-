import 'package:flutter/material.dart';
import 'package:clubroyale/main.dart';

/// Service to show toast messages/snackbars across the app
class ToastService {
  static void show(String message, {bool isError = false}) {
    final state = rootScaffoldMessengerKey.currentState;
    if (state == null) return;

    state.showSnackBar(
      SnackBar(
        content: Text(message, style: const TextStyle(color: Colors.white)),
        backgroundColor: isError ? Colors.red.shade700 : Colors.green.shade700,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  static void showError(String message) {
    show(message, isError: true);
  }

  static void showSuccess(String message) {
    show(message, isError: false);
  }
}
