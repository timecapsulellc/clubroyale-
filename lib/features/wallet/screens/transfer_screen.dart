import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:clubroyale/features/auth/auth_service.dart';
import 'package:clubroyale/features/wallet/diamond_transfer_service.dart';
import 'package:clubroyale/features/wallet/diamond_service.dart';

/// Screen for sending and receiving diamond transfers
class TransferScreen extends ConsumerStatefulWidget {
  const TransferScreen({super.key});

  @override
  ConsumerState<TransferScreen> createState() => _TransferScreenState();
}

class _TransferScreenState extends ConsumerState<TransferScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Transfer Diamonds'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(icon: Icon(Icons.send), text: 'Send'),
            Tab(icon: Icon(Icons.inbox), text: 'Incoming'),
            Tab(icon: Icon(Icons.outbox), text: 'Outgoing'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: const [
          _SendTab(),
          _IncomingTab(),
          _OutgoingTab(),
        ],
      ),
    );
  }
}

/// Tab for sending diamonds
class _SendTab extends ConsumerStatefulWidget {
  const _SendTab();

  @override
  ConsumerState<_SendTab> createState() => _SendTabState();
}

class _SendTabState extends ConsumerState<_SendTab> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _noteController = TextEditingController();
  final _searchController = TextEditingController();
  
  bool _isLoading = false;
  bool _isSearching = false;
  List<TransferRecipient> _searchResults = [];
  TransferRecipient? _selectedRecipient;

  Future<void> _searchUsers(String query) async {
    if (query.length < 2) {
      setState(() => _searchResults = []);
      return;
    }

    setState(() => _isSearching = true);
    try {
      final transferService = ref.read(diamondTransferServiceProvider);
      final results = await transferService.searchUsers(query);
      setState(() => _searchResults = results);
    } finally {
      setState(() => _isSearching = false);
    }
  }

  Future<void> _sendTransfer() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedRecipient == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a recipient')),
      );
      return;
    }

    final user = ref.read(authServiceProvider).currentUser;
    if (user == null) return;

    setState(() => _isLoading = true);
    try {
      final transferService = ref.read(diamondTransferServiceProvider);
      final result = await transferService.initiateTransfer(
        fromUserId: user.uid,
        fromUserName: user.displayName ?? 'Unknown',
        toUserId: _selectedRecipient!.userId,
        toUserName: _selectedRecipient!.displayName,
        amount: int.parse(_amountController.text),
        note: _noteController.text.isNotEmpty ? _noteController.text : null,
      );

      if (mounted) {
        if (result.success) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('✅ Transfer initiated! Waiting for recipient to confirm.'),
              backgroundColor: Colors.green,
            ),
          );
          _amountController.clear();
          _noteController.clear();
          _searchController.clear();
          setState(() {
            _selectedRecipient = null;
            _searchResults = [];
          });
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(result.reason ?? 'Transfer failed'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(authServiceProvider).currentUser;
    if (user == null) {
      return const Center(child: Text('Please sign in'));
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Balance display
            StreamBuilder(
              stream: ref.read(diamondServiceProvider).watchWallet(user.uid),
              builder: (context, snapshot) {
                final balance = snapshot.data?.balance ?? 0;
                return Card(
                  color: Colors.amber.shade50,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text('Your Balance: ', style: TextStyle(fontSize: 18)),
                        Text(
                          '$balance 💎',
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.amber,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 24),

            // Recipient search
            TextFormField(
              controller: _searchController,
              decoration: InputDecoration(
                labelText: 'Search recipient',
                hintText: 'Enter username...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _isSearching
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : null,
                border: const OutlineInputBorder(),
              ),
              onChanged: _searchUsers,
            ),

            // Search results
            if (_searchResults.isNotEmpty)
              Card(
                margin: const EdgeInsets.only(top: 8),
                child: Column(
                  children: _searchResults.map((recipient) {
                    final isSelected = _selectedRecipient?.userId == recipient.userId;
                    return ListTile(
                      leading: CircleAvatar(
                        backgroundImage: recipient.photoUrl != null
                            ? NetworkImage(recipient.photoUrl!)
                            : null,
                        child: recipient.photoUrl == null
                            ? Text(recipient.displayName[0].toUpperCase())
                            : null,
                      ),
                      title: Text(recipient.displayName),
                      trailing: isSelected
                          ? const Icon(Icons.check_circle, color: Colors.green)
                          : null,
                      selected: isSelected,
                      onTap: () {
                        setState(() {
                          _selectedRecipient = recipient;
                          _searchController.text = recipient.displayName;
                          _searchResults = [];
                        });
                      },
                    );
                  }).toList(),
                ),
              ),

            // Selected recipient chip
            if (_selectedRecipient != null) ...[
              const SizedBox(height: 16),
              Chip(
                avatar: const Icon(Icons.person, size: 18),
                label: Text('To: ${_selectedRecipient!.displayName}'),
                deleteIcon: const Icon(Icons.close, size: 18),
                onDeleted: () => setState(() => _selectedRecipient = null),
              ),
            ],

            const SizedBox(height: 16),

            // Amount field
            TextFormField(
              controller: _amountController,
              decoration: const InputDecoration(
                labelText: 'Amount',
                hintText: 'Enter amount...',
                prefixIcon: Icon(Icons.diamond),
                suffixText: '💎',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Enter an amount';
                }
                final amount = int.tryParse(value);
                if (amount == null || amount < 1) {
                  return 'Enter a valid amount';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // Note field
            TextFormField(
              controller: _noteController,
              decoration: const InputDecoration(
                labelText: 'Note (optional)',
                hintText: 'Add a message...',
                prefixIcon: Icon(Icons.note),
                border: OutlineInputBorder(),
              ),
              maxLines: 2,
            ),
            const SizedBox(height: 24),

            // Send button
            FilledButton.icon(
              onPressed: _isLoading ? null : _sendTransfer,
              icon: _isLoading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.send),
              label: const Text('Send Diamonds'),
              style: FilledButton.styleFrom(
                padding: const EdgeInsets.all(16),
              ),
            ),

            const SizedBox(height: 16),
            const Text(
              '⚠️ Transfers are held until the recipient confirms receipt.\n'
              '📅 Pending transfers expire after 48 hours.',
              style: TextStyle(color: Colors.grey, fontSize: 12),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _amountController.dispose();
    _noteController.dispose();
    _searchController.dispose();
    super.dispose();
  }
}

/// Tab for incoming transfers
class _IncomingTab extends ConsumerWidget {
  const _IncomingTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authServiceProvider).currentUser;
    if (user == null) {
      return const Center(child: Text('Please sign in'));
    }

    final transferService = ref.read(diamondTransferServiceProvider);

    return StreamBuilder<List<DiamondTransfer>>(
      stream: transferService.watchIncomingTransfers(user.uid),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        final transfers = snapshot.data ?? [];

        if (transfers.isEmpty) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.inbox, size: 64, color: Colors.grey),
                SizedBox(height: 16),
                Text('No pending incoming transfers'),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: transfers.length,
          itemBuilder: (context, index) {
            final transfer = transfers[index];
            return _TransferCard(
              transfer: transfer,
              isIncoming: true,
              onConfirm: () async {
                final result = await transferService.confirmAsReceiver(
                  transfer.id,
                  user.uid,
                );
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        result.success
                            ? '✅ Transfer confirmed! Diamonds received.'
                            : result.reason ?? 'Error',
                      ),
                      backgroundColor: result.success ? Colors.green : Colors.red,
                    ),
                  );
                }
              },
            );
          },
        );
      },
    );
  }
}

