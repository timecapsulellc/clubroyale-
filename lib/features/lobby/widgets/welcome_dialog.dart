import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:clubroyale/config/casino_theme.dart';
import 'package:clubroyale/core/services/settings_service.dart';

/// First-time user welcome dialog with tutorial option
class WelcomeDialog extends ConsumerWidget {
  const WelcomeDialog({super.key});

  /// Show the welcome dialog
  static Future<void> show(BuildContext context) {
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const WelcomeDialog(),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Semantics(
      label: 'Welcome dialog for first-time users',
      child: AlertDialog(
        backgroundColor: const Color(0xFF1E1E2C),
        title: Semantics(
          header: true,
          child: const Text(
            '🎉 Welcome to ClubRoyale!',
            style: TextStyle(color: CasinoColors.gold),
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'It looks like it\'s your first time here.\n\n'
              'ClubRoyale features the authentic Nepali Marriage card game. '
              'Would you like a quick interactive tutorial?',
              style: TextStyle(color: Colors.white),
            ),
            const SizedBox(height: 16),
            Semantics(
              label: 'Tutorial highlights: Learn Tiplu, Maal, Tunnels, and Kidnap rules',
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.black26,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: CasinoColors.gold.withValues(alpha: 0.3)),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.school, color: CasinoColors.gold, size: 20),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Learn rules: Tiplu, Maal, Tunnels, and Kidnap!',
                        style: TextStyle(color: Colors.white70, fontSize: 12),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        actions: [
          Semantics(
            button: true,
            label: 'Skip tutorial and dismiss dialog',
            child: SizedBox(
              height: 48, // Ensure 48px minimum touch target
              child: TextButton(
                onPressed: () {
                  ref.read(settingsServiceProvider.notifier).setHasSeenTutorial(true);
                  Navigator.pop(context);
                },
                child: const Text('Skip for Now', style: TextStyle(color: Colors.grey)),
              ),
            ),
          ),
          Semantics(
            button: true,
            label: 'Start interactive tutorial',
            child: SizedBox(
              height: 48, // Ensure 48px minimum touch target
              child: FilledButton(
                onPressed: () {
                  ref.read(settingsServiceProvider.notifier).setHasSeenTutorial(true);
                  Navigator.pop(context);
                  context.push('/marriage/practice?tutorial=true');
                },
                style: FilledButton.styleFrom(backgroundColor: CasinoColors.gold),
                child: const Text('Start Tutorial', style: TextStyle(color: Colors.black)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
