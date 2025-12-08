// Compliance Constants & Banned Terms Sanitizer
//
// Centralized disclaimers and term sanitization for Google Play compliance.

/// Legal disclaimers for Safe Harbor compliance
class Disclaimers {
  /// Main Safe Harbor disclaimer - REQUIRED on first launch
  static const String safeHarbor = '''
TaasClub is a social scorekeeping utility for card games.

• All point settlements are private and offline
• We do not process, facilitate, or track real-money transactions
• Virtual currency (Diamonds) cannot be exchanged for cash or prizes
• This is a skill-based game, not gambling
• Players must be 18+ to use this app

By continuing, you agree to these terms.
''';

  /// Short version for in-app display
  static const String shortDisclaimer = 
    'TaasClub is for entertainment only. Diamonds have no cash value.';

  /// Age verification prompt
  static const String ageVerification = 
    'You must be 18 or older to use TaasClub. Please confirm your age.';

  /// Terms for settlement screen
  static const String settlementDisclaimer = '''
This is a scorecard only. TaasClub does not process payments.
Any settlements between players are private and offline.
''';

  /// Store disclaimer
  static const String storeDisclaimer =
    'Diamonds are virtual currency for platform fees only. No cash value.';
}

/// Banned terms that should NEVER appear in UI
class BannedTerms {
  static const List<String> banned = [
    'bet', 'wager', 'gamble', 'gambling', 'casino',
    'payout', 'winnings', 'jackpot', 'cash out', 'cashout',
    'rupee', 'dollar', 'real money', 'withdraw', 'withdrawal',
    'stake', 'odds', 'betting', 'prize money',
  ];
  
  static const Map<String, String> replacements = {
    'bet': 'entry fee',
    'wager': 'stake points',
    'payout': 'settlement',
    'winnings': 'balance',
    'cash': 'credits',
    'gambling': 'skill game',
    'casino': 'club',
    'prize': 'reward',
    'stake': 'entry',
    'jackpot': 'bonus pool',
  };
  
  /// Validate text doesn't contain banned terms
  static bool containsBannedTerms(String text) {
    final lowerText = text.toLowerCase();
    return banned.any((term) => lowerText.contains(term));
  }
  
  /// Replace banned terms with safe alternatives
  static String sanitize(String text) {
    var result = text;
    for (final entry in replacements.entries) {
      result = result.replaceAll(
        RegExp(entry.key, caseSensitive: false), 
        entry.value,
      );
    }
    return result;
  }

  /// Get list of violations in text
  static List<String> getViolations(String text) {
    final lowerText = text.toLowerCase();
    return banned.where((term) => lowerText.contains(term)).toList();
  }
}
