// Conditional import for web compatibility
import 'package:flutter/foundation.dart' show kIsWeb;
import 'ad_service_stub.dart'
    if (dart.library.io) 'ad_service_mobile.dart'
    if (dart.library.html) 'ad_service_web.dart';

/// Main AdService that delegates to platform-specific implementations
class AdService {
  final _impl = getAdService();

  Future<void> initialize() => _impl.initialize();
  Future<bool> showRewardedAd() => _impl.showRewardedAd();
}
