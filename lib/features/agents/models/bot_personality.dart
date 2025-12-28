import 'dart:math';

/// Bot Personality System
/// 
/// Gives bots unique playing styles and behaviors for more engaging gameplay.
/// Each personality affects decision-making, bluffing, and aggression levels.

enum BotPersonalityType {
  /// Plays safe, rarely bluffs, conservative bidding
  cautious,
  
  /// Balanced play style
  balanced,
  
  /// Takes risks, bluffs often, aggressive betting
  aggressive,
  
  /// Unpredictable, random decisions
  chaotic,
  
  /// Calculates everything, optimal plays
  analytical,
  
  /// Bets big, goes all-in often
  highRoller,
  
  /// Waits for premium hands
  patient,
  
  /// Adapts to opponent patterns
  adaptive,
}

class BotPersonality {
  final String id;
  final String name;
  final String avatarEmoji;
  final BotPersonalityType type;
  final String catchphrase;
  final double aggression; // 0.0 - 1.0
  final double bluffRate;  // 0.0 - 1.0
  final double riskTolerance; // 0.0 - 1.0
  final double patience; // 0.0 - 1.0
  
  const BotPersonality({
    required this.id,
    required this.name,
    required this.avatarEmoji,
    required this.type,
    required this.catchphrase,
    required this.aggression,
    required this.bluffRate,
    required this.riskTolerance,
    required this.patience,
  });

  /// Get all available bot personalities
  static List<BotPersonality> get all => [
    // Cautious bots
    const BotPersonality(
      id: 'careful_carl',
      name: 'Careful Carl',
      avatarEmoji: '🤓',
      type: BotPersonalityType.cautious,
      catchphrase: 'Better safe than sorry!',
      aggression: 0.2,
      bluffRate: 0.1,
      riskTolerance: 0.2,
      patience: 0.9,
    ),
    const BotPersonality(
      id: 'timid_tina',
      name: 'Timid Tina',
      avatarEmoji: '😰',
      type: BotPersonalityType.cautious,
      catchphrase: 'Are you sure about this?',
      aggression: 0.1,
      bluffRate: 0.05,
      riskTolerance: 0.15,
      patience: 0.95,
    ),
    
    // Aggressive bots
    const BotPersonality(
      id: 'bold_barry',
      name: 'Bold Barry',
      avatarEmoji: '😎',
      type: BotPersonalityType.aggressive,
      catchphrase: 'Go big or go home!',
      aggression: 0.85,
      bluffRate: 0.4,
      riskTolerance: 0.8,
      patience: 0.2,
    ),
    const BotPersonality(
      id: 'risky_rita',
      name: 'Risky Rita',
      avatarEmoji: '🔥',
      type: BotPersonalityType.aggressive,
      catchphrase: 'Fortune favors the bold!',
      aggression: 0.9,
      bluffRate: 0.5,
      riskTolerance: 0.9,
      patience: 0.1,
    ),
    
    // Balanced bots
    const BotPersonality(
      id: 'steady_steve',
      name: 'Steady Steve',
      avatarEmoji: '😊',
      type: BotPersonalityType.balanced,
      catchphrase: 'Consistency is key.',
      aggression: 0.5,
      bluffRate: 0.25,
      riskTolerance: 0.5,
      patience: 0.5,
    ),
    const BotPersonality(
      id: 'fair_fiona',
      name: 'Fair Fiona',
      avatarEmoji: '🌟',
      type: BotPersonalityType.balanced,
      catchphrase: 'May the best hand win!',
      aggression: 0.45,
      bluffRate: 0.2,
      riskTolerance: 0.45,
      patience: 0.55,
    ),
    
    // Chaotic bots
    const BotPersonality(
      id: 'crazy_charlie',
      name: 'Crazy Charlie',
      avatarEmoji: '🤪',
      type: BotPersonalityType.chaotic,
      catchphrase: 'Chaos is a ladder!',
      aggression: 0.6,
      bluffRate: 0.7,
      riskTolerance: 0.7,
      patience: 0.3,
    ),
    const BotPersonality(
      id: 'wild_wendy',
      name: 'Wild Wendy',
      avatarEmoji: '🎲',
      type: BotPersonalityType.chaotic,
      catchphrase: 'Roll the dice!',
      aggression: 0.65,
      bluffRate: 0.6,
      riskTolerance: 0.75,
      patience: 0.25,
    ),
    
    // Analytical bots
    const BotPersonality(
      id: 'analytical_alex',
      name: 'Analytical Alex',
      avatarEmoji: '🧠',
      type: BotPersonalityType.analytical,
      catchphrase: 'The numbers never lie.',
      aggression: 0.4,
      bluffRate: 0.15,
      riskTolerance: 0.3,
      patience: 0.7,
    ),
    const BotPersonality(
      id: 'calculating_cathy',
      name: 'Calculating Cathy',
      avatarEmoji: '📊',
      type: BotPersonalityType.analytical,
      catchphrase: 'Probability favors the prepared.',
      aggression: 0.35,
      bluffRate: 0.12,
      riskTolerance: 0.25,
      patience: 0.8,
    ),
    
    // High Roller bots
    const BotPersonality(
      id: 'lucky_leo',
      name: 'Lucky Leo',
      avatarEmoji: '🍀',
      type: BotPersonalityType.highRoller,
      catchphrase: 'Feeling lucky today!',
      aggression: 0.75,
      bluffRate: 0.35,
      riskTolerance: 0.95,
      patience: 0.15,
    ),
    const BotPersonality(
      id: 'diamond_diana',
      name: 'Diamond Diana',
      avatarEmoji: '💎',
      type: BotPersonalityType.highRoller,
      catchphrase: 'Diamonds are forever!',
      aggression: 0.7,
      bluffRate: 0.3,
      riskTolerance: 0.85,
      patience: 0.2,
    ),
    
    // Patient bots
    const BotPersonality(
      id: 'patient_pete',
      name: 'Patient Pete',
      avatarEmoji: '🐢',
      type: BotPersonalityType.patient,
      catchphrase: 'Good things come to those who wait.',
      aggression: 0.25,
      bluffRate: 0.1,
      riskTolerance: 0.2,
      patience: 0.95,
    ),
    
    // Adaptive bots
    const BotPersonality(
      id: 'mirror_mike',
      name: 'Mirror Mike',
      avatarEmoji: '🪞',
      type: BotPersonalityType.adaptive,
      catchphrase: 'I see what you did there...',
      aggression: 0.5,
      bluffRate: 0.3,
      riskTolerance: 0.5,
      patience: 0.5,
    ),
  ];

