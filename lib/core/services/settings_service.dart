/// Settings Service - Persists user preferences
///
/// Features:
/// - Audio volume persistence
/// - Music on/off toggle
/// - SFX on/off toggle
/// - Theme preference
/// - Haptic feedback toggle
library;

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Provider for settings service
final settingsServiceProvider =
    AsyncNotifierProvider<SettingsService, UserSettings>(() {
      return SettingsService();
    });

/// User settings data class
class UserSettings {
  final bool soundEnabled;
  final bool musicEnabled;
  final double sfxVolume;
  final double musicVolume;
  final bool hapticEnabled;
  final String themeMode; // 'light', 'dark', 'system'
  final bool notificationsEnabled;

  const UserSettings({
    this.soundEnabled = true,
    this.musicEnabled = true,
    this.sfxVolume = 1.0,
    this.musicVolume = 0.5,
    this.hapticEnabled = true,
    this.themeMode = 'system',
    this.notificationsEnabled = true,
  });

  UserSettings copyWith({
    bool? soundEnabled,
    bool? musicEnabled,
    double? sfxVolume,
    double? musicVolume,
    bool? hapticEnabled,
    String? themeMode,
    bool? notificationsEnabled,
  }) {
    return UserSettings(
      soundEnabled: soundEnabled ?? this.soundEnabled,
      musicEnabled: musicEnabled ?? this.musicEnabled,
      sfxVolume: sfxVolume ?? this.sfxVolume,
      musicVolume: musicVolume ?? this.musicVolume,
      hapticEnabled: hapticEnabled ?? this.hapticEnabled,
      themeMode: themeMode ?? this.themeMode,
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
    );
  }
}

/// Settings service that persists preferences
class SettingsService extends AsyncNotifier<UserSettings> {
  static const _keySound = 'sound_enabled';
  static const _keyMusic = 'music_enabled';
  static const _keySfxVolume = 'sfx_volume';
  static const _keyMusicVolume = 'music_volume';
  static const _keyHaptic = 'haptic_enabled';
  static const _keyTheme = 'theme_mode';
  static const _keyNotifications = 'notifications_enabled';

  @override
  Future<UserSettings> build() async {
    return await _loadSettings();
  }

  Future<UserSettings> _loadSettings() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return UserSettings(
        soundEnabled: prefs.getBool(_keySound) ?? true,
        musicEnabled: prefs.getBool(_keyMusic) ?? true,
        sfxVolume: prefs.getDouble(_keySfxVolume) ?? 1.0,
        musicVolume: prefs.getDouble(_keyMusicVolume) ?? 0.5,
        hapticEnabled: prefs.getBool(_keyHaptic) ?? true,
        themeMode: prefs.getString(_keyTheme) ?? 'system',
        notificationsEnabled: prefs.getBool(_keyNotifications) ?? true,
      );
    } catch (e) {
      debugPrint('Error loading settings: $e');
      return const UserSettings();
    }
  }

  Future<void> setSoundEnabled(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keySound, enabled);
    state = AsyncValue.data(state.value!.copyWith(soundEnabled: enabled));
  }

  Future<void> setMusicEnabled(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyMusic, enabled);
    state = AsyncValue.data(state.value!.copyWith(musicEnabled: enabled));
  }

  Future<void> setSfxVolume(double volume) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(_keySfxVolume, volume);
    state = AsyncValue.data(state.value!.copyWith(sfxVolume: volume));
  }

  Future<void> setMusicVolume(double volume) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(_keyMusicVolume, volume);
    state = AsyncValue.data(state.value!.copyWith(musicVolume: volume));
  }

  Future<void> setHapticEnabled(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyHaptic, enabled);
    state = AsyncValue.data(state.value!.copyWith(hapticEnabled: enabled));
  }

  Future<void> setThemeMode(String mode) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyTheme, mode);
    state = AsyncValue.data(state.value!.copyWith(themeMode: mode));
  }

  Future<void> setNotificationsEnabled(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyNotifications, enabled);
    state = AsyncValue.data(
      state.value!.copyWith(notificationsEnabled: enabled),
    );
  }
}
