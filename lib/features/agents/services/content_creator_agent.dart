import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_functions/cloud_functions.dart';

/// Content Creator Agent provider
final contentCreatorAgentProvider = Provider<ContentCreatorAgent>((ref) {
  return ContentCreatorAgent();
});

/// Content Creator Agent - AI-Generated Content for ClubRoyale
///
/// Features:
/// - Story content generation
/// - Reel/video script creation
/// - Caption generation
/// - Achievement celebrations
class ContentCreatorAgent {
  final FirebaseFunctions _functions = FirebaseFunctions.instance;

  // ==================== STORY GENERATION ====================

  /// Generate content for a story post
  Future<StoryContent> generateStory({
    required StoryType storyType,
    required StoryContext context,
    StoryStyle style = StoryStyle.celebratory,
    String language = 'en',
  }) async {
    try {
      final callable = _functions.httpsCallable('generateStory');
      final result = await callable.call<Map<String, dynamic>>({
        'storyType': storyType.name,
        'context': context.toJson(),
        'style': style.name,
        'language': language,
      });
      return StoryContent.fromJson(result.data);
    } catch (e) {
      return StoryContent.fallback(storyType);
    }
  }

  // ==================== REEL SCRIPTS ====================

  /// Generate a script for a short video/reel
  Future<ReelScript> generateReelScript({
    required String topic,
    required ReelDuration duration,
    ReelStyle style = ReelStyle.entertainment,
    String? targetAudience,
    String? gameType,
  }) async {
    try {
      final callable = _functions.httpsCallable('generateReelScript');
      final result = await callable.call<Map<String, dynamic>>({
        'topic': topic,
        'duration': duration.value,
        'style': style.name,
        if (targetAudience != null) 'targetAudience': targetAudience,
        if (gameType != null) 'gameType': gameType,
      });
      return ReelScript.fromJson(result.data);
    } catch (e) {
      return ReelScript.fallback(topic);
    }
  }

  // ==================== CAPTIONS ====================

  /// Generate a caption for any content type
  Future<CaptionResult> generateCaption({
    required CaptionType contentType,
    required String context,
    CaptionTone tone = CaptionTone.casual,
    bool includeEmojis = true,
    int? maxLength,
  }) async {
    try {
      final callable = _functions.httpsCallable('generateCaption');
      final result = await callable.call<Map<String, dynamic>>({
        'contentType': contentType.name,
        'context': context,
        'tone': tone.name,
        'includeEmojis': includeEmojis,
        if (maxLength != null) 'maxLength': maxLength,
      });
      return CaptionResult.fromJson(result.data);
    } catch (e) {
      return CaptionResult(
        primary: 'Great game! 🎮',
        alternatives: ['Having fun!', 'Let\'s play!'],
        hashtags: ['#ClubRoyale'],
      );
    }
  }

  // ==================== ACHIEVEMENTS ====================

  /// Generate celebration content for an achievement
  Future<AchievementCelebration> generateAchievementCelebration({
    required String achievement,
    required AchievementType achievementType,
    String? userName,
    int? value,
  }) async {
    try {
      final callable = _functions.httpsCallable(
        'generateAchievementCelebration',
      );
      final result = await callable.call<Map<String, dynamic>>({
        'achievement': achievement,
        'achievementType': achievementType.name,
        if (userName != null) 'userName': userName,
        if (value != null) 'value': value,
      });
      return AchievementCelebration.fromJson(result.data);
    } catch (e) {
      return AchievementCelebration.fallback(achievement);
    }
  }

  /// Quick share caption for game results
  Future<String> getQuickShareCaption({
    required String gameType,
    required bool isWin,
    int? score,
  }) async {
    final result = await generateCaption(
      contentType: CaptionType.story,
      context: isWin
          ? 'Just won a $gameType game${score != null ? ' with $score points' : ''}!'
          : 'Close game of $gameType! GG everyone!',
      tone: isWin ? CaptionTone.competitive : CaptionTone.casual,
    );
    return result.primary;
  }
}

