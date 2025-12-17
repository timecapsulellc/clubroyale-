import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_functions/cloud_functions.dart';

/// Coach Agent provider
final coachAgentProvider = Provider<CoachAgent>((ref) {
  return CoachAgent();
});

/// Coach Agent - Personal game strategy coach and skill trainer
/// 
/// Features:
/// - Strategy lessons for each game type
/// - Play analysis with improvement suggestions
/// - Skill assessment and rankings
/// - Personalized training recommendations
class CoachAgent {
  final FirebaseFunctions _functions = FirebaseFunctions.instance;

  // ==================== STRATEGY LESSONS ====================

  /// Get a strategy lesson for a specific game and topic
  Future<StrategyLesson> getLesson({
    required String gameType,
    required String topic,
    String skillLevel = 'beginner',
  }) async {
    try {
      final callable = _functions.httpsCallable('getGameLesson');
      final result = await callable.call<Map<String, dynamic>>({
        'gameType': gameType,
        'topic': topic,
        'skillLevel': skillLevel,
      });

      return StrategyLesson.fromJson(result.data);
    } catch (e) {
      // Return canned lesson as fallback
      return _getLocalLesson(gameType, topic, skillLevel);
    }
  }

  /// Get available lesson topics for a game
  List<LessonTopic> getAvailableTopics(String gameType) {
    switch (gameType) {
      case 'call_break':
        return [
          LessonTopic(
            id: 'bidding_basics',
            title: 'Bidding Fundamentals',
            description: 'Learn to count tricks accurately',
            difficulty: 'beginner',
            estimatedMinutes: 5,
          ),
          LessonTopic(
            id: 'trump_management',
            title: 'Trump Card Strategy',
            description: 'When to use and save your spades',
            difficulty: 'intermediate',
            estimatedMinutes: 8,
          ),
          LessonTopic(
            id: 'reading_opponents',
            title: 'Reading Opponents',
            description: 'Predict what cards others hold',
            difficulty: 'advanced',
            estimatedMinutes: 10,
          ),
          LessonTopic(
            id: 'endgame_tactics',
            title: 'Endgame Mastery',
            description: 'Winning the last few tricks',
            difficulty: 'advanced',
            estimatedMinutes: 12,
          ),
        ];

      case 'marriage':
        return [
          LessonTopic(
            id: 'meld_basics',
            title: 'Meld Fundamentals',
            description: 'Understanding sets and runs',
            difficulty: 'beginner',
            estimatedMinutes: 5,
          ),
          LessonTopic(
            id: 'tiplu_mastery',
            title: 'Wild Card Strategy',
            description: 'Using Tiplu effectively',
            difficulty: 'intermediate',
            estimatedMinutes: 8,
          ),
          LessonTopic(
            id: 'discard_strategy',
            title: 'Smart Discarding',
            description: 'What to throw and keep',
            difficulty: 'intermediate',
            estimatedMinutes: 7,
          ),
          LessonTopic(
            id: 'marriage_timing',
            title: 'Marriage Timing',
            description: 'When to declare your marriages',
            difficulty: 'advanced',
            estimatedMinutes: 10,
          ),
        ];

      case 'teen_patti':
        return [
          LessonTopic(
            id: 'hand_rankings',
            title: 'Hand Rankings',
            description: 'Know your winning hands',
            difficulty: 'beginner',
            estimatedMinutes: 4,
          ),
          LessonTopic(
            id: 'betting_basics',
            title: 'Betting Fundamentals',
            description: 'When to bet, raise, or fold',
            difficulty: 'beginner',
            estimatedMinutes: 6,
          ),
          LessonTopic(
            id: 'bluffing',
            title: 'The Art of Bluffing',
            description: 'Deceive your opponents',
            difficulty: 'advanced',
            estimatedMinutes: 10,
          ),
          LessonTopic(
            id: 'pot_odds',
            title: 'Calculating Pot Odds',
            description: 'Math behind smart betting',
            difficulty: 'advanced',
            estimatedMinutes: 12,
          ),
        ];

      case 'in_between':
        return [
          LessonTopic(
            id: 'spread_basics',
            title: 'Understanding Spreads',
            description: 'Reading the card gap',
            difficulty: 'beginner',
            estimatedMinutes: 3,
          ),
          LessonTopic(
            id: 'bet_sizing',
            title: 'Optimal Bet Sizing',
            description: 'How much to wager',
            difficulty: 'intermediate',
            estimatedMinutes: 6,
          ),
        ];

      default:
        return [];
    }
  }

