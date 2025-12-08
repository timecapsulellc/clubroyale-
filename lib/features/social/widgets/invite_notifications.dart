/// Invite Notifications Widget
/// 
/// Shows pending game invitations with accept/decline actions.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:taasclub/features/social/invite_service.dart';

class InviteNotificationsBadge extends ConsumerWidget {
  const InviteNotificationsBadge({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final invitesAsync = ref.watch(myInvitesProvider);

    return invitesAsync.when(
      data: (invites) {
        if (invites.isEmpty) return const SizedBox.shrink();

        return Badge(
          label: Text('${invites.length}'),
          backgroundColor: Colors.red,
          child: IconButton(
            icon: const Icon(Icons.mail, color: Colors.amber),
            onPressed: () => _showInvitesDialog(context, invites, ref),
          ),
        ).animate(onPlay: (c) => c.repeat(reverse: true))
         .scale(duration: 1000.ms, begin: const Offset(1, 1), end: const Offset(1.1, 1.1));
      },
      loading: () => const SizedBox.shrink(),
      error: (_, __) => const SizedBox.shrink(),
    );
  }

  void _showInvitesDialog(BuildContext context, List<GameInvite> invites, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: Colors.grey.shade900,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              margin: const EdgeInsets.only(top: 8),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade600,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const Padding(
              padding: EdgeInsets.all(16),
              child: Text(
                'Game Invitations',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const Divider(height: 1),
            ConstrainedBox(
              constraints: BoxConstraints(
                maxHeight: MediaQuery.of(context).size.height * 0.4,
              ),
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: invites.length,
                itemBuilder: (context, index) {
                  final invite = invites[index];
                  return _InviteTile(invite: invite);
                },
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}

class _InviteTile extends ConsumerStatefulWidget {
  final GameInvite invite;

  const _InviteTile({required this.invite});

  @override
  ConsumerState<_InviteTile> createState() => _InviteTileState();
}

class _InviteTileState extends ConsumerState<_InviteTile> {
  bool _isProcessing = false;

  String _getGameEmoji(String gameType) {
    switch (gameType) {
      case 'marriage':
        return '👰';
      case 'call_break':
        return '♠️';
      case 'teen_patti':
        return '🃏';
      default:
        return '🎮';
    }
  }

  @override
  Widget build(BuildContext context) {
    final remainingTime = widget.invite.expiresAt.difference(DateTime.now());
    final minutesLeft = remainingTime.inMinutes;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.deepPurple.shade800,
            Colors.purple.shade600,
          ],
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Text(
                _getGameEmoji(widget.invite.gameType),
                style: const TextStyle(fontSize: 28),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${widget.invite.fromDisplayName} invited you',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'to play ${widget.invite.gameType}',
                      style: TextStyle(
                        color: Colors.grey.shade400,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: minutesLeft < 1 ? Colors.red : Colors.amber,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  minutesLeft < 1 ? 'Expiring!' : '${minutesLeft}m',
                  style: const TextStyle(
                    color: Colors.black,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: _isProcessing ? null : () => _decline(),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.red,
                    side: const BorderSide(color: Colors.red),
                  ),
                  child: const Text('Decline'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: _isProcessing ? null : () => _accept(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                  ),
                  child: _isProcessing
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Text('Join'),
                ),
              ),
            ],
          ),
        ],
      ),
    ).animate()
     .fadeIn(duration: 200.ms)
     .slideX(begin: 0.1, end: 0);
  }

  Future<void> _accept() async {
    setState(() => _isProcessing = true);

    final inviteService = ref.read(inviteServiceProvider);
    final roomId = await inviteService.acceptInvite(widget.invite.id);

    if (mounted) {
      Navigator.pop(context); // Close bottom sheet
      if (roomId != null) {
        context.go('/lobby/$roomId');
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Invite expired or room not found'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _decline() async {
    setState(() => _isProcessing = true);

    final inviteService = ref.read(inviteServiceProvider);
    await inviteService.declineInvite(widget.invite.id);

    if (mounted) {
      Navigator.pop(context); // Close bottom sheet
    }
  }
}
