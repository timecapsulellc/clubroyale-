import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:clubroyale/features/chat/chat_service.dart';
import 'package:clubroyale/features/chat/chat_message.dart';
import 'package:intl/intl.dart';

/// In-game social overlay panel
/// Collapsible panel on the right side of game screen with Chat, Voice, and Spectator tabs
class SocialOverlay extends ConsumerStatefulWidget {
  final String gameId;
  final String roomId;
  final bool initiallyExpanded;

  const SocialOverlay({
    super.key,
    required this.gameId,
    required this.roomId,
    this.initiallyExpanded = false,
  });

  @override
  ConsumerState<SocialOverlay> createState() => _SocialOverlayState();
}

class _SocialOverlayState extends ConsumerState<SocialOverlay>
    with SingleTickerProviderStateMixin {
  bool _isExpanded = false;
  int _selectedTab = 0; // 0: Chat, 1: Voice, 2: Spectators
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  late AnimationController _animationController;
  late Animation<double> _widthAnimation;

  static const double _collapsedWidth = 48.0;
  static const double _expandedWidth = 280.0;

  @override
  void initState() {
    super.initState();
    _isExpanded = widget.initiallyExpanded;
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _widthAnimation = Tween<double>(
      begin: _collapsedWidth,
      end: _expandedWidth,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
    if (_isExpanded) {
      _animationController.forward();
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _toggleExpanded() {
    setState(() {
      _isExpanded = !_isExpanded;
      if (_isExpanded) {
        _animationController.forward();
      } else {
        _animationController.reverse();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _widthAnimation,
      builder: (context, child) {
        return Container(
          width: _widthAnimation.value,
          decoration: BoxDecoration(
            color: Colors.black.withValues(alpha: 0.85),
            borderRadius: const BorderRadius.horizontal(
              left: Radius.circular(16),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.3),
                blurRadius: 8,
                offset: const Offset(-2, 0),
              ),
            ],
          ),
          child: _isExpanded ? _buildExpandedContent() : _buildCollapsedContent(),
        );
      },
    );
  }

  Widget _buildCollapsedContent() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildCollapsedButton(Icons.chat_bubble, 0, 'Chat'),
        const SizedBox(height: 8),
        _buildCollapsedButton(Icons.mic, 1, 'Voice'),
        const SizedBox(height: 8),
        _buildCollapsedButton(Icons.visibility, 2, 'Watch'),
        const Divider(color: Colors.white24, height: 32),
        IconButton(
          icon: const Icon(Icons.chevron_left, color: Colors.white),
          onPressed: _toggleExpanded,
          tooltip: 'Expand',
        ),
      ],
    );
  }

  Widget _buildCollapsedButton(IconData icon, int tabIndex, String tooltip) {
    final isSelected = _selectedTab == tabIndex;
    return Tooltip(
      message: tooltip,
      child: GestureDetector(
        onTap: () {
          setState(() => _selectedTab = tabIndex);
          _toggleExpanded();
        },
        child: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: isSelected ? Colors.purple.withValues(alpha: 0.3) : null,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            color: isSelected ? Colors.purple.shade200 : Colors.white54,
            size: 24,
          ),
        ),
      ),
    );
  }

  Widget _buildExpandedContent() {
    return Column(
      children: [
        // Header with tabs and collapse button
        _buildHeader(),
        // Tab content
        Expanded(
          child: IndexedStack(
            index: _selectedTab,
            children: [
              _GameChatPanel(
                gameId: widget.gameId,
                messageController: _messageController,
                scrollController: _scrollController,
              ),
              _VoiceControlPanel(gameId: widget.gameId),
              _SpectatorListPanel(gameId: widget.gameId),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: Colors.white.withValues(alpha: 0.1)),
        ),
      ),
      child: Row(
        children: [
          _buildTabButton(Icons.chat_bubble, 'Chat', 0),
          _buildTabButton(Icons.mic, 'Voice', 1),
          _buildTabButton(Icons.visibility, 'Watch', 2),
          const Spacer(),
          IconButton(
            icon: const Icon(Icons.chevron_right, color: Colors.white54, size: 20),
            onPressed: _toggleExpanded,
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
        ],
      ),
    );
  }

  Widget _buildTabButton(IconData icon, String label, int index) {
    final isSelected = _selectedTab == index;
    return GestureDetector(
      onTap: () => setState(() => _selectedTab = index),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        margin: const EdgeInsets.symmetric(horizontal: 2),
        decoration: BoxDecoration(
          color: isSelected ? Colors.purple.withValues(alpha: 0.3) : null,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 16,
              color: isSelected ? Colors.purple.shade200 : Colors.white54,
            ),
            const SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                color: isSelected ? Colors.white : Colors.white54,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Game chat panel for in-game messaging
class _GameChatPanel extends ConsumerWidget {
  final String gameId;
  final TextEditingController messageController;
  final ScrollController scrollController;

  const _GameChatPanel({
    required this.gameId,
    required this.messageController,
    required this.scrollController,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      children: [
        // Message list
        Expanded(
          child: StreamBuilder<List<ChatMessage>>(
            stream: ref.watch(chatServiceProvider).watchMessages(gameId),
            builder: (context, snapshot) {
              final messages = snapshot.data ?? [];
              
              if (messages.isEmpty) {
                return const Center(
                  child: Text(
                    'No messages yet',
                    style: TextStyle(color: Colors.white38, fontSize: 12),
                  ),
                );
              }

              return ListView.builder(
                controller: scrollController,
                reverse: true,
                padding: const EdgeInsets.all(8),
                itemCount: messages.length,
                itemBuilder: (context, index) {
                  final message = messages[index];
                  return _CompactMessageBubble(message: message);
                },
              );
            },
          ),
        ),
        // Input area
        _buildInputArea(ref),
      ],
    );
  }

  Widget _buildInputArea(WidgetRef ref) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(color: Colors.white.withValues(alpha: 0.1)),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: messageController,
              style: const TextStyle(color: Colors.white, fontSize: 12),
              decoration: InputDecoration(
                hintText: 'Message...',
                hintStyle: const TextStyle(color: Colors.white38, fontSize: 12),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: Colors.white.withValues(alpha: 0.1),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                isDense: true,
              ),
              onSubmitted: (_) => _sendMessage(ref),
            ),
          ),
          const SizedBox(width: 4),
          IconButton(
            icon: const Icon(Icons.send, color: Colors.purple, size: 20),
            onPressed: () => _sendMessage(ref),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
          ),
        ],
      ),
    );
  }

  void _sendMessage(WidgetRef ref) {
    if (messageController.text.trim().isEmpty) return;
    
    final text = messageController.text.trim();
    messageController.clear();
    
    ref.read(chatServiceProvider).sendMessage(
      roomId: gameId,
      content: text,
    );
  }
}