// ==================== ENUMS ====================

enum StoryType { gameResult, achievement, highlight, social, custom }

enum StoryStyle { celebratory, funny, dramatic, minimal, professional }

enum ReelStyle { tutorial, entertainment, highlight, meme, storytelling }

enum CaptionType { post, story, bio, comment }

enum CaptionTone { casual, professional, funny, inspirational, competitive }

enum AchievementType { rank, streak, wins, diamonds, social, special }

enum ReelDuration {
  short('15s'),
  medium('30s'),
  long('60s');

  final String value;
  const ReelDuration(this.value);
}

// ==================== DATA MODELS ====================

class StoryContext {
  final String? gameType;
  final String? result; // win, loss, draw
  final int? score;
  final String? achievement;
  final String? customPrompt;
  final String? userName;

  StoryContext({
    this.gameType,
    this.result,
    this.score,
    this.achievement,
    this.customPrompt,
    this.userName,
  });

  Map<String, dynamic> toJson() => {
    if (gameType != null) 'gameType': gameType,
    if (result != null) 'result': result,
    if (score != null) 'score': score,
    if (achievement != null) 'achievement': achievement,
    if (customPrompt != null) 'customPrompt': customPrompt,
    if (userName != null) 'userName': userName,
  };
}

class StoryContent {
  final String caption;
  final List<String> hashtags;
  final List<String> suggestedFilters;
  final String? suggestedMusic;
  final String backgroundStyle;
  final String mood;
  final List<String> emojis;

  StoryContent({
    required this.caption,
    required this.hashtags,
    required this.suggestedFilters,
    this.suggestedMusic,
    required this.backgroundStyle,
    required this.mood,
    required this.emojis,
  });

  factory StoryContent.fromJson(Map<String, dynamic> json) {
    return StoryContent(
      caption: json['caption'] as String? ?? '',
      hashtags: List<String>.from(json['hashtags'] ?? []),
      suggestedFilters: List<String>.from(json['suggestedFilters'] ?? []),
      suggestedMusic: json['suggestedMusic'] as String?,
      backgroundStyle: json['backgroundStyle'] as String? ?? 'Purple gradient',
      mood: json['mood'] as String? ?? 'Exciting',
      emojis: List<String>.from(json['emojis'] ?? ['🎮']),
    );
  }

  factory StoryContent.fallback(StoryType type) {
    switch (type) {
      case StoryType.gameResult:
        return StoryContent(
          caption: 'Great game! 🎮',
          hashtags: ['#ClubRoyale', '#Gaming', '#Winner'],
          suggestedFilters: ['Victory Gold'],
          backgroundStyle: 'Gold gradient',
          mood: 'Victorious',
          emojis: ['🎮', '🏆', '🎉'],
        );
      case StoryType.achievement:
        return StoryContent(
          caption: 'Achievement unlocked! 🏆',
          hashtags: ['#ClubRoyale', '#Achievement', '#LevelUp'],
          suggestedFilters: ['Trophy Shine'],
          backgroundStyle: 'Purple gradient',
          mood: 'Proud',
          emojis: ['🏆', '⭐', '🎊'],
        );
      default:
        return StoryContent(
          caption: 'Having a blast on ClubRoyale! 🎮',
          hashtags: ['#ClubRoyale', '#Gaming'],
          suggestedFilters: ['Classic'],
          backgroundStyle: 'Purple gradient',
          mood: 'Fun',
          emojis: ['🎮', '😊'],
        );
    }
  }
}

class ReelScript {
  final List<ScriptScene> scenes;
  final String suggestedMusic;
  final List<String> hashtags;
  final String hook;
  final String callToAction;

  ReelScript({
    required this.scenes,
    required this.suggestedMusic,
    required this.hashtags,
    required this.hook,
    required this.callToAction,
  });

