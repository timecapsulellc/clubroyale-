import 'package:flutter/material.dart';
import 'package:taasclub/core/theme/app_theme.dart';

class CasinoButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final Color backgroundColor;
  final Color borderColor;
  final bool isLarge;

  const CasinoButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.backgroundColor = AppTheme.teal,
    this.borderColor = AppTheme.gold,
    this.isLarge = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
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
          foregroundColor: Colors.white,
          side: BorderSide(color: borderColor, width: 2), // The Gold Border
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
          padding: EdgeInsets.symmetric(
            horizontal: isLarge ? 32 : 16,
            vertical: isLarge ? 16 : 8,
          ),
        ),
        child: Text(
          label.toUpperCase(),
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: isLarge ? 18 : 14,
            letterSpacing: 1.0,
          ),
        ),
      ),
    );
  }
}
