import 'dart:ui';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:clubroyale/core/config/game_terminology.dart';

/// Provider for GameSettings
final gameSettingsProvider = Provider<GameSettings>((ref) {
  throw UnimplementedError('Must be overridden with SharedPreferences');
});

/// Provider for async initialization
final gameSettingsInitProvider = FutureProvider<GameSettings>((ref) async {
  final prefs = await SharedPreferences.getInstance();
  final settings = GameSettings(prefs);
  await settings.init();
  return settings;
});

/// Game Settings - Region and Terminology Preferences
/// 
/// Manages user preferences for game region (Global/South Asia)
/// with locale auto-detection for first-time users
class GameSettings {
  static const String _regionKey = 'game_region';
  static const String _hasInitializedKey = 'settings_initialized';
  
  final SharedPreferences _prefs;
  
  GameSettings(this._prefs);
  
  /// Initialize settings - auto-detect region on first launch
  Future<void> init() async {
    final hasInitialized = _prefs.getBool(_hasInitializedKey) ?? false;
    
    if (!hasInitialized) {
      // First launch - auto-detect region from device locale
      final detectedRegion = detectFromLocale(PlatformDispatcher.instance.locale);
      await setRegion(detectedRegion);
      await _prefs.setBool(_hasInitializedKey, true);
    } else {
      // Load saved region
      GameTerminology.currentRegion = region;
    }
  }
  
  /// Get current region preference
  GameRegion get region {
    final value = _prefs.getString(_regionKey);
    if (value == 'southAsia') return GameRegion.southAsia;
    return GameRegion.global; // Default to global
  }
  
  /// Set region preference
  Future<void> setRegion(GameRegion newRegion) async {
    await _prefs.setString(_regionKey, newRegion.name);
    GameTerminology.currentRegion = newRegion;
  }
  
  /// Toggle between regions
  Future<void> toggleRegion() async {
    final newRegion = region == GameRegion.global 
        ? GameRegion.southAsia 
        : GameRegion.global;
    await setRegion(newRegion);
  }
  
  /// Auto-detect region based on device locale
  /// South Asian locales get Marriage terminology by default
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
  
  /// Check if user is using South Asian terminology
  bool get isSouthAsian => region == GameRegion.southAsia;
  
  /// Check if user is using Global terminology
  bool get isGlobal => region == GameRegion.global;
  
  /// Get display name for current region
  String get regionDisplayName => isSouthAsian 
      ? 'Marriage (दक्षिण एशिया)' 
      : 'ClubRoyale (International)';
}
