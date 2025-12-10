import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_functions/cloud_functions.dart';

/// Social Agent provider
final socialAgentProvider = Provider<SocialAgent>((ref) {
  return SocialAgent();
});

/// Social Agent - Handles chat moderation, translation, and social interactions
class SocialAgent {
  final FirebaseFunctions _functions = FirebaseFunctions.instance;

  // ==================== MODERATION ====================

  /// Moderate a chat message
  Future<ModerationResult> moderateMessage(String message, {String? userId}) async {
    try {
      final callable = _functions.httpsCallable('moderateChat');
      final result = await callable.call<Map<String, dynamic>>({
        'message': message,
        'userId': userId,
      });

      return ModerationResult(
        isAllowed: result.data['isAllowed'] as bool? ?? true,
        category: result.data['category'] as String? ?? 'unknown',
        action: result.data['action'] as String? ?? 'allow',
        reason: result.data['reason'] as String?,
        editedMessage: result.data['editedMessage'] as String?,
      );
    } catch (e) {
      // Fail open - allow message if moderation fails
      return ModerationResult(
        isAllowed: true,
        category: 'unknown',
        action: 'allow',
      );
    }
  }

  /// Check if content is safe for stories/posts
  Future<ModerationResult> moderateContent(String content, {String? mediaUrl}) async {
    try {
      final callable = _functions.httpsCallable('moderateContent');
      final result = await callable.call<Map<String, dynamic>>({
        'content': content,
        'mediaUrl': mediaUrl,
      });

      return ModerationResult(
        isAllowed: result.data['isAllowed'] as bool? ?? true,
        category: result.data['category'] as String? ?? 'unknown',
        action: result.data['action'] as String? ?? 'allow',
        reason: result.data['reason'] as String?,
      );
    } catch (e) {
      return ModerationResult(isAllowed: true, category: 'unknown', action: 'allow');
    }
  }

  // ==================== TRANSLATION ====================

  /// Translate text to target language
  Future<TranslationResult> translate(String text, String targetLanguage) async {
    try {
      final callable = _functions.httpsCallable('translateText');
      final result = await callable.call<Map<String, dynamic>>({
        'text': text,
        'targetLanguage': targetLanguage,
      });

      return TranslationResult(
        translatedText: result.data['translatedText'] as String,
        detectedLanguage: result.data['detectedLanguage'] as String?,
        confidence: result.data['confidence'] as double? ?? 1.0,
      );
    } catch (e) {
      return TranslationResult(
        translatedText: text,
        detectedLanguage: null,
        confidence: 0.0,
        error: e.toString(),
      );
    }
  }

  /// Detect language of text
  Future<String?> detectLanguage(String text) async {
    try {
      final callable = _functions.httpsCallable('detectLanguage');
      final result = await callable.call<Map<String, dynamic>>({
        'text': text,
      });
      return result.data['language'] as String?;
    } catch (e) {
      return null;
    }
  }

  // ==================== SMART REPLIES ====================

  /// Suggest quick replies based on conversation context
  Future<List<String>> suggestReplies({
    required List<String> recentMessages,
    String? context,
  }) async {
    try {
      final callable = _functions.httpsCallable('suggestReplies');
      final result = await callable.call<Map<String, dynamic>>({
        'recentMessages': recentMessages,
        'context': context,
      });

      return List<String>.from(result.data['suggestions'] ?? []);
    } catch (e) {
      // Fallback suggestions
      return _getDefaultReplies(recentMessages.lastOrNull);
    }
  }

  List<String> _getDefaultReplies(String? lastMessage) {
    if (lastMessage == null) {
      return ['👋 Hello!', 'Good game!', 'Ready to play?'];
    }

    final lower = lastMessage.toLowerCase();

    if (lower.contains('gg') || lower.contains('good game')) {
      return ['Thanks! GG!', '🎉', 'Rematch?', 'Well played!'];
    }

    if (lower.contains('hello') || lower.contains('hi')) {
      return ['Hey!', 'Hello! 👋', 'Ready to play?'];
    }

    if (lower.contains('?')) {
      return ['Yes', 'No', 'Maybe', 'Not sure'];
    }

    return ['👍', '😊', 'Nice!', 'Sure!'];
  }

  // ==================== SENTIMENT ANALYSIS ====================

  /// Analyze sentiment of a message
  Future<SentimentResult> analyzeSentiment(String text) async {
    try {
      final callable = _functions.httpsCallable('analyzeSentiment');
      final result = await callable.call<Map<String, dynamic>>({
        'text': text,
      });

      return SentimentResult(
        sentiment: result.data['sentiment'] as String? ?? 'neutral',
        score: result.data['score'] as double? ?? 0.0,
        magnitude: result.data['magnitude'] as double? ?? 0.0,
      );
    } catch (e) {
      return SentimentResult(sentiment: 'neutral', score: 0.0, magnitude: 0.0);
    }
  }
}

/// Result of content moderation
class ModerationResult {
  final bool isAllowed;
  final String category;
  final String action;
  final String? reason;
  final String? editedMessage;

  ModerationResult({
    required this.isAllowed,
    required this.category,
    required this.action,
    this.reason,
    this.editedMessage,
  });
}

/// Result of translation
class TranslationResult {
  final String translatedText;
  final String? detectedLanguage;
  final double confidence;
  final String? error;

  TranslationResult({
    required this.translatedText,
    this.detectedLanguage,
    required this.confidence,
    this.error,
  });

  bool get hasError => error != null;
}

/// Result of sentiment analysis
class SentimentResult {
  final String sentiment; // positive, negative, neutral
  final double score; // -1.0 to 1.0
  final double magnitude;

  SentimentResult({
    required this.sentiment,
    required this.score,
    required this.magnitude,
  });

  bool get isPositive => sentiment == 'positive';
  bool get isNegative => sentiment == 'negative';
}
