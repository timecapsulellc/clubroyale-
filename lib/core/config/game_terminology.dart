/// ClubRoyale Game Terminology
///
/// Centralized terminology for global audience
/// Supports multiple regional modes for localization
library;

enum GameRegion {
  global, // ClubRoyale international terms
  southAsia, // Nepal/India traditional terms
}

/// Centralized game terminology for multi-region support
class GameTerminology {
  static GameRegion currentRegion = GameRegion.global;

  // ============ BRANDING ============

  static String get appName => 'ClubRoyale';
  static String get appTagline => 'Your Private Card Club';

  // ============ GAME NAMES ============

  static String get royalMeldGame {
    switch (currentRegion) {
      case GameRegion.global:
        return 'Royal Meld';
      case GameRegion.southAsia:
        return 'Marriage';
    }
  }

  static String get royalMeldDescription {
    switch (currentRegion) {
      case GameRegion.global:
        return 'The Ultimate Card Experience';
      case GameRegion.southAsia:
        return 'Classic South Asian Card Game';
    }
  }

  static String get callBreakGame => 'Call Break';
  static String get callBreakDescription => 'Strategic Trick-Taking Game';

  static String get teenPattiGame => 'Teen Patti';
  static String get teenPattiDescription => 'Three Card Poker';

  static String get inBetweenGame {
    switch (currentRegion) {
      case GameRegion.global:
        return 'In-Between';
      case GameRegion.southAsia:
        return 'Bahir';
    }
  }

  static String get inBetweenDescription {
    switch (currentRegion) {
      case GameRegion.global:
        return 'Hi-Lo Betting Game';
      case GameRegion.southAsia:
        return 'Andar Bahir Style';
    }
  }

  static String get dhumbalGame => 'Dhumbal';
  static String get dhumbalDescription => 'Jhyaap Style';

  static String get wildCard {
    switch (currentRegion) {
      case GameRegion.global:
        return 'Wild';
      case GameRegion.southAsia:
        return 'Tiplu';
    }
  }

  static String get wildCardFull {
    switch (currentRegion) {
      case GameRegion.global:
        return 'Wild Card';
      case GameRegion.southAsia:
        return 'Tiplu';
    }
  }

  static String get highWild {
    switch (currentRegion) {
      case GameRegion.global:
        return 'High Wild';
      case GameRegion.southAsia:
        return 'Poplu';
    }
  }

  static String get lowWild {
    switch (currentRegion) {
      case GameRegion.global:
        return 'Low Wild';
      case GameRegion.southAsia:
        return 'Jhiplu';
    }
  }

  // ============ MELD TERMS ============

  static String get royalSequence {
    switch (currentRegion) {
      case GameRegion.global:
        return 'Royal Sequence';
      case GameRegion.southAsia:
        return 'Marriage';
    }
  }

  static String get royalSequenceShort {
    switch (currentRegion) {
      case GameRegion.global:
        return 'Royal';
      case GameRegion.southAsia:
        return 'Marriage';
    }
  }

  static String get triple {
    switch (currentRegion) {
      case GameRegion.global:
        return 'Triple';
      case GameRegion.southAsia:
        return 'Tunella';
    }
  }

  static String get set => 'Set';
  static String get trial => 'Trial';
  static String get run => 'Run';
  static String get sequence => 'Sequence';
  static String get tunnel => 'Tunnel';

  // ============ ACTION TERMS ============

  static String get declare {
    switch (currentRegion) {
      case GameRegion.global:
        return 'Go Royale';
      case GameRegion.southAsia:
        return 'Declare';
    }
  }

  static String get drawDeck => 'Draw';
  static String get pickDiscard => 'Pick';
  static String get discard => 'Discard';
  static String get sort => 'Sort';

  // ============ PHASE TERMS ============

  static String get drawingPhase => '📥 DRAW A CARD';
  static String get discardingPhase => '📤 DISCARD A CARD';
  static String get declaringPhase => 'Ready to Declare?';
  static String get waitingPhase => 'Waiting for others...';
  static String get scoringPhase => 'Scoring';

  // ============ HELP TEXT ============

  static String get wildCardHelp {
    switch (currentRegion) {
      case GameRegion.global:
        return 'Wild Card can substitute any card in a meld!';
      case GameRegion.southAsia:
        return 'Tiplu is the wild card - use it in any meld!';
    }
  }

  static String royalSequenceHelp(String wildRank, String wildSuit) {
    switch (currentRegion) {
      case GameRegion.global:
        return 'Royal Sequence = Low Wild + Wild + High Wild\n'
            'Form a sequence around $wildRank$wildSuit for 100 bonus points!';
      case GameRegion.southAsia:
        return 'Marriage = Jhiplu + Tiplu + Poplu\n'
            'Form around $wildRank$wildSuit for 100 bonus points!';
    }
  }

  static String get setHelp => '3+ cards of same rank from different suits';
  static String get runHelp => '3+ consecutive cards of same suit';

  // ============ SCORING ============

  static String get bonusPoints => 'Bonus';
  static String get penaltyPoints => 'Penalty';
  static String get royalBonus => 'Royal Bonus';
  static String points(int value) => '$value pts';

  // ============ UI MESSAGES ============

  static String get yourTurn => "It's Your Turn!";
  static String playerTurn(String name) => "$name's Turn";
  static String get selectCard => 'Select a card to discard';
  static String get noMeldsYet => 'No melds found - collect matching cards!';
  static String get readyToDeclare =>
      'All cards in melds - ready to Go Royale!';
  static String get invalidDeclare =>
      'Cannot declare - not all cards form valid melds';

  // ============ ROOM TERMS ============

  static String get createRoom => 'Create Room';
  static String get joinRoom => 'Join Room';
  static String get practiceMode => 'Practice';
  static String get privateRoom => 'Private Room';
  static String get roomCode => 'Room Code';
  static String get enterCode => 'Enter 6-digit code';

  // ============ PLAYER TERMS ============

  static String get host => 'Host';
  static String get player => 'Player';
  static String get bot => 'Bot';
  static String get spectator => 'Spectator';

  // ============ MELD TYPE DISPLAY NAMES ============

  static String getMeldTypeName(String type) {
    switch (type.toLowerCase()) {
      case 'marriage':
        return royalSequenceShort;
      case 'set':
        return trial;
      case 'run':
        return sequence;
      case 'tunnel':
        return triple;
      default:
        return type;
    }
  }
}
