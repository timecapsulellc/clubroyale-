/// App Lifecycle Service - Manages app state changes
///
/// Features:
/// - Pause audio when app goes to background
/// - Resume audio when app returns to foreground
/// - Save game state before app is killed
/// - Notify listeners of lifecycle changes
library;

import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:clubroyale/core/services/game_audio_service.dart';

/// Provider for app lifecycle state
final appLifecycleProvider = StateNotifierProvider<AppLifecycleNotifier, AppLifecycleState>((ref) {
  return AppLifecycleNotifier(ref);
});

/// App lifecycle states
enum AppLifecycleState {
  active,
  inactive,
  paused,
  detached,
  hidden,
}

/// Notifier that tracks app lifecycle and manages audio accordingly
class AppLifecycleNotifier extends StateNotifier<AppLifecycleState> with WidgetsBindingObserver {
  final Ref _ref;
  bool _wasAudioEnabled = true;

  AppLifecycleNotifier(this._ref) : super(AppLifecycleState.active) {
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState appState) {
    // Map Flutter's AppLifecycleState to our enum
    switch (appState.name) {
      case 'resumed':
        _onResumed();
        state = AppLifecycleState.active;
        break;
      case 'inactive':
        state = AppLifecycleState.inactive;
        break;
      case 'paused':
        _onPaused();
        state = AppLifecycleState.paused;
        break;
      case 'detached':
        _onDetached();
        state = AppLifecycleState.detached;
        break;
      case 'hidden':
        state = AppLifecycleState.hidden;
        break;
    }
  }

  void _onResumed() {
    debugPrint('🔄 App resumed - restoring audio state');
    final audioService = _ref.read(gameAudioServiceProvider);
    
    // Restore audio if it was enabled before pausing
    if (_wasAudioEnabled) {
      audioService.setSoundEnabled(true);
    }
  }

  void _onPaused() {
    debugPrint('⏸️ App paused - saving state and pausing audio');
    final audioService = _ref.read(gameAudioServiceProvider);
    
    // Remember audio state and pause
    _wasAudioEnabled = audioService.isSoundEnabled;
    audioService.setSoundEnabled(false);
    
    // TODO: Save game state to local storage if in active game
  }

  void _onDetached() {
    debugPrint('🛑 App detached - cleaning up');
    final audioService = _ref.read(gameAudioServiceProvider);
    audioService.dispose();
  }
}

/// Widget that initializes app lifecycle observer
class AppLifecycleWrapper extends ConsumerStatefulWidget {
  final Widget child;

  const AppLifecycleWrapper({super.key, required this.child});

  @override
  ConsumerState<AppLifecycleWrapper> createState() => _AppLifecycleWrapperState();
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
