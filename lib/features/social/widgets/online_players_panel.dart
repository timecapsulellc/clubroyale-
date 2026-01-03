/// Online Players Panel
///
/// Shows list of online players in the lobby with invite/friend actions.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:clubroyale/features/social/presence_service.dart';
import 'package:clubroyale/features/social/friends_service.dart';
import 'package:clubroyale/features/social/invite_service.dart';

class OnlinePlayersPanel extends ConsumerWidget {
  final String? currentRoomId;
  final String? roomCode;
  final String gameType;

  const OnlinePlayersPanel({
    super.key,
    this.currentRoomId,
    this.roomCode,
    this.gameType = 'marriage',
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final onlineUsersAsync = ref.watch(onlineUsersProvider);
    final myFriendsAsync = ref.watch(myFriendsProvider);

    return Container(
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.deepPurple.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.deepPurple.shade800, Colors.purple.shade600],
              ),
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(16),
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: Colors.green,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.green.withValues(alpha: 0.5),
                        blurRadius: 6,
                      ),
                    ],
                  ),
                  child: const SizedBox(width: 6, height: 6),
                ),
                const SizedBox(width: 8),
                const Text(
                  'Online Players',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                const Spacer(),
                onlineUsersAsync.when(
                  data: (users) => Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '${users.length}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  loading: () => const SizedBox.shrink(),
                  error: (_, __) => const SizedBox.shrink(),
                ),
              ],
            ),
          ),

          // Player List
          Expanded(
            child: onlineUsersAsync.when(
              data: (users) {
                if (users.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.person_search,
                          size: 48,
                          color: Colors.grey.shade600,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'No other players online',
                          style: TextStyle(color: Colors.grey.shade500),
                        ),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  itemCount: users.length,
                  itemBuilder: (context, index) {
                    final user = users[index];
                    return _OnlinePlayerTile(
                          user: user,
                          currentRoomId: currentRoomId,
                          roomCode: roomCode,
                          gameType: gameType,
                        )
                        .animate(delay: Duration(milliseconds: index * 50))
                        .fadeIn(duration: 200.ms)
                        .slideX(begin: 0.1, end: 0);
                  },
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(
                child: Text(
                  'Error: $e',
                  style: TextStyle(color: Colors.red.shade300),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _OnlinePlayerTile extends ConsumerWidget {
  final UserPresence user;
  final String? currentRoomId;
  final String? roomCode;
  final String gameType;

  const _OnlinePlayerTile({
    required this.user,
    this.currentRoomId,
    this.roomCode,
    required this.gameType,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final myFriendsAsync = ref.watch(myFriendsProvider);
    final isFriend =
        myFriendsAsync.whenOrNull(
          data: (friends) => friends.any((f) => f.userId == user.userId),
        ) ??
        false;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isFriend
              ? Colors.amber.withValues(alpha: 0.5)
              : Colors.transparent,
          width: isFriend ? 1.5 : 0,
        ),
      ),
      child: Row(
        children: [
          // Avatar with online indicator
          Stack(
            children: [
              CircleAvatar(
                radius: 20,
                backgroundColor: Colors.deepPurple.shade400,
                backgroundImage: user.avatarUrl != null
                    ? NetworkImage(user.avatarUrl!)
                    : null,
                child: user.avatarUrl == null
                    ? Text(
                        user.displayName[0].toUpperCase(),
                        style: const TextStyle(color: Colors.white),
                      )
                    : null,
              ),
              Positioned(
                right: 0,
                bottom: 0,
                child: Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    color: Colors.green,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.black, width: 2),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(width: 12),

          // Name and status
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        user.displayName,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w500,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (isFriend) ...[
                      const SizedBox(width: 4),
                      const Icon(Icons.star, size: 14, color: Colors.amber),
                    ],
                  ],
                ),
                Text(
                  user.currentGameType != null
                      ? 'Playing ${user.currentGameType}'
                      : 'In Lobby',
                  style: TextStyle(color: Colors.grey.shade400, fontSize: 12),
                ),
              ],
            ),
          ),

          // Action buttons
          if (currentRoomId != null)
            _InviteButton(
              toUserId: user.userId,
              roomId: currentRoomId!,
              roomCode: roomCode,
              gameType: gameType,
            )
          else if (!isFriend)
            _AddFriendButton(toUserId: user.userId),
        ],
      ),
    );
  }
}

class _InviteButton extends ConsumerStatefulWidget {
  final String toUserId;
  final String roomId;
  final String? roomCode;
  final String gameType;

  const _InviteButton({
    required this.toUserId,
    required this.roomId,
    this.roomCode,
    required this.gameType,
  });

  @override
  ConsumerState<_InviteButton> createState() => _InviteButtonState();
}

class _InviteButtonState extends ConsumerState<_InviteButton> {
  bool _isSending = false;
  bool _sent = false;

  @override
  Widget build(BuildContext context) {
    if (_sent) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: Colors.green.withValues(alpha: 0.2),
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.check, size: 16, color: Colors.green),
            SizedBox(width: 4),
            Text('Sent', style: TextStyle(color: Colors.green, fontSize: 12)),
          ],
        ),
      );
    }

    return TextButton.icon(
      onPressed: _isSending ? null : _sendInvite,
      style: TextButton.styleFrom(
        backgroundColor: Colors.deepPurple.withValues(alpha: 0.2),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      ),
      icon: _isSending
          ? const SizedBox(
              width: 14,
              height: 14,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          : const Icon(Icons.mail_outline, size: 16),
      label: const Text('Invite', style: TextStyle(fontSize: 12)),
    );
  }

  Future<void> _sendInvite() async {
    setState(() => _isSending = true);

    final inviteService = ref.read(inviteServiceProvider);
    final success = await inviteService.sendInvite(
      toUserId: widget.toUserId,
      roomId: widget.roomId,
      roomCode: widget.roomCode,
      gameType: widget.gameType,
    );

    if (mounted) {
      setState(() {
        _isSending = false;
        _sent = success;
      });

      if (!success) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Invite already sent')));
      }
    }
  }
}

class _AddFriendButton extends ConsumerStatefulWidget {
  final String toUserId;

  const _AddFriendButton({required this.toUserId});

  @override
  ConsumerState<_AddFriendButton> createState() => _AddFriendButtonState();
}

class _AddFriendButtonState extends ConsumerState<_AddFriendButton> {
  bool _isSending = false;
  bool _sent = false;

  @override
  Widget build(BuildContext context) {
    if (_sent) {
      return const Icon(
        Icons.person_add_disabled,
        size: 20,
        color: Colors.grey,
      );
    }

    return IconButton(
      onPressed: _isSending ? null : _sendRequest,
      icon: _isSending
          ? const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          : const Icon(Icons.person_add, size: 20, color: Colors.amber),
      tooltip: 'Add Friend',
    );
  }

  Future<void> _sendRequest() async {
    setState(() => _isSending = true);

    final friendsService = ref.read(friendsServiceProvider);
    final success = await friendsService.sendFriendRequest(widget.toUserId);

    if (mounted) {
      setState(() {
        _isSending = false;
        _sent = success;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            success ? 'Friend request sent!' : 'Request already sent',
          ),
          backgroundColor: success ? Colors.green : Colors.orange,
        ),
      );
    }
  }
}
