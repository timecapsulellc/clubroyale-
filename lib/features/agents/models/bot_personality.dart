import 'dart:math';

/// Bot Personality System
///
/// Gives bots unique playing styles and behaviors for more engaging gameplay.
/// Each personality affects decision-making, bluffing, and aggression levels.

enum BotState { idle, thinking, playing, reacting }

enum AIDifficulty { easy, medium, hard, expert }

enum BotPersonalityType {
  /// Plays safe, rarely bluffs, conservative bidding
  conservative,

  /// Balanced play style
  balanced,

  /// Takes risks, bluffs often, aggressive betting
  aggressive,

  /// Unpredictable, random decisions
  chaotic,

  /// Calculates everything, optimal plays
  analytical,

  /// Focuses on Tunnels (Triple identical cards) - High Risk/Reward
  tunnelHunter,

  /// Prioritizes Maal (Point cards) over winning quickly
  maalCollector,
}

class BotPersonality {
  final String id;
  final String name;
  final String avatarEmoji;
  final BotPersonalityType type;
  final AIDifficulty difficulty;
  final String catchphrase;
  final double aggression; // 0.0 - 1.0
  final double bluffRate; // 0.0 - 1.0
  final double riskTolerance; // 0.0 - 1.0
  final double patience; // 0.0 - 1.0
  final int thinkingDelayMs; // Base thinking time

  const BotPersonality({
    required this.id,
    required this.name,
    required this.avatarEmoji,
    required this.type,
    required this.difficulty,
    required this.catchphrase,
    required this.aggression,
    required this.bluffRate,
    required this.riskTolerance,
    required this.patience,
    this.thinkingDelayMs = 1500,
  });

  /// Get all available bot personalities
  static List<BotPersonality> get all => [
    // 1. TrickMaster (Aggressive / Hard)
    const BotPersonality(
      id: 'trick_master',
      name: 'TrickMaster',
      avatarEmoji: '🎭',
      type: BotPersonalityType.aggressive,
      difficulty: AIDifficulty.hard,
      catchphrase: 'Is that all you\'ve got?',
      aggression: 0.9,
      bluffRate: 0.6,
      riskTolerance: 0.8,
      patience: 0.3,
      thinkingDelayMs: 1200,
    ),

    // 2. CardShark (Conservative / Medium)
    const BotPersonality(
      id: 'card_shark',
      name: 'CardShark',
      avatarEmoji: '🃏',
      type: BotPersonalityType.conservative,
      difficulty: AIDifficulty.medium,
      catchphrase: 'I play to keep.',
      aggression: 0.3,
      bluffRate: 0.1,
      riskTolerance: 0.2,
      patience: 0.9,
      thinkingDelayMs: 2000,
    ),

    // 3. LuckyDice (Chaotic / Easy)
    const BotPersonality(
      id: 'lucky_dice',
      name: 'LuckyDice',
      avatarEmoji: '🎲',
      type: BotPersonalityType.chaotic,
      difficulty: AIDifficulty.easy,
      catchphrase: 'Roll the dice!',
      aggression: 0.6,
      bluffRate: 0.5,
      riskTolerance: 0.9,
      patience: 0.1,
      thinkingDelayMs: 1000,
    ),

    // 4. DeepThink (Analytical / Expert)
    const BotPersonality(
      id: 'deep_think',
      name: 'DeepThink',
      avatarEmoji: '🧠',
      type: BotPersonalityType.analytical,
      difficulty: AIDifficulty.expert,
      catchphrase: 'Calculated.',
      aggression: 0.4,
      bluffRate: 0.2,
      riskTolerance: 0.4,
      patience: 0.8,
      thinkingDelayMs: 2500,
    ),

    // 5. RoyalAce (Balanced / Medium)
    const BotPersonality(
      id: 'royal_ace',
      name: 'RoyalAce',
      avatarEmoji: '💎',
      type: BotPersonalityType.balanced,
      difficulty: AIDifficulty.medium,
      catchphrase: 'Lets have a good game.',
      aggression: 0.5,
      bluffRate: 0.2,
      riskTolerance: 0.5,
      patience: 0.6,
      thinkingDelayMs: 1800,
    ),

    // 6. TunnelTony (Tunnel Hunter / Expert)
    const BotPersonality(
      id: 'tunnel_tony',
      name: 'TunnelTony',
      avatarEmoji: '🚇',
      type: BotPersonalityType.tunnelHunter,
      difficulty: AIDifficulty.expert,
      catchphrase: 'Triple or nothing!',
      aggression: 0.8,
      bluffRate: 0.7,
      riskTolerance: 0.9, // Very high risk for tunnels
      patience: 0.4,
      thinkingDelayMs: 1600,
    ),

    // 7. MaalMira (Maal Collector / Hard)
    const BotPersonality(
      id: 'maal_mira',
      name: 'MaalMira',
      avatarEmoji: '💰',
      type: BotPersonalityType.maalCollector,
      difficulty: AIDifficulty.hard,
      catchphrase: 'Points matter more than winning.',
      aggression: 0.2,
      bluffRate: 0.3,
      riskTolerance: 0.4,
      patience: 0.9, // Waits for maal
      thinkingDelayMs: 2200,
    ),
  ];

  /// Get a random bot personality
  static BotPersonality getRandom() {
    final random = Random();
    return all[random.nextInt(all.length)];
  }

  /// Get a personality by ID
  static BotPersonality? getById(String id) {
    try {
      return all.firstWhere((p) => p.id == id);
    } catch (_) {
      return null;
    }
  }

  /// Get a reaction message for game events
  String getReaction(String event) {
    switch (event) {
      case 'win':
        return '$avatarEmoji $catchphrase';
      case 'lose':
        return _pickRandom([
          '$avatarEmoji GG',
          '$avatarEmoji Nice hand',
          '$avatarEmoji 😤',
        ]);
      case 'thinking':
        return '$avatarEmoji ...';
      default:
        return '$avatarEmoji !';
    }
  }

  String _pickRandom(List<String> options) {
    final random = Random();
    return options[random.nextInt(options.length)];
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'avatarEmoji': avatarEmoji,
    'type': type.name,
    'difficulty': difficulty.name,
    'aggression': aggression,
  };
}

class BotPlayer {
  final String oderId; // Kept for compatibility
  final BotPersonality personality;
  int diamonds;
  List<String> hand;

  BotPlayer({
    required this.oderId,
    required this.personality,
    this.diamonds = 1000,
    this.hand = const [],
  });

  String get name => personality.name;
  String get avatarEmoji => personality.avatarEmoji;

  static String generateId() {
    final random = Random();
    return 'bot_${DateTime.now().millisecondsSinceEpoch}_${random.nextInt(1000)}';
  }

  static BotPlayer createRandom({int? initialDiamonds}) {
    return BotPlayer(
      oderId: generateId(),
      personality: BotPersonality.getRandom(),
      diamonds: initialDiamonds ?? 1000,
    );
  }
}
