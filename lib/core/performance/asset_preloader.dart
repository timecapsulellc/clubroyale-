/// Card Asset Preloader
///
/// Preloads card images during splash screen to eliminate
/// loading delays when entering games.
library;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Preloads all card assets for faster game loading
class CardAssetPreloader {
  static final CardAssetPreloader _instance = CardAssetPreloader._internal();
  factory CardAssetPreloader() => _instance;
  CardAssetPreloader._internal();

  bool _isPreloaded = false;
  bool get isPreloaded => _isPreloaded;

  /// All card asset paths
  static const List<String> _cardAssets = [
    // Standard deck
    'assets/cards/png/ace_of_hearts.png',
    'assets/cards/png/2_of_hearts.png',
    'assets/cards/png/3_of_hearts.png',
    'assets/cards/png/4_of_hearts.png',
    'assets/cards/png/5_of_hearts.png',
    'assets/cards/png/6_of_hearts.png',
    'assets/cards/png/7_of_hearts.png',
    'assets/cards/png/8_of_hearts.png',
    'assets/cards/png/9_of_hearts.png',
    'assets/cards/png/10_of_hearts.png',
    'assets/cards/png/jack_of_hearts.png',
    'assets/cards/png/queen_of_hearts.png',
    'assets/cards/png/king_of_hearts.png',
    'assets/cards/png/ace_of_diamonds.png',
    'assets/cards/png/2_of_diamonds.png',
    'assets/cards/png/3_of_diamonds.png',
    'assets/cards/png/4_of_diamonds.png',
    'assets/cards/png/5_of_diamonds.png',
    'assets/cards/png/6_of_diamonds.png',
    'assets/cards/png/7_of_diamonds.png',
    'assets/cards/png/8_of_diamonds.png',
    'assets/cards/png/9_of_diamonds.png',
    'assets/cards/png/10_of_diamonds.png',
    'assets/cards/png/jack_of_diamonds.png',
    'assets/cards/png/queen_of_diamonds.png',
    'assets/cards/png/king_of_diamonds.png',
    'assets/cards/png/ace_of_clubs.png',
    'assets/cards/png/2_of_clubs.png',
    'assets/cards/png/3_of_clubs.png',
    'assets/cards/png/4_of_clubs.png',
    'assets/cards/png/5_of_clubs.png',
    'assets/cards/png/6_of_clubs.png',
    'assets/cards/png/7_of_clubs.png',
    'assets/cards/png/8_of_clubs.png',
    'assets/cards/png/9_of_clubs.png',
    'assets/cards/png/10_of_clubs.png',
    'assets/cards/png/jack_of_clubs.png',
    'assets/cards/png/queen_of_clubs.png',
    'assets/cards/png/king_of_clubs.png',
    'assets/cards/png/ace_of_spades.png',
    'assets/cards/png/2_of_spades.png',
    'assets/cards/png/3_of_spades.png',
    'assets/cards/png/4_of_spades.png',
    'assets/cards/png/5_of_spades.png',
    'assets/cards/png/6_of_spades.png',
    'assets/cards/png/7_of_spades.png',
    'assets/cards/png/8_of_spades.png',
    'assets/cards/png/9_of_spades.png',
    'assets/cards/png/10_of_spades.png',
    'assets/cards/png/jack_of_spades.png',
    'assets/cards/png/queen_of_spades.png',
    'assets/cards/png/king_of_spades.png',
    // Jokers
    'assets/cards/png/black_joker.png',
    'assets/cards/png/red_joker.png',
    // Card backs
    'assets/cards/backs/back.png',
    'assets/cards/png/back.png',
  ];

  /// Essential assets only (for faster initial load)
  static const List<String> _essentialAssets = [
    'assets/cards/png/back.png',
    'assets/cards/backs/back.png',
  ];

  /// Preload essential assets only (fast)
  Future<void> preloadEssential(BuildContext context) async {
    if (_isPreloaded) return;
    
    for (final path in _essentialAssets) {
      try {
        await precacheImage(AssetImage(path), context);
      } catch (e) {
        debugPrint('⚠️ Failed to preload: $path');
      }
    }
  }

  /// Preload all card assets (call during splash or background)
  Future<void> preloadAll(BuildContext context) async {
    if (_isPreloaded) return;

    final stopwatch = Stopwatch()..start();
    int loaded = 0;
    int failed = 0;

    for (final path in _cardAssets) {
      try {
        await precacheImage(AssetImage(path), context);
        loaded++;
      } catch (e) {
        failed++;
        // Silent fail - asset might not exist
      }
    }

    stopwatch.stop();
    debugPrint('🃏 Preloaded $loaded cards in ${stopwatch.elapsedMilliseconds}ms ($failed failed)');
    _isPreloaded = true;
  }

  /// Preload in background without blocking UI
  void preloadInBackground(BuildContext context) {
    if (_isPreloaded) return;
    
    // Use compute or run in microtask to not block UI
    Future.microtask(() async {
      await preloadAll(context);
    });
  }

  /// Check if an asset exists
  static Future<bool> assetExists(String path) async {
    try {
      await rootBundle.load(path);
      return true;
    } catch (e) {
      return false;
    }
  }
}

/// Splash screen that preloads assets
class AssetPreloadSplash extends StatefulWidget {
  final Widget child;
  final Duration minSplashDuration;

  const AssetPreloadSplash({
    super.key,
    required this.child,
    this.minSplashDuration = const Duration(milliseconds: 1500),
  });

  @override
  State<AssetPreloadSplash> createState() => _AssetPreloadSplashState();
}

class _AssetPreloadSplashState extends State<AssetPreloadSplash> {
  bool _isReady = false;
  double _progress = 0.0;

  @override
  void initState() {
    super.initState();
    _preload();
  }

  Future<void> _preload() async {
    final startTime = DateTime.now();
    
    // Start preloading
    await _preloadWithProgress();

    // Ensure minimum splash duration
    final elapsed = DateTime.now().difference(startTime);
    if (elapsed < widget.minSplashDuration) {
      await Future.delayed(widget.minSplashDuration - elapsed);
    }

    if (mounted) {
      setState(() => _isReady = true);
    }
  }

  Future<void> _preloadWithProgress() async {
    final assets = CardAssetPreloader._cardAssets;
    int completed = 0;

    for (final path in assets) {
      if (!mounted) return;
      try {
        await precacheImage(AssetImage(path), context);
      } catch (_) {
        // Continue on failure
      }
      completed++;
      if (mounted) {
        setState(() => _progress = completed / assets.length);
      }
    }

    CardAssetPreloader()._isPreloaded = true;
  }

  @override
  Widget build(BuildContext context) {
    if (_isReady) {
      return widget.child;
    }

    return Scaffold(
      backgroundColor: const Color(0xFF1A1A2E),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Logo
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: Colors.amber.withValues(alpha: 0.2),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.casino,
                size: 64,
                color: Colors.amber,
              ),
            ),
            const SizedBox(height: 32),
            
            // App name
            const Text(
              'ClubRoyale',
              style: TextStyle(
                color: Colors.white,
                fontSize: 32,
                fontWeight: FontWeight.bold,
                letterSpacing: 2,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Loading game assets...',
              style: TextStyle(
                color: Colors.white54,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 40),
            
            // Progress bar
            SizedBox(
              width: 200,
              child: Column(
                children: [
                  LinearProgressIndicator(
                    value: _progress,
                    backgroundColor: Colors.white12,
                    valueColor: const AlwaysStoppedAnimation(Colors.amber),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${(_progress * 100).toInt()}%',
                    style: const TextStyle(
                      color: Colors.white38,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
