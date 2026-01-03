import 'package:flutter/material.dart';
import 'package:clubroyale/core/services/feedback_service.dart';

/// Dialog for collecting user feedback
class FeedbackDialog extends StatefulWidget {
  const FeedbackDialog({super.key});

  /// Show the feedback dialog
  static Future<void> show(BuildContext context) {
    return showDialog(
      context: context,
      builder: (context) => const FeedbackDialog(),
    );
  }

  @override
  State<FeedbackDialog> createState() => _FeedbackDialogState();
}

class _FeedbackDialogState extends State<FeedbackDialog> {
  final _formKey = GlobalKey<FormState>();
  final _messageController = TextEditingController();
  final _emailController = TextEditingController();
  final _feedbackService = FeedbackService();

  FeedbackType _selectedType = FeedbackType.general;
  bool _isSubmitting = false;

  @override
  void dispose() {
    _messageController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSubmitting = true);

    try {
      await _feedbackService.submitFeedback(
        type: _selectedType,
        message: _messageController.text.trim(),
        email: _emailController.text.trim().isNotEmpty
            ? _emailController.text.trim()
            : null,
      );

      if (mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Thank you for your feedback!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to submit feedback: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AlertDialog(
      title: Row(
        children: [
          Icon(Icons.feedback_outlined, color: theme.colorScheme.primary),
          const SizedBox(width: 8),
          const Text('Send Feedback'),
        ],
      ),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Feedback type selector
              Text('Type', style: theme.textTheme.labelLarge),
              const SizedBox(height: 8),
              SegmentedButton<FeedbackType>(
                segments: FeedbackType.values.map((type) {
                  return ButtonSegment(
                    value: type,
                    label: Text(_getShortLabel(type)),
                    icon: Icon(_getIcon(type)),
                  );
                }).toList(),
                selected: {_selectedType},
                onSelectionChanged: (selection) {
                  setState(() => _selectedType = selection.first);
                },
              ),
              const SizedBox(height: 16),

              // Message input
              TextFormField(
                controller: _messageController,
                decoration: const InputDecoration(
                  labelText: 'Your feedback',
                  hintText: 'Tell us what you think...',
                  border: OutlineInputBorder(),
                  alignLabelWithHint: true,
                ),
                maxLines: 4,
                maxLength: 1000,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter your feedback';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 8),

              // Email input (optional)
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(
                  labelText: 'Email (optional)',
                  hintText: 'For follow-up',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.emailAddress,
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isSubmitting ? null : () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        FilledButton.icon(
          onPressed: _isSubmitting ? null : _submit,
          icon: _isSubmitting
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Icon(Icons.send),
          label: const Text('Submit'),
        ),
      ],
    );
  }

  String _getShortLabel(FeedbackType type) {
    switch (type) {
      case FeedbackType.bug:
        return 'Bug';
      case FeedbackType.feature:
        return 'Feature';
      case FeedbackType.general:
        return 'General';
    }
  }

  IconData _getIcon(FeedbackType type) {
    switch (type) {
      case FeedbackType.bug:
        return Icons.bug_report;
      case FeedbackType.feature:
        return Icons.lightbulb_outline;
      case FeedbackType.general:
        return Icons.chat_bubble_outline;
    }
  }
}
