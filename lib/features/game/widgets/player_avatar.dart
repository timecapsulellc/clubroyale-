import 'dart:math' as dart;
import 'package:flutter/material.dart';
import 'package:clubroyale/config/casino_theme.dart';

/// Player avatar widget positioned around the game table
class PlayerAvatar extends StatelessWidget {
  final String name;
  final String? imageUrl;
  final bool isCurrentTurn;
  final bool isHost;
  final int? bid;
  final int? tricksWon;
  final double size;
  
  const PlayerAvatar({
    super.key,
    required this.name,
    this.imageUrl,
    this.isCurrentTurn = false,
    this.isHost = false,
    this.bid,
    this.tricksWon,
    this.size = 60,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Avatar with glow for current turn
        Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color: isCurrentTurn ? CasinoColors.gold : Colors.white.withOpacity(0.3),
              width: isCurrentTurn ? 3 : 2,
            ),
            boxShadow: isCurrentTurn ? [
              BoxShadow(
                color: CasinoColors.gold.withOpacity(0.6),
                blurRadius: 12,
                spreadRadius: 2,
              ),
            ] : null,
          ),
          child: ClipOval(
            child: imageUrl != null
                ? Image.network(imageUrl!, fit: BoxFit.cover)
                : _buildDefaultAvatar(),
          ),
        ),
        
        const SizedBox(height: 6),
        
        // Name label
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: isCurrentTurn 
                ? CasinoColors.gold
                : Colors.black.withOpacity(0.6),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (isHost) ...[
                Icon(Icons.star, color: isCurrentTurn ? CasinoColors.feltGreenDark : CasinoColors.gold, size: 12),
                const SizedBox(width: 4),
              ],
              Text(
                name,
                style: TextStyle(
                  color: isCurrentTurn ? CasinoColors.feltGreenDark : Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
        
        // Bid and tricks info
        if (bid != null || tricksWon != null) ...[
          const SizedBox(height: 4),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: CasinoColors.feltGreenDark.withOpacity(0.8),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: CasinoColors.gold.withOpacity(0.3)),
            ),
            child: Text(
              '${tricksWon ?? 0}/${bid ?? 0}',
              style: TextStyle(
                color: (tricksWon ?? 0) >= (bid ?? 0) ? Colors.green.shade300 : Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 11,
              ),
            ),
          ),
        ],
      ],
    );
  }
  
  Widget _buildDefaultAvatar() {
    // Generate color based on name
    final hue = (name.hashCode % 360).abs().toDouble();
    final bgColor = HSLColor.fromAHSL(1.0, hue, 0.6, 0.4).toColor();
    
    return Container(
      color: bgColor,
      child: Center(
        child: Text(
          name.isNotEmpty ? name[0].toUpperCase() : '?',
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 24,
          ),
        ),
      ),
    );
  }
}

/// Player info model for game table
class PlayerInfo {
  final String id;
  final String name;
  final String? avatarUrl;
  final bool isCurrentTurn;
  final bool isHost;
  final int? bid;
  final int? tricksWon;
  
  const PlayerInfo({
    required this.id,
    required this.name,
    this.avatarUrl,
    this.isCurrentTurn = false,
    this.isHost = false,
    this.bid,
    this.tricksWon,
  });
}

/// Game table layout with players positioned around
class GameTableLayout extends StatelessWidget {
  final List<PlayerInfo> players;
  final String currentPlayerId;
  final Widget centerContent;
  
  const GameTableLayout({
    super.key,
    required this.players,
    required this.currentPlayerId,
    required this.centerContent,
  });

  @override
  Widget build(BuildContext context) {
    // Find the current player's index to position them at bottom
    final currentIndex = players.indexWhere((p) => p.id == currentPlayerId);
    
    // Reorder players so current player is always at bottom
    final orderedPlayers = <PlayerInfo>[];
    if (currentIndex >= 0) {
      for (int i = 0; i < players.length; i++) {
        final idx = (currentIndex + i) % players.length;
        orderedPlayers.add(players[idx]);
      }
    } else {
      orderedPlayers.addAll(players);
    }
    
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final height = constraints.maxHeight;
        
        // Calculate positions based on player count
        final positions = _getPlayerPositions(orderedPlayers.length, width, height);
        
        return Stack(
          children: [
            // Center content (trick area)
            Center(child: centerContent),
            
            // Player avatars
            ...orderedPlayers.asMap().entries.map((entry) {
              final index = entry.key;
              final player = entry.value;
              final position = positions[index];
              
              return Positioned(
                left: position.dx - 40,
                top: position.dy - 50,
                child: PlayerAvatar(
                  name: player.name,
                  imageUrl: player.avatarUrl,
                  isCurrentTurn: player.isCurrentTurn,
                  isHost: player.isHost,
                  bid: player.bid,
                  tricksWon: player.tricksWon,
                ),
              );
            }),
          ],
        );
      },
    );
  }
  
  List<Offset> _getPlayerPositions(int playerCount, double width, double height) {
    // Position players around a virtual table
    // Bottom = current player (not rendered), then clockwise from right
    switch (playerCount) {
      case 2:
        return [
          Offset(width / 2, height - 20), // Bottom (current - hidden)
          Offset(width / 2, 40), // Top
        ];
      case 3:
        return [
          Offset(width / 2, height - 20), // Bottom (current - hidden)
          Offset(width - 60, height / 2), // Right
          Offset(60, height / 2), // Left
        ];
      case 4:
        return [
          Offset(width / 2, height - 20), // Bottom (current - hidden)
          Offset(width - 60, height / 2), // Right
          Offset(width / 2, 40), // Top
          Offset(60, height / 2), // Left
        ];
      default:
        return List.generate(playerCount, (i) {
          final angle = (i / playerCount) * 2 * dart.pi - dart.pi / 2;
          return Offset(
            width / 2 + (width * 0.35) * dart.cos(angle),
            height / 2 + (height * 0.4) * dart.sin(angle),
          );
        });
    }
  }
}

/// Bottom navigation bar for game screens
class GameBottomNav extends StatelessWidget {
  final VoidCallback? onAccountTap;
  final VoidCallback? onSettingsTap;
  final VoidCallback? onStoreTap;
  final VoidCallback? onBackTap;
  
  const GameBottomNav({
    super.key,
    this.onAccountTap,
    this.onSettingsTap,
    this.onStoreTap,
    this.onBackTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.7),
        border: Border(
          top: BorderSide(color: CasinoColors.gold.withOpacity(0.3)),
        ),
      ),
      child: SafeArea(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _NavItem(
              icon: Icons.person,
              label: 'Account',
              onTap: onAccountTap,
            ),
            _NavItem(
              icon: Icons.settings,
              label: 'Settings',
              onTap: onSettingsTap,
            ),
            _NavItem(
              icon: Icons.shopping_cart,
              label: 'Store',
              onTap: onStoreTap,
            ),
            _NavItem(
              icon: Icons.arrow_back,
              label: 'Go Back',
              onTap: onBackTap ?? () => Navigator.of(context).pop(),
            ),
          ],
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback? onTap;
  
  const _NavItem({
    required this.icon,
    required this.label,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white.withOpacity(0.5)),
              ),
              child: Icon(icon, color: Colors.white, size: 20),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 11,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
