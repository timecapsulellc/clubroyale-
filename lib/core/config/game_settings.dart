import 'dart:ui';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:clubroyale/core/config/game_terminology.dart';

/// Provider for GameSettings state
final gameSettingsProvider =
    NotifierProvider<GameSettingsNotifier, GameSettingsState>(() {
      return GameSettingsNotifier();
    });

/// Legacy provider for backward compatibility (maps to state)
final gameSettingsInitProvider = FutureProvider<GameSettings>((ref) async {
  // Wait for the notifier to initialize
  final state = ref.watch(gameSettingsProvider);
  // This is a bit of a hack to maintain API compatibility,
  // but ideally we should migrate consumers to watch gameSettingsProvider directly.
  // For now, we return a GameSettings object that wraps the current state.
  return GameSettings(state.region);
});

class GameSettingsState {
  final GameRegion region;
  final bool isInitialized;

  const GameSettingsState({required this.region, this.isInitialized = false});

  GameSettingsState copyWith({GameRegion? region, bool? isInitialized}) {
    return GameSettingsState(
      region: region ?? this.region,
      isInitialized: isInitialized ?? this.isInitialized,
    );
  }
}

class GameSettingsNotifier extends Notifier<GameSettingsState> {
  static const String _regionKey = 'game_region';

  @override
  GameSettingsState build() {
    // Initialize asynchronously
    _init();
    return const GameSettingsState(region: GameRegion.global);
  }

  Future<void> _init() async {
    final prefs = await SharedPreferences.getInstance();
    final savedRegionName = prefs.getString(_regionKey);

    GameRegion initialRegion;
    if (savedRegionName != null) {
      initialRegion = savedRegionName == 'southAsia'
          ? GameRegion.southAsia
          : GameRegion.global;
    } else {
      // First launch - auto-detect
      initialRegion = GameSettings.detectFromLocale(
        PlatformDispatcher.instance.locale,
      );
      await prefs.setString(_regionKey, initialRegion.name);
    }

    // Update static global
    GameTerminology.currentRegion = initialRegion;

    state = state.copyWith(region: initialRegion, isInitialized: true);
  }

  Future<void> setRegion(GameRegion newRegion) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_regionKey, newRegion.name);

    GameTerminology.currentRegion = newRegion;
    state = state.copyWith(region: newRegion);
  }
}

/// Wrapper for backward compatibility with existing code
class GameSettings {
  final GameRegion region;

  GameSettings(this.region);

  // These are for backward compatibility
  Future<void> init() async {}

  // Proxies for the new notifier logic would be handled by the consumer using the notifier directly,
  // but for the toggle widget which calls this class directly, we need to adapt.
  // The Toggle widget should be updated to use the Notifier, but we can verify that next.

  bool get isSouthAsian => region == GameRegion.southAsia;
  bool get isGlobal => region == GameRegion.global;

  String get regionDisplayName =>
      isSouthAsian ? 'Marriage (दक्षिण एशिया)' : 'ClubRoyale (International)';

  static GameRegion detectFromLocale(Locale locale) {
    // South Asian language codes
    const southAsianLocales = [
      'ne', // Nepali
      'hi', // Hindi
      'bn', // Bengali
      'ta', // Tamil
      'te', // Telugu
      'mr', // Marathi
      'gu', // Gujarati
      'pa', // Punjabi
      'ml', // Malayalam
      'kn', // Kannada
      'ur', // Urdu
      'si', // Sinhala
    ];

    if (southAsianLocales.contains(locale.languageCode)) {
      return GameRegion.southAsia;
    }

    // Also check country codes for users with English locale but in South Asia
    const southAsianCountries = ['NP', 'IN', 'BD', 'LK', 'PK'];
    if (southAsianCountries.contains(locale.countryCode)) {
      return GameRegion.southAsia;
    }

    return GameRegion.global;
  }
}
