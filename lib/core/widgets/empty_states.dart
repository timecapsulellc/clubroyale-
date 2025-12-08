// Empty State Widgets
//
// Friendly empty states for "No data" scenarios.

import 'package:flutter/material.dart';

/// Generic empty state widget
class EmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final Widget? action;

  const EmptyState({
    super.key,
    required this.icon,
    required this.title,
    this.subtitle,
    this.action,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                size: 64,
                color: Colors.grey.shade400,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              title,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            if (subtitle != null) ...[
              const SizedBox(height: 8),
              Text(
                subtitle!,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey.shade600,
                ),
                textAlign: TextAlign.center,
              ),
            ],
            if (action != null) ...[
              const SizedBox(height: 24),
              action!,
            ],
          ],
        ),
      ),
    );
  }
}

/// No rooms empty state
class NoRoomsEmptyState extends StatelessWidget {
  final VoidCallback? onCreateRoom;

  const NoRoomsEmptyState({
    super.key,
    this.onCreateRoom,
  });

  @override
  Widget build(BuildContext context) {
    return EmptyState(
      icon: Icons.meeting_room_outlined,
      title: 'No Active Rooms',
      subtitle: 'Create a room to start playing with friends',
      action: onCreateRoom != null
          ? FilledButton.icon(
              onPressed: onCreateRoom,
              icon: const Icon(Icons.add),
              label: const Text('Create Room'),
            )
          : null,
    );
  }
}

/// No games history empty state
class NoGamesEmptyState extends StatelessWidget {
  const NoGamesEmptyState({super.key});

  @override
  Widget build(BuildContext context) {
    return const EmptyState(
      icon: Icons.history,
      title: 'No Game History',
      subtitle: 'Your completed games will appear here',
    );
  }
}

/// No players in room empty state
class WaitingForPlayersState extends StatelessWidget {
  final String roomCode;
  final VoidCallback? onShareInvite;

  const WaitingForPlayersState({
    super.key,
    required this.roomCode,
    this.onShareInvite,
  });

  @override
  Widget build(BuildContext context) {
    return EmptyState(
      icon: Icons.groups_outlined,
      title: 'Waiting for Players',
      subtitle: 'Share the room code: $roomCode',
      action: onShareInvite != null
          ? FilledButton.icon(
              onPressed: onShareInvite,
              icon: const Icon(Icons.share),
              label: const Text('Invite Friends'),
            )
          : null,
    );
  }
}

/// No friends empty state
class NoFriendsEmptyState extends StatelessWidget {
  final VoidCallback? onAddFriend;

  const NoFriendsEmptyState({
    super.key,
    this.onAddFriend,
  });

  @override
  Widget build(BuildContext context) {
    return EmptyState(
      icon: Icons.person_add_outlined,
      title: 'No Friends Yet',
      subtitle: 'Add friends to play together',
      action: onAddFriend != null
          ? OutlinedButton.icon(
              onPressed: onAddFriend,
              icon: const Icon(Icons.person_add),
              label: const Text('Add Friend'),
            )
          : null,
    );
  }
}

/// No diamonds empty state
class NoDiamondsEmptyState extends StatelessWidget {
  final VoidCallback? onBuyDiamonds;

  const NoDiamondsEmptyState({
    super.key,
    this.onBuyDiamonds,
  });

  @override
  Widget build(BuildContext context) {
    return EmptyState(
      icon: Icons.diamond_outlined,
      title: 'No Diamonds',
      subtitle: 'Get diamonds to create rooms and unlock features',
      action: onBuyDiamonds != null
          ? FilledButton.icon(
              onPressed: onBuyDiamonds,
              icon: const Icon(Icons.shopping_cart),
              label: const Text('Get Diamonds'),
            )
          : null,
    );
  }
}

/// Search no results empty state
class NoSearchResultsState extends StatelessWidget {
  final String query;

  const NoSearchResultsState({
    super.key,
    required this.query,
  });

  @override
  Widget build(BuildContext context) {
    return EmptyState(
      icon: Icons.search_off,
      title: 'No Results',
      subtitle: 'No matches found for "$query"',
    );
  }
}

/// Error state widget
class ErrorState extends StatelessWidget {
  final String message;
  final VoidCallback? onRetry;

  const ErrorState({
    super.key,
    required this.message,
    this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.red.shade50,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.error_outline,
                size: 48,
                color: Colors.red.shade400,
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Something went wrong',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              message,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade600,
              ),
              textAlign: TextAlign.center,
            ),
            if (onRetry != null) ...[
              const SizedBox(height: 24),
              OutlinedButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh),
                label: const Text('Try Again'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
