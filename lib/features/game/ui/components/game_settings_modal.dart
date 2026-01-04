import 'package:flutter/material.dart';
import 'package:clubroyale/config/casino_theme.dart';
import 'package:clubroyale/core/services/sound_service.dart';

/// A reusable in-game settings modal with volume and notification controls.
class GameSettingsModal extends StatefulWidget {
  final String? gameName;
  final VoidCallback? onClose;

  const GameSettingsModal({
    super.key,
    this.gameName,
    this.onClose,
  });

  /// Shows the modal as a bottom sheet.
  static Future<void> show(BuildContext context, {String? gameName}) {
    return showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) => GameSettingsModal(
        gameName: gameName,
        onClose: () => Navigator.pop(ctx),
      ),
    );
  }

  @override
  State<GameSettingsModal> createState() => _GameSettingsModalState();
}

class _GameSettingsModalState extends State<GameSettingsModal> {
  double _musicVolume = 0.7;
  double _sfxVolume = 1.0;
  bool _notificationsEnabled = true;
  bool _vibrationsEnabled = true;

  @override
  void initState() {
    super.initState();
    // TODO: Load persisted settings from SharedPreferences or Hive
  }

  void _saveSettings() {
    // TODO: Persist settings
    SoundService.setMusicVolume(_musicVolume);
    SoundService.setSfxVolume(_sfxVolume);
    widget.onClose?.call();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: CasinoColors.cardBackground,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.5),
            blurRadius: 20,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                widget.gameName != null
                    ? '${widget.gameName} Settings'
                    : 'Game Settings',
                style: const TextStyle(
                  color: CasinoColors.gold,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.close, color: Colors.white54),
                onPressed: widget.onClose,
              ),
            ],
          ),
          const Divider(color: Colors.white24),
          const SizedBox(height: 16),

          // Music Volume
          _buildSliderRow(
            icon: Icons.music_note,
            label: 'Music',
            value: _musicVolume,
            onChanged: (v) => setState(() => _musicVolume = v),
          ),

          const SizedBox(height: 16),

          // SFX Volume
          _buildSliderRow(
            icon: Icons.volume_up,
            label: 'Sound Effects',
            value: _sfxVolume,
            onChanged: (v) => setState(() => _sfxVolume = v),
          ),

          const SizedBox(height: 24),

          // Toggles
          _buildToggleRow(
            icon: Icons.notifications,
            label: 'Notifications',
            value: _notificationsEnabled,
            onChanged: (v) => setState(() => _notificationsEnabled = v),
          ),
          _buildToggleRow(
            icon: Icons.vibration,
            label: 'Vibrations',
            value: _vibrationsEnabled,
            onChanged: (v) => setState(() => _vibrationsEnabled = v),
          ),

          const SizedBox(height: 24),

          // Save Button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _saveSettings,
              style: ElevatedButton.styleFrom(
                backgroundColor: CasinoColors.gold,
                foregroundColor: Colors.black,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                'Save Settings',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
            ),
          ),

          // Safe area padding
          SizedBox(height: MediaQuery.of(context).viewInsets.bottom + 16),
        ],
      ),
    );
  }

  Widget _buildSliderRow({
    required IconData icon,
    required String label,
    required double value,
    required ValueChanged<double> onChanged,
  }) {
    return Row(
      children: [
        Icon(icon, color: Colors.white54, size: 24),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(color: Colors.white, fontSize: 14),
              ),
              SliderTheme(
                data: SliderTheme.of(context).copyWith(
                  activeTrackColor: CasinoColors.gold,
                  inactiveTrackColor: Colors.white24,
                  thumbColor: CasinoColors.gold,
                  overlayColor: CasinoColors.gold.withValues(alpha: 0.2),
                ),
                child: Slider(
                  value: value,
                  onChanged: onChanged,
                ),
              ),
            ],
          ),
        ),
        SizedBox(
          width: 40,
          child: Text(
            '${(value * 100).round()}%',
            style: const TextStyle(color: Colors.white54, fontSize: 12),
            textAlign: TextAlign.end,
          ),
        ),
      ],
    );
  }

  Widget _buildToggleRow({
    required IconData icon,
    required String label,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, color: Colors.white54, size: 24),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              label,
              style: const TextStyle(color: Colors.white, fontSize: 14),
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeThumbColor: CasinoColors.gold,
          ),
        ],
      ),
    );
  }
}
