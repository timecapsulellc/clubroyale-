import 'package:flutter/material.dart';
class VariantSwitch extends StatelessWidget {
  final String label;
  final String description;
  final String? detailedExplanation; // New field for long explanation
  final bool value;
  final ValueChanged<bool> onChanged;

  const VariantSwitch({
    required this.label,
    required this.description,
    this.detailedExplanation,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      label,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    if (detailedExplanation != null) ...[
                      const SizedBox(width: 4),
                      GestureDetector(
                        onTap: () => _showExplanation(context),
                        child: Icon(
                          Icons.info_outline,
                          size: 16,
                          color: Colors.white.withValues(alpha: 0.5),
                        ),
                      ),
                    ],
                  ],
                ),
                Text(
                  description,
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.6),
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: Colors.amber.shade400,
            activeTrackColor: Colors.amber.shade900,
          ),
        ],
      ),
    );
  }

  void _showExplanation(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1E1E2C), // Dark theme
        title: Text(label, style: const TextStyle(color: Colors.white)),
        content: Text(
          detailedExplanation!,
          style: const TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Got it'),
          ),
        ],
      ),
    );
  }
}
