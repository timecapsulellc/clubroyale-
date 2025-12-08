// Safe Harbor Disclaimer Widget
//
// Mandatory modal shown on app launch to comply with Google Play guidelines.
// Ensures TaasClub is classified as a "scorekeeping utility" not gambling.

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Safe Harbor disclaimer that must be shown on first launch
class SafeHarborDisclaimer extends StatelessWidget {
  final VoidCallback onAccept;

  const SafeHarborDisclaimer({
    super.key,
    required this.onAccept,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        padding: const EdgeInsets.all(24),
        constraints: const BoxConstraints(maxWidth: 400),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Icon
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.info_outline,
                size: 48,
                color: Colors.blue.shade700,
              ),
            ),
            const SizedBox(height: 20),
            
            // Title
            const Text(
              'Important Notice',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            
            // Disclaimer text
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Text(
                'TaasClub is a scorekeeping utility for private card games.\n\n'
                '• All point settlements are private and offline\n'
                '• We do not process real-money transactions\n'
                '• Users are responsible for their own offline settlements\n'
                '• This app is for entertainment purposes only',
                style: TextStyle(
                  fontSize: 14,
                  height: 1.5,
                ),
              ),
            ),
            const SizedBox(height: 24),
            
            // Accept button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: onAccept,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'I Understand',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Service to manage Safe Harbor disclaimer state
class SafeHarborService {
  static const String _acceptedKey = 'safe_harbor_accepted';
  static const String _acceptedVersionKey = 'safe_harbor_version';
  static const int _currentVersion = 1; // Increment to force re-acceptance

  /// Check if user has accepted the disclaimer
  static Future<bool> hasAccepted() async {
    final prefs = await SharedPreferences.getInstance();
    final accepted = prefs.getBool(_acceptedKey) ?? false;
    final version = prefs.getInt(_acceptedVersionKey) ?? 0;
    
    // Re-show if version changed
    return accepted && version >= _currentVersion;
  }

  /// Mark disclaimer as accepted
  static Future<void> markAccepted() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_acceptedKey, true);
    await prefs.setInt(_acceptedVersionKey, _currentVersion);
  }

  /// Reset acceptance (for testing)
  static Future<void> reset() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_acceptedKey);
    await prefs.remove(_acceptedVersionKey);
  }
}

/// Wrapper widget that shows disclaimer if not accepted
class SafeHarborWrapper extends StatefulWidget {
  final Widget child;

  const SafeHarborWrapper({
    super.key,
    required this.child,
  });

  @override
  State<SafeHarborWrapper> createState() => _SafeHarborWrapperState();
}

class _SafeHarborWrapperState extends State<SafeHarborWrapper> {
  bool _showDisclaimer = false;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _checkDisclaimer();
  }

  Future<void> _checkDisclaimer() async {
    final accepted = await SafeHarborService.hasAccepted();
    setState(() {
      _showDisclaimer = !accepted;
      _loading = false;
    });
  }

  Future<void> _onAccept() async {
    await SafeHarborService.markAccepted();
    setState(() {
      _showDisclaimer = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Stack(
      children: [
        widget.child,
        if (_showDisclaimer)
          Container(
            color: Colors.black54,
            child: Center(
              child: SafeHarborDisclaimer(onAccept: _onAccept),
            ),
          ),
      ],
    );
  }
}
