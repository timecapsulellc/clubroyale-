/// Nepali Language Localization for Marriage Game
/// 
/// Contains Devanagari translations for UI strings.
library;

/// Nepali translations for Marriage game terms
class NepaliStrings {
  // Game Actions
  static const String showSequence = 'क्रम देखाउनुहोस्'; // SHOW SEQUENCE
  static const String showDublee = 'डबली देखाउनुहोस्'; // SHOW DUBLEE
  static const String show7Dublees = '७ डबली देखाउनुहोस्'; // SHOW 7 DUBLEES
  static const String finishGame = 'खेल सकाउनुहोस्'; // FINISH GAME
  static const String cancelAction = 'रद्द गर्नुहोस्'; // CANCEL ACTION
  static const String getTunela = 'टनेला लिनुहोस्'; // GET TUNELA IN HAND
  static const String quitGame = 'खेल छोड्नुहोस्'; // QUIT GAME
  static const String settings = 'सेटिङ'; // SETTINGS

  // Maal Types
  static const String tiplu = 'टिप्लु'; // Tiplu
  static const String poplu = 'पोप्लु'; // Poplu
  static const String jhiplu = 'झिप्लु'; // Jhiplu
  static const String alter = 'अल्टर'; // Alter
  static const String man = 'म्यान'; // Man (Joker)
  static const String maal = 'माल'; // Maal
  static const String maalCard = 'माल कार्ड'; // Maal Card

  // Game Terms
  static const String tunnel = 'टनेल'; // Tunnel
  static const String tunnella = 'टनेला'; // Tunnella
  static const String dublee = 'डबली'; // Dublee (pair)
  static const String sequence = 'क्रम'; // Sequence
  static const String pureSequence = 'शुद्ध क्रम'; // Pure Sequence
  static const String marriage = 'म्यारिज'; // Marriage (combo)

  // Game Phases
  static const String dealing = 'कार्ड बाँडिँदैछ'; // Dealing cards
  static const String yourTurn = 'तपाईंको पालो'; // Your turn
  static const String waitingForPlayer = 'खेलाडीको प्रतीक्षा'; // Waiting for player
  static const String gameOver = 'खेल समाप्त'; // Game over

  // Actions
  static const String draw = 'तान्नुहोस्'; // Draw
  static const String discard = 'फाल्नुहोस्'; // Discard
  static const String declare = 'घोषणा गर्नुहोस्'; // Declare
  static const String visit = 'भेट गर्नुहोस्'; // Visit (Open/See)
  
  // Results
  static const String winner = 'विजेता'; // Winner
  static const String points = 'अंक'; // Points
  static const String round = 'राउन्ड'; // Round
  static const String score = 'स्कोर'; // Score

  // UI Labels
  static const String gameActions = 'खेल कार्यहरू'; // Game Actions
  static const String chat = 'च्याट'; // Chat
  static const String video = 'भिडियो'; // Video
  static const String audio = 'अडियो'; // Audio
  static const String help = 'मद्दत'; // Help

  // Warnings/Messages
  static const String reconnecting = 'पुन: जडान हुँदैछ...'; // Reconnecting...
  static const String noSets = 'कुनै सेट छैन'; // No sets declared
  static const String tapToClose = 'बन्द गर्न ट्याप गर्नुहोस्'; // Tap to close
}

/// English translations (default)
class EnglishStrings {
  // Game Actions
  static const String showSequence = 'SHOW SEQUENCE';
  static const String showDublee = 'SHOW DUBLEE';
  static const String show7Dublees = 'SHOW 7 DUBLEES';
  static const String finishGame = 'FINISH GAME';
  static const String cancelAction = 'CANCEL ACTION';
  static const String getTunela = 'GET TUNELA IN HAND';
  static const String quitGame = 'QUIT GAME';
  static const String settings = 'SETTINGS';

  // Maal Types
  static const String tiplu = 'Tiplu';
  static const String poplu = 'Poplu';
  static const String jhiplu = 'Jhiplu';
  static const String alter = 'Alter';
  static const String man = 'Man';
  static const String maal = 'Maal';
  static const String maalCard = 'Maal Card';

  // Game Terms
  static const String tunnel = 'Tunnel';
  static const String tunnella = 'Tunnella';
  static const String dublee = 'Dublee';
  static const String sequence = 'Sequence';
  static const String pureSequence = 'Pure Sequence';
  static const String marriage = 'Marriage';

  // Game Phases
  static const String dealing = 'Dealing cards';
  static const String yourTurn = 'Your turn';
  static const String waitingForPlayer = 'Waiting for player';
  static const String gameOver = 'Game Over';

