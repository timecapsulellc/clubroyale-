import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:clubroyale/core/services/localization_service.dart';
import 'dart:ui';

class GameActionsHUD extends ConsumerWidget {
  final VoidCallback? onShowCards; // "SHOW"
  final VoidCallback? onSequence; // "SEQ"
  final VoidCallback? onDublee; // "DUB"
  final VoidCallback? onCancel; // "CAN"
  final bool isShowEnabled;
  final bool isSequenceEnabled;
  final bool isDubleeEnabled;
  final bool isCancelEnabled;

  const GameActionsHUD({
    super.key,
    this.onShowCards,
    this.onSequence,
    this.onDublee,
    this.onCancel,
    this.isShowEnabled = false,
    this.isSequenceEnabled = false,
    this.isDubleeEnabled = false,
    this.isCancelEnabled = false,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Determine screen orientation
    final isLandscape = MediaQuery.of(context).orientation == Orientation.landscape;

    return Align(
      alignment: Alignment.centerRight,
      child: Container(
        margin: EdgeInsets.only(
          right: isLandscape ? 16.0 : 8.0, 
          bottom: isLandscape ? 0 : 80.0 // Lift up in portrait to clear hand
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(30),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(30),
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.1),
                  width: 1,
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _ActionButton(
                    label: 'btn_dublee'.tr(ref), // DUB
                    icon: Icons.copy_all_rounded,
                    onTap: onDublee,
                    isEnabled: isDubleeEnabled,
                    isLandscape: isLandscape,
                  ),
                  const SizedBox(height: 12),
                  _ActionButton(
                    label: 'btn_sequence'.tr(ref), // SEQ
                    icon: Icons.format_list_numbered_rounded,
                    onTap: onSequence,
                    isEnabled: isSequenceEnabled,
                    isLandscape: isLandscape,
                  ),
                  const SizedBox(height: 12),
                  _ActionButton(
                    label: 'btn_show'.tr(ref), // SHOW
                    icon: Icons.visibility_rounded,
                    onTap: onShowCards,
                    isEnabled: isShowEnabled,
                    isPrimary: true,
                    isLandscape: isLandscape,
                  ),
                  if (onCancel != null) ...[
                     const SizedBox(height: 12),
                    _ActionButton(
                      label: 'btn_cancel'.tr(ref),
                      icon: Icons.close_rounded,
                      onTap: onCancel,
                      isEnabled: isCancelEnabled,
                      isDestructive: true,
                      isLandscape: isLandscape,
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback? onTap;
  final bool isEnabled;
  final bool isPrimary;
  final bool isDestructive;
  final bool isLandscape;

  const _ActionButton({
    required this.label,
    required this.icon,
    this.onTap,
    this.isEnabled = false,
    this.isPrimary = false,
    this.isDestructive = false,
    required this.isLandscape,
  });

  @override
  Widget build(BuildContext context) {
    // Scale down slightly on mobile portrait
    final size = isLandscape ? 56.0 : 48.0; 
    
    final Color baseColor = isDestructive 
        ? Colors.red 
        : (isPrimary ? const Color(0xFFD4AF37) : Colors.white); // Gold for primary

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: isEnabled ? onTap : null,
        customBorder: const CircleBorder(),
        child: Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isEnabled 
                ? baseColor.withValues(alpha: 0.2) 
                : Colors.grey.withValues(alpha: 0.1),
            border: Border.all(
              color: isEnabled 
                  ? baseColor.withValues(alpha: 0.8) 
                  : Colors.white.withValues(alpha: 0.1),
              width: 1.5,
            ),
            boxShadow: isPrimary && isEnabled
                ? [
                    BoxShadow(
                      color: baseColor.withValues(alpha: 0.4),
                      blurRadius: 8,
                      spreadRadius: 1,
                    )
                  ]
                : null,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: size * 0.4,
                color: isEnabled ? baseColor : Colors.white24,
              ),
              const SizedBox(height: 2),
              Text(
                label,
                style: TextStyle(
                  color: isEnabled ? baseColor : Colors.white24,
                  fontSize: size * 0.18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
