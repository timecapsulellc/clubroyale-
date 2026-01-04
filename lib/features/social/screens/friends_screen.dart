import 'package:flutter/material.dart';
import 'package:clubroyale/core/utils/error_helper.dart';
import 'package:clubroyale/core/widgets/contextual_loader.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:go_router/go_router.dart';
import '../services/friend_service.dart';
import '../services/social_service.dart';
import '../services/presence_service.dart';
import '../models/social_user_model.dart';
import 'dart:async'; // For Timer

class FriendsScreen extends ConsumerStatefulWidget {
  const FriendsScreen({super.key});

  @override
  ConsumerState<FriendsScreen> createState() => _FriendsScreenState();
}

class _FriendsScreenState extends ConsumerState<FriendsScreen>
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
        title: const Text('Connect'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Friends'),
            Tab(text: 'Requests'),
            Tab(text: 'Find'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: const [MyFriendsTab(), FriendRequestsTab(), FindFriendsTab()],
      ),
    );
  }
}

// -----------------------------------------------------
// TAB 1: MY FRIENDS
// -----------------------------------------------------
class MyFriendsTab extends ConsumerWidget {
  const MyFriendsTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final friendIdsStream = ref.watch(friendServiceProvider).watchMyFriendIds();

    return StreamBuilder<List<String>>(
      stream: friendIdsStream,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const ContextualLoader(
            message: 'Loading friends...',
            icon: Icons.people,
          );
        }
        final ids = snapshot.data ?? [];

        if (ids.isEmpty) {
          return EmptyStateWidget(
            icon: Icons.people_outline,
            title: 'No friends yet',
            subtitle: 'Find and add friends to play together!',
            actionLabel: 'Find People',
            onAction: () {},
          );
        }

        // Fetch User Data for each ID (FutureBuilder or specialized stream)
        // Ideally we should have a provider family that streams user data.
        // For now, simpler: ListView with UserTile that fetches/streams individual user data.

        return ListView.separated(
          itemCount: ids.length,
          separatorBuilder: (_, __) => const Divider(height: 1),
          itemBuilder: (context, index) {
            return FriendTile(userId: ids[index]);
          },
        );
      },
    );
  }
}

class FriendTile extends ConsumerWidget {
  final String userId;
  const FriendTile({super.key, required this.userId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statusStream = ref
        .watch(presenceServiceProvider)
        .watchUserStatus(userId);
    final userFuture = ref.watch(socialServiceProvider).getUserProfile(userId);

    return FutureBuilder<SocialUser?>(
      future: userFuture,
      builder: (context, snapshot) {
        final user = snapshot.data;
        final name = user?.displayName ?? 'User $userId';
        final avatarUrl = user?.avatarUrl;

        return ListTile(
          leading: Stack(
            children: [
              CircleAvatar(
                backgroundImage: avatarUrl != null
                    ? CachedNetworkImageProvider(avatarUrl)
                    : null,
                child: avatarUrl == null
                    ? Text(name.isNotEmpty ? name[0].toUpperCase() : '?')
                    : null,
              ),
              Positioned(
                right: 0,
                bottom: 0,
                child: StreamBuilder<SocialUserStatus>(
                  stream: statusStream,
                  builder: (c, s) {
                    if (!s.hasData) return const SizedBox();
                    final isOnline = s.data!.status == UserStatus.online;
                    return Container(
                      width: 12,
                      height: 12,
                      decoration: BoxDecoration(
                        color: isOnline ? Colors.green : Colors.grey,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
          title: Text(name),
          subtitle: StreamBuilder<SocialUserStatus>(
            stream: statusStream,
            builder: (c, s) {
              final status = s.data?.status;
              return Text(status?.name ?? 'offline');
            },
          ),
          trailing: IconButton(
            icon: const Icon(Icons.chat_bubble_outline),
            onPressed: () async {
              final chatId = await ref
                  .read(socialServiceProvider)
                  .createDirectChat(userId);
              if (context.mounted) context.push('/social/chat/$chatId');
            },
          ),
        );
      },
    );
  }
}

// -----------------------------------------------------
// TAB 2: REQUESTS
// -----------------------------------------------------
class FriendRequestsTab extends ConsumerWidget {
  const FriendRequestsTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final requestsStream = ref
        .watch(friendServiceProvider)
        .watchIncomingRequests();

    return StreamBuilder<List<FriendRequest>>(
      stream: requestsStream,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        final requests = snapshot.data ?? [];

        if (requests.isEmpty) {
          return const Center(child: Text('No pending requests'));
        }

        return ListView.builder(
          itemCount: requests.length,
          itemBuilder: (context, index) {
            final req = requests[index];
            return ListTile(
              leading: const CircleAvatar(child: Icon(Icons.person_add)),
              title: Text("Request from ${req.from}"), // Need to fetch name
              subtitle: Text("Sent at ${req.createdAt}"),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(Icons.check, color: Colors.green),
                    onPressed: () => ref
                        .read(friendServiceProvider)
                        .acceptFriendRequest(req.id),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.red),
                    onPressed: () => ref
                        .read(friendServiceProvider)
                        .rejectFriendRequest(req.id),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}

// -----------------------------------------------------
// TAB 3: FIND FRIENDS (SEARCH)
// -----------------------------------------------------
class FindFriendsTab extends ConsumerStatefulWidget {
  const FindFriendsTab({super.key});

  @override
  ConsumerState<FindFriendsTab> createState() => _FindFriendsTabState();
}

class _FindFriendsTabState extends ConsumerState<FindFriendsTab> {
  final _searchController = TextEditingController();
  List<SocialUser> _results = [];
  bool _loading = false;
  Timer? _debounce;

  void _onSearchChanged(String query) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () async {
      if (query.trim().isEmpty) {
        setState(() => _results = []);
        return;
      }

      setState(() => _loading = true);
      try {
        final results = await ref
            .read(friendServiceProvider)
            .searchUsers(query);
        setState(() => _results = results);
      } catch (e) {
        // Handle error
      } finally {
        setState(() => _loading = false);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: TextField(
            controller: _searchController,
            decoration: const InputDecoration(
              prefixIcon: Icon(Icons.search),
              hintText: 'Search by name...',
              border: OutlineInputBorder(),
            ),
            onChanged: _onSearchChanged,
          ),
        ),
        if (_loading) const LinearProgressIndicator(),

        Expanded(
          child: ListView.builder(
            itemCount: _results.length,
            itemBuilder: (context, index) {
              final user = _results[index];
              return ListTile(
                leading: CircleAvatar(
                  backgroundImage: user.avatarUrl != null
                      ? CachedNetworkImageProvider(user.avatarUrl!)
                      : null,
                  child: user.avatarUrl == null
                      ? Text(user.displayName[0])
                      : null,
                ),
                title: Text(user.displayName),
                trailing: IconButton(
                  icon: const Icon(Icons.person_add),
                  onPressed: () async {
                    try {
                      await ref
                          .read(friendServiceProvider)
                          .sendFriendRequest(user.id);
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Request sent')),
                        );
                      }
                    } catch (e) {
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(ErrorHelper.getFriendlyMessage(e)),
                          ),
                        );
                      }
                    }
                  },
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
