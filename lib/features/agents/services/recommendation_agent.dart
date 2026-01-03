import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_functions/cloud_functions.dart';

/// Recommendation Agent provider
final recommendationAgentProvider = Provider<RecommendationAgent>((ref) {
  return RecommendationAgent();
});

/// Recommendation Agent - Personalized Content & Discovery
///
/// Features:
/// - Feed ranking
/// - Friend suggestions
/// - Game recommendations
class RecommendationAgent {
  final FirebaseFunctions _functions = FirebaseFunctions.instance;

  /// Rank content for personalized feed
  Future<FeedRankingResult> rankFeed({
    required String userId,
    required UserProfile userProfile,
    required List<ContentItem> contentItems,
    FeedType feedType = FeedType.home,
    int limit = 20,
  }) async {
    try {
      final callable = _functions.httpsCallable('rankFeed');
      final result = await callable.call<Map<String, dynamic>>({
        'userId': userId,
        'userProfile': userProfile.toJson(),
        'contentItems': contentItems.map((c) => c.toJson()).toList(),
        'feedType': feedType.name,
        'limit': limit,
      });
      return FeedRankingResult.fromJson(result.data);
    } catch (e) {
      // Return default ranking
      return FeedRankingResult(
        rankedContent: contentItems
            .take(limit)
            .map(
              (c) => RankedContent(
                contentId: c.id,
                score: c.engagementScore,
                reason: 'Default ranking',
              ),
            )
            .toList(),
        trendingTopics: [],
        suggestedCreators: [],
      );
    }
  }

  /// Get friend suggestions
  Future<List<FriendSuggestion>> suggestFriends({
    required String userId,
    required UserGameProfile userProfile,
    required List<PotentialFriend> potentialFriends,
    int limit = 10,
  }) async {
    try {
      final callable = _functions.httpsCallable('suggestFriends');
      final result = await callable.call<Map<String, dynamic>>({
        'userId': userId,
        'userProfile': userProfile.toJson(),
        'potentialFriends': potentialFriends.map((f) => f.toJson()).toList(),
        'limit': limit,
      });
      return (result.data['suggestions'] as List<dynamic>?)
              ?.map((s) => FriendSuggestion.fromJson(s))
              .toList() ??
          [];
    } catch (e) {
      return [];
    }
  }

  /// Get game recommendations
  Future<List<GameRecommendation>> recommendGames({
    required String userId,
    required List<GameHistory> playHistory,
    String? currentMood,
    String? availableTime,
  }) async {
    try {
      final callable = _functions.httpsCallable('recommendGames');
      final result = await callable.call<Map<String, dynamic>>({
        'userId': userId,
        'playHistory': playHistory.map((h) => h.toJson()).toList(),
        if (currentMood != null) 'currentMood': currentMood,
        if (availableTime != null) 'availableTime': availableTime,
      });
      return (result.data['recommendations'] as List<dynamic>?)
              ?.map((r) => GameRecommendation.fromJson(r))
              .toList() ??
          [];
    } catch (e) {
      return [
        GameRecommendation(
          game: 'Call Break',
          reason: 'Popular choice!',
          matchScore: 0.8,
        ),
      ];
    }
  }
}

// ==================== ENUMS ====================

enum FeedType { home, discover, gaming, social }

// ==================== DATA MODELS ====================

class UserProfile {
  final List<String> interests;
  final List<String> playedGames;
  final List<String> followedUsers;
  final String? skillLevel;

  UserProfile({
    required this.interests,
    required this.playedGames,
    required this.followedUsers,
    this.skillLevel,
  });

  Map<String, dynamic> toJson() => {
    'interests': interests,
    'playedGames': playedGames,
    'followedUsers': followedUsers,
    if (skillLevel != null) 'skillLevel': skillLevel,
  };
}

class ContentItem {
  final String id;
  final String type;
  final String creatorId;
  final List<String> tags;
  final double engagementScore;
  final String createdAt;

