// Match Cache Service
//
// Client-side caching for match data with offline resilience.
// Reduces Firestore reads and provides better UX during network issues.

import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';

/// Cached match data
class CachedMatch {
  final String matchId;
  final Map<String, dynamic> data;
  final DateTime cachedAt;

  CachedMatch({
    required this.matchId,
    required this.data,
    required this.cachedAt,
  });

  /// Check if cache has expired (default: 30 seconds)
  bool get isExpired => DateTime.now().difference(cachedAt).inSeconds > 30;
}

/// Match cache service singleton
class MatchCacheService {
  static final MatchCacheService _instance = MatchCacheService._internal();
  factory MatchCacheService() => _instance;
  MatchCacheService._internal();

  // In-memory cache
  final Map<String, CachedMatch> _cache = {};

  // Active subscriptions
  final Map<String, StreamSubscription> _subscriptions = {};

  // Firestore reference
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Get match from cache or Firestore
  Future<Map<String, dynamic>?> getMatch(
    String matchId, {
    bool forceRefresh = false,
  }) async {
    // Check cache first
    if (!forceRefresh && _cache.containsKey(matchId)) {
      final cached = _cache[matchId]!;
      if (!cached.isExpired) {
        return cached.data;
      }
    }

    // Try Firestore cache first
    try {
      final doc = await _firestore
          .collection('matches')
          .doc(matchId)
          .get(const GetOptions(source: Source.cache));

      if (doc.exists) {
        _updateCache(matchId, doc.data()!);
        return doc.data();
      }
    } catch (_) {
      // Cache miss, continue to server
    }

    // Fetch from server
    try {
      final doc = await _firestore
          .collection('matches')
          .doc(matchId)
          .get(const GetOptions(source: Source.server));

      if (doc.exists) {
        _updateCache(matchId, doc.data()!);
        return doc.data();
      }
    } catch (e) {
      // Return stale cache if available
      if (_cache.containsKey(matchId)) {
        return _cache[matchId]!.data;
      }
      rethrow;
    }

    return null;
  }

  /// Watch match with caching
  Stream<Map<String, dynamic>?> watchMatch(String matchId) {
    final controller = StreamController<Map<String, dynamic>?>.broadcast();

    // Emit cached data immediately if available
    if (_cache.containsKey(matchId)) {
      controller.add(_cache[matchId]!.data);
    }

    // Subscribe to Firestore updates
    _subscriptions[matchId]?.cancel();
    _subscriptions[matchId] = _firestore
        .collection('matches')
        .doc(matchId)
        .snapshots()
        .listen(
          (doc) {
            if (doc.exists) {
              _updateCache(matchId, doc.data()!);
              controller.add(doc.data());
            } else {
              controller.add(null);
            }
          },
          onError: (error) {
            // On error, keep emitting stale cache
            if (_cache.containsKey(matchId)) {
              controller.add(_cache[matchId]!.data);
            }
          },
        );

    return controller.stream;
  }

  /// Update cache entry
  void _updateCache(String matchId, Map<String, dynamic> data) {
    _cache[matchId] = CachedMatch(
      matchId: matchId,
      data: data,
      cachedAt: DateTime.now(),
    );
  }

  /// Invalidate cache for a match
  void invalidate(String matchId) {
    _cache.remove(matchId);
  }

  /// Clear all cache
  void clearAll() {
    _cache.clear();
    for (final sub in _subscriptions.values) {
      sub.cancel();
    }
    _subscriptions.clear();
  }

  /// Stop watching a match
  void stopWatching(String matchId) {
    _subscriptions[matchId]?.cancel();
    _subscriptions.remove(matchId);
  }

  /// Get cached match immediately (sync)
  Map<String, dynamic>? getCachedSync(String matchId) {
    return _cache[matchId]?.data;
  }

  /// Check if match is cached
  bool isCached(String matchId) {
    return _cache.containsKey(matchId) && !_cache[matchId]!.isExpired;
  }

  /// Get cache stats for debugging
  Map<String, dynamic> getCacheStats() {
    return {
      'cacheSize': _cache.length,
      'activeSubscriptions': _subscriptions.length,
      'entries': _cache.keys.toList(),
    };
  }
}
