import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../services/social_service.dart';
import '../services/presence_service.dart';
import '../models/social_chat_model.dart';
import '../models/social_user_model.dart'; // For UserStatus if needed

class ChatListScreen extends ConsumerWidget {
  const ChatListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final chatStream = ref.watch(socialServiceProvider).watchMyChats();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Chats'),
        actions: [
          IconButton(
            icon: const Icon(Icons.people),
            tooltip: 'Friends',
            onPressed: () => context.push('/friends'),
          ),
          IconButton(
            icon: const Icon(Icons.shield_outlined), // Club icon
            tooltip: 'Clubs',
            onPressed: () => context.push('/clubs'),
          ),
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => _createVoiceRoom(context, ref),
          ),
        ],
      ),
      body: StreamBuilder<List<SocialChat>>(
        stream: chatStream,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          final chats = snapshot.data ?? [];

          if (chats.isEmpty) {
            return _buildEmptyState(context);
          }

          return ListView.separated(
            itemCount: chats.length,
            separatorBuilder: (ctx, i) => const Divider(height: 1),
            itemBuilder: (context, index) {
              final chat = chats[index];
              return ChatListTile(chat: chat);
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.chat),
        onPressed: () {
          // Navigate to "New Chat" contact picker
          // context.push('/social/new-chat'); 
        },
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    // AI Companion Bots for instant engagement
    final aiBots = [
      {'id': 'tips_bot', 'name': '🎯 Tips Bot', 'desc': 'Get game strategies & tips', 'color': Colors.blue},
      {'id': 'news_bot', 'name': '📰 News Bot', 'desc': 'Latest updates & features', 'color': Colors.orange},
      {'id': 'finder_bot', 'name': '🎲 Club Finder', 'desc': 'Discover clubs to join', 'color': Colors.purple},
    ];

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          const SizedBox(height: 32),
          Icon(Icons.chat_bubble_outline, size: 64, color: Colors.grey.shade400),
          const SizedBox(height: 16),
          const Text(
            'No conversations yet',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          const Text('Start a chat with a friend!'),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () {},
            child: const Text('Start New Chat'),
          ),
          const SizedBox(height: 32),
          // AI Companions Section
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.deepPurple.shade50, Colors.blue.shade50],
              ),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.deepPurple.shade100),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.smart_toy, color: Colors.deepPurple.shade600),
                    const SizedBox(width: 8),
                    Text(
                      'AI Companions',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: Colors.deepPurple.shade800,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  'Chat with our bots for help & discovery!',
                  style: TextStyle(color: Colors.grey.shade700),
                ),
                const SizedBox(height: 16),
                ...aiBots.map((bot) => _buildBotTile(context, bot)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBotTile(BuildContext context, Map<String, dynamic> bot) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: (bot['color'] as Color).withValues(alpha: 0.2),
          child: Text(
            bot['name'].toString().substring(0, 2),
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: bot['color'] as Color,
            ),
          ),
        ),
        title: Text(
          bot['name'] as String,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(bot['desc'] as String),
        trailing: Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey.shade400),
        onTap: () {
          // Navigate to AI bot chat
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Starting chat with ${bot['name']}...'),
              backgroundColor: bot['color'] as Color,
            ),
          );
          // TODO: Implement AI bot chat - context.push('/social/ai-chat/${bot['id']}');
        },
      ),
    );
  }

  void _createVoiceRoom(BuildContext context, WidgetRef ref) {
    final nameController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('New Voice Room'),
        content: TextField(
          controller: nameController,
          decoration: const InputDecoration(hintText: 'Room Name (e.g. Chill Lounge)'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () async {
              final name = nameController.text.trim();
              if (name.isEmpty) return;
              
              Navigator.pop(context); // Close dialog
              
              try {
                final chatId = await ref.read(socialServiceProvider).createVoiceRoom(name);
                if (context.mounted) {
                   context.push('/voice-room/$chatId');
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
                }
              }
            },
            child: const Text('Create'),
          ),
        ],
      ),
    );
  }
}

class ChatListTile extends ConsumerWidget {
  final SocialChat chat;

  const ChatListTile({super.key, required this.chat});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Logic to determine Avatar and Title based on chat type
    final currentUserId = ref.read(socialServiceProvider).currentUserId;
    
    // For Direct Chat, name/avatar is the other person
    String displayTitle = chat.name ?? 'Chat';
    String? displayAvatar = chat.avatarUrl;
    String? otherUserId;

    if (chat.type == ChatType.direct && currentUserId != null) {
       final others = chat.participants.where((id) => id != currentUserId).toList();
       if (others.isNotEmpty) {
         otherUserId = others.first;
         // TODO: We should ideally fetch the User Profile here to get the name/avatar 
         // if it's not stored in the chat object. 
         // For now, assume chat.name is updated or use 'User'
       }
    }

    final subtitle = chat.lastMessage?.content ?? 'No messages yet';
    final time = chat.lastMessage != null 
        ? DateFormat.Hm().format(chat.lastMessage!.timestamp) 
        : '';
        
    return ListTile(
      leading: Stack(
        children: [
          CircleAvatar(
            radius: 24,
            backgroundColor: Colors.purple.shade100,
            child: displayAvatar != null
                ? getAvatarImage(displayAvatar)
                : Text(displayTitle.isNotEmpty ? displayTitle[0].toUpperCase() : '?'),
          ),
          if (otherUserId != null)
             Positioned(
               right: 0,
               bottom: 0,
               child: Consumer(
                 builder: (context, ref, child) {
                   final statusSnapshot = ref.watch(presenceServiceProvider).watchUserStatus(otherUserId!);
                   
                   return StreamBuilder<SocialUserStatus>(
                     stream: statusSnapshot,
                     builder: (context, snapshot) {
                        if (!snapshot.hasData) return const SizedBox();
                        final isOnline = snapshot.data!.status == UserStatus.online;
                        final isInGame = snapshot.data!.status == UserStatus.inGame;
                        
                        Color? statusColor;
                        if (isOnline) statusColor = Colors.green;
                        if (isInGame) statusColor = Colors.amber;
                        
                        if (statusColor == null) return const SizedBox();

                        return Container(
                          width: 12,
                          height: 12,
                          decoration: BoxDecoration(
                            color: statusColor,
                            shape: BoxShape.circle,
                            border: Border.all(color: Theme.of(context).scaffoldBackgroundColor, width: 2),
                          ),
                        );
                     },
                   );
                 }
               ),
             ),
        ],
      ),
      title: Text(
        displayTitle, 
        style: const TextStyle(fontWeight: FontWeight.bold),
      ),
      subtitle: Text(
        subtitle,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      trailing: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(
            time, 
            style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
          ),
        ],
      ),
      onTap: () {
        if (chat.type == ChatType.voiceRoom) {
          context.push('/voice-room/${chat.id}');
        } else {
          context.push('/social/chat/${chat.id}');
        }
      },
    );
  }
  
  Widget getAvatarImage(String url) {
    if (url.startsWith('http')) {
      return CircleAvatar(backgroundImage: NetworkImage(url));
    }
    return const Icon(Icons.person);
  }
}
