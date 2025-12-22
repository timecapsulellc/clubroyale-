/// Contextual Loading Widget - Premium loading states with messages
///
/// Replaces plain CircularProgressIndicator with contextual, informative loading
library;

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:clubroyale/config/casino_theme.dart';

/// Loading indicator with contextual message
class ContextualLoader extends StatelessWidget {
  final String message;
  final IconData? icon;
  final Color? color;
  
  const ContextualLoader({
    super.key,
    this.message = 'Loading...',
    this.icon,
    this.color,
  });
  
  /// Pre-defined loading states
  factory ContextualLoader.findingPlayers() => const ContextualLoader(
    message: 'Finding players...',
    icon: Icons.people_outline,
  );
  
  factory ContextualLoader.loadingProfile() => const ContextualLoader(
    message: 'Loading profile...',
    icon: Icons.person_outline,
  );
  
  factory ContextualLoader.settingUpGame() => const ContextualLoader(
    message: 'Setting up game...',
    icon: Icons.casino,
  );
  
  factory ContextualLoader.shufflingCards() => const ContextualLoader(
    message: 'Shuffling cards...',
    icon: Icons.style,
  );
  
  factory ContextualLoader.connectingRoom() => const ContextualLoader(
    message: 'Connecting to room...',
    icon: Icons.wifi,
  );
  
  factory ContextualLoader.loadingChat() => const ContextualLoader(
    message: 'Loading messages...',
    icon: Icons.chat_bubble_outline,
  );
  
  factory ContextualLoader.processing() => const ContextualLoader(
    message: 'Processing...',
    icon: Icons.hourglass_empty,
  );
  
  factory ContextualLoader.checkingWallet() => const ContextualLoader(
    message: 'Checking wallet...',
    icon: Icons.account_balance_wallet_outlined,
  );
  
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final effectiveColor = color ?? CasinoColors.gold;
    
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Animated icon with pulse
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: effectiveColor.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon ?? Icons.hourglass_empty,
              size: 32,
              color: effectiveColor,
            ),
          ).animate(onPlay: (c) => c.repeat(reverse: true))
           .scale(begin: const Offset(1, 1), end: const Offset(1.1, 1.1), duration: 800.ms),
          
          const SizedBox(height: 24),
          
          // Loading indicator
          SizedBox(
            width: 24,
            height: 24,
            child: CircularProgressIndicator(
              strokeWidth: 2.5,
              color: effectiveColor,
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Message
          Text(
            message,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}

/// Inline loading button - shows loading state inside a button
class LoadingButton extends StatelessWidget {
  final String label;
  final bool isLoading;
  final VoidCallback? onPressed;
  final IconData? icon;
  final ButtonStyle? style;
  
  const LoadingButton({
    super.key,
    required this.label,
    required this.isLoading,
    required this.onPressed,
    this.icon,
    this.style,
  });
  
  @override
  Widget build(BuildContext context) {
    return FilledButton.icon(
      onPressed: isLoading ? null : onPressed,
      style: style,
      icon: isLoading 
          ? const SizedBox(
              width: 18,
              height: 18,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          : Icon(icon ?? Icons.check),
      label: Text(isLoading ? 'Please wait...' : label),
    );
  }
}

/// Empty state widget with illustration and CTA
class EmptyStateWidget extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final String? actionLabel;
  final VoidCallback? onAction;
  
  const EmptyStateWidget({
    super.key,
    required this.icon,
    required this.title,
    this.subtitle,
    this.actionLabel,
    this.onAction,
  });
  
  /// Pre-defined empty states
  factory EmptyStateWidget.noGames({VoidCallback? onCreate}) => EmptyStateWidget(
    icon: Icons.sports_esports_outlined,
    title: 'No games yet',
    subtitle: 'Create or join a game to get started!',
    actionLabel: 'Create Game',
    onAction: onCreate,
  );
  
  factory EmptyStateWidget.noMessages({VoidCallback? onStartChat}) => EmptyStateWidget(
    icon: Icons.chat_bubble_outline,
    title: 'No messages',
    subtitle: 'Start a conversation with friends',
    actionLabel: 'New Chat',
    onAction: onStartChat,
  );
  
  factory EmptyStateWidget.noFriends({VoidCallback? onFindFriends}) => EmptyStateWidget(
    icon: Icons.people_outline,
    title: 'No friends yet',
    subtitle: 'Find and add friends to play together',
    actionLabel: 'Find Friends',
    onAction: onFindFriends,
  );
  
  factory EmptyStateWidget.noResults() => const EmptyStateWidget(
    icon: Icons.search_off,
    title: 'No results found',
    subtitle: 'Try adjusting your search',
  );
  
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Icon with subtle background
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: colorScheme.surfaceContainerHighest,
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                size: 48,
                color: colorScheme.onSurfaceVariant,
              ),
            ).animate().fadeIn().scale(delay: 100.ms),
            
            const SizedBox(height: 24),
            
            // Title
            Text(
              title,
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ).animate().fadeIn(delay: 200.ms),
            
            // Subtitle
            if (subtitle != null) ...[
              const SizedBox(height: 8),
              Text(
                subtitle!,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
                textAlign: TextAlign.center,
              ).animate().fadeIn(delay: 300.ms),
            ],
            
            // Action button
            if (actionLabel != null && onAction != null) ...[
              const SizedBox(height: 24),
              FilledButton.icon(
                onPressed: onAction,
                icon: const Icon(Icons.add),
                label: Text(actionLabel!),
              ).animate().fadeIn(delay: 400.ms).slideY(begin: 0.2),
            ],
          ],
        ),
      ),
    );
  }
}
