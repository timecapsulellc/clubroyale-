/// Base Safe State
///
/// Base class for StatefulWidget states with proper lifecycle management.
/// Provides mounted checks, dispose handlers, and safe setState.
library;

import 'package:flutter/material.dart';

/// Mixin for safe setState that checks mounted before calling
mixin SafeSetStateMixin<T extends StatefulWidget> on State<T> {
  /// Safe setState that only updates if widget is still mounted
  void safeSetState(VoidCallback fn) {
    if (mounted) {
      setState(fn);
    }
  }

  /// Execute a callback only if mounted
  void ifMounted(VoidCallback fn) {
    if (mounted) {
      fn();
    }
  }

  /// Execute an async callback and update state only if mounted
  Future<void> safeAsync(Future<void> Function() fn) async {
    await fn();
    // Caller should use safeSetState in their callback
  }
}

/// Base state class that tracks disposal and provides safe setState
abstract class SafeState<T extends StatefulWidget> extends State<T>
    with SafeSetStateMixin<T> {
  bool _isDisposed = false;

  /// Whether this state has been disposed
  bool get isDisposed => _isDisposed;

  /// List of disposable resources to clean up
  final List<ChangeNotifier> _disposables = [];

  /// Register a disposable resource for automatic cleanup
  void registerDisposable(ChangeNotifier disposable) {
    _disposables.add(disposable);
  }

  /// Register a TextEditingController for auto-disposal
  TextEditingController createTextController([String? text]) {
    final controller = TextEditingController(text: text);
    _disposables.add(controller);
    return controller;
  }

  /// Register a ScrollController for auto-disposal
  ScrollController createScrollController() {
    final controller = ScrollController();
    _disposables.add(controller);
    return controller;
  }

  @override
  void dispose() {
    _isDisposed = true;
    for (final disposable in _disposables) {
      disposable.dispose();
    }
    _disposables.clear();
    super.dispose();
  }
}

/// Extension on State for safe setState
extension SafeStateExtension<T extends StatefulWidget> on State<T> {
  /// Safely call setState only if mounted
  void safeSetState(VoidCallback fn) {
    if (mounted) {
      // ignore: invalid_use_of_protected_member
      setState(fn);
    }
  }
}
