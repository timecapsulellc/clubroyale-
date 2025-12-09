import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:taasclub/core/config/admin_config.dart';
import 'package:taasclub/features/auth/auth_service.dart';
import 'package:taasclub/features/admin/admin_diamond_service.dart';
import 'package:taasclub/features/admin/admin_chat_service.dart';

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
            onTap: () {
              // TODO: Implement user lookup
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Coming soon!')),
              );
            },
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
              onTap: () {
                // TODO: Implement grant history
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Coming soon!')),
                );
              },
            ),
          ],
        ],
      ),
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
