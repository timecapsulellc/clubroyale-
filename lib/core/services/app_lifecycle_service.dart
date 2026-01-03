/// App Lifecycle Service - Manages app state changes
///
/// Features:
/// - Pause audio when app goes to background
/// - Resume audio when app returns to foreground
/// - Save game state before app is killed
/// - Notify listeners of lifecycle changes
library;

import 'package:flutter/widgets.dart';
import 'dart:ui' as ui;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:clubroyale/core/services/game_audio_service.dart';

/// Provider for app lifecycle state
final appLifecycleProvider =
    NotifierProvider<AppLifecycleNotifier, ui.AppLifecycleState>(() {
      return AppLifecycleNotifier();
    });

/// Notifier that tracks app lifecycle and manages audio accordingly
class AppLifecycleNotifier extends Notifier<ui.AppLifecycleState>
    with WidgetsBindingObserver {
  bool _wasAudioEnabled = true;
  bool _initialized = false;

  @override
  ui.AppLifecycleState build() {
    // Set up observer on first build
    if (!_initialized) {
      WidgetsBinding.instance.addObserver(this);
      _initialized = true;
    }
    return ui.AppLifecycleState.resumed;
  }

  @override
  void didChangeAppLifecycleState(ui.AppLifecycleState appState) {
    state = appState;

    switch (appState) {
      case ui.AppLifecycleState.resumed:
        _onResumed();
        break;
      case ui.AppLifecycleState.inactive:
        break;
      case ui.AppLifecycleState.paused:
        _onPaused();
        break;
      case ui.AppLifecycleState.detached:
        _onDetached();
        break;
      case ui.AppLifecycleState.hidden:
        break;
    }
  }

  void _onResumed() {
    debugPrint('🔄 App resumed - restoring audio state');
    final audioService = ref.read(gameAudioServiceProvider);

    // Restore audio if it was enabled before pausing
    if (_wasAudioEnabled) {
      audioService.setSoundEnabled(true);
    }
  }

  void _onPaused() {
    debugPrint('⏸️ App paused - saving state and pausing audio');
    final audioService = ref.read(gameAudioServiceProvider);

    // Remember audio state and pause
    _wasAudioEnabled = audioService.isSoundEnabled;
    audioService.setSoundEnabled(false);

    // TODO: Save game state to local storage if in active game
  }

  void _onDetached() {
    debugPrint('🛑 App detached - cleaning up');
    final audioService = ref.read(gameAudioServiceProvider);
    audioService.dispose();
    WidgetsBinding.instance.removeObserver(this);
  }
}

/// Widget that initializes app lifecycle observer
class AppLifecycleWrapper extends ConsumerStatefulWidget {
  final Widget child;

  const AppLifecycleWrapper({super.key, required this.child});

  @override
  ConsumerState<AppLifecycleWrapper> createState() =>
      _AppLifecycleWrapperState();
}

class _AppLifecycleWrapperState extends ConsumerState<AppLifecycleWrapper> {
  @override
  void initState() {
    super.initState();
    // Initialize the lifecycle notifier
    ref.read(appLifecycleProvider.notifier);
  }

  @override
  Widget build(BuildContext context) {
    // Watch lifecycle state to rebuild if needed
    ref.watch(appLifecycleProvider);
    return widget.child;
  }
}
