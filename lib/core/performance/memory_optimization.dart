import 'package:flutter/material.dart';

/// PhD Audit Finding #15: Memory Optimization
/// Responsive texture loading for low-end devices

class ResponsiveAssetLoader {
  /// Get optimal card texture path based on screen size
  static String getCardTexturePath(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    
    if (screenWidth < 400) {
      return 'assets/cards/cards_low.webp';     // 256px - Low-end phones
    } else if (screenWidth < 768) {
      return 'assets/cards/cards_medium.webp';  // 384px - Phones
    } else if (screenWidth < 1024) {
      return 'assets/cards/cards_high.webp';    // 512px - Tablets
    } else {
      return 'assets/cards/cards_ultra.webp';   // 714px - Desktop
    }
  }
  
  /// Get optimal table texture
  static String getTableTexturePath(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    
    if (screenWidth < 768) {
      return 'assets/tables/felt_mobile.webp';
    }
    return 'assets/tables/felt_desktop.webp';
  }
  
  /// Card dimensions based on screen size
  static Size getCardSize(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    
    if (screenWidth < 400) {
      return const Size(40, 56);   // Small phones
    } else if (screenWidth < 768) {
      return const Size(50, 70);   // Regular phones
    } else if (screenWidth < 1024) {
      return const Size(60, 84);   // Tablets
    } else {
      return const Size(80, 112);  // Desktop
    }
  }
}

/// Memory-efficient image widget with lazy loading
class OptimizedImage extends StatefulWidget {
  final String assetPath;
  final double? width;
  final double? height;
  final BoxFit fit;
  final Widget? placeholder;
  
  const OptimizedImage({
    super.key,
    required this.assetPath,
    this.width,
    this.height,
    this.fit = BoxFit.contain,
    this.placeholder,
  });
  
  @override
  State<OptimizedImage> createState() => _OptimizedImageState();
}

class _OptimizedImageState extends State<OptimizedImage> {
  bool _isLoaded = false;
  
  @override
  Widget build(BuildContext context) {
    return Image.asset(
      widget.assetPath,
      width: widget.width,
      height: widget.height,
      fit: widget.fit,
      cacheWidth: widget.width?.toInt(),
      cacheHeight: widget.height?.toInt(),
      frameBuilder: (context, child, frame, wasSynchronouslyLoaded) {
        if (wasSynchronouslyLoaded || frame != null) {
          return child;
        }
        return widget.placeholder ?? 
            Container(
              width: widget.width,
              height: widget.height,
              color: Colors.grey.withValues(alpha: 0.2),
              child: const Center(
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            );
      },
      errorBuilder: (context, error, stackTrace) {
        return Container(
          width: widget.width,
          height: widget.height,
          color: Colors.red.withValues(alpha: 0.2),
          child: const Icon(Icons.error, color: Colors.red),
        );
      },
    );
  }
}

/// Memory cache manager
class MemoryCacheManager {
  static final MemoryCacheManager _instance = MemoryCacheManager._internal();
  factory MemoryCacheManager() => _instance;
  MemoryCacheManager._internal();
  
  final Map<String, dynamic> _cache = {};
  int _cacheSize = 0;
  static const int _maxCacheSize = 50 * 1024 * 1024; // 50MB limit
  
  void put(String key, dynamic value, int size) {
    // Evict old entries if over limit
    while (_cacheSize + size > _maxCacheSize && _cache.isNotEmpty) {
      final oldestKey = _cache.keys.first;
      _cache.remove(oldestKey);
      // Approximate size reduction
      _cacheSize = (_cacheSize * 0.9).toInt();
    }
    
    _cache[key] = value;
    _cacheSize += size;
  }
  
  dynamic get(String key) => _cache[key];
  
  bool contains(String key) => _cache.containsKey(key);
  
  void clear() {
    _cache.clear();
    _cacheSize = 0;
  }
  
  void evict(String key) {
    if (_cache.containsKey(key)) {
      _cache.remove(key);
    }
  }
}

/// Asset preloading for smooth gameplay
class GameAssetPreloader {
  static final Set<String> _preloadedAssets = {};
  
  /// Preload essential game assets
  static Future<void> preloadGameAssets(BuildContext context) async {
    final assets = [
      ResponsiveAssetLoader.getCardTexturePath(context),
      ResponsiveAssetLoader.getTableTexturePath(context),
      'assets/animations/confetti.json',
      'assets/animations/winner.json',
    ];
    
    for (final asset in assets) {
      if (!_preloadedAssets.contains(asset)) {
        try {
          // Precache images
          if (asset.endsWith('.png') || 
              asset.endsWith('.webp') || 
              asset.endsWith('.jpg')) {
            await precacheImage(AssetImage(asset), context);
          }
          _preloadedAssets.add(asset);
        } catch (e) {
          debugPrint('Failed to preload: $asset');
        }
      }
    }
  }
  
  /// Check if assets are preloaded
  static bool areAssetsReady() => _preloadedAssets.length >= 4;
  
  /// Clear preloaded assets (for memory pressure)
  static void clearCache() {
    _preloadedAssets.clear();
    PaintingBinding.instance.imageCache.clear();
    PaintingBinding.instance.imageCache.clearLiveImages();
  }
}

/// Device capability detection
class DeviceCapabilities {
  static bool? _isLowEndDevice;
  
  /// Detect if device is low-end (for performance adjustments)
  static Future<bool> isLowEndDevice() async {
    if (_isLowEndDevice != null) return _isLowEndDevice!;
    
    // Use heuristics based on available info
    final memory = await _estimateAvailableMemory();
    _isLowEndDevice = memory < 2 * 1024 * 1024 * 1024; // Less than 2GB
    
    return _isLowEndDevice!;
  }
  
  static Future<int> _estimateAvailableMemory() async {
    // Rough estimation - in real app, use platform channels
    return 3 * 1024 * 1024 * 1024; // Assume 3GB average
  }
  
  /// Get recommended quality settings
  static Future<QualitySettings> getRecommendedSettings() async {
    final isLowEnd = await isLowEndDevice();
    
    if (isLowEnd) {
      return QualitySettings(
        textureQuality: TextureQuality.low,
        animationFrameRate: 30,
        enableParticles: false,
        enableShadows: false,
        maxConcurrentAnimations: 2,
      );
    }
    
    return QualitySettings(
      textureQuality: TextureQuality.high,
      animationFrameRate: 60,
      enableParticles: true,
      enableShadows: true,
      maxConcurrentAnimations: 8,
    );
  }
}

enum TextureQuality { low, medium, high, ultra }

class QualitySettings {
  final TextureQuality textureQuality;
  final int animationFrameRate;
  final bool enableParticles;
  final bool enableShadows;
  final int maxConcurrentAnimations;
  
  const QualitySettings({
    required this.textureQuality,
    required this.animationFrameRate,
    required this.enableParticles,
    required this.enableShadows,
    required this.maxConcurrentAnimations,
  });
}
