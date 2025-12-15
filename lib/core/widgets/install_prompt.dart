// Install Prompt Widget
//
// Shows a banner prompting users to install PWA.
// Customized for iOS, Android, and Desktop.

import 'package:flutter/material.dart';
import 'package:clubroyale/core/services/pwa_service.dart';

/// PWA Install Prompt Banner
class PWAInstallBanner extends StatefulWidget {
  final VoidCallback? onInstalled;
  final VoidCallback? onDismissed;

  const PWAInstallBanner({
    super.key,
    this.onInstalled,
    this.onDismissed,
  });

  @override
  State<PWAInstallBanner> createState() => _PWAInstallBannerState();
}

class _PWAInstallBannerState extends State<PWAInstallBanner> {
  final _pwaService = PWAService();
  bool _isVisible = false;
  bool _installing = false;

  @override
  void initState() {
    super.initState();
    _checkVisibility();
    _pwaService.installStateStream.listen((_) => _checkVisibility());
  }

  void _checkVisibility() {
    setState(() {
      _isVisible = _pwaService.shouldShowInstallPrompt();
    });
  }

  Future<void> _install() async {
    setState(() => _installing = true);
    
    final success = await _pwaService.promptInstall();
    
    setState(() => _installing = false);
    
    if (success) {
      widget.onInstalled?.call();
      _checkVisibility();
    }
  }

  void _dismiss() {
    _pwaService.dismissInstallPrompt();
    widget.onDismissed?.call();
    _checkVisibility();
  }

  @override
  Widget build(BuildContext context) {
    if (!_isVisible) return const SizedBox.shrink();

    final platform = _pwaService.getPlatform();

    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.deepPurple.shade700,
            Colors.deepPurple.shade500,
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.deepPurple.withValues(alpha: 0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Icon
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  platform == 'ios' ? Icons.ios_share : Icons.install_mobile,
                  color: Colors.white,
                  size: 28,
                ),
              ),
              const SizedBox(width: 16),
              
              // Text
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      'Install ClubRoyale',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _getInstallText(platform),
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.9),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              
              // Actions
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Dismiss button
                  IconButton(
                    onPressed: _dismiss,
                    icon: const Icon(Icons.close, color: Colors.white70, size: 20),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                  const SizedBox(height: 8),
                  // Install button
                  if (platform != 'ios')
                    ElevatedButton(
                      onPressed: _installing ? null : _install,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: Colors.deepPurple,
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                      child: _installing
                          ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Text('Install'),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _getInstallText(String platform) {
    switch (platform) {
      case 'ios':
        return 'Tap Share ⬆ then "Add to Home Screen"';
      case 'android':
        return 'Add to home screen for quick access';
      default:
        return 'Install for a better experience';
    }
  }
}

/// Floating install button for settings/menu
class PWAInstallButton extends StatelessWidget {
  const PWAInstallButton({super.key});

  @override
  Widget build(BuildContext context) {
    final pwaService = PWAService();

    return StreamBuilder<PWAInstallState>(
      stream: pwaService.installStateStream,
      initialData: pwaService.installState,
      builder: (context, snapshot) {
        final state = snapshot.data ?? PWAInstallState.notAvailable;

        if (state == PWAInstallState.installed) {
          return ListTile(
            leading: const Icon(Icons.check_circle, color: Colors.green),
            title: const Text('App Installed'),
            subtitle: const Text('ClubRoyale is installed on your device'),
          );
        }

        if (state == PWAInstallState.available) {
          return ListTile(
            leading: const Icon(Icons.install_mobile),
            title: const Text('Install App'),
            subtitle: const Text('Add ClubRoyale to your home screen'),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () async {
              final success = await pwaService.promptInstall();
              if (success && context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('ClubRoyale installed!'),
                    backgroundColor: Colors.green,
                  ),
                );
              }
            },
          );
        }

        // Not available - show iOS instructions
        if (pwaService.getPlatform() == 'ios') {
          return ListTile(
            leading: const Icon(Icons.ios_share),
            title: const Text('Add to Home Screen'),
            subtitle: const Text('Tap Share ⬆ then "Add to Home Screen"'),
          );
        }

        return const SizedBox.shrink();
      },
    );
  }
}

/// Install prompt dialog
class PWAInstallDialog extends StatelessWidget {
  const PWAInstallDialog({super.key});

  @override
  Widget build(BuildContext context) {
    final platform = PWAService().getPlatform();

    return AlertDialog(
      title: Row(
        children: [
          Icon(
            platform == 'ios' ? Icons.ios_share : Icons.install_mobile,
            color: Colors.deepPurple,
          ),
          const SizedBox(width: 12),
          const Text('Install ClubRoyale'),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Install ClubRoyale for the best experience:',
            style: TextStyle(fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 16),
          _buildBenefit(Icons.flash_on, 'Faster loading'),
          _buildBenefit(Icons.notifications, 'Get game invites'),
          _buildBenefit(Icons.wifi_off, 'Works offline'),
          _buildBenefit(Icons.fullscreen, 'Full screen mode'),
          if (platform == 'ios') ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Row(
                children: [
                  Icon(Icons.info, color: Colors.blue, size: 20),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Tap the Share button ⬆ in Safari, then "Add to Home Screen"',
                      style: TextStyle(fontSize: 12),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Maybe Later'),
        ),
        if (platform != 'ios')
          FilledButton(
            onPressed: () async {
              Navigator.of(context).pop();
              await PWAService().promptInstall();
            },
            child: const Text('Install Now'),
          ),
      ],
    );
  }

  Widget _buildBenefit(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Colors.green),
          const SizedBox(width: 12),
          Text(text),
        ],
      ),
    );
  }
}
