import 'package:flutter/material.dart';
import 'package:clubroyale/core/utils/error_helper.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:clubroyale/core/config/admin_config.dart';
import 'package:clubroyale/features/auth/auth_service.dart';
import 'package:clubroyale/features/admin/admin_diamond_service.dart';
import 'package:clubroyale/features/admin/admin_chat_service.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

/// Admin panel dashboard screen
class AdminPanelScreen extends ConsumerWidget {
  const AdminPanelScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authServiceProvider).currentUser;
    final theme = Theme.of(context);

    if (user == null || !AdminConfig.isAdmin(user.email ?? '')) {
      return Scaffold(
        appBar: AppBar(title: const Text('Admin Panel')),
        body: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.lock, size: 64, color: Colors.grey),
              SizedBox(height: 16),
              Text('Access Denied'),
              Text('You are not an admin'),
            ],
          ),
        ),
      );
    }

    final adminDiamondService = ref.read(adminDiamondServiceProvider);
    final adminChatService = ref.read(adminChatServiceProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Panel'),
        actions: [
          Chip(
            avatar: const Icon(Icons.verified_user, size: 16),
            label: Text(
              AdminConfig.isPrimaryAdmin(user.email!) ? 'Primary' : 'Sub',
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Welcome card
          Card(
            color: theme.colorScheme.primaryContainer,
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  const Icon(Icons.admin_panel_settings, size: 48),
                  const SizedBox(height: 8),
                  Text(
                    'Welcome, ${user.displayName ?? 'Admin'}!',
                    style: theme.textTheme.headlineSmall,
                  ),
                  Text(user.email ?? ''),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Pending approvals
          StreamBuilder<List<DiamondRequest>>(
            stream: adminDiamondService.watchRequestsForAdmin(user.email!),
            builder: (context, snapshot) {
              final count = snapshot.data?.length ?? 0;
              return _AdminMenuCard(
                icon: Icons.pending_actions,
                title: 'Pending Approvals',
                subtitle: '$count requests waiting',
                badgeCount: count,
                onTap: () => context.push('/admin/approvals'),
              );
            },
          ),

          // Support chats
          StreamBuilder<List<SupportChat>>(
            stream: adminChatService.watchOpenChats(),
            builder: (context, snapshot) {
              final count = snapshot.data?.length ?? 0;
              final unread = snapshot.data?.where((c) => c.unreadByAdmin).length ?? 0;
              return _AdminMenuCard(
                icon: Icons.chat,
                title: 'Support Chats',
                subtitle: '$count open chats',
                badgeCount: unread,
                onTap: () => context.push('/admin/chats'),
              );
            },
          ),

          // Create grant
          _AdminMenuCard(
            icon: Icons.add_circle,
            title: 'Create Grant',
            subtitle: 'Grant diamonds to a user',
            onTap: () => context.push('/admin/grant'),
          ),

          // User lookup
          _AdminMenuCard(
            icon: Icons.search,
            title: 'User Lookup',
            subtitle: 'Find user by email or ID',
            onTap: () => _showUserLookup(context, ref),
          ),

          if (AdminConfig.isPrimaryAdmin(user.email!)) ...[
            const SizedBox(height: 24),
            Text(
              'Primary Admin Only',
              style: theme.textTheme.titleMedium?.copyWith(color: Colors.grey),
            ),
            const SizedBox(height: 8),

            // Manage sub-admins
            _AdminMenuCard(
              icon: Icons.people,
              title: 'Manage Admins',
              subtitle: 'Add or remove sub-admins',
              onTap: () {
                // TODO: Implement admin management
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Coming soon!')),
                );
              },
            ),

            // View all grants
            _AdminMenuCard(
              icon: Icons.history,
              title: 'Grant History',
              subtitle: 'View all past grants',
              onTap: () => _showGrantHistory(context, ref),
            ),
          ],
        ],
      ),
    );
  }

  void _showUserLookup(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => const _UserLookupDialog(),
    );
  }

  void _showGrantHistory(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.7,
          minChildSize: 0.5,
          maxChildSize: 0.9,
          expand: false,
          builder: (context, scrollController) {
            final historyStream = ref.watch(adminDiamondServiceProvider).watchGrantHistory();
            
            return Column(
              children: [
                AppBar(
                  title: const Text('Grant History'),
                  leading: const SizedBox(),
                  actions: [
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
                Expanded(
                  child: StreamBuilder(
                    stream: historyStream,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      }
                      
                      final history = snapshot.data ?? [];
                      if (history.isEmpty) {
                        return const Center(child: Text('No grant history found.'));
                      }
                      
                      return ListView.builder(
                        controller: scrollController,
                        itemCount: history.length,
                        itemBuilder: (context, index) {
                          final grant = history[index];
                          final isRejected = grant.status == 'rejected';
                          final date = grant.createdAt != null 
                              ? DateFormat('MMM d, h:mm a').format(grant.createdAt!) 
                              : 'Unknown';
                          
                          return ListTile(
                            leading: CircleAvatar(
                              backgroundColor: isRejected ? Colors.red.shade100 : Colors.green.shade100,
                              child: Icon(
                                isRejected ? Icons.block : Icons.check, 
                                color: isRejected ? Colors.red : Colors.green
                              ),
                            ),
                            title: Text('${grant.amount} Diamonds -> ${grant.targetUserEmail}'),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('${grant.reason} • $date'),
                                Text('By: ${grant.requestedBy}'),
                                if (isRejected)
                                  Text('Rejected: ${grant.approvals}', style: const TextStyle(color: Colors.red)),
                              ],
                            ),
                            isThreeLine: true,
                          );
                        },
                      );
                    },
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }
}

class _UserLookupDialog extends ConsumerStatefulWidget {
  const _UserLookupDialog();

  @override
  ConsumerState<_UserLookupDialog> createState() => _UserLookupDialogState();
}

class _UserLookupDialogState extends ConsumerState<_UserLookupDialog> {
  final _searchController = TextEditingController();
  List<dynamic> _results = []; // List<SocialUser>
  bool _loading = false;

  Future<void> _search() async {
    if (_searchController.text.isEmpty) return;
    
    setState(() => _loading = true);
    try {
      final results = await ref.read(adminDiamondServiceProvider).lookupUser(_searchController.text);
      if (mounted) {
        setState(() => _results = results);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(ErrorHelper.getFriendlyMessage(e))));
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('User Lookup'),
      content: SizedBox(
        width: double.maxFinite,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Email, ID, or Name',
                suffixIcon: IconButton(
                  icon: const Icon(Icons.search),
                  onPressed: _search,
                ),
              ),
              onSubmitted: (_) => _search(),
            ),
            const SizedBox(height: 16),
            if (_loading)
              const LinearProgressIndicator()
            else if (_results.isNotEmpty)
              Flexible(
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: _results.length,
                  itemBuilder: (context, index) {
                    final user = _results[index];
                    return ListTile(
                      leading: CircleAvatar(
                        backgroundImage: user.avatarUrl != null ? NetworkImage(user.avatarUrl) : null,
                        child: user.avatarUrl == null ? Text(user.displayName[0]) : null,
                      ),
                      title: Text(user.displayName),
                      subtitle: Text(user.email ?? user.id),
                      onTap: () {
                        Clipboard.setData(ClipboardData(text: user.id));
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Copied ID: ${user.id}')),
                        );
                        Navigator.pop(context);
                      },
                    );
                  },
                ),
              )
            else if (_searchController.text.isNotEmpty && !_loading)
              const Text('No users found'),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Close'),
        ),
      ],
    );
  }
}

class _AdminMenuCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final int badgeCount;
  final VoidCallback? onTap;

  const _AdminMenuCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    this.badgeCount = 0,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: Stack(
          children: [
            CircleAvatar(
              backgroundColor: Colors.purple.shade100,
              child: Icon(icon, color: Colors.purple),
            ),
            if (badgeCount > 0)
              Positioned(
                right: 0,
                top: 0,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: const BoxDecoration(
                    color: Colors.red,
                    shape: BoxShape.circle,
                  ),
                  child: Text(
                    '$badgeCount',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
          ],
        ),
        title: Text(title),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: onTap,
      ),
    );
  }
}
