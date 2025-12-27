/// Logging Service
/// 
/// Production-ready logging service that replaces debug prints.
/// Only logs in debug mode to prevent log pollution in production.
library;

import 'package:flutter/foundation.dart';

/// Log levels for categorizing messages
enum LogLevel {
  debug,
  info,
  warning,
  error,
}

/// Centralized logging service
class AppLogger {
  static const String _tag = 'ClubRoyale';
  
  /// Log a debug message (only in debug mode)
  static void debug(String message, {String? tag}) {
    if (kDebugMode) {
      debugPrint('[$_tag${tag != null ? ':$tag' : ''}] 🔍 $message');
    }
  }
  
  /// Log an info message
  static void info(String message, {String? tag}) {
    if (kDebugMode) {
      debugPrint('[$_tag${tag != null ? ':$tag' : ''}] ℹ️ $message');
    }
  }
  
  /// Log a warning message
  static void warning(String message, {String? tag}) {
    if (kDebugMode) {
      debugPrint('[$_tag${tag != null ? ':$tag' : ''}] ⚠️ $message');
    }
  }
  
  /// Log an error message (always logs, sends to Sentry in production)
  static void error(String message, {Object? error, StackTrace? stackTrace, String? tag}) {
    if (kDebugMode) {
      debugPrint('[$_tag${tag != null ? ':$tag' : ''}] ❌ $message');
      if (error != null) {
        debugPrint('  Error: $error');
      }
      if (stackTrace != null) {
        debugPrint('  Stack: $stackTrace');
      }
    }
    // In production, errors are captured by Sentry automatically
  }
  
  /// Log game-related events
  static void game(String message, {String? gameType}) {
    if (kDebugMode) {
      debugPrint('[$_tag:Game${gameType != null ? ':$gameType' : ''}] 🎮 $message');
    }
  }
  
  /// Log wallet/diamond events
  static void wallet(String message) {
    if (kDebugMode) {
      debugPrint('[$_tag:Wallet] 💎 $message');
    }
  }
  
  /// Log auth events
  static void auth(String message) {
    if (kDebugMode) {
      debugPrint('[$_tag:Auth] 🔐 $message');
    }
  }
  
  /// Log network/API events
  static void network(String message) {
    if (kDebugMode) {
      debugPrint('[$_tag:Network] 🌐 $message');
    }
  }
}
