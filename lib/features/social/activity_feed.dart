/// Activity Feed Model and Provider
/// 
/// Displays friends' game results, achievements, and activity
library;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

part 'activity_feed.freezed.dart';
part 'activity_feed.g.dart';

/// Types of feed items
enum FeedItemType {
  gameResult,
  achievement,
  friendJoined,
  storyPost,
  clubJoined,
  tournamentWin,
}

/// A single item in the activity feed
@freezed
abstract class FeedItem with _$FeedItem {
  const FeedItem._();

  const factory FeedItem({
    required String id,
    required String oderId,
    required String userName,
    String? userAvatarUrl,
    required FeedItemType type,
    required String title,
    required String description,
    String? imageUrl,
    required DateTime createdAt,
    
    // Game result specific
    String? gameType,
    int? score,
    bool? isWin,
    Map<String, int>? gameScores,
    
    // Achievement specific
    String? achievementId,
    String? achievementRarity,
    
    // Reactions
    @Default([]) List<String> likedBy,
    @Default(0) int likesCount,
    @Default(0) int commentsCount,
  }) = _FeedItem;

  factory FeedItem.fromJson(Map<String, dynamic> json) => _$FeedItemFromJson(json);

  /// Check if current user liked this item
  bool isLikedBy(String oderId) => likedBy.contains(oderId);
}

/// Activity Feed Service
class ActivityFeedService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Collection reference for global feed
  CollectionReference<Map<String, dynamic>> get _feedRef =>
      _firestore.collection('activity_feed');

  /// Stream of feed items for a user (includes friends' activities)
  Stream<List<FeedItem>> watchFeed(String oderId, {int limit = 50}) {
    // For now, return global feed - in production, filter by friends
    return _feedRef
        .orderBy('createdAt', descending: true)
        .limit(limit)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => FeedItem.fromJson({...doc.data(), 'id': doc.id}))
            .toList());
  }

  /// Post a game result to the feed
  Future<void> postGameResult({
    required String oderId,
    required String userName,
    String? userAvatarUrl,
    required String gameType,
    required int score,
    required bool isWin,
    Map<String, int>? allScores,
  }) async {
    final gameDisplayName = _getGameDisplayName(gameType);
    final title = isWin ? '🏆 Won a $gameDisplayName game!' : 'Played $gameDisplayName';
    
    await _feedRef.add({
      'oderId': oderId,
      'userName': userName,
      'userAvatarUrl': userAvatarUrl,
      'type': FeedItemType.gameResult.name,
      'title': title,
      'description': 'Score: $score points',
      'createdAt': FieldValue.serverTimestamp(),
      'gameType': gameType,
      'score': score,
      'isWin': isWin,
      'gameScores': allScores,
      'likedBy': [],
      'likesCount': 0,
      'commentsCount': 0,
    });
  }

  /// Post achievement unlock to feed
  Future<void> postAchievement({
    required String oderId,
    required String userName,
    String? userAvatarUrl,
    required String achievementId,
    required String achievementTitle,
    required String achievementRarity,
  }) async {
    await _feedRef.add({
      'oderId': oderId,
      'userName': userName,
      'userAvatarUrl': userAvatarUrl,
      'type': FeedItemType.achievement.name,
      'title': '🏅 Unlocked "$achievementTitle"',
      'description': '$achievementRarity achievement',
      'createdAt': FieldValue.serverTimestamp(),
      'achievementId': achievementId,
      'achievementRarity': achievementRarity,
      'likedBy': [],
      'likesCount': 0,
      'commentsCount': 0,
    });
  }

  /// Toggle like on a feed item
  Future<void> toggleLike(String feedItemId, String oderId) async {
    final docRef = _feedRef.doc(feedItemId);
    
    await _firestore.runTransaction((transaction) async {
      final doc = await transaction.get(docRef);
      if (!doc.exists) return;
      
      final data = doc.data()!;
      final likedBy = List<String>.from(data['likedBy'] ?? []);
      
      if (likedBy.contains(oderId)) {
        likedBy.remove(oderId);
      } else {
        likedBy.add(oderId);
      }
      
      transaction.update(docRef, {
        'likedBy': likedBy,
        'likesCount': likedBy.length,
      });
    });
  }

  String _getGameDisplayName(String gameType) {
    switch (gameType) {
      case 'marriage':
        return 'Marriage';
      case 'call_break':
        return 'Call Break';
      case 'teen_patti':
        return 'Teen Patti';
      case 'in_between':
        return 'In-Between';
      default:
        return gameType;
    }
  }
}

/// Provider for activity feed service
final activityFeedServiceProvider = Provider<ActivityFeedService>((ref) {
  return ActivityFeedService();
});

/// Provider for feed items stream
final activityFeedProvider = StreamProvider.family<List<FeedItem>, String>((ref, oderId) {
  return ref.watch(activityFeedServiceProvider).watchFeed(oderId);
});