/// Tab for outgoing transfers
class _OutgoingTab extends ConsumerWidget {
  const _OutgoingTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authServiceProvider).currentUser;
    if (user == null) {
      return const Center(child: Text('Please sign in'));
    }

    final transferService = ref.read(diamondTransferServiceProvider);

    return StreamBuilder<List<DiamondTransfer>>(
      stream: transferService.watchOutgoingTransfers(user.uid),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        final transfers = snapshot.data ?? [];

        if (transfers.isEmpty) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.outbox, size: 64, color: Colors.grey),
                SizedBox(height: 16),
                Text('No pending outgoing transfers'),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: transfers.length,
          itemBuilder: (context, index) {
            final transfer = transfers[index];
            return _TransferCard(
              transfer: transfer,
              isIncoming: false,
              onCancel: () async {
                final result = await transferService.cancelTransfer(
                  transfer.id,
                  user.uid,
                );
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        result.success
                            ? '❌ Transfer cancelled. Diamonds returned.'
                            : result.reason ?? 'Error',
                      ),
                      backgroundColor: result.success ? Colors.orange : Colors.red,
                    ),
                  );
                }
              },
            );
          },
        );
      },
    );
  }
}

/// Transfer card widget
class _TransferCard extends StatelessWidget {
  final DiamondTransfer transfer;
  final bool isIncoming;
  final VoidCallback? onConfirm;
  final VoidCallback? onCancel;

  const _TransferCard({
    required this.transfer,
    required this.isIncoming,
    this.onConfirm,
    this.onCancel,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: isIncoming ? Colors.green.shade100 : Colors.blue.shade100,
                  child: Icon(
                    isIncoming ? Icons.arrow_downward : Icons.arrow_upward,
                    color: isIncoming ? Colors.green : Colors.blue,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        isIncoming
                            ? 'From: ${transfer.fromUserName}'
                            : 'To: ${transfer.toUserName}',
                        style: theme.textTheme.titleMedium,
                      ),
                      Text(
                        transfer.timeRemaining,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ),
                Text(
                  '${transfer.amount} 💎',
                  style: theme.textTheme.titleLarge?.copyWith(
                    color: Colors.amber.shade700,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            if (transfer.note != null) ...[
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(transfer.note!, style: const TextStyle(fontStyle: FontStyle.italic)),
              ),
            ],
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                if (isIncoming && onConfirm != null)
                  FilledButton.icon(
                    onPressed: onConfirm,
                    icon: const Icon(Icons.check),
                    label: const Text('Confirm Received'),
                  ),
                if (!isIncoming && onCancel != null)
                  OutlinedButton.icon(
                    onPressed: onCancel,
                    icon: const Icon(Icons.close),
                    label: const Text('Cancel'),
                    style: OutlinedButton.styleFrom(foregroundColor: Colors.red),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
