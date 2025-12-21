import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../services/social_service.dart';
import '../models/social_message_model.dart';
import 'package:intl/intl.dart';
import 'package:clubroyale/core/widgets/skeleton_loading.dart';

class ChatRoomScreen extends ConsumerStatefulWidget {
  final String chatId;
  final String title;

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
  SocialMessage? _replyingTo; // Track the message being replied to

  void _sendMessage() {
    if (_controller.text.trim().isEmpty) return;

    final text = _controller.text.trim();
    _controller.clear();
    
    // Capture reply context if active
    final replyId = _replyingTo?.id;
    final replyPreview = _replyingTo != null 
        ? SocialMessagePreviewData(
            id: _replyingTo!.id,
            senderName: _replyingTo!.senderName,
            contentPreview: _getMessagePreviewText(_replyingTo!),
          ) 
        : null;

    // Clear reply state
    setState(() => _replyingTo = null);

    ref.read(socialServiceProvider).sendTextMessage(
      chatId: widget.chatId,
      text: text,
      replyToMessageId: replyId,
      replyToPreview: replyPreview,
    ).catchError((e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to send: $e')),
      );
    });
  }
  
  String _getMessagePreviewText(SocialMessage msg) {
    if (msg.type == SocialMessageType.text) return msg.content.text ?? '';
    if (msg.type == SocialMessageType.image) return '📷 Image';
    if (msg.type == SocialMessageType.diamondGift) return '💎 Diamond Gift';
    if (msg.type == SocialMessageType.gameInvite) return '🎮 Game Invite';
    return 'Message';
  }

  Future<void> _pickAndSendImage() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery, imageQuality: 70);
    
    if (picked != null) {
      final file = File(picked.path);
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
                  return ListView.builder(
                    itemCount: 12,
                    reverse: true,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    itemBuilder: (context, index) => SkeletonMessage(isMe: index % 2 == 0),
                  );
                }

                final messages = snapshot.data ?? [];

                return ListView.builder(
                  reverse: true,
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    final message = messages[index];
                    final isMe = message.senderId == ref.read(socialServiceProvider).currentUserId;
                    
                    return GestureDetector(
                      onLongPress: () {
                         setState(() => _replyingTo = message);
                      },
                      child: MessageBubble(
                        message: message, 
                        isMe: isMe,
                        onSwipe: () => setState(() => _replyingTo = message), // Future: Implement swipe gesture
                      ),
                    );
                  },
                );
              },
            ),
          ),
          
          // Reply Preview Bar
          if (_replyingTo != null)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              color: Theme.of(context).colorScheme.surfaceContainerHighest,
              child: Row(
                children: [
                  const Icon(Icons.reply, size: 20, color: Colors.grey),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Replying to ${_replyingTo!.senderName}', 
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).colorScheme.primary,
                            fontSize: 12,
                          ),
                        ),
                        Text(
                          _getMessagePreviewText(_replyingTo!),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, size: 20),
                    onPressed: () => setState(() => _replyingTo = null),
                  ),
                ],
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
      color: Theme.of(context).scaffoldBackgroundColor,
      child: SafeArea(
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
                textCapitalization: TextCapitalization.sentences,
                onSubmitted: (_) => _sendMessage(),
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
      ),
    );
  }
}

class MessageBubble extends StatelessWidget {
  final SocialMessage message;
  final bool isMe;
  final int participantCount;
  final VoidCallback? onSwipe;

  const MessageBubble({
    super.key, 
    required this.message, 
    required this.isMe,
    this.participantCount = 2,
    this.onSwipe,
  });

