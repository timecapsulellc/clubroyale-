/// Theme Store Bottom Sheet
/// 
/// Premium UI for selecting table themes and card skins.
/// Features live preview and unlockable progression.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:clubroyale/core/theme/game_themes.dart';
import 'package:clubroyale/features/store/theme_store_provider.dart';

/// Show the theme store bottom sheet
void showThemeStoreBottomSheet(BuildContext context) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) => const ThemeStoreBottomSheet(),
  );
}

class ThemeStoreBottomSheet extends ConsumerStatefulWidget {
  const ThemeStoreBottomSheet({super.key});

  @override
  ConsumerState<ThemeStoreBottomSheet> createState() => _ThemeStoreBottomSheetState();
}

class _ThemeStoreBottomSheetState extends ConsumerState<ThemeStoreBottomSheet> {
  GameTheme? _previewTheme;
  CardSkin? _previewSkin;

  @override
  Widget build(BuildContext context) {
    final customization = ref.watch(userCustomizationProvider);
    final selectedTheme = ref.watch(selectedThemeProvider);
    final selectedSkin = ref.watch(selectedCardSkinProvider);
    final userLevel = ref.watch(userLevelProvider);

    final previewTheme = _previewTheme ?? selectedTheme;
    final previewSkin = _previewSkin ?? selectedSkin;

    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
      decoration: BoxDecoration(
        color: const Color(0xFF0D4A2E),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        border: Border.all(color: Colors.amber.shade600, width: 2),
      ),
      child: Column(
        children: [
          // Handle bar
          Container(
            margin: const EdgeInsets.only(top: 12),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.amber.shade400,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          
          // Title
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Icon(Icons.palette_outlined, color: Colors.amber.shade400, size: 28),
                const SizedBox(width: 12),
                const Text(
                  'Customize Your Table',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.amber.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.amber.shade600),
                  ),
                  child: Text(
                    'Level $userLevel',
                    style: TextStyle(color: Colors.amber.shade400, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          ),

          // Live Preview
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16),
            height: 160,
            decoration: BoxDecoration(
              gradient: previewTheme.gradient,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: previewTheme.accentColor.withValues(alpha: 0.5)),
              boxShadow: [
                BoxShadow(
                  color: previewTheme.primaryColor.withValues(alpha: 0.3),
                  blurRadius: 16,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Card suit pattern
                ...List.generate(4, (i) {
                  final suits = ['♠', '♥', '♣', '♦'];
                  final colors = [Colors.white, Colors.red, Colors.white, Colors.red];
                  return Positioned(
                    left: 30.0 + i * 70,
                    top: 60,
                    child: Text(
                      suits[i],
                      style: TextStyle(
                        color: colors[i].withValues(alpha: 0.15),
                        fontSize: 48,
                      ),
                    ).animate().fadeIn(delay: (100 * i).ms),
                  );
                }),
                // Preview cards
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildPreviewCard('A', '♠', previewSkin),
                    const SizedBox(width: 8),
                    _buildPreviewCard('K', '♥', previewSkin, isRed: true),
                    const SizedBox(width: 8),
                    _buildPreviewCard('Q', '♣', previewSkin),
                  ],
                ),
              ],
            ),
          ).animate().fadeIn().scale(begin: const Offset(0.95, 0.95)),

          const SizedBox(height: 24),

