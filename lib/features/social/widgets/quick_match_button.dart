/// Quick Match Widget
/// 
/// Button for instant matchmaking with animation and status.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:clubroyale/features/social/matchmaking_service.dart';
import 'package:clubroyale/features/auth/auth_service.dart';

class QuickMatchButton extends ConsumerStatefulWidget {
  final String gameType;

  const QuickMatchButton({
    super.key,
    required this.gameType,
  });

  @override
  ConsumerState<QuickMatchButton> createState() => _QuickMatchButtonState();
}

class _QuickMatchButtonState extends ConsumerState<QuickMatchButton>
    with SingleTickerProviderStateMixin {
  bool _isSearching = false;
  int _waitTime = 0;
  String? _matchedRoomId;

  @override
  Widget build(BuildContext context) {
    final authService = ref.watch(authServiceProvider);
    final user = authService.currentUser;

    if (user == null) {
      return const SizedBox.shrink();
    }

    return Container(
      decoration: BoxDecoration(
        gradient: _isSearching
            ? LinearGradient(
                colors: [Colors.orange.shade800, Colors.amber.shade600],
              )
            : LinearGradient(
                colors: [Colors.green.shade800, Colors.green.shade600],
              ),
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: (_isSearching ? Colors.orange : Colors.green).withValues(alpha: 0.3),
            blurRadius: 12,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: _isSearching ? _cancelSearch : _startSearch,
          borderRadius: BorderRadius.circular(30),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (_isSearching) ...[
                  SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  ).animate(onPlay: (c) => c.repeat())
                   .rotate(duration: 1000.ms),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text(
                        'Finding Match...',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      Text(
                        '${_waitTime}s - Tap to cancel',
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ] else ...[
                  const Icon(Icons.flash_on, color: Colors.white, size: 28),
                  const SizedBox(width: 8),
                  const Text(
                    'Quick Match',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    ).animate()
     .fadeIn(duration: 300.ms)
     .scale(begin: const Offset(0.9, 0.9), end: const Offset(1, 1));
  }

  Future<void> _startSearch() async {
    setState(() {
      _isSearching = true;
      _waitTime = 0;
    });

    final matchmakingService = ref.read(matchmakingServiceProvider);

    // Start timer to update wait time
    _startTimer();

    // Join queue
    final roomId = await matchmakingService.joinQueue(widget.gameType);

    if (roomId != null) {
      // Match found immediately!
      setState(() => _matchedRoomId = roomId);
      _navigateToRoom(roomId);
    } else {
      // Poll for match every 3 seconds
      _pollForMatch();
    }
  }

  void _startTimer() {
    Future.doWhile(() async {
      await Future.delayed(const Duration(seconds: 1));
      if (!_isSearching) return false;
      if (!mounted) return false;
      setState(() => _waitTime++);
      
      // Timeout after 2 minutes
      if (_waitTime > 120) {
        _cancelSearch();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('No match found. Try again later.'),
              backgroundColor: Colors.orange,
            ),
          );
        }
        return false;
      }
      return true;
    });
  }

  void _pollForMatch() async {
    final matchmakingService = ref.read(matchmakingServiceProvider);
    final authService = ref.read(authServiceProvider);
    final userId = authService.currentUser?.uid;

    if (userId == null) return;

    while (_isSearching && mounted) {
      await Future.delayed(const Duration(seconds: 3));
      
      // Check if matched
      final roomId = await matchmakingService.joinQueue(widget.gameType);
      if (roomId != null) {
        _navigateToRoom(roomId);
        return;
      }
    }
  }

  Future<void> _cancelSearch() async {
    final matchmakingService = ref.read(matchmakingServiceProvider);
    await matchmakingService.leaveQueue();

    setState(() {
      _isSearching = false;
      _waitTime = 0;
    });
  }

  void _navigateToRoom(String roomId) {
    setState(() {
      _isSearching = false;
      _waitTime = 0;
    });

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Match found! 🎉'),
          backgroundColor: Colors.green,
        ),
      );
      context.go('/lobby/$roomId');
    }
  }
}

/// ELO Rating Display Widget
class EloRatingBadge extends ConsumerWidget {
  final String userId;

  const EloRatingBadge({super.key, required this.userId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return FutureBuilder<PlayerRating>(
      future: ref.read(matchmakingServiceProvider).getPlayerRating(userId),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const SizedBox.shrink();
        }

        final rating = snapshot.data!;
        final rankColor = _getRankColor(rating.rank);

        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [rankColor.withValues(alpha: 0.8), rankColor.withValues(alpha: 0.5)],
            ),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: rankColor, width: 2),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(_getRankIcon(rating.rank), color: Colors.white, size: 16),
              const SizedBox(width: 6),
              Text(
                '${rating.elo}',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Color _getRankColor(String rank) {
    switch (rank) {
      case 'Diamond':
        return Colors.cyan;
      case 'Platinum':
        return Colors.grey.shade400;
      case 'Gold':
        return Colors.amber;
      case 'Silver':
        return Colors.grey;
      default:
        return Colors.brown;
    }
  }

  IconData _getRankIcon(String rank) {
    switch (rank) {
      case 'Diamond':
        return Icons.diamond;
      case 'Platinum':
        return Icons.workspace_premium;
      case 'Gold':
        return Icons.emoji_events;
      case 'Silver':
        return Icons.shield;
      default:
        return Icons.military_tech;
    }
  }
}
