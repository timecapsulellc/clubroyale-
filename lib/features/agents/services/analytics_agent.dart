import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_functions/cloud_functions.dart';

/// Analytics Agent provider
final analyticsAgentProvider = Provider<AnalyticsAgent>((ref) {
  return AnalyticsAgent();
});

/// Analytics Agent - User Insights & Engagement
///
/// Features:
/// - Engagement prediction
/// - Trend analysis
class AnalyticsAgent {
  final FirebaseFunctions _functions = FirebaseFunctions.instance;

  /// Predict user engagement and churn risk
  Future<EngagementPrediction> predictEngagement({
    required String userId,
    required UserMetrics userMetrics,
    List<String>? recentActivity,
  }) async {
    try {
      final callable = _functions.httpsCallable('predictEngagement');
      final result = await callable.call<Map<String, dynamic>>({
        'userId': userId,
        'userMetrics': userMetrics.toJson(),
        if (recentActivity != null) 'recentActivity': recentActivity,
      });
      return EngagementPrediction.fromJson(result.data);
    } catch (e) {
      return EngagementPrediction.fallback();
    }
  }

  /// Analyze platform trends
  Future<TrendAnalysis> analyzeTrends({
    required TimeRange timeRange,
    required PlatformMetrics metrics,
    PlatformMetrics? previousPeriod,
  }) async {
    try {
      final callable = _functions.httpsCallable('analyzeTrends');
      final result = await callable.call<Map<String, dynamic>>({
        'timeRange': timeRange.name,
        'metrics': metrics.toJson(),
        if (previousPeriod != null) 'previousPeriod': previousPeriod.toJson(),
      });
      return TrendAnalysis.fromJson(result.data);
    } catch (e) {
      return TrendAnalysis.empty();
    }
  }
}

// ==================== ENUMS ====================

enum TimeRange { day, week, month }

enum ChurnRisk { low, medium, high }

// ==================== DATA MODELS ====================

class UserMetrics {
  final int totalGames;
  final int gamesThisWeek;
  final int avgSessionLength;
  final int friendCount;
  final int diamondBalance;
  final int lastLoginDaysAgo;

  UserMetrics({
    required this.totalGames,
    required this.gamesThisWeek,
    required this.avgSessionLength,
    required this.friendCount,
    required this.diamondBalance,
    required this.lastLoginDaysAgo,
  });

  Map<String, dynamic> toJson() => {
    'totalGames': totalGames,
    'gamesThisWeek': gamesThisWeek,
    'avgSessionLength': avgSessionLength,
    'friendCount': friendCount,
    'diamondBalance': diamondBalance,
    'lastLoginDaysAgo': lastLoginDaysAgo,
  };
}

class EngagementPrediction {
  final double engagementScore;
  final ChurnRisk churnRisk;
  final String predictedNextAction;
  final List<String> retentionStrategies;
  final List<String>? upsellOpportunities;

  EngagementPrediction({
    required this.engagementScore,
    required this.churnRisk,
    required this.predictedNextAction,
    required this.retentionStrategies,
    this.upsellOpportunities,
  });

  factory EngagementPrediction.fromJson(Map<String, dynamic> json) {
    return EngagementPrediction(
      engagementScore: (json['engagementScore'] as num?)?.toDouble() ?? 50.0,
      churnRisk: ChurnRisk.values.firstWhere(
        (r) => r.name == json['churnRisk'],
        orElse: () => ChurnRisk.medium,
      ),
      predictedNextAction:
          json['predictedNextAction'] as String? ?? 'Play a game',
      retentionStrategies: List<String>.from(json['retentionStrategies'] ?? []),
      upsellOpportunities: (json['upsellOpportunities'] as List<dynamic>?)
          ?.cast<String>(),
    );
  }

  factory EngagementPrediction.fallback() {
    return EngagementPrediction(
      engagementScore: 50.0,
      churnRisk: ChurnRisk.medium,
      predictedNextAction: 'Play a game',
      retentionStrategies: ['Send daily reward notification'],
    );
  }
}

class PlatformMetrics {
  final int totalUsers;
  final int activeUsers;
  final int gamesPlayed;
  final int storiesPosted;
  final int diamondsTransferred;

  PlatformMetrics({
    required this.totalUsers,
    required this.activeUsers,
    required this.gamesPlayed,
    required this.storiesPosted,
    required this.diamondsTransferred,
  });

  Map<String, dynamic> toJson() => {
    'totalUsers': totalUsers,
    'activeUsers': activeUsers,
    'gamesPlayed': gamesPlayed,
    'storiesPosted': storiesPosted,
    'diamondsTransferred': diamondsTransferred,
  };
}

class TrendAnalysis {
  final List<TrendInsight> insights;
  final List<String> recommendations;
  final List<String> highlights;
  final List<String>? concerns;

  TrendAnalysis({
    required this.insights,
    required this.recommendations,
    required this.highlights,
    this.concerns,
  });

  factory TrendAnalysis.fromJson(Map<String, dynamic> json) {
    return TrendAnalysis(
      insights:
          (json['insights'] as List<dynamic>?)
              ?.map((i) => TrendInsight.fromJson(i))
              .toList() ??
          [],
      recommendations: List<String>.from(json['recommendations'] ?? []),
      highlights: List<String>.from(json['highlights'] ?? []),
      concerns: (json['concerns'] as List<dynamic>?)?.cast<String>(),
    );
  }

  factory TrendAnalysis.empty() {
    return TrendAnalysis(insights: [], recommendations: [], highlights: []);
  }
}

class TrendInsight {
  final String metric;
  final String trend; // up, down, stable
  final double change;
  final String insight;

  TrendInsight({
    required this.metric,
    required this.trend,
    required this.change,
    required this.insight,
  });

  factory TrendInsight.fromJson(Map<String, dynamic> json) {
    return TrendInsight(
      metric: json['metric'] as String? ?? '',
      trend: json['trend'] as String? ?? 'stable',
      change: (json['change'] as num?)?.toDouble() ?? 0.0,
      insight: json['insight'] as String? ?? '',
    );
  }
}
