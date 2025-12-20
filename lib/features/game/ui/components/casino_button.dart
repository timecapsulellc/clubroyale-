import 'package:flutter/material.dart';
import 'package:clubroyale/core/theme/app_theme.dart';

class CasinoButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final Color backgroundColor;
  final Color borderColor;
  final Color? textColor;
  final IconData? icon;
  final bool isLarge;

  const CasinoButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.backgroundColor = AppTheme.teal,
    this.borderColor = AppTheme.gold,
    this.textColor,
    this.icon,
    this.isLarge = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.3),
            blurRadius: 4,
            offset: const Offset(0, 2),
            spreadRadius: 1,
          ),
        ],
      ),
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: backgroundColor,
          foregroundColor: textColor ?? Colors.white,
          side: BorderSide(color: borderColor, width: 2), // The Gold Border
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
          padding: EdgeInsets.symmetric(
            horizontal: isLarge ? 32 : 16,
            vertical: isLarge ? 16 : 8,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(icon, size: isLarge ? 20 : 16),
              const SizedBox(width: 8),
            ],
            Text(
              label.toUpperCase(),
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: textColor ?? Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: isLarge ? 18 : 14,
                letterSpacing: 1.0,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
