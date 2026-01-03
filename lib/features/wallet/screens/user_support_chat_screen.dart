import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:clubroyale/features/auth/auth_service.dart';
import 'package:clubroyale/features/admin/admin_chat_service.dart';
import 'package:intl/intl.dart';

/// Screen for users to chat with admin support
class UserSupportChatScreen extends ConsumerStatefulWidget {
  const UserSupportChatScreen({super.key});

  @override
  ConsumerState<UserSupportChatScreen> createState() =>
      _UserSupportChatScreenState();
}

class _UserSupportChatScreenState extends ConsumerState<UserSupportChatScreen> {
  final _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  bool _isLoading = false;
  String? _activeChatId;

  @override
  void initState() {
    super.initState();
    _loadActiveChat();
  }

  Future<void> _loadActiveChat() async {
    final user = ref.read(authServiceProvider).currentUser;
    if (user == null) return;

    // Check if user already has an open chat
    final snapshot = await FirebaseFirestore.instance
        .collection('admin_chats')
        .where('userId', isEqualTo: user.uid)
        .where('status', isEqualTo: 'open')
        .limit(1)
        .get();

    if (snapshot.docs.isNotEmpty && mounted) {
      final chatId = snapshot.docs.first.id;
      setState(() {
        _activeChatId = chatId;
      });
      // Mark as read by user
      ref.read(adminChatServiceProvider).markAsRead(chatId, isAdmin: false);
    }
  }

  Future<void> _startNewChat() async {
    final user = ref.read(authServiceProvider).currentUser;
    if (user == null) return;

    setState(() => _isLoading = true);
    try {
      final chatService = ref.read(adminChatServiceProvider);
      final chatId = await chatService.startChat(
        userId: user.uid,
        userName: user.displayName ?? 'User',
        subject: 'Support Request',
      );

      if (mounted) {
        setState(() {
          _activeChatId = chatId;
        });
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _sendMessage() async {
    if (_messageController.text.trim().isEmpty) return;
    final content = _messageController.text.trim();
    _messageController.clear();

    final user = ref.read(authServiceProvider).currentUser;
    if (user == null) return;

    if (_activeChatId == null) {
      await _startNewChat();
    }

    if (_activeChatId != null) {
      final chatService = ref.read(adminChatServiceProvider);
      await chatService.sendMessage(
        chatId: _activeChatId!,
        senderId: user.uid,
        senderName: user.displayName ?? 'User',
        content: content,
        isAdmin: false,
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
    }
  }

  @override
  Widget build(BuildContext context) {
    // Loading State (Initial check)
    if (_activeChatId == null && _isLoading) {
      return Scaffold(
        appBar: AppBar(title: const Text('Support Chat')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    // Empty State (No Active Chat)
    if (_activeChatId == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Support Chat')),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.support_agent,
                  size: 64,
                  color: Theme.of(context).primaryColor,
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'How can we help?',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 8),
              const Text(
                'Talk to our support team directly.',
                style: TextStyle(color: Colors.grey),
              ),
              const SizedBox(height: 32),
              FilledButton.icon(
                onPressed: _startNewChat,
                icon: const Icon(Icons.chat_bubble),
                label: const Text('Start Conversation'),
                style: FilledButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 32,
                    vertical: 16,
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    final chatService = ref.read(adminChatServiceProvider);
    final user = ref.watch(authServiceProvider).currentUser;

    return Scaffold(
      appBar: AppBar(
        title: const Row(
          children: [
            CircleAvatar(
              backgroundColor: Colors.white24,
              child: Icon(Icons.support_agent, color: Colors.white, size: 20),
            ),
            SizedBox(width: 12),
            Text('ClubRoyale Support'),
          ],
        ),
      ),
      body: Column(
        children: [
          // Chat messages
          Expanded(
            child: StreamBuilder<List<ChatMessage>>(
              stream: chatService.watchMessages(_activeChatId!),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                final messages = snapshot.data ?? [];

                if (messages.isEmpty) {
                  return const Center(child: Text('Start the conversation...'));
                }

                return ListView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 20,
                  ),
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    final msg = messages[index];
                    final isMe = msg.senderId == user?.uid;
                    return _MessageBubble(message: msg, isMe: isMe);
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
                      decoration: InputDecoration(
                        hintText: 'Type a message...',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(24),
                          borderSide: BorderSide.none,
                        ),
                        filled: true,
                        fillColor: Theme.of(context)
                            .colorScheme
                            .surfaceContainerHighest
                            .withValues(alpha: 0.3),
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
                    onPressed: _sendMessage,
                    icon: const Icon(Icons.send),
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

class _MessageBubble extends StatelessWidget {
  final ChatMessage message;
  final bool isMe;

  const _MessageBubble({required this.message, required this.isMe});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final timeStr = message.createdAt != null
        ? DateFormat('HH:mm').format(message.createdAt!)
        : '';

    // User messages (Me) -> Blue/Primary
    // Admin messages (Other) -> Grey/Surface

    final bubbleColor = isMe
        ? theme.primaryColor
        : theme.colorScheme.surfaceContainerHighest;

    final textColor = isMe ? Colors.white : theme.colorScheme.onSurface;

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
            if (!isMe)
              Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Text(
                  'Support Team',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: textColor.withValues(alpha: 0.7),
                  ),
                ),
              ),
            Text(
              message.content,
              style: theme.textTheme.bodyMedium?.copyWith(color: textColor),
            ),
            const SizedBox(height: 4),
            Text(
              timeStr,
              style: theme.textTheme.labelSmall?.copyWith(
                color: textColor.withValues(alpha: 0.7),
                fontSize: 10,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
