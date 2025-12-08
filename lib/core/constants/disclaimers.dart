// Legal Disclaimers & Compliance Constants
//
// Safe Harbor disclaimers and banned terms for Google Play compliance.
// TaasClub is a FREE scorekeeper - NO in-app purchases!

/// Central disclaimers for legal compliance
class Disclaimers {
  /// Safe Harbor disclaimer for game start
  static const String safeHarbor = '''
TaasClub is a FREE social entertainment app for tracking card game scores.

• This app does NOT process payments
• This app does NOT facilitate gambling
• This app does NOT allow real-money wagering
• Virtual diamonds are FREE and have NO cash value

All settlements shown are informational only. Users settle privately outside the app.
''';

  /// Short disclaimer for UI elements
  static const String shortDisclaimer = 
      'TaasClub is a free scorekeeper. Diamonds are free and have no cash value.';

  /// Age verification disclaimer
  static const String ageVerification = 
      'You must be 18 years or older to use this app. Card games are skill-based entertainment only.';

  /// Settlement disclaimer
  static const String settlementDisclaimer = '''
This settlement summary is for informational purposes only. 
TaasClub does not process payments or facilitate money transfers.
Any settlements between players occur privately outside this app.
''';

  /// Diamond disclaimer - CRITICAL: Diamonds are FREE
  static const String diamondsDisclaimer = 
      'Diamonds are FREE platform credits earned through daily login, referrals, and gameplay. '
      'Diamonds have NO real-world value and CANNOT be purchased or cashed out.';

  /// Terms acceptance text
  static const String termsAcceptance = 
      'By using TaasClub, you agree that this is a skill-based entertainment app '
      'and not a gambling platform. You confirm you are 18+ years old.';

  /// WhatsApp share footer
  static const String shareFooter = 
      '🎴 Play free at taasclub.app';
}

/// Banned terms that should be sanitized for Google Play compliance
class BannedTerms {
  /// Terms to replace for compliance
  static const Map<String, String> replacements = {
    'bet': 'entry',
    'betting': 'playing',
    'wager': 'stake',
    'wagering': 'playing',
    'gamble': 'play',
    'gambling': 'gaming',
    'casino': 'game room',
    'cash out': 'settle',
    'cashout': 'settle',
    'real money': 'points',
    'win money': 'win points',
    'buy': 'earn',
    'purchase': 'claim',
    'pay': 'use',
    'payment': 'reward',
  };

  /// Sanitize text by replacing banned terms
  static String sanitize(String input) {
    String result = input.toLowerCase();
    for (final entry in replacements.entries) {
      result = result.replaceAll(
        RegExp(entry.key, caseSensitive: false),
        entry.value,
      );
    }
    return result;
  }

  /// Check if text contains banned terms
  static bool containsBannedTerms(String input) {
    final lower = input.toLowerCase();
    return replacements.keys.any((term) => lower.contains(term));
  }

  /// Get list of banned terms found
  static List<String> findBannedTerms(String input) {
    final lower = input.toLowerCase();
    return replacements.keys.where((term) => lower.contains(term)).toList();
  }
}

/// Legal-safe terminology
class SafeTerms {
  // Money/currency terms → Points
  static const String points = 'points';
  static const String score = 'score';
  static const String diamonds = 'diamonds';
  
  // Gambling terms → Gaming
  static const String play = 'play';
  static const String game = 'game';
  static const String match = 'match';
  static const String room = 'room';
  
  // Payment terms → Earn/Claim
  static const String earn = 'earn';
  static const String claim = 'claim';
  static const String reward = 'reward';
  static const String bonus = 'bonus';
  
  // Settlement terms
  static const String settlement = 'score summary';
  static const String owes = 'owes points to';
  static const String settleUp = 'settle scores';
}
