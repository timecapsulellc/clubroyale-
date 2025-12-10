import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:taasclub/core/config/game_terminology.dart';
import 'package:taasclub/core/config/game_settings.dart';
import 'package:taasclub/core/config/club_royale_theme.dart';

/// Terminology Toggle Widget for Settings Screen
/// 
/// Allows users to switch between Global (ClubRoyale) 
/// and South Asian (Marriage) terminology
class TerminologyToggle extends ConsumerStatefulWidget {
  final VoidCallback? onChanged;
  
  const TerminologyToggle({
    this.onChanged,
    super.key,
  });

  @override
  ConsumerState<TerminologyToggle> createState() => _TerminologyToggleState();
}

class _TerminologyToggleState extends ConsumerState<TerminologyToggle> {
  @override
  Widget build(BuildContext context) {
    final settingsAsync = ref.watch(gameSettingsInitProvider);
    
    return settingsAsync.when(
      loading: () => const ListTile(
        leading: Icon(Icons.language, color: ClubRoyaleTheme.gold),
        title: Text('Game Terminology'),
        trailing: SizedBox(width: 24, height: 24, child: CircularProgressIndicator(strokeWidth: 2)),
      ),
      error: (e, s) => ListTile(
        leading: const Icon(Icons.error, color: Colors.red),
        title: const Text('Error loading settings'),
        subtitle: Text(e.toString()),
      ),
      data: (settings) => _buildToggle(settings),
    );
  }
  
  Widget _buildToggle(GameSettings settings) {
    final isSouthAsian = settings.isSouthAsian;
    
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: ClubRoyaleTheme.deepPurple.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: ClubRoyaleTheme.gold.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              const Icon(Icons.language, color: ClubRoyaleTheme.gold, size: 28),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Game Terminology',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      settings.regionDisplayName,
                      style: TextStyle(color: ClubRoyaleTheme.textMuted, fontSize: 12),
                    ),
                  ],
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 16),
          
          // Toggle Switch
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: Colors.black26,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Expanded(
                  child: _buildRegionButton(
                    emoji: '🌍',
                    label: 'ClubRoyale',
                    subtitle: 'International',
                    isSelected: !isSouthAsian,
                    onTap: () => _setRegion(GameRegion.global, settings),
                  ),
                ),
                Expanded(
                  child: _buildRegionButton(
                    emoji: '🇳🇵',
                    label: 'Marriage',
                    subtitle: 'दक्षिण एशिया',
                    isSelected: isSouthAsian,
                    onTap: () => _setRegion(GameRegion.southAsia, settings),
                  ),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Preview
          _buildTerminologyPreview(isSouthAsian),
        ],
      ),
    );
  }
  
  Widget _buildRegionButton({
    required String emoji,
    required String label,
    required String subtitle,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        decoration: BoxDecoration(
          color: isSelected ? ClubRoyaleTheme.gold : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          children: [
            Text(emoji, style: const TextStyle(fontSize: 24)),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? ClubRoyaleTheme.deepPurple : Colors.white70,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                fontSize: 14,
              ),
            ),
            Text(
              subtitle,
              style: TextStyle(
                color: isSelected ? ClubRoyaleTheme.deepPurple.withValues(alpha: 0.7) : Colors.white38,
                fontSize: 10,
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildTerminologyPreview(bool isSouthAsian) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.black12,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Preview',
            style: TextStyle(color: ClubRoyaleTheme.gold, fontSize: 12, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          _buildTermRow(
            isSouthAsian ? 'Tiplu' : 'Wild Card',
            isSouthAsian ? '👰' : '🃏',
          ),
          _buildTermRow(
            isSouthAsian ? 'Marriage' : 'Royal Sequence',
            isSouthAsian ? '💒' : '👑',
          ),
          _buildTermRow(
            isSouthAsian ? 'Declare' : 'Go Royale',
            isSouthAsian ? '🏆' : '🎯',
          ),
        ],
      ),
    );
  }
  
  Widget _buildTermRow(String term, String emoji) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          Text(emoji, style: const TextStyle(fontSize: 14)),
          const SizedBox(width: 8),
          Text(term, style: const TextStyle(color: Colors.white70, fontSize: 13)),
        ],
      ),
    );
  }
  
  Future<void> _setRegion(GameRegion region, GameSettings settings) async {
    await settings.setRegion(region);
    setState(() {});
    widget.onChanged?.call();
  }
}
