import 'package:flutter/material.dart';
import 'package:clubroyale/core/utils/error_helper.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../chat_message.dart';
import '../chat_service.dart';
import 'package:clubroyale/core/widgets/skeleton_loading.dart';

/// Compact floating chat overlay for game screen
class ChatOverlay extends ConsumerStatefulWidget {
  final String roomId;
  final String userId;
  final String userName;
  final bool isExpanded;
  final VoidCallback onToggle;

  const ChatOverlay({
    super.key,
    required this.roomId,
    required this.userId,
    required this.userName,
    required this.isExpanded,
    required this.onToggle,
  });

  @override
  ConsumerState<ChatOverlay> createState() => _ChatOverlayState();
}

class _ChatOverlayState extends ConsumerState<ChatOverlay> {
  final TextEditingController _controller = TextEditingController();
  int _unreadCount = 0;

  late ChatServiceParams _params;

  @override
  void initState() {
    super.initState();
    _params = ChatServiceParams(
      roomId: widget.roomId,
      userId: widget.userId,
      userName: widget.userName,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (!widget.isExpanded) {
      return _buildCollapsedBubble(theme);
    }

    return _buildExpandedChat(theme);
  }

  Widget _buildCollapsedBubble(ThemeData theme) {
    // Watch messages provider to trigger updates
    ref.watch(chatMessagesProvider(_params));

    return GestureDetector(
      onTap: () {
        _unreadCount = 0;
        widget.onToggle();
      },
      child: Container(
        width: 56,
        height: 56,
        decoration: BoxDecoration(
          color: theme.colorScheme.primaryContainer,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.2),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            Icon(
              Icons.chat_bubble,
              color: theme.colorScheme.onPrimaryContainer,
            ),
            // Unread badge
            if (_unreadCount > 0)
              Positioned(
                top: 8,
                right: 8,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.error,
                    shape: BoxShape.circle,
                  ),
                  child: Text(
                    _unreadCount > 9 ? '9+' : '$_unreadCount',
                    style: TextStyle(
                      color: theme.colorScheme.onError,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildExpandedChat(ThemeData theme) {
    final messagesAsync = ref.watch(chatMessagesProvider(_params));

    return Container(
      width: 300,
      height: 400,
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: theme.colorScheme.primaryContainer,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.chat,
                  size: 18,
                  color: theme.colorScheme.onPrimaryContainer,
                ),
                const SizedBox(width: 8),
                Text(
                  'Chat',
                  style: theme.textTheme.titleSmall?.copyWith(
                    color: theme.colorScheme.onPrimaryContainer,
                  ),
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.close, size: 18),
                  onPressed: widget.onToggle,
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ],
            ),
          ),

          // Messages
          Expanded(
            child: messagesAsync.when(
              data: (messages) => _buildMessagesList(messages, theme),
              loading: () => ListView.builder(
                padding: const EdgeInsets.all(8),
                itemCount: 4,
                itemBuilder: (context, index) {
                  final isMe = index % 2 == 0;
                  return Align(
                    alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: SkeletonBox(
                        width: 120 + (index * 20) % 80,
                        height: 36,
                        borderRadius: 12,
                      ),
                    ),
                  );
                },
              ),
              error: (e, _) => Center(child: Text(ErrorHelper.getFriendlyMessage(e))),
            ),
          ),

          // Quick emoji row
          _buildQuickEmojiRow(theme),

          // Input
          _buildInput(theme),
        ],
      ),
    );
  }

  Widget _buildMessagesList(List<ChatMessage> messages, ThemeData theme) {
    if (messages.isEmpty) {
      return Center(
        child: Text(
          'No messages',
          style: theme.textTheme.bodySmall,
        ),
      );
    }

    return ListView.builder(
      reverse: true,
      padding: const EdgeInsets.all(8),
      itemCount: messages.length,
      itemBuilder: (context, index) {
        final message = messages[messages.length - 1 - index];
        final isMe = message.senderId == widget.userId;

        if (message.type == MessageType.system ||
            message.type == MessageType.gameEvent) {
          return Center(
            child: Container(
              margin: const EdgeInsets.symmetric(vertical: 2),
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                message.content,
                style: theme.textTheme.bodySmall?.copyWith(
                  fontStyle: FontStyle.italic,
                ),
              ),
            ),
          );
        }

        return Align(
          alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
          child: Container(
            margin: const EdgeInsets.symmetric(vertical: 2),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            constraints: const BoxConstraints(maxWidth: 200),
            decoration: BoxDecoration(
              color: isMe
                  ? theme.colorScheme.primary
                  : theme.colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (!isMe)
                  Text(
                    message.senderName,
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: theme.colorScheme.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                Text(
                  message.content,
                  style: message.type == MessageType.emoji
                      ? const TextStyle(fontSize: 24)
                      : theme.textTheme.bodySmall?.copyWith(
                          color: isMe
                              ? theme.colorScheme.onPrimary
                              : null,
                        ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildQuickEmojiRow(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: QuickEmojis.quickPlay.take(6).map((emoji) {
            return GestureDetector(
              onTap: () => _sendEmoji(emoji),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: Text(emoji, style: const TextStyle(fontSize: 20)),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildInput(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(color: theme.colorScheme.outlineVariant),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _controller,
              decoration: InputDecoration(
                hintText: 'Message...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: theme.colorScheme.surfaceContainerHighest,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                isDense: true,
              ),
              style: theme.textTheme.bodySmall,
              onSubmitted: (_) => _sendMessage(),
            ),
          ),
          const SizedBox(width: 4),
          IconButton(
            onPressed: _sendMessage,
            icon: Icon(Icons.send, size: 20, color: theme.colorScheme.primary),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
        ],
      ),
    );
  }

  Future<void> _sendMessage() async {
    if (_controller.text.trim().isEmpty) return;

    final chatService = ref.read(chatServiceProvider(_params));
    await chatService.sendMessage(_controller.text);
    _controller.clear();
  }

  void _sendEmoji(String emoji) {
    final chatService = ref.read(chatServiceProvider(_params));
    chatService.sendQuickEmoji(emoji);
  }
}

/// Mini chat bubble showing last message
class ChatMiniBubble extends ConsumerWidget {
  final String roomId;
  final String userId;
  final String userName;
  final VoidCallback onTap;

  const ChatMiniBubble({
    super.key,
    required this.roomId,
    required this.userId,
    required this.userName,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final params = ChatServiceParams(
      roomId: roomId,
      userId: userId,
      userName: userName,
    );
    final messagesAsync = ref.watch(chatMessagesProvider(params));
    final theme = Theme.of(context);

    return messagesAsync.when(
      data: (messages) {
        if (messages.isEmpty) {
          return const SizedBox.shrink();
        }

        final lastMessage = messages.last;
        
        return GestureDetector(
          onTap: onTap,
          child: Container(
            margin: const EdgeInsets.all(8),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircleAvatar(
                  radius: 12,
                  child: Text(
                    lastMessage.senderName[0],
                    style: const TextStyle(fontSize: 10),
                  ),
                ),
                const SizedBox(width: 8),
                Flexible(
                  child: Text(
                    '${lastMessage.senderName}: ${lastMessage.content}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.bodySmall,
                  ),
                ),
              ],
            ),
          ),
        );
      },
      loading: () => const SizedBox.shrink(),
      error: (_, __) => const SizedBox.shrink(),
    );
  }
}
