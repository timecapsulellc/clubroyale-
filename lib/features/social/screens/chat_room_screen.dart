import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../services/social_service.dart';
import '../models/social_message_model.dart';
import 'package:intl/intl.dart';

class ChatRoomScreen extends ConsumerStatefulWidget {
  final String chatId;
  final String title; // Pass title for now to avoid extra fetch delay

  const ChatRoomScreen({
    super.key, 
    required this.chatId,
    this.title = 'Chat',
  });

  @override
  ConsumerState<ChatRoomScreen> createState() => _ChatRoomScreenState();
}

class _ChatRoomScreenState extends ConsumerState<ChatRoomScreen> {
  final TextEditingController _controller = TextEditingController();

  void _sendMessage() {
    if (_controller.text.trim().isEmpty) return;

    final text = _controller.text.trim();
    _controller.clear();

    ref.read(socialServiceProvider).sendTextMessage(
      chatId: widget.chatId,
      text: text,
    ).catchError((e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to send: $e')),
      );
    });
  }

  Future<void> _pickAndSendImage() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery, imageQuality: 70);
    
    if (picked != null) {
      final file = File(picked.path);
      // Show loading indicator or optimistic UI?
      // For now, simple fire and forget with snackbar on error
      
      try {
        await ref.read(socialServiceProvider).sendImageMessage(
          chatId: widget.chatId, 
          imageFile: file,
        );
      } catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to send image: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final messagesStream = ref.watch(socialServiceProvider).watchMessages(widget.chatId);

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        actions: [
          IconButton(
             icon: const Icon(Icons.call), 
             onPressed: () {
                // Future: Voice Call
             }
          ),
          IconButton(
             icon: const Icon(Icons.videocam), 
             onPressed: () {
                // Future: Video Call
             }
          ),
          IconButton(icon: const Icon(Icons.more_vert), onPressed: () {}),
        ],
      ),
      body: Column(
        children: [
          // Message List
          Expanded(
            child: StreamBuilder<List<SocialMessage>>(
              stream: messagesStream,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                final messages = snapshot.data ?? [];
                // Reverse is handled by ListView.reverse

                return ListView.builder(
                  reverse: true, // Show newest at bottom (requires list to be sorted desc)
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    final message = messages[index];
                    final isMe = message.senderId == ref.read(socialServiceProvider).currentUserId;
                    return MessageBubble(message: message, isMe: isMe);
                  },
                );
              },
            ),
          ),
          // Input Area
          _buildInputArea(),
        ],
      ),
    );
  }

  Widget _buildInputArea() {
    return Container(
      padding: const EdgeInsets.all(8.0),
      color: Theme.of(context).scaffoldBackgroundColor, // Or surface color
      child: Row(
        children: [
          IconButton(
             icon: const Icon(Icons.photo_camera), 
             onPressed: _pickAndSendImage,
             tooltip: 'Send Image',
          ),
          Expanded(
            child: TextField(
              controller: _controller,
              decoration: InputDecoration(
                hintText: 'Type a message...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24.0),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              ),
            ),
          ),
          const SizedBox(width: 8),
          CircleAvatar(
            backgroundColor: Theme.of(context).primaryColor,
            child: IconButton(
              icon: const Icon(Icons.send, color: Colors.white),
              onPressed: _sendMessage,
            ),
          ),
        ],
      ),
    );
  }
}

class MessageBubble extends StatelessWidget {
  final SocialMessage message;
  final bool isMe;
  final int participantCount; // Total participants in chat (for read status)

  const MessageBubble({
    super.key, 
    required this.message, 
    required this.isMe,
    this.participantCount = 2, // Default to direct chat
  });

  @override
  Widget build(BuildContext context) {
    // Basic rendering by type
    Widget contentWidget;
    
    switch (message.type) {
      case SocialMessageType.text:
        contentWidget = Text(
          message.content.text ?? '',
          style: TextStyle(color: isMe ? Colors.white : Colors.black87),
        );
        break;
      case SocialMessageType.image:
        final url = message.content.mediaUrl;
        contentWidget = url != null 
          ? ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: CachedNetworkImage(
                 imageUrl: url,
                 width: 200,
                 fit: BoxFit.cover,
                 placeholder: (context, url) => Container(
                   width: 200, height: 150, 
                   color: Colors.grey.shade300,
                   child: const Center(child: CircularProgressIndicator()),
                 ),
                 errorWidget: (context, url, error) => const Icon(Icons.broken_image, size: 50, color: Colors.white),
              ),
            ) 
          : const Text('📷 Image (Error)', style: TextStyle(fontStyle: FontStyle.italic));
        break;
      case SocialMessageType.gameInvite:
        contentWidget = _buildGameInviteContent();
        break;
      case SocialMessageType.diamondGift:
        contentWidget = _buildDiamondGiftContent();
        break;
      case SocialMessageType.gameResult:
        contentWidget = _buildGameResultContent();
        break;
      default:
        contentWidget = Text('[${message.type.name}]');
    }

