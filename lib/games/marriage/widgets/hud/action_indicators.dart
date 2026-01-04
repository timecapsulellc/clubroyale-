import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:clubroyale/config/casino_theme.dart';

/// Action indicator bubble showing what an opponent is doing
/// Displays above opponent avatar during their turn
class ActionIndicatorBubble extends StatelessWidget {
  final OpponentAction action;
  final bool isVisible;

  const ActionIndicatorBubble({
    super.key,
    required this.action,
    required this.isVisible,
  });

  @override
  Widget build(BuildContext context) {
    if (!isVisible) return const SizedBox.shrink();

    return Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: _getBackgroundColor(),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: _getBorderColor(), width: 1),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.3),
                blurRadius: 6,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildIcon(),
              const SizedBox(width: 6),
              Text(
                _getText(),
                style: TextStyle(
                  color: _getTextColor(),
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                ),
              ),
              if (action == OpponentAction.thinking) _buildDots(),
            ],
          ),
        )
        .animate()
        .fadeIn(duration: 200.ms)
        .slideY(begin: 0.3, end: 0, duration: 200.ms);
  }

  Color _getBackgroundColor() {
    switch (action) {
      case OpponentAction.drawing:
        return Colors.blue.withValues(alpha: 0.9);
      case OpponentAction.thinking:
        return Colors.grey[800]!;
      case OpponentAction.discarding:
        return Colors.orange.withValues(alpha: 0.9);
      case OpponentAction.visiting:
        return Colors.green.withValues(alpha: 0.9);
      case OpponentAction.declaring:
        return CasinoColors.gold.withValues(alpha: 0.9);
    }
  }

  Color _getBorderColor() {
    switch (action) {
      case OpponentAction.drawing:
        return Colors.blue[300]!;
      case OpponentAction.thinking:
        return Colors.grey[600]!;
      case OpponentAction.discarding:
        return Colors.orange[300]!;
      case OpponentAction.visiting:
        return Colors.green[300]!;
      case OpponentAction.declaring:
        return CasinoColors.gold;
    }
  }

  Color _getTextColor() {
    switch (action) {
      case OpponentAction.declaring:
        return Colors.black;
      default:
        return Colors.white;
    }
  }

  Widget _buildIcon() {
    IconData icon;
    double size = 14;

    switch (action) {
      case OpponentAction.drawing:
        icon = Icons.download;
      case OpponentAction.thinking:
        icon = Icons.psychology;
      case OpponentAction.discarding:
        icon = Icons.upload;
      case OpponentAction.visiting:
        icon = Icons.visibility;
      case OpponentAction.declaring:
        icon = Icons.emoji_events;
    }

    return Icon(icon, size: size, color: _getTextColor());
  }

  String _getText() {
    switch (action) {
      case OpponentAction.drawing:
        return 'Drawing';
      case OpponentAction.thinking:
        return 'Thinking';
      case OpponentAction.discarding:
        return 'Discarding';
      case OpponentAction.visiting:
        return 'Visiting!';
      case OpponentAction.declaring:
        return 'Got it!';
    }
  }

  Widget _buildDots() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(3, (index) {
        return Container(
              width: 4,
              height: 4,
              margin: const EdgeInsets.only(left: 2),
              decoration: const BoxDecoration(
                color: Colors.white70,
                shape: BoxShape.circle,
              ),
            )
            .animate(
              delay: Duration(milliseconds: index * 200),
              onPlay: (c) => c.repeat(),
            )
            .fadeIn(duration: 200.ms)
            .then(delay: 400.ms)
            .fadeOut(duration: 200.ms);
      }),
    );
  }
}

/// Types of opponent actions
enum OpponentAction { drawing, thinking, discarding, visiting, declaring }

/// Tooltip showing what card opponent drew/discarded
class CardActionTooltip extends StatelessWidget {
  final String cardSymbol; // e.g., "7♠"
  final bool isRed;
  final CardActionType actionType;

  const CardActionTooltip({
    super.key,
    required this.cardSymbol,
    required this.isRed,
    required this.actionType,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: Colors.black.withValues(alpha: 0.8),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.white24),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                actionType == CardActionType.drew
                    ? Icons.download
                    : Icons.upload,
                size: 12,
                color: Colors.white70,
              ),
              const SizedBox(width: 4),
              Text(
                cardSymbol,
                style: TextStyle(
                  color: isRed ? Colors.red : Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        )
        .animate()
        .fadeIn(duration: 150.ms)
        .slideY(begin: -0.3, end: 0, duration: 150.ms)
        .then(delay: 1500.ms)
        .fadeOut(duration: 200.ms);
  }
}

enum CardActionType { drew, discarded }

/// Floating Maal point popup (e.g., "+3 Tiplu!")
class MaalPointPopup extends StatelessWidget {
  final int points;
  final String maalType; // 'Tiplu', 'Poplu', 'Jhiplu', 'Alter'

  const MaalPointPopup({
    super.key,
    required this.points,
    required this.maalType,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Colors.amber, Colors.orange],
            ),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.amber.withValues(alpha: 0.5),
                blurRadius: 8,
                spreadRadius: 1,
              ),
            ],
          ),
          child: Text(
            '+$points $maalType!',
            style: const TextStyle(
              color: Colors.black,
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
        )
        .animate()
        .fadeIn(duration: 200.ms)
        .scale(
          begin: const Offset(0.5, 0.5),
          end: const Offset(1, 1),
          duration: 200.ms,
          curve: Curves.easeOutBack,
        )
        .slideY(begin: 0, end: -0.5, duration: 1000.ms, curve: Curves.easeOut)
        .then(delay: 500.ms)
        .fadeOut(duration: 300.ms);
  }
}

/// Visit success indicator
class VisitSuccessIndicator extends StatelessWidget {
  final String visitType; // 'Sequence' or 'Dublee'

  const VisitSuccessIndicator({super.key, required this.visitType});

  @override
  Widget build(BuildContext context) {
    return Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: BoxDecoration(
            gradient: const LinearGradient(colors: [Colors.green, Colors.teal]),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.green.withValues(alpha: 0.5),
                blurRadius: 12,
                spreadRadius: 2,
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.check_circle, color: Colors.white, size: 20),
              const SizedBox(width: 8),
              Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'VISITED!',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1,
                    ),
                  ),
                  Text(
                    'via $visitType',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.8),
                      fontSize: 10,
                    ),
                  ),
                ],
              ),
            ],
          ),
        )
        .animate()
        .fadeIn(duration: 200.ms)
        .scale(
          begin: const Offset(0.8, 0.8),
          end: const Offset(1, 1),
          duration: 300.ms,
          curve: Curves.easeOutBack,
        )
        .then(delay: 2000.ms)
        .fadeOut(duration: 300.ms);
  }
}