  ContentItem({
    required this.id,
    required this.type,
    required this.creatorId,
    required this.tags,
    required this.engagementScore,
    required this.createdAt,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'type': type,
    'creatorId': creatorId,
    'tags': tags,
    'engagementScore': engagementScore,
    'createdAt': createdAt,
  };
}

class FeedRankingResult {
  final List<RankedContent> rankedContent;
  final List<String> trendingTopics;
  final List<String> suggestedCreators;

  FeedRankingResult({
    required this.rankedContent,
    required this.trendingTopics,
    required this.suggestedCreators,
  });

  factory FeedRankingResult.fromJson(Map<String, dynamic> json) {
    return FeedRankingResult(
      rankedContent:
          (json['rankedContent'] as List<dynamic>?)
              ?.map((r) => RankedContent.fromJson(r))
              .toList() ??
          [],
      trendingTopics: List<String>.from(json['trendingTopics'] ?? []),
      suggestedCreators: List<String>.from(json['suggestedCreators'] ?? []),
    );
  }
}

class RankedContent {
  final String contentId;
  final double score;
  final String reason;

  RankedContent({
    required this.contentId,
    required this.score,
    required this.reason,
  });

  factory RankedContent.fromJson(Map<String, dynamic> json) {
    return RankedContent(
      contentId: json['contentId'] as String? ?? '',
      score: (json['score'] as num?)?.toDouble() ?? 0.0,
      reason: json['reason'] as String? ?? '',
    );
  }
}

class UserGameProfile {
  final List<String> games;
  final String skillLevel;
  final String? location;

  UserGameProfile({
    required this.games,
    required this.skillLevel,
    this.location,
  });

  Map<String, dynamic> toJson() => {
    'games': games,
    'skillLevel': skillLevel,
    if (location != null) 'location': location,
  };
}

class PotentialFriend {
  final String id;
  final List<String> games;
  final String skillLevel;
  final int mutualFriends;
  final String lastActive;

  PotentialFriend({
    required this.id,
    required this.games,
    required this.skillLevel,
    required this.mutualFriends,
    required this.lastActive,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'games': games,
    'skillLevel': skillLevel,
    'mutualFriends': mutualFriends,
    'lastActive': lastActive,
  };
}

class FriendSuggestion {
  final String userId;
  final double compatibilityScore;
  final String reason;
  final List<String> commonInterests;

  FriendSuggestion({
    required this.userId,
    required this.compatibilityScore,
    required this.reason,
    required this.commonInterests,
  });

  factory FriendSuggestion.fromJson(Map<String, dynamic> json) {
    return FriendSuggestion(
      userId: json['userId'] as String? ?? '',
      compatibilityScore:
          (json['compatibilityScore'] as num?)?.toDouble() ?? 0.0,
      reason: json['reason'] as String? ?? '',
      commonInterests: List<String>.from(json['commonInterests'] ?? []),
    );
  }
}

class GameHistory {
  final String game;
  final int timesPlayed;
  final double winRate;

  GameHistory({
    required this.game,
    required this.timesPlayed,
    required this.winRate,
  });

  Map<String, dynamic> toJson() => {
    'game': game,
    'timesPlayed': timesPlayed,
    'winRate': winRate,
  };
}

class GameRecommendation {
  final String game;
  final String reason;
  final double matchScore;
  final String? suggestedMode;

  GameRecommendation({
    required this.game,
    required this.reason,
    required this.matchScore,
    this.suggestedMode,
  });

  factory GameRecommendation.fromJson(Map<String, dynamic> json) {
    return GameRecommendation(
      game: json['game'] as String? ?? '',
      reason: json['reason'] as String? ?? '',
      matchScore: (json['matchScore'] as num?)?.toDouble() ?? 0.0,
      suggestedMode: json['suggestedMode'] as String?,
    );
  }
}