  /// Get a random bot personality
  static BotPersonality getRandom() {
    final random = Random();
    return all[random.nextInt(all.length)];
  }

  /// Get bots by personality type
  static List<BotPersonality> getByType(BotPersonalityType type) {
    return all.where((p) => p.type == type).toList();
  }

  /// Get a personality by ID
  static BotPersonality? getById(String id) {
    try {
      return all.firstWhere((p) => p.id == id);
    } catch (_) {
      return null;
    }
  }

  /// Should the bot bluff in the current situation?
  bool shouldBluff(double handStrength) {
    final random = Random();
    // More likely to bluff with weak hand and high bluff rate
    final bluffChance = bluffRate * (1.0 - handStrength);
    return random.nextDouble() < bluffChance;
  }

  /// How much should the bot bet? Returns multiplier (1.0 = normal)
  double getBetMultiplier(double handStrength) {
    final random = Random();
    final base = 1.0 + (aggression * handStrength);
    final variance = (random.nextDouble() - 0.5) * 0.3;
    return (base + variance).clamp(0.5, 3.0);
  }

  /// Should the bot take a risky action?
  bool shouldTakeRisk(double successProbability) {
    final random = Random();
    final threshold = 1.0 - riskTolerance;
    return successProbability > threshold || 
           (riskTolerance > 0.7 && random.nextDouble() < 0.3);
  }

  /// Should the bot wait for a better opportunity?
  bool shouldWait(double currentValue, double potentialValue) {
    if (potentialValue <= currentValue) return false;
    final improvement = (potentialValue - currentValue) / currentValue;
    return improvement * patience > 0.2;
  }