  StrategyLesson _getLocalLesson(String gameType, String topic, String level) {
    // Fallback lessons stored locally
    final lessons = {
      'call_break': {
        'bidding_basics': StrategyLesson(
          title: 'Counting Your Tricks',
          content: '''
**Step 1: Count Your High Cards**
- Aces are usually 1 trick each
- Kings are 0.5-1 trick depending on position
- Queens rarely win unless backed by strength

**Step 2: Count Your Trump (Spades)**
- Each spade can potentially win 1 trick
- Having 4+ spades is strong
- Low spades can still trump other suits

**Step 3: Consider Your Position**
- Later positions can bid more aggressively
- First position should bid conservatively

**Practice Tip:** Start by bidding the number of Aces + high Spades you have!
''',
          examples: [
            'Hand: A♠ K♠ 5♠ A♥ Q♥ → Bid: 3-4',
            'Hand: 7♠ 3♠ K♦ Q♣ J♣ → Bid: 1-2',
          ],
          keyTakeaways: [
            'Count Aces as guaranteed tricks',
            'Spades are your best friend',
            'When in doubt, bid conservatively',
          ],
        ),
        'trump_management': StrategyLesson(
          title: 'Mastering Trump Cards',
          content: '''
**Rule 1: Don't Waste High Trumps Early**
Save your A♠ and K♠ for when they matter most.

**Rule 2: Force Out Opponent Trumps**
Lead with mid-spades to draw out opponents' high trumps.

**Rule 3: Trump When You're Void**
Can't follow suit? Perfect time to trump!

**Rule 4: Count Trumps Played**
Keep mental track of how many spades remain.
''',
          examples: [
            'Opponent leads K♥, you\'re void → Trump with 4♠',
            'You have A♠ K♠ left, 2 tricks remain → Guaranteed win!',
          ],
          keyTakeaways: [
            'Save high trumps for endgame',
            'Being void in a suit gives power',
            'Track trumps mentally',
          ],
        ),
      },
      'marriage': {
        'meld_basics': StrategyLesson(
          title: 'Building Winning Melds',
          content: '''
**Sets (3 or 4 of a Kind)**
- Easier to collect
- Worth fewer points
- Example: 7♥ 7♦ 7♣

**Runs (Sequence of Same Suit)**
- Harder to complete
- Worth more points
- Example: 5♥ 6♥ 7♥

**Pure vs Impure**
- Pure runs (no Tiplu) score higher
- Impure melds use the wild Tiplu

**Minimum Requirement**
You need at least 2 melds to declare!
''',
          examples: [
            'Pure run: 8♠ 9♠ 10♠ → Best!',
            'Impure: 8♠ Tiplu 10♠ → Still valid',
          ],
          keyTakeaways: [
            'Aim for pure melds first',
            'Sets are easier, runs score more',
            'Keep flexible cards that fit multiple melds',
          ],
        ),
      },
    };

    return lessons[gameType]?[topic] ?? StrategyLesson(
      title: 'Lesson Coming Soon',
      content: 'This lesson is being prepared by our coaches!',
      examples: [],
      keyTakeaways: ['Check back later for this lesson'],
    );
  }

  // ==================== PLAY ANALYSIS ====================

  /// Analyze a completed game and provide feedback
  Future<GameAnalysis> analyzeGame({
    required String gameId,
    required String gameType,
    required String userId,
  }) async {
    try {
      final callable = _functions.httpsCallable('analyzeGamePlay');
      final result = await callable.call<Map<String, dynamic>>({
        'gameId': gameId,
        'gameType': gameType,
        'userId': userId,
      });

      return GameAnalysis.fromJson(result.data);
    } catch (e) {
      // Return generic analysis as fallback
      return GameAnalysis(
        overallRating: 3,
        summary: 'Good game! Keep practicing to improve.',
        strengths: ['Completed the game', 'Stayed engaged'],
        improvements: ['Try our strategy lessons', 'Play more games'],
        keyMoments: [],
        nextLesson: 'bidding_basics',
      );
    }
  }

  /// Get real-time suggestion during gameplay
  Future<PlaySuggestion> getSuggestion({
    required String gameType,
    required List<String> hand,
    required Map<String, dynamic> gameState,
    bool explain = true,
  }) async {
    try {
      final callable = _functions.httpsCallable('getPlaySuggestion');
      final result = await callable.call<Map<String, dynamic>>({
        'gameType': gameType,
        'hand': hand,
        'gameState': gameState,
        'explain': explain,
      });

      return PlaySuggestion.fromJson(result.data);
    } catch (e) {
      return _getLocalSuggestion(gameType, hand, gameState);
    }
  }