  factory ReelScript.fromJson(Map<String, dynamic> json) {
    return ReelScript(
      scenes:
          (json['script'] as List<dynamic>?)
              ?.map((s) => ScriptScene.fromJson(s))
              .toList() ??
          [],
      suggestedMusic: json['suggestedMusic'] as String? ?? 'Upbeat electronic',
      hashtags: List<String>.from(json['hashtags'] ?? []),
      hook: json['hook'] as String? ?? 'Watch this!',
      callToAction: json['callToAction'] as String? ?? 'Follow for more!',
    );
  }

  factory ReelScript.fallback(String topic) {
    return ReelScript(
      scenes: [
        ScriptScene(
          timestamp: '0:00',
          action: 'Hook',
          visualCue: 'Bold text: "$topic"',
        ),
        ScriptScene(
          timestamp: '0:03',
          action: 'Content',
          visualCue: 'Game footage',
        ),
        ScriptScene(
          timestamp: '0:12',
          action: 'CTA',
          visualCue: 'Follow button',
        ),
      ],
      suggestedMusic: 'Trending beats',
      hashtags: ['#ClubRoyale', '#Gaming', '#Viral'],
      hook: 'You won\'t believe this!',
      callToAction: 'Follow for more gaming content!',
    );
  }
}

class ScriptScene {
  final String timestamp;
  final String action;
  final String? text;
  final String visualCue;
  final String? audioNote;

  ScriptScene({
    required this.timestamp,
    required this.action,
    this.text,
    required this.visualCue,
    this.audioNote,
  });

  factory ScriptScene.fromJson(Map<String, dynamic> json) {
    return ScriptScene(
      timestamp: json['timestamp'] as String? ?? '',
      action: json['action'] as String? ?? '',
      text: json['text'] as String?,
      visualCue: json['visualCue'] as String? ?? '',
      audioNote: json['audioNote'] as String?,
    );
  }
}

class CaptionResult {
  final String primary;
  final List<String> alternatives;
  final List<String> hashtags;

  CaptionResult({
    required this.primary,
    required this.alternatives,
    required this.hashtags,
  });

  factory CaptionResult.fromJson(Map<String, dynamic> json) {
    return CaptionResult(
      primary: json['primary'] as String? ?? '',
      alternatives: List<String>.from(json['alternatives'] ?? []),
      hashtags: List<String>.from(json['hashtags'] ?? []),
    );
  }
}

class AchievementCelebration {
  final String title;
  final String subtitle;
  final String animation;
  final String sound;
  final String shareCaption;
  final BadgeStyle badgeStyle;

  AchievementCelebration({
    required this.title,
    required this.subtitle,
    required this.animation,
    required this.sound,
    required this.shareCaption,
    required this.badgeStyle,
  });

  factory AchievementCelebration.fromJson(Map<String, dynamic> json) {
    return AchievementCelebration(
      title: json['title'] as String? ?? 'Achievement!',
      subtitle: json['subtitle'] as String? ?? '',
      animation: json['animation'] as String? ?? 'confetti',
      sound: json['sound'] as String? ?? 'victory_fanfare',
      shareCaption: json['shareCaption'] as String? ?? 'Achievement unlocked!',
      badgeStyle: BadgeStyle.fromJson(json['badgeStyle'] ?? {}),
    );
  }

  factory AchievementCelebration.fallback(String achievement) {
    return AchievementCelebration(
      title: 'Achievement Unlocked!',
      subtitle: achievement,
      animation: 'confetti',
      sound: 'victory_fanfare',
      shareCaption: 'Just unlocked: $achievement! 🏆 #ClubRoyale',
      badgeStyle: BadgeStyle(color: 'gold', icon: '🏆', effect: 'glow'),
    );
  }
}

class BadgeStyle {
  final String color;
  final String icon;
  final String effect;

  BadgeStyle({required this.color, required this.icon, required this.effect});

  factory BadgeStyle.fromJson(Map<String, dynamic> json) {
    return BadgeStyle(
      color: json['color'] as String? ?? 'gold',
      icon: json['icon'] as String? ?? '🏆',
      effect: json['effect'] as String? ?? 'glow',
    );
  }
}
