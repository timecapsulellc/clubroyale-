/// PhD Audit Finding #6: Regional Variants
/// Support for Dashain, Murder, Kidnap modes

enum MarriageVariant {
  standard,
  dashain,
  murder,
  kidnap,
}

/// Configuration for regional variants
class MarriageVariantConfig {
  final MarriageVariant variant;
  final String name;
  final String nepaliName;
  final String description;
  final int targetScore;
  final int kidneyPenalty;
  final bool requiresPureSequence;
  final bool murderMode;
  final double speedMultiplier;
  
  const MarriageVariantConfig({
    required this.variant,
    required this.name,
    required this.nepaliName,
    required this.description,
    this.targetScore = 100,
    this.kidneyPenalty = 10,
    this.requiresPureSequence = true,
    this.murderMode = false,
    this.speedMultiplier = 1.0,
  });
  
  /// Standard Marriage rules
  static const standard = MarriageVariantConfig(
    variant: MarriageVariant.standard,
    name: 'Standard Marriage',
    nepaliName: 'सामान्य म्यारिज',
    description: 'Classic Nepali Marriage rules. First to 100 points wins.',
    targetScore: 100,
    kidneyPenalty: 10,
  );
  
  /// Dashain Festival Mode - Higher stakes
  static const dashain = MarriageVariantConfig(
    variant: MarriageVariant.dashain,
    name: 'Dashain Mode',
    nepaliName: 'दशैं म्यारिज',
    description: 'Festival special! Higher targets, faster games, bigger rewards.',
    targetScore: 500,
    kidneyPenalty: 25,
    speedMultiplier: 1.5,
  );
  
  /// Murder Mode - Severe penalties
  static const murder = MarriageVariantConfig(
    variant: MarriageVariant.murder,
    name: 'Murder Mode',
    nepaliName: 'मर्डर म्यारिज',
    description: 'Hardcore! No pure sequence = lose ALL points.',
    targetScore: 100,
    kidneyPenalty: 10,
    requiresPureSequence: true,
    murderMode: true,
  );
  
  /// Kidnap Mode - Enhanced penalties
  static const kidnap = MarriageVariantConfig(
    variant: MarriageVariant.kidnap,
    name: 'Kidnap Mode',
    nepaliName: 'किडनाप म्यारिज',
    description: 'Not visiting before game ends = -15 penalty instead of -10.',
    targetScore: 100,
    kidneyPenalty: 15,
  );
  
  /// Get all available variants
  static List<MarriageVariantConfig> get all => [
    standard,
    dashain,
    murder,
    kidnap,
  ];
  
  /// Get variant by enum
  static MarriageVariantConfig fromVariant(MarriageVariant variant) {
    switch (variant) {
      case MarriageVariant.standard: return standard;
      case MarriageVariant.dashain: return dashain;
      case MarriageVariant.murder: return murder;
      case MarriageVariant.kidnap: return kidnap;
    }
  }
}

/// Mixin for variant-aware game logic
mixin VariantAwareGameLogic {
  MarriageVariantConfig get variantConfig;
  
  /// Calculate penalty for not visiting
  int calculateKidnapPenalty() {
    return variantConfig.kidneyPenalty;
  }
  
  /// Check if player is "murdered" (no pure sequence in murder mode)
  bool isMurdered({required bool hasPureSequence}) {
    if (!variantConfig.murderMode) return false;
    return !hasPureSequence;
  }
  
  /// Get target score for this variant
  int getTargetScore() {
    return variantConfig.targetScore;
  }
  
  /// Get turn time based on speed multiplier
  Duration getTurnDuration({Duration baseDuration = const Duration(seconds: 30)}) {
    final millis = baseDuration.inMilliseconds ~/ variantConfig.speedMultiplier;
    return Duration(milliseconds: millis);
  }
}