    // Special styling for diamond gifts
    final bool isDiamondGift = message.type == SocialMessageType.diamondGift;

    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          gradient: isDiamondGift 
            ? const LinearGradient(
                colors: [Color(0xFF9C27B0), Color(0xFFE91E63)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              )
            : null,
          color: isDiamondGift ? null : (isMe ? Colors.purple : Colors.grey.shade200),
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(16),
            topRight: const Radius.circular(16),
            bottomLeft: Radius.circular(isMe ? 16 : 4),
            bottomRight: Radius.circular(isMe ? 4 : 16),
          ),
          boxShadow: isDiamondGift ? [
            BoxShadow(
              color: Colors.purple.withValues(alpha: 0.4),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ] : null,
        ),
        constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            contentWidget,
            const SizedBox(height: 4),
            // Metadata row with time and read receipts
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  DateFormat.Hm().format(message.timestamp),
                  style: TextStyle(
                    fontSize: 10,
                    color: (isMe || isDiamondGift) ? Colors.white70 : Colors.black54,
                  ),
                ),
                if (isMe) ...[
                  const SizedBox(width: 4),
                  _ReadReceiptIndicator(
                    readBy: message.readBy,
                    participantCount: participantCount,
                    senderId: message.senderId,
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGameInviteContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('🎮 Game Invite', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
        Text('${message.content.gameType}', style: const TextStyle(color: Colors.white70)),
        const SizedBox(height: 4),
        ElevatedButton(
          onPressed: () {
            // Join Game Logic
          },
          child: const Text('Join'),
        )
      ],
    );
  }

  Widget _buildDiamondGiftContent() {
    final amount = message.content.diamondAmount ?? 0;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // Diamond icon with sparkle effect
        Stack(
          alignment: Alignment.center,
          children: [
            const Text('💎', style: TextStyle(fontSize: 40)),
            Positioned(
              top: -4,
              right: -4,
              child: const Text('✨', style: TextStyle(fontSize: 16)),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          '+$amount Diamonds',
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        if (message.content.text != null && message.content.text!.isNotEmpty) ...[
          const SizedBox(height: 4),
          Text(
            '"${message.content.text}"',
            style: const TextStyle(
              color: Colors.white70,
              fontStyle: FontStyle.italic,
              fontSize: 12,
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildGameResultContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('🏆 Game Result', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
        Text('${message.content.gameType}', style: const TextStyle(color: Colors.white70)),
        const SizedBox(height: 4),
        const Text('Tap to view details', style: TextStyle(color: Colors.white54, fontSize: 11)),
      ],
    );
  }
}

/// Read receipt indicator widget (WhatsApp-style ticks)
class _ReadReceiptIndicator extends StatelessWidget {
  final List<String> readBy;
  final int participantCount;
  final String senderId;

  const _ReadReceiptIndicator({
    required this.readBy,
    required this.participantCount,
    required this.senderId,
  });

  @override
  Widget build(BuildContext context) {
    // Calculate read status
    // readBy should contain userIds who have read the message
    // Exclude sender from count
    final othersWhoRead = readBy.where((id) => id != senderId).length;
    final totalOthers = participantCount - 1; // Exclude sender
    
    // Status: sent (no confirmation), delivered (message saved), read (others read)
    final bool isRead = othersWhoRead > 0 && othersWhoRead >= totalOthers;
    final bool isDelivered = readBy.isNotEmpty; // At least message was saved
    
    if (isRead) {
      // Blue double tick - read by all others
      return const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.done_all, size: 14, color: Colors.lightBlueAccent),
        ],
      );
    } else if (isDelivered) {
      // Grey double tick - delivered but not fully read
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.done_all, size: 14, color: Colors.white.withValues(alpha: 0.7)),
        ],
      );
    } else {
      // Single tick - sent
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.done, size: 14, color: Colors.white.withValues(alpha: 0.7)),
        ],
      );
    }
  }
}

