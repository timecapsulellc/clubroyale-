/// Matchmaking Widget
/// 
/// UI component for finding a match

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:taasclub/config/casino_theme.dart';
import 'package:taasclub/features/lobby/matchmaking_service.dart';
import 'package:taasclub/features/auth/auth_service.dart';

/// Matchmaking button and modal
class MatchmakingButton extends ConsumerStatefulWidget {
  final String gameType;
  
  const MatchmakingButton({super.key, required this.gameType});

  @override
  ConsumerState<MatchmakingButton> createState() => _MatchmakingButtonState();
}

class _MatchmakingButtonState extends ConsumerState<MatchmakingButton> {
  bool _isSearching = false;
  Duration _searchTime = Duration.zero;
  MatchResult? _matchResult;
  
  void _startSearch() async {
    final authService = ref.read(authServiceProvider);
    final user = authService.currentUser;
    if (user == null) return;
    
    final matchmaking = ref.read(matchmakingServiceProvider);
    
    setState(() {
      _isSearching = true;
      _searchTime = Duration.zero;
      _matchResult = null;
    });
    
    // Start timer
    _startTimer();
    
    // Listen for status changes
    matchmaking.statusStream.listen((status) {
      if (status == QueueStatus.found) {
        // Match found!
      } else if (status == QueueStatus.timeout || status == QueueStatus.cancelled) {
        setState(() => _isSearching = false);
      }
    });
    
    // Listen for matches
    matchmaking.matchStream.listen((match) {
      if (match != null) {
        setState(() {
          _matchResult = match;
        });
        _showMatchFoundDialog(match);
      }
    });
    
    // Join queue
    await matchmaking.joinQueue(
      playerId: user.uid,
      playerName: user.displayName ?? 'Player',
      gameType: widget.gameType,
    );
  }
  
  void _cancelSearch() async {
    final authService = ref.read(authServiceProvider);
    final user = authService.currentUser;
    if (user == null) return;
    
    final matchmaking = ref.read(matchmakingServiceProvider);
    await matchmaking.leaveQueue(user.uid);
    
    setState(() {
      _isSearching = false;
    });
  }
  
  void _startTimer() {
    Future.doWhile(() async {
      await Future.delayed(const Duration(seconds: 1));
      if (_isSearching && mounted) {
        setState(() {
          _searchTime = _searchTime + const Duration(seconds: 1);
        });
        return true;
      }
      return false;
    });
  }
  
  void _showMatchFoundDialog(MatchResult match) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => _MatchFoundDialog(
        match: match,
        onAccept: () {
          final matchmaking = ref.read(matchmakingServiceProvider);
          matchmaking.acceptMatch(match.matchId);
          Navigator.of(context).pop();
          // Navigate to game
          context.go('/${match.gameType}/${match.matchId}');
        },
        onDecline: () {
          final matchmaking = ref.read(matchmakingServiceProvider);
          matchmaking.declineMatch(match.matchId);
          Navigator.of(context).pop();
          setState(() {
            _isSearching = false;
            _matchResult = null;
          });
        },
      ),
    );
  }
  
  String get _searchTimeFormatted {
    final minutes = _searchTime.inMinutes;
    final seconds = _searchTime.inSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      child: _isSearching ? _buildSearchingState() : _buildIdleState(),
    );
  }
  
  Widget _buildIdleState() {
    return ElevatedButton.icon(
      onPressed: _startSearch,
      icon: const Icon(Icons.search),
      label: const Text('Find Match'),
      style: ElevatedButton.styleFrom(
        backgroundColor: CasinoColors.gold,
        foregroundColor: Colors.black,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
    );
  }
  
  Widget _buildSearchingState() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: CasinoColors.cardBackground,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: CasinoColors.gold.withValues(alpha: 0.5)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: CasinoColors.gold,
                ),
              ).animate(onPlay: (c) => c.repeat())
                  .rotate(duration: 1.seconds),
              const SizedBox(width: 12),
              Text(
                'Finding players...',
                style: TextStyle(
                  color: CasinoColors.gold,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 12),
          
          // Timer
          Text(
            _searchTimeFormatted,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 24,
              fontFamily: 'monospace',
            ),
          ),
          
          const SizedBox(height: 8),
          
          // Game type
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              widget.gameType.replaceAll('_', ' ').toUpperCase(),
              style: const TextStyle(
                color: Colors.white60,
                fontSize: 12,
              ),
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Cancel button
          TextButton.icon(
            onPressed: _cancelSearch,
            icon: const Icon(Icons.close, size: 16),
            label: const Text('Cancel'),
            style: TextButton.styleFrom(
              foregroundColor: Colors.red.shade300,
            ),
          ),
        ],
      ),
    ).animate().fadeIn().scale(begin: const Offset(0.95, 0.95));
  }
}

/// Match found dialog
class _MatchFoundDialog extends StatelessWidget {
  final MatchResult match;
  final VoidCallback onAccept;
  final VoidCallback onDecline;
  
  const _MatchFoundDialog({
    required this.match,
    required this.onAccept,
    required this.onDecline,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [CasinoColors.cardBackgroundLight, CasinoColors.cardBackground],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: CasinoColors.gold, width: 2),
          boxShadow: CasinoColors.goldGlow,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Success icon
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: CasinoColors.gold.withValues(alpha: 0.2),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.check_circle,
                color: CasinoColors.gold,
                size: 48,
              ),
            ).animate().scale().fadeIn(),
            
            const SizedBox(height: 16),
            
            Text(
              'MATCH FOUND!',
              style: TextStyle(
                color: CasinoColors.gold,
                fontSize: 24,
                fontWeight: FontWeight.bold,
                letterSpacing: 2,
              ),
            ).animate().fadeIn(delay: 200.ms),
            
            const SizedBox(height: 8),
            
            Text(
              match.gameType.replaceAll('_', ' ').toUpperCase(),
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 14,
              ),
            ),
            
            const SizedBox(height: 20),
            
            // Player list
            ...match.playerNames.asMap().entries.map((entry) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 16,
                        backgroundColor: CasinoColors.gold.withValues(alpha: 0.3),
                        child: Text(
                          '${entry.key + 1}',
                          style: TextStyle(
                            color: CasinoColors.gold,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        entry.value,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ).animate().fadeIn(delay: (300 + entry.key * 100).ms).slideX(begin: -0.1),
              );
            }),
            
            const SizedBox(height: 24),
            
            // Action buttons
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: onDecline,
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.red,
                      side: const BorderSide(color: Colors.red),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: const Text('Decline'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  flex: 2,
                  child: ElevatedButton(
                    onPressed: onAccept,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: CasinoColors.gold,
                      foregroundColor: Colors.black,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.play_arrow),
                        SizedBox(width: 8),
                        Text('Play!', style: TextStyle(fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ),
                ),
              ],
            ).animate().fadeIn(delay: 600.ms),
          ],
        ),
      ),
    );
  }
}
