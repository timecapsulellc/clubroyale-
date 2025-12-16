import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:clubroyale/core/config/admin_config.dart';
import 'package:clubroyale/features/auth/auth_service.dart';
import 'package:clubroyale/features/admin/admin_chat_service.dart';
import 'package:clubroyale/features/admin/screens/grant_request_screen.dart'; // Reuse for quick grant
import 'package:intl/intl.dart';

/// Screen for admins to manage support chats
class AdminChatScreen extends ConsumerWidget {
  const AdminChatScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authServiceProvider).currentUser;
    
    // Safety check - though route should be protected
    if (user == null || !AdminConfig.isAdmin(user.email ?? '')) {
      return Scaffold(
        appBar: AppBar(title: const Text('Support Chats')),
        body: const Center(child: Text('Access Denied: Admins Only')),
      );
    }

    final chatService = ref.read(adminChatServiceProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Support Inbox'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              // Force refresh logic if needed, but stream updates automatically
            },
          ),
        ],
      ),
      body: StreamBuilder<List<SupportChat>>(
        stream: chatService.watchOpenChats(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          final chats = snapshot.data ?? [];

          if (chats.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.mark_email_read, size: 80, color: Colors.grey.shade300),
                  const SizedBox(height: 16),
                  Text(
                    'All caught up!',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      color: Colors.grey.shade600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text('No open support tickets at the moment.'),
                ],
              ),
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.all(8),
            itemCount: chats.length,
            separatorBuilder: (c, i) => const Divider(height: 1),
            itemBuilder: (context, index) {
              final chat = chats[index];
              final isUnread = chat.unreadByAdmin;
              
              return ListTile(
                leading: CircleAvatar(
                  backgroundColor: isUnread ? Colors.redAccent : Colors.grey.shade300,
                  foregroundColor: isUnread ? Colors.white : Colors.black54,
                  child: Text(chat.userName.isNotEmpty ? chat.userName[0].toUpperCase() : '?'),
                ),
                title: Text(
                  chat.userName,
                  style: TextStyle(
                    fontWeight: isUnread ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
                subtitle: Text(
                  chat.subject,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: isUnread ? Colors.black87 : Colors.black54,
                    fontWeight: isUnread ? FontWeight.w500 : FontWeight.normal,
                  ),
                ),
                trailing: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      chat.lastMessageAt != null 
                        ? DateFormat('MMM d, HH:mm').format(chat.lastMessageAt!) 
                        : '',
                      style: TextStyle(
                        fontSize: 12,
                        color: isUnread ? Colors.red : Colors.grey,
                        fontWeight: isUnread ? FontWeight.bold : FontWeight.normal,
                      ),
                    ),
                    if (isUnread)
                      Container(
                        margin: const EdgeInsets.only(top: 4),
                        width: 8,
                        height: 8,
                        decoration: const BoxDecoration(
                          color: Colors.red,
                          shape: BoxShape.circle,
                        ),
                      ),
                  ],
                ),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => AdminChatDetailScreen(chat: chat),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}

/// Detail screen for a specific support chat
class AdminChatDetailScreen extends ConsumerStatefulWidget {
  final SupportChat chat;

  const AdminChatDetailScreen({super.key, required this.chat});

  @override
  ConsumerState<AdminChatDetailScreen> createState() => _AdminChatDetailScreenState();
}

class _AdminChatDetailScreenState extends ConsumerState<AdminChatDetailScreen> {
  final _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  bool _isSending = false;

