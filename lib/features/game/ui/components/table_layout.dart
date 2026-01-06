import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:clubroyale/features/store/theme_store_provider.dart';
import 'package:clubroyale/config/casino_theme.dart';

/// Dynamic table layout that uses the user's selected theme
class TableLayout extends ConsumerWidget {
  final Widget child;

  const TableLayout({super.key, required this.child});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Watch the selected theme (currently unused but needed for future theme switching)
    final _ = ref.watch(selectedThemeProvider);

    return Container(
      decoration: const BoxDecoration(gradient: CasinoColors.greenFeltGradient),
      child: SafeArea(
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Content Layer
            SizedBox.expand(child: child),
          ],
        ),
      ),
    );
  }
}

// Removed legacy TableFeltPainter as we now use rich assets
