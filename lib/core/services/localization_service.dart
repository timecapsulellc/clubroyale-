import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum AppLocale {
  en, // English
  ne, // Nepali (Devanagari)
}

/// Provider for the current locale
final localeProvider = StateNotifierProvider<LocaleNotifier, AppLocale>((ref) {
  return LocaleNotifier();
});

/// Notifier to manage locale state
class LocaleNotifier extends StateNotifier<AppLocale> {
  LocaleNotifier() : super(AppLocale.en) {
    _loadLocale();
  }

  static const _keyLocale = 'app_locale';

  Future<void> _loadLocale() async {
    final prefs = await SharedPreferences.getInstance();
    final code = prefs.getString(_keyLocale);
    if (code == 'ne') {
      state = AppLocale.ne;
    } else {
      state = AppLocale.en;
    }
  }

  Future<void> setLocale(AppLocale locale) async {
    state = locale;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyLocale, locale.name);
  }
}

/// Localization strings
class AppStrings {
  static const Map<String, Map<AppLocale, String>> _values = {
    // --- General ---
    'app_name': {
      AppLocale.en: 'ClubRoyale',
      AppLocale.ne: 'क्लब रोयल',
    },
    'loading': {
      AppLocale.en: 'Loading...',
      AppLocale.ne: 'लोड हुँदैछ...',
    },
    'welcome': {
      AppLocale.en: 'Welcome',
      AppLocale.ne: 'स्वागतम',
    },
    'settings': {
      AppLocale.en: 'Settings',
      AppLocale.ne: 'सेटिङ',
    },
    'language': {
      AppLocale.en: 'Language',
      AppLocale.ne: 'भाषा',
    },
    'section_gameplay': {
      AppLocale.en: 'GAMEPLAY',
      AppLocale.ne: 'खेल मोड',
    },
    'section_social': {
      AppLocale.en: 'SOCIAL',
      AppLocale.ne: 'सामाजिक',
    },
    'section_audio': {
      AppLocale.en: 'AUDIO',
      AppLocale.ne: 'आवाज',
    },
    'section_appearance': {
      AppLocale.en: 'APPEARANCE',
      AppLocale.ne: 'रुपरेखा',
    },
    'section_support': {
      AppLocale.en: 'SUPPORT',
      AppLocale.ne: 'सहयोग',
    },
    'wallet': {
      AppLocale.en: 'WALLET',
      AppLocale.ne: 'वालेट',
    },
    'profile': {
      AppLocale.en: 'PROFILE',
      AppLocale.ne: 'प्रोफाइल',
    },
    
    // --- Game Modes ---
    'game_marriage': {
      AppLocale.en: 'Marriage',
      AppLocale.ne: 'म्यारिज',
    },
    'game_callbreak': {
      AppLocale.en: 'Call Break',
      AppLocale.ne: 'कल ब्रेक',
    },
    'game_teenpatti': {
      AppLocale.en: 'Teen Patti',
      AppLocale.ne: 'तीन पत्ती',
    },
    'game_inbetween': {
      AppLocale.en: 'In-Between',
      AppLocale.ne: 'इन्-बिटवीन',
    },
    
    // --- Lobby Buttons ---
    'play_now': {
      AppLocale.en: 'PLAY NOW',
      AppLocale.ne: 'खेल्नुहोस् (PLAY)',
    },
    'create': {
      AppLocale.en: 'Create',
      AppLocale.ne: 'बनाउनुहोस्',
    },
    'join_code': {
      AppLocale.en: 'Join Code',
      AppLocale.ne: 'कोड हाल्नुहोस्',
    },
    'active_tables': {
      AppLocale.en: 'ACTIVE TABLES',
      AppLocale.ne: 'सक्रिय खेलहरू',
    },
    'learn': {
      AppLocale.en: 'Learn',
      AppLocale.ne: 'सिक्नुहोस्',
    },
    'rankings': {
      AppLocale.en: 'Rankings',
      AppLocale.ne: 'वरियता (Ranking)',
    },
    
    // --- Utilities ---
    'feedback': {
      AppLocale.en: 'Feedback',
      AppLocale.ne: 'सुझाव',
    },
    'privacy': {
      AppLocale.en: 'Privacy',
      AppLocale.ne: 'गोपनीयता',
    },
    'tutorial': {
      AppLocale.en: 'Tutorial',
      AppLocale.ne: 'ट्यूटोरियल',
    },
    'other_games': {
      AppLocale.en: 'Other Games',
      AppLocale.ne: 'अन्य खेलहरू',
    },
    'account': {
      AppLocale.en: 'Account',
      AppLocale.ne: 'खाता',
    },
    'action_draw': {
      AppLocale.en: 'Draw',
      AppLocale.ne: 'तान्नुहोस्',
    },
    'action_discard': {
      AppLocale.en: 'Discard',
      AppLocale.ne: 'फाल्नुहोस्',
    },
    'action_pick': {
      AppLocale.en: 'Pick',
      AppLocale.ne: 'उठाउनुहोस्',
    },
    'action_finish': {
      AppLocale.en: 'Finish',
      AppLocale.ne: 'फिनिस',
    },
    'action_declare': {
      AppLocale.en: 'Declare',
      AppLocale.ne: 'शो (Show)',
    },
    'action_cancel': {
      AppLocale.en: 'Cancel',
      AppLocale.ne: 'रद्द',
    },
    'btn_dublee': {
      AppLocale.en: 'DUB',
      AppLocale.ne: 'डबल',
    },
    'btn_sequence': {
      AppLocale.en: 'SEQ',
      AppLocale.ne: 'क्रम',
    },
    'btn_show': {
      AppLocale.en: 'SHOW',
      AppLocale.ne: 'शो',
    },
    'btn_cancel': {
      AppLocale.en: 'CAN',
      AppLocale.ne: 'रद्द',
    },
    
    // --- Terminology ---
    'term_tiplu': {
      AppLocale.en: 'Tiplu',
      AppLocale.ne: 'तिप्लु',
    },
    'term_jhiplu': {
      AppLocale.en: 'Jhiplu',
      AppLocale.ne: 'झिप्लु',
    },
    'term_poplu': {
      AppLocale.en: 'Poplu',
      AppLocale.ne: 'पोप्लु',
    },
    'term_alter': {
      AppLocale.en: 'Alter',
      AppLocale.ne: 'अल्टर',
    },
    'term_mariage': {
      AppLocale.en: 'Marriage',
      AppLocale.ne: 'म्यारिज',
    },
    'term_tunnel': {
      AppLocale.en: 'Tunnel',
      AppLocale.ne: 'टनेल',
    },
    'term_sequence': {
      AppLocale.en: 'Sequence',
      AppLocale.ne: 'सिक्वेन्स',
    },
    'term_trial': {
      AppLocale.en: 'Trial',
      AppLocale.ne: 'ट्रायल',
    },
    'term_maal': {
      AppLocale.en: 'Maal',
      AppLocale.ne: 'माल',
    },
    
    // --- Messages ---
    'msg_your_turn': {
      AppLocale.en: "It's Your Turn!",
      AppLocale.ne: "तपाईंको पालो!",
    },
    'msg_waiting': {
      AppLocale.en: 'Waiting for others...',
      AppLocale.ne: 'अरूको पालो कुर्दै...',
    },
    'msg_winner': {
      AppLocale.en: 'Winner',
      AppLocale.ne: 'विजेता',
    },
    'msg_game_over': {
      AppLocale.en: 'Game Over',
      AppLocale.ne: 'खेल समाप्त',
    },
  };

  /// Get localized string manually
  static String get(String key, AppLocale locale) {
    if (!_values.containsKey(key)) return key;
    return _values[key]![locale] ?? _values[key]![AppLocale.en] ?? key;
  }
}

/// Extension for easier usage in Widgets
extension LocalizationExt on String {
  /// Usage: 'key_name'.tr(ref)
  String tr(WidgetRef ref) {
    final locale = ref.watch(localeProvider);
    return AppStrings.get(this, locale);
  }
}
