import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:clubroyale/core/theme/game_themes.dart';
import 'package:clubroyale/features/store/theme_store_provider.dart';

/// Dynamic table layout that uses the user's selected theme
class TableLayout extends ConsumerWidget {
  final Widget child;
  
  const TableLayout({super.key, required this.child});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = ref.watch(selectedThemeProvider);
    
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF121212), // Dark ambient background
        image: DecorationImage(
           image: AssetImage('assets/images/tables/table_oval_premium.png'),
           fit: BoxFit.contain, // Keep the oval shape visible
           alignment: Alignment.center,
        ),
      ),
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