  @override
  void initState() {
    super.initState();
    // Mark as read when opening
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(adminChatServiceProvider).markAsRead(widget.chat.id, isAdmin: true);
    });
  }

  Future<void> _sendMessage() async {
    if (_messageController.text.trim().isEmpty) return;
    
    setState(() => _isSending = true);
    final content = _messageController.text.trim();
    _messageController.clear();

    try {
      final user = ref.read(authServiceProvider).currentUser;
      if (user == null) return;

      final chatService = ref.read(adminChatServiceProvider);
      await chatService.sendMessage(
        chatId: widget.chat.id,
        senderId: user.uid,
        senderName: user.displayName ?? 'ClubRoyale Support',
        content: content,
        isAdmin: true,
      );

      // Scroll to bottom
      Future.delayed(const Duration(milliseconds: 100), () {
        if (_scrollController.hasClients) {
          _scrollController.animateTo(
            _scrollController.position.maxScrollExtent,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOut,
          );
        }
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to send: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isSending = false);
    }
  }

  Future<void> _closeChat() async {
    final user = ref.read(authServiceProvider).currentUser;
    if (user == null) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Close Ticket?'),
        content: const Text('This will archive the conversation and mark it as resolved.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Close Ticket'),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      final chatService = ref.read(adminChatServiceProvider);
      await chatService.closeChat(widget.chat.id, user.email ?? 'admin');
      if (mounted) Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final chatService = ref.read(adminChatServiceProvider);

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(widget.chat.userName, style: const TextStyle(fontSize: 16)),
            Text(
              'Ticket: ${widget.chat.subject}', 
              style: const TextStyle(fontSize: 12, color: Colors.white70),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.check_circle_outline),
            tooltip: 'Resolve Ticket',
            onPressed: _closeChat,
          ),
          IconButton(
            icon: const Icon(Icons.diamond_outlined),
            tooltip: 'Grant Diamonds',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => GrantRequestScreen(prefillUserId: widget.chat.userId),
                ),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Chat messages
          Expanded(
            child: StreamBuilder<List<ChatMessage>>(
              stream: chatService.watchMessages(widget.chat.id),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                final messages = snapshot.data ?? [];

                return ListView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    final msg = messages[index];
                    final isMyMessage = msg.isAdmin; // In admin interface, admin msgs are "mine"
                    return _AdminMessageBubble(
                      message: msg,
                      isMe: isMyMessage,
                    );
                  },
                );
              },
            ),
          ),
          
          // Input area
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 4,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: SafeArea(
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _messageController,
                      enabled: !_isSending,
                      decoration: InputDecoration(
                        hintText: 'Reply as Admin...',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(24),
                          borderSide: BorderSide.none,
                        ),
                        filled: true,
                        fillColor: Theme.of(context).colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 10,
                        ),
                      ),
                      textCapitalization: TextCapitalization.sentences,
                      onSubmitted: (_) => _sendMessage(),
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton.filled(
                    onPressed: _isSending ? null : _sendMessage,
                    icon: _isSending 
                      ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                      : const Icon(Icons.send),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _AdminMessageBubble extends StatelessWidget {
  final ChatMessage message;
  final bool isMe;

  const _AdminMessageBubble({
    required this.message,
    required this.isMe,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final timeStr = message.createdAt != null 
        ? DateFormat('HH:mm').format(message.createdAt!)
        : '';
    final dateStr = message.createdAt != null
        ? DateFormat('MMM d').format(message.createdAt!)
        : '';

    // Color Scheme: Admins (Me) get Purple, Users get Grey/White
    final bubbleColor = isMe 
        ? Colors.deepPurple 
        : theme.colorScheme.surfaceContainerHighest;
    
    final textColor = isMe 
        ? Colors.white 
        : theme.colorScheme.onSurface;

    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.75,
        ),
        decoration: BoxDecoration(
          color: bubbleColor,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(20),
            topRight: const Radius.circular(20),
            bottomLeft: isMe ? const Radius.circular(20) : Radius.zero,
            bottomRight: isMe ? Radius.zero : const Radius.circular(20),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Sender name for clarity in support chats
            if (!isMe)
              Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Text(
                  message.senderName,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: textColor.withValues(alpha: 0.7),
                  ),
                ),
              ),
              
            Text(
              message.content,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: textColor,
              ),
            ),
            const SizedBox(height: 4),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '$timeStr · $dateStr',
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: textColor.withValues(alpha: 0.6),
                    fontSize: 10,
                  ),
                ),
                if (isMe) ...[
                  const SizedBox(width: 4),
                  Icon(
                    Icons.done_all, // Support chats don't have read receipts per se yet, assume delivered
                    size: 12, 
                    color: textColor.withValues(alpha: 0.6),
                  ),
                ]
              ],
            ),
          ],
        ),
      ),
    );
  }
}
