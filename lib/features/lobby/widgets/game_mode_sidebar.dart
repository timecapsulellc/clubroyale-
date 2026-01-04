import 'package:flutter/material.dart';
import 'package:clubroyale/config/casino_theme.dart';
import 'package:clubroyale/core/config/game_terminology.dart';

class GameModeSidebar extends StatelessWidget {
  final String selectedGameId;
  final Function(String) onGameSelected;

  const GameModeSidebar({
    super.key,
    required this.selectedGameId,
    required this.onGameSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 240,
      decoration: BoxDecoration(
        color: CasinoColors.deepPurple.withValues(alpha: 0.8),
        border: Border(
          right: BorderSide(
            color: CasinoColors.gold.withValues(alpha: 0.3),
            width: 1,
          ),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 100), // Space for Top-Left Profile
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Text(
              'GAME MODES',
              style: TextStyle(
                color: CasinoColors.gold.withValues(alpha: 0.7),
                fontSize: 12,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.2,
              ),
            ),
          ),
          _buildGameItem(
            id: 'marriage',
            label: GameTerminology.royalMeldGame,
            icon: Icons.layers_rounded,
          ),
          _buildGameItem(
            id: 'call_break',
            label: GameTerminology.callBreakGame,
            icon: Icons.style_rounded,
          ),
          _buildGameItem(
            id: 'teen_patti',
            label: GameTerminology.teenPattiGame,
            icon: Icons.casino_rounded,
          ),
          _buildGameItem(
            id: 'in_between',
            label: GameTerminology.inBetweenGame,
            icon: Icons.unfold_more_rounded,
            isNew: true,
          ),
        ],
      ),
    );
  }

  Widget _buildGameItem({
    required String id,
    required String label,
    required IconData icon,
    bool isNew = false,
  }) {
    final isSelected = selectedGameId == id;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => onGameSelected(id),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          decoration: BoxDecoration(
            color: isSelected
                ? CasinoColors.gold.withValues(alpha: 0.1)
                : Colors.transparent,
            border: Border(
              left: BorderSide(
                color: isSelected ? CasinoColors.gold : Colors.transparent,
                width: 4,
              ),
            ),
          ),
          child: Row(
            children: [
              Icon(
                icon,
                color: isSelected ? CasinoColors.gold : Colors.grey.shade400,
                size: 24,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  label,
                  style: TextStyle(
                    color: isSelected ? Colors.white : Colors.grey.shade400,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                    fontSize: 16,
                  ),
                ),
              ),
              if (isNew)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.red,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: const Text(
                    'NEW',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