  /// Get a reaction message for game events
  /// 
  /// Supported events: win, lose, big_win, bluff_caught, bluff_success,
  /// good_hand, bad_hand, opponent_mistake, opponent_win, thinking,
  /// taunt, greeting, goodbye, lucky, unlucky
  String getReaction(String event) {
    switch (event) {
      case 'win':
        return _pickRandom([
          '$avatarEmoji $catchphrase',
          '$avatarEmoji Victory!',
          '$avatarEmoji That\'s how it\'s done!',
        ]);
      case 'lose':
        return _pickRandom([
          '$avatarEmoji Better luck next time...',
          '$avatarEmoji I\'ll get you next round!',
          '$avatarEmoji 😤',
        ]);
      case 'big_win':
        return _pickRandom([
          '$avatarEmoji 🎉 JACKPOT!',
          '$avatarEmoji This is my moment!',
          '$avatarEmoji 💰💰💰',
        ]);
      case 'bluff_caught':
        return _pickRandom([
          '$avatarEmoji Well played...',
          '$avatarEmoji You saw right through me!',
          '$avatarEmoji 😅 Oops',
        ]);
      case 'bluff_success':
        return _pickRandom([
          '$avatarEmoji 😏',
          '$avatarEmoji Fooled ya!',
          '$avatarEmoji All in the game!',
        ]);
      
      // ===== NEW REACTION TYPES =====
      case 'good_hand':
        return _pickRandom([
          '$avatarEmoji Feeling good about this one!',
          '$avatarEmoji 👀',
          '$avatarEmoji Interesting...',
        ]);
      case 'bad_hand':
        return _pickRandom([
          '$avatarEmoji Well...let\'s see what happens.',
          '$avatarEmoji 😬',
          '$avatarEmoji Every hand is a chance!',
        ]);
      case 'opponent_mistake':
        return _pickRandom([
          '$avatarEmoji Did you mean to do that? 😄',
          '$avatarEmoji Thank you!',
          '$avatarEmoji I\'ll take it!',
        ]);
      case 'opponent_win':
        return _pickRandom([
          '$avatarEmoji Nice play!',
          '$avatarEmoji Well done 👏',
          '$avatarEmoji You got me there.',
        ]);
      case 'thinking':
        return _pickRandom([
          '$avatarEmoji Hmm...',
          '$avatarEmoji 🤔',
          '$avatarEmoji Let me think...',
        ]);
      
      // ===== TAUNTS (personality-based) =====
      case 'taunt':
        return _getTaunt();
      case 'greeting':
        return _pickRandom([
          '$avatarEmoji Hey there! Ready to play?',
          '$avatarEmoji Let\'s go! 🎮',
          '$avatarEmoji $name is in the house!',
        ]);
      case 'goodbye':
        return _pickRandom([
          '$avatarEmoji GG! See you next time!',
          '$avatarEmoji Until next time! 👋',
          '$avatarEmoji That was fun!',
        ]);
      case 'lucky':
        return _pickRandom([
          '$avatarEmoji 🍀 Feeling lucky!',
          '$avatarEmoji The cards are with me today!',
          '$avatarEmoji Fortune smiles upon me!',
        ]);
      case 'unlucky':
        return _pickRandom([
          '$avatarEmoji Not my day... 😔',
          '$avatarEmoji The cards are against me!',
          '$avatarEmoji Can\'t catch a break!',
        ]);
        
      default:
        return '$avatarEmoji ...';
    }
  }
  
  /// Get a personality-based taunt
  String _getTaunt() {
    switch (type) {
      case BotPersonalityType.aggressive:
        return _pickRandom([
          '$avatarEmoji Is that all you\'ve got? 😏',
          '$avatarEmoji Come at me!',
          '$avatarEmoji You\'re going down!',
        ]);
      case BotPersonalityType.cautious:
        return _pickRandom([
          '$avatarEmoji Slow and steady wins...',
          '$avatarEmoji Patience is a virtue.',
          '$avatarEmoji Think before you act!',
        ]);
      case BotPersonalityType.chaotic:
        return _pickRandom([
          '$avatarEmoji CHAOS! 🌀',
          '$avatarEmoji Expect the unexpected!',
          '$avatarEmoji Wild card baby!',
        ]);
      case BotPersonalityType.analytical:
        return _pickRandom([
          '$avatarEmoji Probability: not in your favor.',
          '$avatarEmoji The math says I win.',
          '$avatarEmoji Calculating your defeat...',
        ]);
      case BotPersonalityType.highRoller:
        return _pickRandom([
          '$avatarEmoji Go big or go home! 💎',
          '$avatarEmoji All in energy!',
          '$avatarEmoji Risk it for the biscuit!',
        ]);
      case BotPersonalityType.patient:
        return _pickRandom([
          '$avatarEmoji Good things come to those who wait...',
          '$avatarEmoji I\'ve got all day.',
          '$avatarEmoji Tick tock... 🕐',
        ]);
      case BotPersonalityType.adaptive:
        return _pickRandom([
          '$avatarEmoji I\'ve got your number now.',
          '$avatarEmoji Learning your moves...',
          '$avatarEmoji Adapting... Evolving...',
        ]);
      default:
        return _pickRandom([
          '$avatarEmoji Let\'s see what you\'ve got!',
          '$avatarEmoji Game on!',
          '$avatarEmoji May the best player win!',
        ]);
    }
  }

  String _pickRandom(List<String> options) {
    final random = Random();
    return options[random.nextInt(options.length)];
  }

  /// Convert to JSON for storage
  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'avatarEmoji': avatarEmoji,
    'type': type.name,
    'catchphrase': catchphrase,
    'aggression': aggression,
    'bluffRate': bluffRate,
    'riskTolerance': riskTolerance,
    'patience': patience,
  };
}

/// Bot player with personality
class BotPlayer {
  final String oderId;
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

  /// Generate unique bot ID
  static String generateId() {
    final random = Random();
    return 'bot_${DateTime.now().millisecondsSinceEpoch}_${random.nextInt(1000)}';
  }

  /// Create a random bot
  static BotPlayer createRandom({int? initialDiamonds}) {
    return BotPlayer(
      oderId: generateId(),
      personality: BotPersonality.getRandom(),
      diamonds: initialDiamonds ?? 1000,
    );
  }

  /// Create a bot with specific personality
  static BotPlayer createWithPersonality(BotPersonality personality, {int? initialDiamonds}) {
    return BotPlayer(
      oderId: generateId(),
      personality: personality,
      diamonds: initialDiamonds ?? 1000,
    );
  }
}
