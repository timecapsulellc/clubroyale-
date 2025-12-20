/// Marriage Game Settings Widget
/// 
/// Toggle switches for configuring Marriage game rules
/// Used in room creation flow
library;

import 'package:flutter/material.dart';
import 'package:clubroyale/games/marriage/marriage_config.dart';

/// Widget for configuring Marriage game rules
class MarriageSettingsWidget extends StatefulWidget {
  final MarriageGameConfig initialConfig;
  final ValueChanged<MarriageGameConfig> onConfigChanged;
  
  const MarriageSettingsWidget({
    super.key,
    this.initialConfig = const MarriageGameConfig(),
    required this.onConfigChanged,
  });
  
  @override
  State<MarriageSettingsWidget> createState() => _MarriageSettingsWidgetState();
}

class _MarriageSettingsWidgetState extends State<MarriageSettingsWidget> {
  late MarriageGameConfig _config;
  
  @override
  void initState() {
    super.initState();
    _config = widget.initialConfig;
  }
  
  void _updateConfig(MarriageGameConfig Function(MarriageGameConfig) updater) {
    setState(() {
      _config = updater(_config);
    });
    widget.onConfigChanged(_config);
  }
  
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Preset selector
        _buildPresetSelector(colorScheme),
        
        const SizedBox(height: 16),
        const Divider(),
        
        // Section: Core Rules
        _buildSectionHeader('Core Rules', Icons.gavel),
        
        _buildToggle(
          title: 'Joker Blocks Discard',
          subtitle: 'Next player cannot pick from discard if Joker is on top',
          value: _config.jokerBlocksDiscard,
          onChanged: (v) => _updateConfig((c) => c.copyWith(jokerBlocksDiscard: v)),
          icon: Icons.block,
        ),
        
        _buildToggle(
          title: 'Allow Wild Card Pickup',
          subtitle: 'Can pick Tiplu/Jhiplu/Poplu from discard pile',
          value: _config.canPickupWildFromDiscard,
          onChanged: (v) => _updateConfig((c) => c.copyWith(canPickupWildFromDiscard: v)),
          icon: Icons.visibility,
        ),
        
        _buildToggle(
          title: 'Pure Sequence Required',
          subtitle: 'Must have at least one sequence without wilds to declare',
          value: _config.requirePureSequence,
          onChanged: (v) => _updateConfig((c) => c.copyWith(requirePureSequence: v)),
          icon: Icons.check_circle,
        ),
        
        _buildToggle(
          title: 'Marriage Required to Win',
          subtitle: 'Must have K+Q pair in melds to declare',
          value: _config.requireMarriageToWin,
          onChanged: (v) => _updateConfig((c) => c.copyWith(requireMarriageToWin: v)),
          icon: Icons.favorite,
        ),
        
        const Divider(),
        
        // Section: Bonus Rules
        _buildSectionHeader('Bonus Points', Icons.star),
        
        _buildToggle(
          title: 'Dublee Bonus',
          subtitle: '+25 points for two sequences of same suit',
          value: _config.dubleeBonus,
          onChanged: (v) => _updateConfig((c) => c.copyWith(dubleeBonus: v)),
          icon: Icons.looks_two,
        ),
        
        _buildToggle(
          title: 'Tunnel Bonus',
          subtitle: '+50 points for 3 identical cards (same suit from 3 decks)',
          value: _config.tunnelBonus,
          onChanged: (v) => _updateConfig((c) => c.copyWith(tunnelBonus: v)),
          icon: Icons.filter_3,
        ),
        
        _buildToggle(
          title: 'Marriage Bonus',
          subtitle: '+100 points for K+Q pair in melds',
          value: _config.marriageBonus,
          onChanged: (v) => _updateConfig((c) => c.copyWith(marriageBonus: v)),
          icon: Icons.favorite_border,
        ),
        
        const Divider(),
        
        // Section: Game Settings
        _buildSectionHeader('Game Settings', Icons.settings),
        
        _buildSlider(
          title: 'Turn Timeout',
          subtitle: '${_config.turnTimeoutSeconds} seconds per turn',
          value: _config.turnTimeoutSeconds.toDouble(),
          min: 15,
          max: 120,
          divisions: 7,
          onChanged: (v) => _updateConfig((c) => c.copyWith(turnTimeoutSeconds: v.round())),
          icon: Icons.timer,
        ),
        
