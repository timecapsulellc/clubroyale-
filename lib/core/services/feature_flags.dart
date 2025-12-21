/// Feature Flags Service
/// 
/// Centralized feature flag management for Gaming-First strategy.
/// Allows features to be enabled/disabled without code changes.
library;

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Feature flag keys
enum Feature {
  // Social Features (PAUSED for Gaming-First)
  stories,
  socialFeed,
  contentCreation,
  clubPosts,
  activityFeed,
  
  // Gaming Features (ENABLED)
  liveAudioVideo,
  spectatorMode,
  inGameChat,
  friendList,
  gameRooms,
  tournaments,
}

/// Feature Flags Service
/// 
/// Controls which features are enabled in the app.
/// Default values implement Gaming-First strategy.
class FeatureFlags {
  static final FeatureFlags _instance = FeatureFlags._internal();
  factory FeatureFlags() => _instance;
  FeatureFlags._internal();

  SharedPreferences? _prefs;
  
  /// Default feature states (Gaming-First Strategy)
  static const Map<Feature, bool> _defaults = {
    // Social Features - DISABLED by default
    Feature.stories: false,
    Feature.socialFeed: false,
    Feature.contentCreation: false,
    Feature.clubPosts: false,
    Feature.activityFeed: false,
    
    // Gaming Features - ENABLED by default
    Feature.liveAudioVideo: true,
    Feature.spectatorMode: true,
    Feature.inGameChat: true,
    Feature.friendList: true,
    Feature.gameRooms: true,
    Feature.tournaments: true,
  };

  /// Initialize feature flags
  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  /// Check if a feature is enabled
  bool isEnabled(Feature feature) {
    if (_prefs == null) {
      return _defaults[feature] ?? false;
    }
    return _prefs!.getBool(feature.name) ?? _defaults[feature] ?? false;
  }

  /// Enable a feature
  Future<void> enable(Feature feature) async {
    await _prefs?.setBool(feature.name, true);
    if (kDebugMode) {
      print('🏴 Feature ENABLED: ${feature.name}');
    }
  }

  /// Disable a feature
  Future<void> disable(Feature feature) async {
    await _prefs?.setBool(feature.name, false);
    if (kDebugMode) {
      print('🏴 Feature DISABLED: ${feature.name}');
    }
  }

  /// Reset feature to default
  Future<void> resetToDefault(Feature feature) async {
    await _prefs?.remove(feature.name);
  }

  /// Reset all features to defaults
  Future<void> resetAll() async {
    for (final feature in Feature.values) {
      await _prefs?.remove(feature.name);
    }
  }

  // ========================================
  // Convenience getters for common checks
  // ========================================

  /// Social features enabled
  bool get socialEnabled => isEnabled(Feature.socialFeed) || isEnabled(Feature.stories);

  /// Stories feature enabled
  bool get storiesEnabled => isEnabled(Feature.stories);

  /// Activity feed enabled
  bool get feedEnabled => isEnabled(Feature.activityFeed);

  /// Content creation enabled
  bool get contentCreationEnabled => isEnabled(Feature.contentCreation);

  /// Live audio/video enabled
  bool get liveMediaEnabled => isEnabled(Feature.liveAudioVideo);

  /// Spectator mode enabled
  bool get spectatorEnabled => isEnabled(Feature.spectatorMode);
}

/// Global instance for easy access
final featureFlags = FeatureFlags();
