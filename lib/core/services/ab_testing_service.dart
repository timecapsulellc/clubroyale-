import 'package:flutter/foundation.dart';
import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:math';

/// A/B Testing Service
///
/// Provides experiment management using Firebase Remote Config.
/// Supports:
/// - Variant assignment with consistent bucketing
/// - Event tracking for conversion analysis
/// - Multiple concurrent experiments
class ABTestingService {
  static final ABTestingService _instance = ABTestingService._internal();
  factory ABTestingService() => _instance;
  ABTestingService._internal();

  /// Set to true in tests to skip Firebase initialization
  static bool isTestMode = false;

  FirebaseRemoteConfig? _remoteConfig;
  FirebaseFirestore? _firestoreInstance;
  
  FirebaseFirestore get _firestore {
    if (isTestMode) throw StateError('ABTestingService used in test mode without proper setup');
    return _firestoreInstance ??= FirebaseFirestore.instance;
  }
  
  // Cache for experiment assignments
  final Map<String, String> _assignments = {};
  bool _initialized = false;

  /// Initialize the A/B testing service
  Future<void> init() async {
    if (_initialized || isTestMode) return;
    
    try {
      _remoteConfig = FirebaseRemoteConfig.instance;
      
      await _remoteConfig!.setConfigSettings(RemoteConfigSettings(
        fetchTimeout: const Duration(minutes: 1),
        minimumFetchInterval: kReleaseMode 
            ? const Duration(hours: 1) 
            : const Duration(minutes: 5),
      ));
      
      // Set defaults for experiments
      await _remoteConfig!.setDefaults({
        'exp_onboarding_flow': 'control',
        'exp_game_lobby_layout': 'control',
        'exp_diamond_pricing': 'control',
        'exp_bot_difficulty': 'control',
        'exp_social_features': 'control',
      });
      
      await _remoteConfig!.fetchAndActivate();
      _initialized = true;
      
      debugPrint('✅ A/B Testing Service initialized');
    } catch (e) {
      debugPrint('⚠️ A/B Testing init failed: $e');
      _initialized = true; // Mark as initialized to prevent retry loops
    }
  }

  /// Get the variant for an experiment
  /// 
  /// Uses consistent bucketing based on user ID to ensure
  /// the same user always sees the same variant.
  String getVariant(String experimentName) {
    // Check cache first
    if (_assignments.containsKey(experimentName)) {
      return _assignments[experimentName]!;
    }
    
    // In test mode, return default control
    if (isTestMode || _remoteConfig == null) {
      _assignments[experimentName] = 'control';
      return 'control';
    }
    
    // Get from Remote Config
    final configValue = _remoteConfig!.getString('exp_$experimentName');
    
    // If config specifies a distribution (e.g., "control:50,variant_a:50")
    if (configValue.contains(':') && configValue.contains(',')) {
      final variant = _assignVariant(experimentName, configValue);
      _assignments[experimentName] = variant;
      return variant;
    }
    
    // Direct variant assignment
    _assignments[experimentName] = configValue.isNotEmpty ? configValue : 'control';
    return _assignments[experimentName]!;
  }

  /// Assign a variant based on distribution weights
  String _assignVariant(String experimentName, String distribution) {
    final userId = FirebaseAuth.instance.currentUser?.uid ?? 'anonymous';
    final bucket = _getBucket(userId, experimentName);
    
    // Parse distribution: "control:50,variant_a:30,variant_b:20"
    final variants = <String, int>{};
    int totalWeight = 0;
    
    for (final part in distribution.split(',')) {
      final kv = part.split(':');
      if (kv.length == 2) {
        final weight = int.tryParse(kv[1].trim()) ?? 0;
        variants[kv[0].trim()] = weight;
        totalWeight += weight;
      }
    }
    
    if (totalWeight == 0) return 'control';
    
    // Map bucket (0-99) to variant based on weights
    int cumulative = 0;
    final threshold = bucket % totalWeight;
    
    for (final entry in variants.entries) {
      cumulative += entry.value;
      if (threshold < cumulative) {
        return entry.key;
      }
    }
    
    return 'control';
  }

  /// Generate consistent bucket for user + experiment
  int _getBucket(String userId, String experimentName) {
    final combined = '$userId:$experimentName';
    int hash = 0;
    for (int i = 0; i < combined.length; i++) {
      hash = ((hash << 5) - hash) + combined.codeUnitAt(i);
      hash = hash & 0xFFFFFFFF;
    }
    return hash.abs() % 100;
  }

  /// Track an experiment event (exposure, conversion, etc.)
  Future<void> trackEvent({
    required String experimentName,
    required String eventName,
    Map<String, dynamic>? properties,
  }) async {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) return;
    
    final variant = getVariant(experimentName);
    
    try {
      await _firestore.collection('experiment_events').add({
        'experimentName': experimentName,
        'variant': variant,
        'eventName': eventName,
        'userId': userId,
        'properties': properties,
        'timestamp': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      debugPrint('Failed to track experiment event: $e');
    }
  }

  /// Track when a user is exposed to an experiment
  Future<void> trackExposure(String experimentName) async {
    await trackEvent(
      experimentName: experimentName,
      eventName: 'exposure',
    );
  }

  /// Track a conversion event
  Future<void> trackConversion(
    String experimentName, {
    String conversionType = 'primary',
    double? value,
  }) async {
    await trackEvent(
      experimentName: experimentName,
      eventName: 'conversion',
      properties: {
        'conversionType': conversionType,
        if (value != null) 'value': value,
      },
    );
  }

  /// Get all active experiments for the current user
  Map<String, String> getActiveExperiments() {
    final experiments = <String, String>{};
    
    final experimentKeys = [
      'onboarding_flow',
      'game_lobby_layout',
      'diamond_pricing',
      'bot_difficulty',
      'social_features',
    ];
    
    for (final key in experimentKeys) {
      experiments[key] = getVariant(key);
    }
    
    return experiments;
  }

  /// Check if a specific variant is active
  bool isVariant(String experimentName, String variantName) {
    return getVariant(experimentName) == variantName;
  }

  /// Force a specific variant (for testing only)
  @visibleForTesting
  void forceVariant(String experimentName, String variant) {
    _assignments[experimentName] = variant;
  }

  /// Clear cached assignments (forces re-evaluation)
  void clearAssignments() {
    _assignments.clear();
  }
}

/// Global instance
final abTesting = ABTestingService();
