import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:clubroyale/core/config/admin_config.dart';
import 'package:clubroyale/features/auth/auth_service.dart';
import 'package:clubroyale/features/admin/admin_diamond_service.dart';

/// Screen for creating a new diamond grant request
class GrantRequestScreen extends ConsumerStatefulWidget {
  final String? prefillUserId;

  const GrantRequestScreen({super.key, this.prefillUserId});

  @override
  ConsumerState<GrantRequestScreen> createState() => _GrantRequestScreenState();
}

class _GrantRequestScreenState extends ConsumerState<GrantRequestScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _userIdController;
  final _userEmailController = TextEditingController();
  final _amountController = TextEditingController();
  final _reasonController = TextEditingController();

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _userIdController = TextEditingController(text: widget.prefillUserId ?? '');
  }

  Future<void> _createGrantRequest() async {
    if (!_formKey.currentState!.validate()) return;

    final user = ref.read(authServiceProvider).currentUser;
    if (user == null) return;

    final amount = int.parse(_amountController.text);

    setState(() => _isLoading = true);
    try {
      final adminDiamondService = ref.read(adminDiamondServiceProvider);
      await adminDiamondService.createGrantRequest(
        adminEmail: user.email!,
        targetUserId: _userIdController.text.trim(),
        targetUserEmail: _userEmailController.text.trim(),
        amount: amount,
        reason: _reasonController.text.trim(),
      );

      if (mounted) {
        final needsSecondApproval =
            AdminConfig.getRequiredApprovals(amount) > 1;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              needsSecondApproval
                  ? '✅ Request created! Waiting for second admin approval.'
                  : '✅ Grant executed! User received $amount diamonds.',
            ),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(authServiceProvider).currentUser;
    final theme = Theme.of(context);

    if (user == null || !AdminConfig.isAdmin(user.email ?? '')) {
      return Scaffold(
        appBar: AppBar(title: const Text('Create Grant')),
        body: const Center(child: Text('Access Denied')),
      );
    }

    final maxAmount = AdminConfig.getRole(user.email!) == AdminRole.sub
        ? AdminConfig.subAdminMaxGrant
        : null;

    return Scaffold(
      appBar: AppBar(title: const Text('Create Diamond Grant')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Info card
              Card(
                color: Colors.blue.shade50,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      const Icon(Icons.info_outline, color: Colors.blue),
                      const SizedBox(height: 8),
                      Text(
                        'Grant Approval Rules',
                        style: theme.textTheme.titleMedium,
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        '• < 1,000 💎: 1 admin approval\n'
                        '• 1,000 - 9,999 💎: 2 admin approvals\n'
                        '• ≥ 10,000 💎: 2 admins + 24h delay',
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // User ID field
              TextFormField(
                controller: _userIdController,
                decoration: const InputDecoration(
                  labelText: 'User ID *',
                  hintText: 'Enter Firebase UID',
                  prefixIcon: Icon(Icons.fingerprint),
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'User ID is required';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // User Email field
              TextFormField(
                controller: _userEmailController,
                decoration: const InputDecoration(
                  labelText: 'User Email *',
                  hintText: 'Enter user email',
                  prefixIcon: Icon(Icons.email),
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.emailAddress,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'User email is required';
                  }
                  if (!value.contains('@')) {
                    return 'Invalid email format';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Amount field
              TextFormField(
                controller: _amountController,
                decoration: InputDecoration(
                  labelText: 'Amount *',
                  hintText: 'Enter diamond amount',
                  prefixIcon: const Icon(Icons.diamond),
                  suffixText: '💎',
                  border: const OutlineInputBorder(),
                  helperText: maxAmount != null
                      ? 'Max: $maxAmount diamonds (sub-admin limit)'
                      : null,
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Amount is required';
                  }
                  final amount = int.tryParse(value);
                  if (amount == null || amount < 1) {
                    return 'Enter a valid positive amount';
                  }
                  if (maxAmount != null && amount > maxAmount) {
                    return 'Maximum amount is $maxAmount for sub-admins';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Reason field
              TextFormField(
                controller: _reasonController,
                decoration: const InputDecoration(
                  labelText: 'Reason *',
                  hintText: 'Why are you granting these diamonds?',
                  prefixIcon: Icon(Icons.note),
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Reason is required';
                  }
                  if (value.trim().length < 10) {
                    return 'Please provide a more detailed reason';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),

              // Preview card
              if (_amountController.text.isNotEmpty) ...[
                Card(
                  color: Colors.amber.shade50,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        const Text(
                          'Preview',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 8),
                        Builder(
                          builder: (context) {
                            final amount =
                                int.tryParse(_amountController.text) ?? 0;
                            final approvals = AdminConfig.getRequiredApprovals(
                              amount,
                            );
                            final hasCooling =
                                AdminConfig.requiresCoolingPeriod(amount);
                            return Column(
                              children: [
                                Text('Amount: $amount 💎'),
                                Text('Required Approvals: $approvals'),
                                if (hasCooling)
                                  const Text(
                                    '⏱️ 24h cooling period applies',
                                    style: TextStyle(color: Colors.orange),
                                  ),
                              ],
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),
              ],

              // Submit button
              FilledButton.icon(
                onPressed: _isLoading ? null : _createGrantRequest,
                icon: _isLoading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.add),
                label: const Text('Create Grant Request'),
                style: FilledButton.styleFrom(
                  padding: const EdgeInsets.all(16),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _userIdController.dispose();
    _userEmailController.dispose();
    _amountController.dispose();
    _reasonController.dispose();
    super.dispose();
  }
}
