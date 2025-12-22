// Legal Disclaimers & Compliance Constants
//
// Entertainment Token Framework for app store compliance.
// ClubRoyale Diamonds are virtual entertainment tokens only.

/// Central disclaimers for legal compliance
class Disclaimers {
  /// Core entertainment token notice (full)
  static const String entertainmentTokenNotice = '''
ClubRoyale Diamonds are virtual entertainment tokens for use within this app only.

• Diamonds are NOT real money or cryptocurrency
• Diamonds have NO guaranteed real-world value
• Diamonds are NOT redeemable for cash within this app
• Diamonds are NOT transferable between users for value

This is a skill-based entertainment platform. Play responsibly.
''';

  /// Wallet screen disclaimer
  static const String walletDisclaimer = 
      'Diamonds are virtual entertainment tokens for use within ClubRoyale only. '
      'They have no cash value and are not a financial instrument.';

  /// Store disclaimer (no prices shown)
  static const String storeDisclaimer = 
      'Diamonds are virtual tokens for entertainment. '
      'Contact admin for acquisition options.';

  /// Skill-gaming disclaimer
  static const String skillGameDisclaimer = 
      'ClubRoyale is a skill-based gaming platform for entertainment only. '
      'Play responsibly.';

  /// Loading screen disclaimer
  static const String loadingDisclaimer = 
      'ClubRoyale is a skill-based card game platform for entertainment.';

  /// Settlement disclaimer (short)
  static const String shortSettlementDisclaimer = 
      'Score summaries are for informational purposes only.';

  /// Settlement disclaimer (full)
  static const String settlementDisclaimer = '''
This score summary is for informational purposes only. 
ClubRoyale does not process payments or facilitate money transfers.
Any settlements between players occur privately outside this app.
''';

  /// Age verification disclaimer
  static const String ageVerification = 
      'You must be 18 years or older to use this app. '
      'Card games are skill-based entertainment only.';

  /// Diamond disclaimer - Critical compliance
  static const String diamondsDisclaimer = 
      'Diamonds are virtual entertainment tokens with no real-world value. '
      'They cannot be purchased or redeemed through this app.';

  /// Welcome bonus disclaimer
  static const String welcomeBonusDisclaimer = 
      'Welcome diamonds are non-transferable entertainment tokens. '
      'They have no cash value and enable gameplay features.';

  /// Request submission disclaimer
  static const String requestDisclaimer = 
      'Submitting a request does not guarantee any external action. '
      'Any services are governed by separate external terms.';

  /// Terms acceptance text
  static const String termsAcceptance = 
      'By using ClubRoyale, you agree that this is a skill-based entertainment app '
      'and not a gambling platform. You confirm you are 18+ years old.';

  /// WhatsApp share footer
  static const String shareFooter = 
      '🎴 Play skill games at ClubRoyale';

  /// Short disclaimer for UI elements
  static const String shortDisclaimer = 
      'ClubRoyale is a skill-based entertainment platform. '
      'Diamonds are virtual tokens with no cash value.';

  /// Safe Harbor disclaimer for game start
  static const String safeHarbor = entertainmentTokenNotice;
}

/// Banned terms that should be sanitized for app store compliance
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
    'cash out': 'request',
    'cashout': 'request',
    'withdraw': 'request',
    'real money': 'tokens',
    'win money': 'earn tokens',
    'buy': 'acquire',
    'purchase': 'acquire',
    'pay': 'use',
    'payment': 'transaction',
    'sell': 'transfer',
    'trade': 'exchange',
    'market': 'shop',
    'invest': 'use',
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
  // Token terms
  static const String tokens = 'tokens';
  static const String diamonds = 'diamonds';
  static const String points = 'points';
  static const String score = 'score';
  
  // Gaming terms
  static const String play = 'play';
  static const String game = 'game';
  static const String match = 'match';
  static const String room = 'room';
  
  // Acquisition terms (no buy/purchase)
  static const String earn = 'earn';
  static const String claim = 'claim';
  static const String reward = 'reward';
  static const String bonus = 'bonus';
  static const String acquire = 'acquire';
  static const String contact = 'contact admin';
  
  // Settlement terms
  static const String settlement = 'score summary';
  static const String request = 'submit request';
}
