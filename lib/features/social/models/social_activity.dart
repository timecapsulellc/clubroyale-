
import 'package:cloud_firestore/cloud_firestore.dart';

/// Activity model for social feed
class SocialActivity {
  final String id;
  final String type; // 'game_won', 'game_lost', 'club_joined', 'friend_added', 'message'
  final String userId;
  final String userName;
  final String? userAvatar;
  final String content;
  final DateTime timestamp;
  final Map<String, dynamic>? metadata;

  SocialActivity({
    required this.id,
    required this.type,
    required this.userId,
    required this.userName,
    this.userAvatar,
    required this.content,
    required this.timestamp,
    this.metadata,
  });

  factory SocialActivity.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return SocialActivity(
      id: doc.id,
      type: data['type'] ?? 'unknown',
      userId: data['userId'] ?? '',
      userName: data['userName'] ?? 'Unknown',
      userAvatar: data['userAvatar'],
      content: data['content'] ?? '',
      timestamp: (data['timestamp'] as Timestamp?)?.toDate() ?? DateTime.now(),
      metadata: data['metadata'],
    );
  }
}
