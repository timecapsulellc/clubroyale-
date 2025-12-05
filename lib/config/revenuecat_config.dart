import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:purchases_flutter/purchases_flutter.dart';

/// RevenueCat configuration and initialization
/// 
/// IMPORTANT: This requires API keys from RevenueCat dashboard
/// Visit https://app.revenuecat.com to get your keys
class RevenueCatConfig {
  // TODO: Replace with your actual API keys from RevenueCat dashboard
  // These should be stored in environment variables in production
  static const String _iosApiKey = 'YOUR_IOS_API_KEY_HERE';
  static const String _androidApiKey = 'YOUR_ANDROID_API_KEY_HERE';
  
  /// Initialize RevenueCat SDK
  /// Call this in main() before runApp()
  static Future<void> initialize() async {
    if (kIsWeb) {
      debugPrint('RevenueCat: Web platform not supported');
      return;
    }

    try {
      // Set log level (use debug for development, info for production)
      await Purchases.setLogLevel(kDebugMode ? LogLevel.debug : LogLevel.info);
      
      // Configure SDK based on platform
      PurchasesConfiguration configuration;
      if (Platform.isIOS) {
        configuration = PurchasesConfiguration(_iosApiKey);
      } else if (Platform.isAndroid) {
        configuration = PurchasesConfiguration(_androidApiKey);
      } else {
        debugPrint('RevenueCat: Platform not supported');
        return;
      }
      
      // Initialize
      await Purchases.configure(configuration);
      debugPrint('RevenueCat: Initialized successfully');
      
    } catch (e) {
      debugPrint('RevenueCat initialization failed: $e');
      // Don't throw - app should continue without IAP
    }
  }
  
  /// Set user identifier for RevenueCat
  /// Call this after user signs in
  static Future<void> setUserId(String userId) async {
    try {
      await Purchases.logIn(userId);
      debugPrint('RevenueCat: User logged in - $userId');
    } catch (e) {
      debugPrint('RevenueCat login failed: $e');
    }
  }
  
  /// Clear user identifier
  /// Call this when user signs out
  static Future<void> clearUserId() async {
    try {
      await Purchases.logOut();
      debugPrint('RevenueCat: User logged out');
    } catch (e) {
      debugPrint('RevenueCat logout failed: $e');
    }
  }
  
  /// Get current customer info
  static Future<CustomerInfo?> getCustomerInfo() async {
    try {
      return await Purchases.getCustomerInfo();
    } catch (e) {
      debugPrint('Failed to get customer info: $e');
      return null;
    }
  }
  
  /// Check if RevenueCat is properly configured
  static bool get isConfigured {
    return _iosApiKey != 'YOUR_IOS_API_KEY_HERE' && 
           _androidApiKey != 'YOUR_ANDROID_API_KEY_HERE';
  }
}