        _buildSlider(
          title: 'Max Wilds in Meld',
          subtitle: '${_config.maxWildsInMeld} wild cards per meld',
          value: _config.maxWildsInMeld.toDouble(),
          min: 1,
          max: 4,
          divisions: 3,
          onChanged: (v) => _updateConfig((c) => c.copyWith(maxWildsInMeld: v.round())),
          icon: Icons.style,
        ),
        
        _buildSlider(
          title: 'Total Rounds',
          subtitle: '${_config.totalRounds} rounds per game',
          value: _config.totalRounds.toDouble(),
          min: 1,
          max: 10,
          divisions: 9,
          onChanged: (v) => _updateConfig((c) => c.copyWith(totalRounds: v.round())),
          icon: Icons.repeat,
        ),
        
        const Divider(),
        
        // Section: Penalties
        _buildSectionHeader('Penalties', Icons.warning_amber),
        
        _buildSlider(
          title: 'No Life Penalty',
          subtitle: '${_config.noLifePenalty} points for no pure sequence',
          value: _config.noLifePenalty.toDouble(),
          min: 50,
          max: 200,
          divisions: 6,
          onChanged: (v) => _updateConfig((c) => c.copyWith(noLifePenalty: v.round())),
          icon: Icons.heart_broken,
        ),
      ],
    );
  }
  
  Widget _buildPresetSelector(ColorScheme colorScheme) {
    return Row(
      children: [
        Text('Preset: ', style: TextStyle(color: colorScheme.onSurface)),
        const SizedBox(width: 8),
        ChoiceChip(
          label: const Text('Nepali'),
          selected: _config.presetName == 'Nepali Standard',
          onSelected: (selected) {
            if (selected) {
              setState(() => _config = MarriageGameConfig.nepaliStandard);
              widget.onConfigChanged(_config);
            }
          },
        ),
        const SizedBox(width: 8),
        ChoiceChip(
          label: const Text('Indian'),
          selected: _config.presetName == 'Indian Rummy',
          onSelected: (selected) {
            if (selected) {
              setState(() => _config = MarriageGameConfig.indianRummy);
              widget.onConfigChanged(_config);
            }
          },
        ),
        const SizedBox(width: 8),
        ChoiceChip(
          label: const Text('Casual'),
          selected: _config.presetName == 'Casual',
          onSelected: (selected) {
            if (selected) {
              setState(() => _config = MarriageGameConfig.casual);
              widget.onConfigChanged(_config);
            }
          },
        ),
      ],
    );
  }
  
  Widget _buildSectionHeader(String title, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Theme.of(context).colorScheme.primary),
          const SizedBox(width: 8),
          Text(
            title,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildToggle({
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
    required IconData icon,
  }) {
    return ListTile(
      leading: Icon(icon, color: value ? Theme.of(context).colorScheme.primary : Colors.grey),
      title: Text(title),
      subtitle: Text(subtitle, style: const TextStyle(fontSize: 12)),
      trailing: Switch(
        value: value,
        onChanged: onChanged,
      ),
      contentPadding: EdgeInsets.zero,
    );
  }
  
  Widget _buildSlider({
    required String title,
    required String subtitle,
    required double value,
    required double min,
    required double max,
    required int divisions,
    required ValueChanged<double> onChanged,
    required IconData icon,
  }) {
    return ListTile(
      leading: Icon(icon, color: Theme.of(context).colorScheme.primary),
      title: Text(title),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(subtitle, style: const TextStyle(fontSize: 12)),
          Slider(
            value: value,
            min: min,
            max: max,
            divisions: divisions,
            onChanged: onChanged,
          ),
        ],
      ),
      contentPadding: EdgeInsets.zero,
    );
  }
}

/// Compact version for room creation dialog
class MarriageSettingsCompact extends StatelessWidget {
  final MarriageGameConfig config;
  final VoidCallback onEditPressed;
  
  const MarriageSettingsCompact({
    super.key,
    required this.config,
    required this.onEditPressed,
  });
  
  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            const Icon(Icons.tune, size: 24),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Rules: ${config.presetName}',
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                  Text(
                    _getRuleSummary(),
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            ),
            TextButton(
              onPressed: onEditPressed,
              child: const Text('Edit'),
            ),
          ],
        ),
      ),
    );
  }
  
  String _getRuleSummary() {
    final rules = <String>[];
    if (config.jokerBlocksDiscard) rules.add('Joker Block');
    if (!config.canPickupWildFromDiscard) rules.add('Wild Block');
    if (config.requirePureSequence) rules.add('Life Required');
    if (config.marriageBonus) rules.add('Marriage Bonus');
    return rules.join(' • ');
  }
}
