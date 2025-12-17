import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_functions/cloud_functions.dart';

/// Safety Agent provider
final safetyAgentProvider = Provider<SafetyAgent>((ref) {
  return SafetyAgent();
});

/// Safety Agent - Enhanced Content Safety
/// 
/// Features:
/// - Content moderation
/// - Behavior analysis
class SafetyAgent {
  final FirebaseFunctions _functions = FirebaseFunctions.instance;

  /// Moderate content
  Future<ModerationResult> moderateContent({
    required ContentType contentType,
    required String content,
    required String userId,
    required String location,
    int previousViolations = 0,
    String language = 'en',
  }) async {
    try {
      final callable = _functions.httpsCallable('moderateContent');
      final result = await callable.call<Map<String, dynamic>>({
        'contentType': contentType.name,
        'content': content,
        'context': {
          'userId': userId,
          'location': location,
          'previousViolations': previousViolations,
        },
        'language': language,
      });
      return ModerationResult.fromJson(result.data);
    } catch (e) {
      // Fail safe - allow if moderation fails
      return ModerationResult.safe();
    }
  }

  /// Analyze user behavior for safety concerns
  Future<BehaviorAnalysis> analyzeBehavior({
    required String userId,
    required List<UserAction> recentActions,
    List<ReportRecord>? reportHistory,
  }) async {
    try {
      final callable = _functions.httpsCallable('analyzeBehavior');
      final result = await callable.call<Map<String, dynamic>>({
        'userId': userId,
        'recentActions': recentActions.map((a) => a.toJson()).toList(),
        if (reportHistory != null)
          'reportHistory': reportHistory.map((r) => r.toJson()).toList(),
      });
      return BehaviorAnalysis.fromJson(result.data);
    } catch (e) {
      return BehaviorAnalysis.normal();
    }
  }

  /// Quick check if text is safe
  Future<bool> isTextSafe(String text, {String location = 'chat'}) async {
    final result = await moderateContent(
      contentType: ContentType.text,
      content: text,
      userId: 'quick_check',
      location: location,
    );
    return result.isSafe;
  }
}

// ==================== ENUMS ====================

enum ContentType { text, username, bio, story, comment }
enum SeverityLevel { none, low, medium, high, critical }
enum ModerAction { allow, warn, filter, block, escalate }
enum RiskLevel { low, medium, high, critical }
enum MonitoringLevel { normal, increased, strict }

// ==================== DATA MODELS ====================

class ModerationResult {
  final bool isSafe;
  final List<ModerationCategory> categories;
  final ModerAction suggestedAction;
  final String? filteredContent;
  final String explanation;

  ModerationResult({
    required this.isSafe,
    required this.categories,
    required this.suggestedAction,
    this.filteredContent,
    required this.explanation,
  });

  factory ModerationResult.fromJson(Map<String, dynamic> json) {
    return ModerationResult(
      isSafe: json['isSafe'] as bool? ?? true,
      categories: (json['categories'] as List<dynamic>?)
          ?.map((c) => ModerationCategory.fromJson(c))
          .toList() ?? [],
      suggestedAction: ModerAction.values.firstWhere(
        (a) => a.name == json['suggestedAction'],
        orElse: () => ModerAction.allow,
      ),
      filteredContent: json['filteredContent'] as String?,
      explanation: json['explanation'] as String? ?? '',
    );
  }

  factory ModerationResult.safe() {
    return ModerationResult(
      isSafe: true,
      categories: [],
      suggestedAction: ModerAction.allow,
      explanation: 'Content is safe',
    );
  }
}

class ModerationCategory {
  final String category;
  final SeverityLevel severity;
  final double confidence;

  ModerationCategory({
    required this.category,
    required this.severity,
    required this.confidence,
  });

  factory ModerationCategory.fromJson(Map<String, dynamic> json) {
    return ModerationCategory(
      category: json['category'] as String? ?? '',
      severity: SeverityLevel.values.firstWhere(
        (s) => s.name == json['severity'],
        orElse: () => SeverityLevel.none,
      ),
      confidence: (json['confidence'] as num?)?.toDouble() ?? 0.0,
    );
  }
}

class UserAction {
  final String action;
  final String timestamp;
  final String? target;

  UserAction({required this.action, required this.timestamp, this.target});

  Map<String, dynamic> toJson() => {
    'action': action,
    'timestamp': timestamp,
    if (target != null) 'target': target,
  };
}

class ReportRecord {
  final String reason;
  final String outcome;
  final String date;

  ReportRecord({required this.reason, required this.outcome, required this.date});

  Map<String, dynamic> toJson() => {
    'reason': reason,
    'outcome': outcome,
    'date': date,
  };
}

class BehaviorAnalysis {
  final RiskLevel riskLevel;
  final List<String> concerns;
  final String recommendedAction;
  final MonitoringLevel monitoringLevel;

  BehaviorAnalysis({
    required this.riskLevel,
    required this.concerns,
    required this.recommendedAction,
    required this.monitoringLevel,
  });

  factory BehaviorAnalysis.fromJson(Map<String, dynamic> json) {
    return BehaviorAnalysis(
      riskLevel: RiskLevel.values.firstWhere(
        (r) => r.name == json['riskLevel'],
        orElse: () => RiskLevel.low,
      ),
      concerns: List<String>.from(json['concerns'] ?? []),
      recommendedAction: json['recommendedAction'] as String? ?? 'No action needed',
      monitoringLevel: MonitoringLevel.values.firstWhere(
        (m) => m.name == json['monitoringLevel'],
        orElse: () => MonitoringLevel.normal,
      ),
    );
  }

  factory BehaviorAnalysis.normal() {
    return BehaviorAnalysis(
      riskLevel: RiskLevel.low,
      concerns: [],
      recommendedAction: 'No action needed',
      monitoringLevel: MonitoringLevel.normal,
    );
  }
}