          // Theme Selection
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Icon(Icons.color_lens_outlined, color: Colors.amber.shade400, size: 20),
                const SizedBox(width: 8),
                const Text(
                  'Table Themes',
                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 100,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: GameTheme.values.length,
              itemBuilder: (context, index) {
                final theme = GameTheme.values[index];
                final isSelected = selectedTheme == theme;
                final isUnlocked = theme.isUnlocked(userLevel);
                final isPreviewing = _previewTheme == theme;

                return GestureDetector(
                  onTap: () {
                    setState(() => _previewTheme = theme);
                    if (isUnlocked) {
                      ref.read(themeSelectionProvider.notifier).selectTheme(theme);
                    }
                  },
                  child: Container(
                    width: 80,
                    margin: const EdgeInsets.only(right: 12),
                    decoration: BoxDecoration(
                      gradient: theme.gradient,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isPreviewing || isSelected ? Colors.amber.shade400 : Colors.transparent,
                        width: 2,
                      ),
                    ),
                    child: Stack(
                      children: [
                        // Theme name
                        Positioned(
                          bottom: 8,
                          left: 8,
                          right: 8,
                          child: Text(
                            theme.name,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        // Lock overlay
                        if (!isUnlocked)
                          Container(
                            decoration: BoxDecoration(
                              color: Colors.black.withValues(alpha: 0.6),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Icon(Icons.lock, color: Colors.white60, size: 24),
                                  const SizedBox(height: 4),
                                  Text(
                                    'Lvl ${theme.unlockLevel}',
                                    style: const TextStyle(color: Colors.white60, fontSize: 10),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        // Selected check
                        if (isSelected && isUnlocked)
                          Positioned(
                            top: 8,
                            right: 8,
                            child: Container(
                              padding: const EdgeInsets.all(2),
                              decoration: BoxDecoration(
                                color: Colors.amber.shade600,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(Icons.check, color: Colors.white, size: 14),
                            ),
                          ),
                      ],
                    ),
                  ).animate(delay: (50 * index).ms).fadeIn().slideX(begin: 0.2),
                );
              },
            ),
          ),

          const SizedBox(height: 24),

          // Card Skin Selection
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Icon(Icons.style_outlined, color: Colors.amber.shade400, size: 20),
                const SizedBox(width: 8),
                const Text(
                  'Card Skins',
                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 100,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: CardSkin.values.length,
              itemBuilder: (context, index) {
                final skin = CardSkin.values[index];
                final isSelected = selectedSkin == skin;
                final isUnlocked = skin.isUnlocked(userLevel);
                final isPreviewing = _previewSkin == skin;

                return GestureDetector(
                  onTap: () {
                    setState(() => _previewSkin = skin);
                    if (isUnlocked) {
                      ref.read(themeSelectionProvider.notifier).selectCardSkin(skin);
                    }
                  },
                  child: Container(
                    width: 80,
                    margin: const EdgeInsets.only(right: 12),
                    decoration: BoxDecoration(
                      color: skin.cardBackColor,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isPreviewing || isSelected ? Colors.amber.shade400 : Colors.transparent,
                        width: 2,
                      ),
                    ),
                    child: Stack(
                      children: [
                        // Skin name
                        Positioned(
                          bottom: 8,
                          left: 8,
                          right: 8,
                          child: Text(
                            skin.name,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        // Exclusive badge
                        if (skin.isExclusive)
                          Positioned(
                            top: 4,
                            left: 4,
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                              decoration: BoxDecoration(
                                color: Colors.amber.shade700,
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: const Text(
                                '★',
                                style: TextStyle(color: Colors.white, fontSize: 10),
                              ),
                            ),
                          ),
                        // Lock overlay
                        if (!isUnlocked)
                          Container(
                            decoration: BoxDecoration(
                              color: Colors.black.withValues(alpha: 0.6),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Icon(Icons.lock, color: Colors.white60, size: 24),
                                  const SizedBox(height: 4),
                                  Text(
                                    'Lvl ${skin.unlockLevel}',
                                    style: const TextStyle(color: Colors.white60, fontSize: 10),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        // Selected check
                        if (isSelected && isUnlocked)
                          Positioned(
                            top: 8,
                            right: 8,
                            child: Container(
                              padding: const EdgeInsets.all(2),
                              decoration: BoxDecoration(
                                color: Colors.amber.shade600,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(Icons.check, color: Colors.white, size: 14),
                            ),
                          ),
                      ],
                    ),
                  ).animate(delay: (50 * index).ms).fadeIn().slideX(begin: 0.2),
                );
              },
            ),
          ),

          const Spacer(),

          // Action buttons
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: Colors.white.withValues(alpha: 0.5)),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: Text(
                      'Close',
                      style: TextStyle(color: Colors.white.withValues(alpha: 0.8)),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  flex: 2,
                  child: FilledButton(
                    onPressed: () => Navigator.pop(context),
                    style: FilledButton.styleFrom(
                      backgroundColor: Colors.amber.shade700,
                      foregroundColor: Colors.black,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: const Text('Apply & Close', style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPreviewCard(String rank, String suit, CardSkin skin, {bool isRed = false}) {
    return Container(
      width: 50,
      height: 70,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.3),
            blurRadius: 8,
            offset: const Offset(2, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            rank,
            style: TextStyle(
              color: isRed ? Colors.red : Colors.black,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            suit,
            style: TextStyle(
              color: isRed ? Colors.red : Colors.black,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }
}