/// Compact message bubble for in-game chat
class _CompactMessageBubble extends StatelessWidget {
  final ChatMessage message;

  const _CompactMessageBubble({required this.message});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Sender name
          Text(
            '${message.senderName}: ',
            style: TextStyle(
              color: Colors.purple.shade200,
              fontSize: 11,
              fontWeight: FontWeight.bold,
            ),
          ),
          // Message content
          Expanded(
            child: Text(
              message.content,
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 11,
              ),
            ),
          ),
          // Time
          Text(
            DateFormat.Hm().format(message.timestamp ?? DateTime.now()),
            style: const TextStyle(
              color: Colors.white38,
              fontSize: 9,
            ),
          ),
        ],
      ),
    );
  }
}

/// Voice control panel for in-game voice chat
class _VoiceControlPanel extends ConsumerWidget {
  final String gameId;

  const _VoiceControlPanel({required this.gameId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Mic toggle button
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.purple.withValues(alpha: 0.2),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.mic,
              color: Colors.white,
              size: 32,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Tap to Mute',
            style: TextStyle(color: Colors.white54, fontSize: 12),
          ),
          const SizedBox(height: 24),
          // Speaker toggle
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildVoiceOption(Icons.volume_up, 'Speaker', true),
              const SizedBox(width: 16),
              _buildVoiceOption(Icons.headphones, 'Earpiece', false),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildVoiceOption(IconData icon, String label, bool isSelected) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: isSelected 
                ? Colors.purple.withValues(alpha: 0.3) 
                : Colors.white.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            color: isSelected ? Colors.purple.shade200 : Colors.white54,
            size: 20,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.white54,
            fontSize: 10,
          ),
        ),
      ],
    );
  }
}

/// Spectator list panel showing who's watching
class _SpectatorListPanel extends ConsumerWidget {
  final String gameId;

  const _SpectatorListPanel({required this.gameId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // TODO: Connect to actual spectator list from Firestore
    return Column(
      children: [
        // Header with count
        Container(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              Icon(Icons.visibility, color: Colors.white54, size: 16),
              const SizedBox(width: 8),
              const Text(
                '0 watching',
                style: TextStyle(color: Colors.white70, fontSize: 12),
              ),
            ],
          ),
        ),
        // Spectator list
        Expanded(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.visibility_off,
                  color: Colors.white24,
                  size: 40,
                ),
                const SizedBox(height: 8),
                const Text(
                  'No spectators yet',
                  style: TextStyle(color: Colors.white38, fontSize: 12),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Share the game to\ninvite friends to watch',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.white24, fontSize: 10),
                ),
              ],
            ),
          ),
        ),
        // Share button
        Padding(
          padding: const EdgeInsets.all(12),
          child: SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () {
                // TODO: Share game link
              },
              icon: const Icon(Icons.share, size: 16),
              label: const Text('Invite to Watch', style: TextStyle(fontSize: 12)),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.purple,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 10),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
