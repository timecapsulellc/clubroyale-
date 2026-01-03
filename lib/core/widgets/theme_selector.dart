import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:clubroyale/core/theme/multi_theme.dart';
import 'package:flutter_animate/flutter_animate.dart';

/// Beautiful theme selector widget for settings
class ThemeSelectorWidget extends ConsumerWidget {
  const ThemeSelectorWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeState = ref.watch(themeProvider);
    final themeNotifier = ref.read(themeProvider.notifier);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section title
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            children: [
              const Icon(Icons.palette, size: 20),
              const SizedBox(width: 8),
              Text(
                'Theme',
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),

        // Color presets
        SizedBox(
          height: 80,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            itemCount: ThemePreset.values.length,
            itemBuilder: (context, index) {
              final preset = ThemePreset.values[index];
              final isSelected = preset == themeState.preset;
              final previewColor = ThemePresetInfo.getPreviewColor(preset);
              final accentColor = ThemePresetInfo.getAccentColor(preset);

              return GestureDetector(
                    onTap: () => themeNotifier.setPreset(preset),
                    child: Container(
                      width: 70,
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      child: Column(
                        children: [
                          // Color preview circle
                          AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            width: isSelected ? 52 : 48,
                            height: isSelected ? 52 : 48,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  previewColor,
                                  previewColor.withValues(alpha: 0.7),
                                ],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: isSelected
                                    ? accentColor
                                    : Colors.transparent,
                                width: 3,
                              ),
                              boxShadow: isSelected
                                  ? [
                                      BoxShadow(
                                        color: previewColor.withValues(
                                          alpha: 0.5,
                                        ),
                                        blurRadius: 12,
                                        spreadRadius: 2,
                                      ),
                                    ]
                                  : null,
                            ),
                            child: Center(
                              // Inner gold/silver circle to show accent
                              child: Container(
                                width: 20,
                                height: 20,
                                decoration: BoxDecoration(
                                  color: accentColor,
                                  shape: BoxShape.circle,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 4),
                          // Theme name
                          Text(
                            ThemePresetInfo.getName(preset).split(' ').first,
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: isSelected
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                              color: isSelected
                                  ? Theme.of(context).colorScheme.primary
                                  : Theme.of(
                                      context,
                                    ).textTheme.bodySmall?.color,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  )
                  .animate(target: isSelected ? 1 : 0)
                  .scale(
                    begin: const Offset(1, 1),
                    end: const Offset(1.05, 1.05),
                  );
            },
          ),
        ),

        const SizedBox(height: 16),

        // Day/Night toggle
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Container(
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: Theme.of(
                  context,
                ).colorScheme.primary.withValues(alpha: 0.3),
              ),
            ),
            child: Row(
              children: [
                // Dark mode button
                Expanded(
                  child: GestureDetector(
                    onTap: () => themeNotifier.setMode(AppThemeMode.dark),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        color: themeState.mode == AppThemeMode.dark
                            ? Theme.of(context).colorScheme.primary
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.dark_mode,
                            size: 18,
                            color: themeState.mode == AppThemeMode.dark
                                ? Colors.white
                                : Theme.of(context).textTheme.bodyMedium?.color,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            'Night',
                            style: TextStyle(
                              fontWeight: themeState.mode == AppThemeMode.dark
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                              color: themeState.mode == AppThemeMode.dark
                                  ? Colors.white
                                  : Theme.of(
                                      context,
                                    ).textTheme.bodyMedium?.color,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                // Light mode button
                Expanded(
                  child: GestureDetector(
                    onTap: () => themeNotifier.setMode(AppThemeMode.light),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        color: themeState.mode == AppThemeMode.light
                            ? Theme.of(context).colorScheme.primary
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.light_mode,
                            size: 18,
                            color: themeState.mode == AppThemeMode.light
                                ? Colors.white
                                : Theme.of(context).textTheme.bodyMedium?.color,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            'Day',
                            style: TextStyle(
                              fontWeight: themeState.mode == AppThemeMode.light
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                              color: themeState.mode == AppThemeMode.light
                                  ? Colors.white
                                  : Theme.of(
                                      context,
                                    ).textTheme.bodyMedium?.color,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

/// Compact theme toggle button for app bar
class ThemeToggleButton extends ConsumerWidget {
  const ThemeToggleButton({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeState = ref.watch(themeProvider);
    final themeNotifier = ref.read(themeProvider.notifier);

    return IconButton(
      icon: Icon(
        themeState.mode == AppThemeMode.dark
            ? Icons.dark_mode
            : Icons.light_mode,
      ),
      onPressed: () => themeNotifier.toggleDarkMode(),
      tooltip: themeState.mode == AppThemeMode.dark
          ? 'Switch to Day'
          : 'Switch to Night',
    );
  }
}

/// Bottom sheet for quick theme selection
void showThemeBottomSheet(BuildContext context) {
  showModalBottomSheet(
    context: context,
    backgroundColor: Colors.transparent,
    builder: (context) => Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 8),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[400],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Choose Theme',
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            const ThemeSelectorWidget(),
            const SizedBox(height: 24),
          ],
        ),
      ),
    ),
  );
}
