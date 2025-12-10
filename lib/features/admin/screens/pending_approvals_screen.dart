import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:clubroyale/core/config/admin_config.dart';
import 'package:clubroyale/features/auth/auth_service.dart';
import 'package:clubroyale/features/admin/admin_diamond_service.dart';

/// Screen showing pending grant requests needing approval
class PendingApprovalsScreen extends ConsumerWidget {
  const PendingApprovalsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authServiceProvider).currentUser;
    final theme = Theme.of(context);

    if (user == null || !AdminConfig.isAdmin(user.email ?? '')) {
      return Scaffold(
        appBar: AppBar(title: const Text('Approvals')),
        body: const Center(child: Text('Access Denied')),
      );
    }

    final adminDiamondService = ref.read(adminDiamondServiceProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Pending Approvals'),
      ),
      body: StreamBuilder<List<DiamondRequest>>(
        stream: adminDiamondService.watchRequestsForAdmin(user.email!),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final requests = snapshot.data ?? [];

          if (requests.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.check_circle, size: 64, color: Colors.green),
                  SizedBox(height: 16),
                  Text('No pending approvals'),
                  Text('All caught up! 🎉'),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: requests.length,
            itemBuilder: (context, index) {
              final request = requests[index];
              return _RequestCard(
                request: request,
                currentAdminEmail: user.email!,
                onApprove: () => _approveRequest(context, ref, request.id, user.email!),
                onReject: () => _showRejectDialog(context, ref, request.id, user.email!),
              );
            },
          );
        },
      ),
    );
  }

  Future<void> _approveRequest(
    BuildContext context,
    WidgetRef ref,
    String requestId,
    String adminEmail,
  ) async {
    try {
      final adminDiamondService = ref.read(adminDiamondServiceProvider);
      await adminDiamondService.approveRequest(requestId, adminEmail);
      
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ Request approved!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _showRejectDialog(
    BuildContext context,
    WidgetRef ref,
    String requestId,
    String adminEmail,
  ) async {
    final reasonController = TextEditingController();

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reject Request'),
        content: TextField(
          controller: reasonController,
          decoration: const InputDecoration(
            labelText: 'Reason for rejection',
            border: OutlineInputBorder(),
          ),
          maxLines: 3,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Reject'),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      try {
        final adminDiamondService = ref.read(adminDiamondServiceProvider);
        await adminDiamondService.rejectRequest(
          requestId,
          adminEmail,
          reasonController.text,
        );

        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Request rejected'),
              backgroundColor: Colors.orange,
            ),
          );
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }

    reasonController.dispose();
  }
}

class _RequestCard extends StatelessWidget {
  final DiamondRequest request;
  final String currentAdminEmail;
  final VoidCallback onApprove;
  final VoidCallback onReject;

  const _RequestCard({
    required this.request,
    required this.currentAdminEmail,
    required this.onApprove,
    required this.onReject,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final requiredApprovals = AdminConfig.getRequiredApprovals(request.amount);
    final hasCooling = AdminConfig.requiresCoolingPeriod(request.amount);
    final isOwnRequest = request.requestedBy == currentAdminEmail;

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: _getStatusColor(request.status).withOpacity(0.2),
                  child: Icon(
                    _getStatusIcon(request.status),
                    color: _getStatusColor(request.status),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        request.targetUserEmail,
                        style: theme.textTheme.titleMedium,
                      ),
                      Text(
                        'ID: ${request.targetUserId.substring(0, 8)}...',
                        style: theme.textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.amber.shade100,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '${request.amount} 💎',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.amber,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Reason
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Reason:', style: TextStyle(fontWeight: FontWeight.bold)),
                  Text(request.reason),
                ],
              ),
            ),
            const SizedBox(height: 12),

            // Approval progress
            Row(
              children: [
                const Icon(Icons.verified_user, size: 16, color: Colors.grey),
                const SizedBox(width: 4),
                Text(
                  'Approvals: ${request.approvals.length}/$requiredApprovals',
                  style: theme.textTheme.bodySmall,
                ),
                if (hasCooling) ...[
                  const SizedBox(width: 12),
                  const Icon(Icons.timer, size: 16, color: Colors.orange),
                  const SizedBox(width: 4),
                  const Text(
                    '24h cooling',
                    style: TextStyle(fontSize: 12, color: Colors.orange),
                  ),
                ],
              ],
            ),

            // Requested by
            const SizedBox(height: 8),
            Text(
              'Requested by: ${request.requestedBy}',
              style: theme.textTheme.bodySmall?.copyWith(color: Colors.grey),
            ),

            // Actions
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                if (isOwnRequest && requiredApprovals > 1)
                  const Text(
                    'Waiting for other admin',
                    style: TextStyle(color: Colors.grey),
                  )
                else ...[
                  OutlinedButton.icon(
                    onPressed: onReject,
                    icon: const Icon(Icons.close),
                    label: const Text('Reject'),
                    style: OutlinedButton.styleFrom(foregroundColor: Colors.red),
                  ),
                  const SizedBox(width: 8),
                  FilledButton.icon(
                    onPressed: onApprove,
                    icon: const Icon(Icons.check),
                    label: const Text('Approve'),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'pending':
        return Colors.orange;
      case 'cooling_period':
        return Colors.blue;
      case 'approved':
        return Colors.green;
      case 'rejected':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  IconData _getStatusIcon(String status) {
    switch (status) {
      case 'pending':
        return Icons.pending;
      case 'cooling_period':
        return Icons.timer;
      case 'approved':
        return Icons.check_circle;
      case 'rejected':
        return Icons.cancel;
      default:
        return Icons.help;
    }
  }
}
