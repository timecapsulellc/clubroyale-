import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_functions/cloud_functions.dart';

/// Streaming Agent provider
final streamingAgentProvider = Provider<StreamingAgent>((ref) {
  return StreamingAgent();
});

/// Streaming Agent - Live Content Management
///
/// Features:
/// - Stream enhancement
/// - Highlight detection
class StreamingAgent {
  final FirebaseFunctions _functions = FirebaseFunctions.instance;

  /// Get stream enhancement suggestions
  Future<StreamEnhancement> enhanceStream({
    required String streamId,
    required StreamType streamType,
    required int viewerCount,
    required int streamDurationSeconds,
    String? gameType,
  }) async {
    try {
      final callable = _functions.httpsCallable('enhanceStream');
      final result = await callable.call<Map<String, dynamic>>({
        'streamId': streamId,
        'streamType': streamType.name,
        'viewerCount': viewerCount,
        'streamDuration': streamDurationSeconds,
        if (gameType != null) 'gameType': gameType,
      });
      return StreamEnhancement.fromJson(result.data);
    } catch (e) {
      return StreamEnhancement.fallback();
    }
  }

  /// Detect highlights from game events
  Future<HighlightResult> detectHighlights({
    required String streamId,
    required List<GameEvent> gameEvents,
    List<ViewerReaction>? viewerReactions,
  }) async {
    try {
      final callable = _functions.httpsCallable('detectHighlights');
      final result = await callable.call<Map<String, dynamic>>({
        'streamId': streamId,
        'gameEvents': gameEvents.map((e) => e.toJson()).toList(),
        if (viewerReactions != null)
          'viewerReactions': viewerReactions.map((r) => r.toJson()).toList(),
      });
      return HighlightResult.fromJson(result.data);
    } catch (e) {
      return HighlightResult(highlights: []);
    }
  }
}

// ==================== ENUMS ====================

enum StreamType { game, chat, tutorial, social }

// ==================== DATA MODELS ====================

class GameEvent {
  final int timestamp;
  final String event;
  final double significance;

  GameEvent({
    required this.timestamp,
    required this.event,
    required this.significance,
  });

  Map<String, dynamic> toJson() => {
    'timestamp': timestamp,
    'event': event,
    'significance': significance,
  };
}

class ViewerReaction {
  final int timestamp;
  final String type;
  final int count;

  ViewerReaction({
    required this.timestamp,
    required this.type,
    required this.count,
  });

  Map<String, dynamic> toJson() => {
    'timestamp': timestamp,
    'type': type,
    'count': count,
  };
}

class StreamEnhancement {
  final List<StreamOverlay> overlays;
  final List<String> interactionPrompts;
  final List<SuggestedPoll> suggestedPolls;
  final List<String> engagementTips;

  StreamEnhancement({
    required this.overlays,
    required this.interactionPrompts,
    required this.suggestedPolls,
    required this.engagementTips,
  });

  factory StreamEnhancement.fromJson(Map<String, dynamic> json) {
    return StreamEnhancement(
      overlays:
          (json['overlays'] as List<dynamic>?)
              ?.map((o) => StreamOverlay.fromJson(o))
              .toList() ??
          [],
      interactionPrompts: List<String>.from(json['interactionPrompts'] ?? []),
      suggestedPolls:
          (json['suggestedPolls'] as List<dynamic>?)
              ?.map((p) => SuggestedPoll.fromJson(p))
              .toList() ??
          [],
      engagementTips: List<String>.from(json['engagementTips'] ?? []),
    );
  }

  factory StreamEnhancement.fallback() {
    return StreamEnhancement(
      overlays: [],
      interactionPrompts: ['Type your predictions in chat!'],
      suggestedPolls: [
        SuggestedPoll(
          question: 'Who will win?',
          options: ['Streamer', 'Opponent'],
        ),
      ],
      engagementTips: ['Acknowledge viewers by name', 'React to chat messages'],
    );
  }
}

class StreamOverlay {
  final String type;
  final String content;
  final String position;
  final int duration;

  StreamOverlay({
    required this.type,
    required this.content,
    required this.position,
    required this.duration,
  });

  factory StreamOverlay.fromJson(Map<String, dynamic> json) {
    return StreamOverlay(
      type: json['type'] as String? ?? '',
      content: json['content'] as String? ?? '',
      position: json['position'] as String? ?? 'bottom',
      duration: json['duration'] as int? ?? 5,
    );
  }
}

class SuggestedPoll {
  final String question;
  final List<String> options;

  SuggestedPoll({required this.question, required this.options});

  factory SuggestedPoll.fromJson(Map<String, dynamic> json) {
    return SuggestedPoll(
      question: json['question'] as String? ?? '',
      options: List<String>.from(json['options'] ?? []),
    );
  }
}

class HighlightResult {
  final List<Highlight> highlights;
  final BestMoment? bestMoment;

  HighlightResult({required this.highlights, this.bestMoment});

  factory HighlightResult.fromJson(Map<String, dynamic> json) {
    return HighlightResult(
      highlights:
          (json['highlights'] as List<dynamic>?)
              ?.map((h) => Highlight.fromJson(h))
              .toList() ??
          [],
      bestMoment: json['bestMoment'] != null
          ? BestMoment.fromJson(json['bestMoment'])
          : null,
    );
  }
}

class Highlight {
  final int startTime;
  final int endTime;
  final String title;
  final double score;
  final String category;

  Highlight({
    required this.startTime,
    required this.endTime,
    required this.title,
    required this.score,
    required this.category,
  });

  factory Highlight.fromJson(Map<String, dynamic> json) {
    return Highlight(
      startTime: json['startTime'] as int? ?? 0,
      endTime: json['endTime'] as int? ?? 0,
      title: json['title'] as String? ?? '',
      score: (json['score'] as num?)?.toDouble() ?? 0.0,
      category: json['category'] as String? ?? '',
    );
  }
}

class BestMoment {
  final int timestamp;
  final String description;

  BestMoment({required this.timestamp, required this.description});

  factory BestMoment.fromJson(Map<String, dynamic> json) {
    return BestMoment(
      timestamp: json['timestamp'] as int? ?? 0,
      description: json['description'] as String? ?? '',
    );
  }
}
