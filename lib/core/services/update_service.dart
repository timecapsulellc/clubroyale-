import 'package:flutter/material.dart';
import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:io';
import 'package:flutter/foundation.dart';

/// Provider for the UpdateService
final updateServiceProvider = Provider<UpdateService>((ref) {
  return UpdateService();
});

/// Service to handle app updates via Firebase Remote Config
class UpdateService {
  final FirebaseRemoteConfig _remoteConfig = FirebaseRemoteConfig.instance;
  
  // Remote Config Keys
  static const String keyLatestVersionCode = 'latest_version_code';
  static const String keyForceUpdate = 'force_update_required';
  static const String keyUpdateUrl = 'update_url';
  static const String keyUpdateMessage = 'update_message';

  /// Initialize config and fetch latest values
  Future<void> init() async {
    // Web applications are always up to date; skip Remote Config init to avoid errors
    if (kIsWeb) return; 

    try {
      await _remoteConfig.setConfigSettings(RemoteConfigSettings(
        fetchTimeout: const Duration(minutes: 1),
        minimumFetchInterval: kDebugMode 
            ? const Duration(minutes: 5) 
            : const Duration(hours: 1),
      ));

      // Defaults
      await _remoteConfig.setDefaults({
        keyLatestVersionCode: 1,
        keyForceUpdate: false,
        keyUpdateUrl: 'https://clubroyale-app.web.app/landing', // Default to landing page
        keyUpdateMessage: 'A new version of ClubRoyale is available!',
      });

      await _remoteConfig.fetchAndActivate();
      debugPrint('✅ Remote Config initialized');
    } catch (e) {
      debugPrint('⚠️ Remote Config init failed: $e');
    }
  }

  /// Check for updates and show dialog if needed
  Future<void> checkForUpdate(BuildContext context) async {
    if (kIsWeb) return; // Web is always up to date

    try {
      final PackageInfo packageInfo = await PackageInfo.fromPlatform();
      final int currentVersionCode = int.parse(packageInfo.buildNumber);
      
      final int latestVersionCode = _remoteConfig.getInt(keyLatestVersionCode);
      final bool forceUpdate = _remoteConfig.getBool(keyForceUpdate);
      final String updateUrl = _remoteConfig.getString(keyUpdateUrl);
      final String message = _remoteConfig.getString(keyUpdateMessage);

      debugPrint('🔍 Version Check: Current=$currentVersionCode, Latest=$latestVersionCode');

      if (latestVersionCode > currentVersionCode) {
        if (!context.mounted) return;
        _showUpdateDialog(context, message, updateUrl, forceUpdate);
      }
    } catch (e) {
      debugPrint('⚠️ Update check failed: $e');
    }
  }

  void _showUpdateDialog(BuildContext context, String message, String url, bool force) {
    showDialog(
      context: context,
      barrierDismissible: !force,
      builder: (context) => PopScope(
        canPop: !force,
        child: AlertDialog(
          title: const Text('New Update Available 🚀'),
          content: Text(message),
          actions: [
            if (!force)
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Later'),
              ),
            FilledButton(
              onPressed: () {
                _launchURL(url);
                if (!force) Navigator.pop(context);
              },
              child: const Text('Update Now'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _launchURL(String urlString) async {
    final Uri url = Uri.parse(urlString);
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    }
  }
}