  // Actions
  static const String draw = 'Draw';
  static const String discard = 'Discard';
  static const String declare = 'Declare';
  static const String visit = 'Visit';
  
  // Results
  static const String winner = 'Winner';
  static const String points = 'Points';
  static const String round = 'Round';
  static const String score = 'Score';

  // UI Labels
  static const String gameActions = 'Game Actions';
  static const String chat = 'Chat';
  static const String video = 'Video';
  static const String audio = 'Audio';
  static const String help = 'Help';

  // Warnings/Messages
  static const String reconnecting = 'Reconnecting...';
  static const String noSets = 'No sets declared yet';
  static const String tapToClose = 'Tap anywhere to close';
}

/// Locale-aware string provider
enum AppLocale { english, nepali }

class LocalizedStrings {
  static AppLocale _currentLocale = AppLocale.english;

  static AppLocale get currentLocale => _currentLocale;
  
  static void setLocale(AppLocale locale) {
    _currentLocale = locale;
  }

  // Helper to get localized string
  static String get(String englishKey, String nepaliKey) {
    return _currentLocale == AppLocale.nepali ? nepaliKey : englishKey;
  }

  // Convenience accessors
  static String get showSequence => _currentLocale == AppLocale.nepali 
      ? NepaliStrings.showSequence 
      : EnglishStrings.showSequence;
      
  static String get showDublee => _currentLocale == AppLocale.nepali 
      ? NepaliStrings.showDublee 
      : EnglishStrings.showDublee;
      
  static String get show7Dublees => _currentLocale == AppLocale.nepali 
      ? NepaliStrings.show7Dublees 
      : EnglishStrings.show7Dublees;
      
  static String get finishGame => _currentLocale == AppLocale.nepali 
      ? NepaliStrings.finishGame 
      : EnglishStrings.finishGame;
      
  static String get maalCard => _currentLocale == AppLocale.nepali 
      ? NepaliStrings.maalCard 
      : EnglishStrings.maalCard;
      
  static String get tiplu => _currentLocale == AppLocale.nepali 
      ? NepaliStrings.tiplu 
      : EnglishStrings.tiplu;
      
  static String get poplu => _currentLocale == AppLocale.nepali 
      ? NepaliStrings.poplu 
      : EnglishStrings.poplu;
      
  static String get jhiplu => _currentLocale == AppLocale.nepali 
      ? NepaliStrings.jhiplu 
      : EnglishStrings.jhiplu;
      
  static String get alter => _currentLocale == AppLocale.nepali 
      ? NepaliStrings.alter 
      : EnglishStrings.alter;
      
  static String get gameActions => _currentLocale == AppLocale.nepali 
      ? NepaliStrings.gameActions 
      : EnglishStrings.gameActions;
      
  static String get yourTurn => _currentLocale == AppLocale.nepali 
      ? NepaliStrings.yourTurn 
      : EnglishStrings.yourTurn;
      
  static String get winner => _currentLocale == AppLocale.nepali 
      ? NepaliStrings.winner 
      : EnglishStrings.winner;
      
  static String get reconnecting => _currentLocale == AppLocale.nepali 
      ? NepaliStrings.reconnecting 
      : EnglishStrings.reconnecting;
      
  static String get tapToClose => _currentLocale == AppLocale.nepali 
      ? NepaliStrings.tapToClose 
      : EnglishStrings.tapToClose;

  static String get noSets => _currentLocale == AppLocale.nepali 
      ? NepaliStrings.noSets 
      : EnglishStrings.noSets;

  static String get maal => _currentLocale == AppLocale.nepali 
      ? NepaliStrings.maal 
      : EnglishStrings.maal;

  static String get chat => _currentLocale == AppLocale.nepali 
      ? NepaliStrings.chat 
      : EnglishStrings.chat;

  static String get video => _currentLocale == AppLocale.nepali 
      ? NepaliStrings.video 
      : EnglishStrings.video;

  static String get audio => _currentLocale == AppLocale.nepali 
      ? NepaliStrings.audio 
      : EnglishStrings.audio;

  static String get help => _currentLocale == AppLocale.nepali 
      ? NepaliStrings.help 
      : EnglishStrings.help;

  static String get cancelAction => _currentLocale == AppLocale.nepali 
      ? NepaliStrings.cancelAction 
      : EnglishStrings.cancelAction;

  static String get getTunela => _currentLocale == AppLocale.nepali 
      ? NepaliStrings.getTunela 
      : EnglishStrings.getTunela;

  static String get settings => _currentLocale == AppLocale.nepali 
      ? NepaliStrings.settings 
      : EnglishStrings.settings;

  static String get quitGame => _currentLocale == AppLocale.nepali 
      ? NepaliStrings.quitGame 
      : EnglishStrings.quitGame;
}
