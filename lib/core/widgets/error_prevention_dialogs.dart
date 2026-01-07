import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// PhD Audit Finding #13: Error Prevention Dialogs
/// Confirms for critical actions (Maal discard, invalid sets)
/// Includes 3-second undo window

/// Shows confirmation dialog before discarding a Maal (high-value) card
Future<bool> confirmMaalDiscard(
  BuildContext context, {
  required String cardName,
  required int maalPoints,
}) async {
  HapticFeedback.mediumImpact();
  
  final result = await showDialog<bool>(
    context: context,
    barrierDismissible: false,
    builder: (context) => AlertDialog(
      backgroundColor: const Color(0xFF1a0a2e),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Colors.amber.withValues(alpha: 0.5)),
      ),
      title: Row(
        children: [
          Icon(Icons.warning_amber_rounded, color: Colors.amber, size: 28),
          const SizedBox(width: 8),
          const Text(
            'Discard Maal Card?',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'You are about to discard:',
            style: TextStyle(color: Colors.white70),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.amber.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.amber.withValues(alpha: 0.3)),
            ),
            child: Row(
              children: [
                Text(
                  cardName,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.amber,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '$maalPoints pts',
                    style: const TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Text(
            '⚠️ This is a high-value card!\nAre you sure you want to discard it?',
            style: TextStyle(color: Colors.orange.shade200),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: const Text(
            'Keep Card',
            style: TextStyle(color: Colors.white70),
          ),
        ),
        FilledButton(
          onPressed: () => Navigator.pop(context, true),
          style: FilledButton.styleFrom(
            backgroundColor: Colors.amber,
            foregroundColor: Colors.black,
          ),
          child: const Text('Discard Anyway'),
        ),
      ],
    ),
  );
  
  return result ?? false;
}

/// Shows validation error for invalid set formation
void showInvalidSetError(
  BuildContext context, {
  required String errorMessage,
}) {
  HapticFeedback.heavyImpact();
  
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Row(
        children: [
          const Icon(Icons.error_outline, color: Colors.white),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              errorMessage,
              style: const TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
      backgroundColor: Colors.red.shade700,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      duration: const Duration(seconds: 3),
    ),
  );
}

/// Shows real-time set validation feedback
class SetValidationFeedback extends StatelessWidget {
  final bool isValid;
  final String? validationMessage;
  
  const SetValidationFeedback({
    super.key,
    required this.isValid,
    this.validationMessage,
  });
  
  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: isValid 
            ? Colors.green.withValues(alpha: 0.2)
            : Colors.red.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isValid ? Colors.green : Colors.red,
          width: 1.5,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isValid ? Icons.check_circle : Icons.error_outline,
            color: isValid ? Colors.green : Colors.red,
            size: 18,
          ),
          const SizedBox(width: 6),
          Text(
            validationMessage ?? (isValid ? 'Valid Set ✓' : 'Invalid Set'),
            style: TextStyle(
              color: isValid ? Colors.green : Colors.red,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

/// Undo action widget with 3-second countdown
class UndoActionWidget extends StatefulWidget {
  final String actionDescription;
  final VoidCallback onUndo;
  final VoidCallback? onTimeout;
  final Duration duration;
  
  const UndoActionWidget({
    super.key,
    required this.actionDescription,
    required this.onUndo,
    this.onTimeout,
    this.duration = const Duration(seconds: 3),
  });
  
  @override
  State<UndoActionWidget> createState() => _UndoActionWidgetState();
}

class _UndoActionWidgetState extends State<UndoActionWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  
  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.duration,
    )..forward().then((_) {
      widget.onTimeout?.call();
    });
  }
  
  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.black87,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white24),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              return Stack(
                alignment: Alignment.center,
                children: [
                  SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      value: 1 - _controller.value,
                      strokeWidth: 2,
                      color: Colors.amber,
                      backgroundColor: Colors.white24,
                    ),
                  ),
                  Text(
                    '${((1 - _controller.value) * widget.duration.inSeconds).ceil()}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              );
            },
          ),
          const SizedBox(width: 12),
          Text(
            widget.actionDescription,
            style: const TextStyle(color: Colors.white70),
          ),
          const SizedBox(width: 12),
          TextButton(
            onPressed: () {
              _controller.stop();
              widget.onUndo();
            },
            style: TextButton.styleFrom(
              backgroundColor: Colors.amber.withValues(alpha: 0.2),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            ),
            child: const Text(
              'UNDO',
              style: TextStyle(
                color: Colors.amber,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Shows undo snackbar for reversible actions
void showUndoSnackbar(
  BuildContext context, {
  required String actionDescription,
  required VoidCallback onUndo,
  Duration duration = const Duration(seconds: 3),
}) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Row(
        children: [
          Text(actionDescription, style: const TextStyle(color: Colors.white)),
          const Spacer(),
          TextButton(
            onPressed: () {
              ScaffoldMessenger.of(context).hideCurrentSnackBar();
              onUndo();
            },
            child: const Text(
              'UNDO',
              style: TextStyle(color: Colors.amber, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
      backgroundColor: Colors.black87,
      behavior: SnackBarBehavior.floating,
      duration: duration,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
    ),
  );
}