  @override
  Widget build(BuildContext context) {
    Widget contentWidget;
    
    switch (message.type) {
      case SocialMessageType.text:
        contentWidget = Text(
          message.content.text ?? '',
          style: TextStyle(color: isMe ? Colors.white : Theme.of(context).colorScheme.onSurface),
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
        contentWidget = _buildGameInviteContent(context);
        break;
      case SocialMessageType.diamondGift:
        contentWidget = _buildDiamondGiftContent(context);
        break;
      case SocialMessageType.gameResult:
        contentWidget = _buildGameResultContent();
        break;
      default:
        contentWidget = Text('[${message.type.name}]');
    }

    final bool isDiamondGift = message.type == SocialMessageType.diamondGift;
    final bool isGameInvite = message.type == SocialMessageType.gameInvite;
    
    // Styling base - use theme colors for dark mode support
    final colorScheme = Theme.of(context).colorScheme;
    Color bubbleColor = isMe ? colorScheme.primary : colorScheme.surfaceContainerHighest;
    Color textColor = isMe ? Colors.white : colorScheme.onSurface;
    
    if (isDiamondGift) {
      textColor = Colors.white;
    }

    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        padding: EdgeInsets.all(isDiamondGift || isGameInvite ? 0 : 12),
        decoration: BoxDecoration(
          gradient: isDiamondGift 
            ? const LinearGradient(
                colors: [Color(0xFF9C27B0), Color(0xFFE91E63)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              )
            : (isGameInvite ? const LinearGradient(
                colors: [Color(0xFF1A237E), Color(0xFF3949AB)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ) : null),
          color: (isDiamondGift || isGameInvite) ? null : bubbleColor,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(16),
            topRight: const Radius.circular(16),
            bottomLeft: Radius.circular(isMe ? 16 : 4),
            bottomRight: Radius.circular(isMe ? 4 : 16),
          ),
          boxShadow: (isDiamondGift || isGameInvite) ? [
            BoxShadow(
              color: (isDiamondGift ? Colors.pink : Colors.indigo).withValues(alpha: 0.3),
              blurRadius: 8,
              offset: const Offset(0, 4),
            )
          ] : null,
        ),
        constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Reply content
            if (message.replyToPreview != null)
              _buildReplyPreview(context, message.replyToPreview!),

            // Main Content
            Padding(
               padding: const EdgeInsets.all(12), // Inner padding for special widgets
               child: Column(
                 crossAxisAlignment: CrossAxisAlignment.end,
                 children: [
                   contentWidget,
                   const SizedBox(height: 4),
                   Row(
                     mainAxisSize: MainAxisSize.min,
                     children: [
                       Text(
                         DateFormat.Hm().format(message.timestamp),
                         style: TextStyle(
                           fontSize: 10,
                           color: textColor.withValues(alpha: 0.7),
                         ),
                       ),
                       if (isMe) ...[
                         const SizedBox(width: 4),
                         _ReadReceiptIndicator(
                           readBy: message.readBy,
                           participantCount: participantCount,
                           senderId: message.senderId,
                           color: textColor.withValues(alpha: 0.7),
                         ),
                       ],
                     ],
                   ),
                 ],
               ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReplyPreview(BuildContext context, SocialMessagePreviewData reply) {
    return Container(
      margin: const EdgeInsets.all(4),
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border(
           left: BorderSide(
             color: isMe ? Colors.white70 : Theme.of(context).primaryColor, 
             width: 4,
           ),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            reply.senderName, 
            style: TextStyle(
              fontWeight: FontWeight.bold, 
              fontSize: 11,
              color: isMe ? Colors.white70 : Theme.of(context).primaryColor,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            reply.contentPreview,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 11, 
              color: isMe ? Colors.white70 : Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGameInviteContent(BuildContext context) {
    return IntrinsicWidth(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              const Icon(Icons.videogame_asset, color: Colors.white, size: 28),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Game Invite', 
                    style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 16)),
                  Text('Let\'s play ${message.content.gameType}!', 
                    style: const TextStyle(color: Colors.white70, fontSize: 12)),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          FilledButton(
            onPressed: () {
               // Navigation logic handled by GoRouter usually
               // context.push('/lobby/${message.content.gameRoomId}');
            },
            style: FilledButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: const Color(0xFF1A237E),
            ),
            child: const Text('JOIN GAME', style: TextStyle(fontWeight: FontWeight.bold)),
          )
        ],
      ),
    );
  }

  Widget _buildDiamondGiftContent(BuildContext context) {
    final amount = message.content.diamondAmount ?? 0;
    return Column(
      children: [
        Stack(
          alignment: Alignment.center,
          children: [
            // Shine effect
             Container(
               width: 60, height: 60,
               decoration: BoxDecoration(
                 shape: BoxShape.circle,
                 boxShadow: [
                   BoxShadow(color: Colors.white.withValues(alpha: 0.6), blurRadius: 20, spreadRadius: 5),
                 ],
               ),
             ),
             const Text('💎', style: TextStyle(fontSize: 48)),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          '+$amount',
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w900,
            fontSize: 24,
            shadows: [Shadow(color: Colors.black26, offset: Offset(0, 2), blurRadius: 4)],
          ),
        ),
        const Text('DIAMONDS', style: TextStyle(color: Colors.white70, fontSize: 10, letterSpacing: 1.5)),
        if (message.content.text != null && message.content.text!.isNotEmpty) ...[
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              message.content.text!,
              style: const TextStyle(color: Colors.white, fontStyle: FontStyle.italic),
              textAlign: TextAlign.center,
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
      ],
    );
  }
}

class _ReadReceiptIndicator extends StatelessWidget {
  final List<String> readBy;
  final int participantCount;
  final String senderId;
  final Color color;

  const _ReadReceiptIndicator({
    required this.readBy,
    required this.participantCount,
    required this.senderId,
    this.color = Colors.white70,
  });

  @override
  Widget build(BuildContext context) {
    final othersWhoRead = readBy.where((id) => id != senderId).length;
    final totalOthers = participantCount - 1;
    
    final bool isRead = othersWhoRead > 0 && othersWhoRead >= totalOthers;
    final bool isDelivered = readBy.isNotEmpty;
    
    if (isRead) {
      return const Icon(Icons.done_all, size: 14, color: Colors.lightBlueAccent); // Blue checks
    } else if (isDelivered) {
      return Icon(Icons.done_all, size: 14, color: color); // Grey checks
    } else {
      return Icon(Icons.done, size: 14, color: color); // Single check
    }
  }
}