  PlaySuggestion _getLocalSuggestion(
    String gameType,
    List<String> hand,
    Map<String, dynamic> gameState,
  ) {
    // Simple local logic for suggestions
    switch (gameType) {
      case 'call_break':
        final led = gameState['ledSuit'] as String?;
        final currentTrick = gameState['currentTrick'] as List<dynamic>? ?? [];
        
        if (led == null && currentTrick.isEmpty) {
          // Leading - play highest non-trump
          final nonSpades = hand.where((c) => !c.contains('♠')).toList();
          if (nonSpades.isNotEmpty) {
            return PlaySuggestion(
              recommendedPlay: nonSpades.first,
              confidence: 0.7,
              reasoning: 'Lead with a strong non-trump to probe opponents.',
              alternative: hand.first,
            );
          }
        }
        
        return PlaySuggestion(
          recommendedPlay: hand.first,
          confidence: 0.5,
          reasoning: 'Play strategically based on the current situation.',
        );

      default:
        return PlaySuggestion(
          recommendedPlay: hand.first,
          confidence: 0.5,
          reasoning: 'Good luck with your play!',
        );
    }
  }

  // ==================== SKILL ASSESSMENT ====================

  /// Assess player's skill level for a game
  Future<SkillAssessment> assessSkill({
    required String userId,
    required String gameType,
  }) async {
    try {
      final callable = _functions.httpsCallable('assessPlayerSkill');
      final result = await callable.call<Map<String, dynamic>>({
        'userId': userId,
        'gameType': gameType,
      });

      return SkillAssessment.fromJson(result.data);
    } catch (e) {
      return SkillAssessment(
        level: 'intermediate',
        rating: 1200,
        rank: 'Silver II',
        gamesPlayed: 0,
        winRate: 0.5,
        strengths: ['Still learning'],
        weaknesses: ['Need more games'],
        nextMilestone: 'Play 10 games',
        progressToNext: 0.0,
      );
    }
  }

  /// Get personalized training plan
  Future<TrainingPlan> getTrainingPlan({
    required String userId,
    required String gameType,
    int weeksTarget = 4,
  }) async {
    try {
      final callable = _functions.httpsCallable('generateTrainingPlan');
      final result = await callable.call<Map<String, dynamic>>({
        'userId': userId,
        'gameType': gameType,
        'weeksTarget': weeksTarget,
      });

      return TrainingPlan.fromJson(result.data);
    } catch (e) {
      return _getDefaultTrainingPlan(gameType);
    }
  }

  TrainingPlan _getDefaultTrainingPlan(String gameType) {
    final topics = getAvailableTopics(gameType);
    
    return TrainingPlan(
      gameType: gameType,
      totalWeeks: 4,
      weeklyGoals: [
        WeeklyGoal(
          week: 1,
          focus: 'Fundamentals',
          lessons: topics.where((t) => t.difficulty == 'beginner').toList(),
          practiceGames: 5,
          targetWinRate: 0.3,
        ),
        WeeklyGoal(
          week: 2,
          focus: 'Core Strategies',
          lessons: topics.where((t) => t.difficulty == 'intermediate').take(2).toList(),
          practiceGames: 7,
          targetWinRate: 0.4,
        ),
        WeeklyGoal(
          week: 3,
          focus: 'Advanced Tactics',
          lessons: topics.where((t) => t.difficulty == 'advanced').take(1).toList(),
          practiceGames: 10,
          targetWinRate: 0.45,
        ),
        WeeklyGoal(
          week: 4,
          focus: 'Mastery',
          lessons: topics.where((t) => t.difficulty == 'advanced').toList(),
          practiceGames: 15,
          targetWinRate: 0.5,
        ),
      ],
    );
  }
}

// ==================== DATA MODELS ====================

class LessonTopic {
  final String id;
  final String title;
  final String description;
  final String difficulty; // beginner, intermediate, advanced
  final int estimatedMinutes;

  LessonTopic({
    required this.id,
    required this.title,
    required this.description,
    required this.difficulty,
    required this.estimatedMinutes,
  });
}

class StrategyLesson {
  final String title;
  final String content;
  final List<String> examples;
  final List<String> keyTakeaways;
  final String? videoUrl;
  final String? quizId;

  StrategyLesson({
    required this.title,
    required this.content,
    this.examples = const [],
    this.keyTakeaways = const [],
    this.videoUrl,
    this.quizId,
  });

  factory StrategyLesson.fromJson(Map<String, dynamic> json) {
    return StrategyLesson(
      title: json['title'] as String? ?? '',
      content: json['content'] as String? ?? '',
      examples: List<String>.from(json['examples'] ?? []),
      keyTakeaways: List<String>.from(json['keyTakeaways'] ?? []),
      videoUrl: json['videoUrl'] as String?,
      quizId: json['quizId'] as String?,
    );
  }
}

class GameAnalysis {
  final int overallRating; // 1-5 stars
  final String summary;
  final List<String> strengths;
  final List<String> improvements;
  final List<KeyMoment> keyMoments;
  final String? nextLesson;

  GameAnalysis({
    required this.overallRating,
    required this.summary,
    required this.strengths,
    required this.improvements,
    required this.keyMoments,
    this.nextLesson,
  });

  factory GameAnalysis.fromJson(Map<String, dynamic> json) {
    return GameAnalysis(
      overallRating: json['overallRating'] as int? ?? 3,
      summary: json['summary'] as String? ?? '',
      strengths: List<String>.from(json['strengths'] ?? []),
      improvements: List<String>.from(json['improvements'] ?? []),
      keyMoments: (json['keyMoments'] as List<dynamic>?)
          ?.map((m) => KeyMoment.fromJson(m))
          .toList() ?? [],
      nextLesson: json['nextLesson'] as String?,
    );
  }
}

class KeyMoment {
  final int round;
  final String description;
  final String yourPlay;
  final String optimalPlay;
  final String lesson;

  KeyMoment({
    required this.round,
    required this.description,
    required this.yourPlay,
    required this.optimalPlay,
    required this.lesson,
  });

  factory KeyMoment.fromJson(Map<String, dynamic> json) {
    return KeyMoment(
      round: json['round'] as int? ?? 0,
      description: json['description'] as String? ?? '',
      yourPlay: json['yourPlay'] as String? ?? '',
      optimalPlay: json['optimalPlay'] as String? ?? '',
      lesson: json['lesson'] as String? ?? '',
    );
  }
}

class PlaySuggestion {
  final String recommendedPlay;
  final double confidence;
  final String reasoning;
  final String? alternative;

  PlaySuggestion({
    required this.recommendedPlay,
    required this.confidence,
    required this.reasoning,
    this.alternative,
  });

  factory PlaySuggestion.fromJson(Map<String, dynamic> json) {
    return PlaySuggestion(
      recommendedPlay: json['recommendedPlay'] as String? ?? '',
      confidence: (json['confidence'] as num?)?.toDouble() ?? 0.5,
      reasoning: json['reasoning'] as String? ?? '',
      alternative: json['alternative'] as String?,
    );
  }
}

class SkillAssessment {
  final String level; // beginner, intermediate, advanced, expert
  final int rating; // ELO-like rating
  final String rank; // Bronze, Silver, Gold, Platinum, Diamond
  final int gamesPlayed;
  final double winRate;
  final List<String> strengths;
  final List<String> weaknesses;
  final String nextMilestone;
  final double progressToNext;

  SkillAssessment({
    required this.level,
    required this.rating,
    required this.rank,
    required this.gamesPlayed,
    required this.winRate,
    required this.strengths,
    required this.weaknesses,
    required this.nextMilestone,
    required this.progressToNext,
  });

  factory SkillAssessment.fromJson(Map<String, dynamic> json) {
    return SkillAssessment(
      level: json['level'] as String? ?? 'beginner',
      rating: json['rating'] as int? ?? 1000,
      rank: json['rank'] as String? ?? 'Bronze',
      gamesPlayed: json['gamesPlayed'] as int? ?? 0,
      winRate: (json['winRate'] as num?)?.toDouble() ?? 0.0,
      strengths: List<String>.from(json['strengths'] ?? []),
      weaknesses: List<String>.from(json['weaknesses'] ?? []),
      nextMilestone: json['nextMilestone'] as String? ?? '',
      progressToNext: (json['progressToNext'] as num?)?.toDouble() ?? 0.0,
    );
  }
}

class TrainingPlan {
  final String gameType;
  final int totalWeeks;
  final List<WeeklyGoal> weeklyGoals;

  TrainingPlan({
    required this.gameType,
    required this.totalWeeks,
    required this.weeklyGoals,
  });

  factory TrainingPlan.fromJson(Map<String, dynamic> json) {
    return TrainingPlan(
      gameType: json['gameType'] as String? ?? '',
      totalWeeks: json['totalWeeks'] as int? ?? 4,
      weeklyGoals: (json['weeklyGoals'] as List<dynamic>?)
          ?.map((g) => WeeklyGoal.fromJson(g))
          .toList() ?? [],
    );
  }
}

class WeeklyGoal {
  final int week;
  final String focus;
  final List<LessonTopic> lessons;
  final int practiceGames;
  final double targetWinRate;

  WeeklyGoal({
    required this.week,
    required this.focus,
    required this.lessons,
    required this.practiceGames,
    required this.targetWinRate,
  });

  factory WeeklyGoal.fromJson(Map<String, dynamic> json) {
    return WeeklyGoal(
      week: json['week'] as int? ?? 1,
      focus: json['focus'] as String? ?? '',
      lessons: [], // Would need full mapping
      practiceGames: json['practiceGames'] as int? ?? 5,
      targetWinRate: (json['targetWinRate'] as num?)?.toDouble() ?? 0.3,
    );
  }
}
