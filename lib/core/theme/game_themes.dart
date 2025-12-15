/// Game Themes and Card Skins
/// 
/// Defines available table themes and card customization options
/// for the ClubRoyale Game Store feature.
library;

import 'package:flutter/material.dart';

/// Available table themes for the game
enum GameTheme {
  forestGreen(
    id: 'forest_green',
    name: 'Forest Green',
    unlockLevel: 1,
    gradientColors: [Color(0xFF1A6B4A), Color(0xFF0D4A2E), Color(0xFF083323)],
    accentColor: Color(0xFFFFD700),
  ),
  midnight(
    id: 'midnight',
    name: 'Midnight Black',
    unlockLevel: 1,
    gradientColors: [Color(0xFF2C3E50), Color(0xFF1A252F), Color(0xFF0D1318)],
    accentColor: Color(0xFF3498DB),
  ),
  ocean(
    id: 'ocean',
    name: 'Ocean Blue',
    unlockLevel: 15,
    gradientColors: [Color(0xFF206A8C), Color(0xFF154360), Color(0xFF0B2F4A)],
    accentColor: Color(0xFF00D4FF),
  ),
  royal(
    id: 'royal',
    name: 'Royal Gold',
    unlockLevel: 30,
    gradientColors: [Color(0xFF8B6914), Color(0xFF5D4A0F), Color(0xFF3D310A)],
    accentColor: Color(0xFFFFD700),
  ),
  neonNight(
    id: 'neon_night',
    name: 'Neon Night',
    unlockLevel: 50,
    gradientColors: [Color(0xFF2D1B4E), Color(0xFF1A1033), Color(0xFF0D0819)],
    accentColor: Color(0xFFFF00FF),
  ),
  cherry(
    id: 'cherry',
    name: 'Cherry Blossom',
    unlockLevel: 40,
    gradientColors: [Color(0xFF8B3A62), Color(0xFF5C2647), Color(0xFF3D1930)],
    accentColor: Color(0xFFFFB6C1),
  );

  final String id;
  final String name;
  final int unlockLevel;
  final List<Color> gradientColors;
  final Color accentColor;

  const GameTheme({
    required this.id,
    required this.name,
    required this.unlockLevel,
    required this.gradientColors,
    required this.accentColor,
  });

  /// Check if theme is unlocked for a given user level
  bool isUnlocked(int userLevel) => userLevel >= unlockLevel;

  /// Get the primary background color
  Color get primaryColor => gradientColors.first;

  /// Get gradient decoration for the table
  LinearGradient get gradient => LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: gradientColors,
  );

  /// Find theme by ID
  static GameTheme fromId(String id) {
    return GameTheme.values.firstWhere(
      (theme) => theme.id == id,
      orElse: () => GameTheme.forestGreen,
    );
  }
}

/// Available card skins for customization
enum CardSkin {
  classic(
    id: 'classic',
    name: 'Classic',
    unlockLevel: 1,
    previewAsset: 'assets/cards/classic_preview.png',
    cardFaceStyle: CardFaceStyle.standard,
    cardBackColor: Color(0xFF1A6B4A),
  ),
  poker(
    id: 'poker',
    name: 'Poker Style',
    unlockLevel: 25,
    previewAsset: 'assets/cards/poker_preview.png',
    cardFaceStyle: CardFaceStyle.poker,
    cardBackColor: Color(0xFF8B0000),
  ),
  nepaliArt(
    id: 'nepali_art',
    name: 'Nepali Heritage',
    unlockLevel: 40,
    previewAsset: 'assets/cards/nepali_preview.png',
    cardFaceStyle: CardFaceStyle.nepali,
    cardBackColor: Color(0xFF4A2C6E),
    isExclusive: true, // ClubRoyale exclusive!

  ),
  minimalist(
    id: 'minimalist',
    name: 'Minimalist',
    unlockLevel: 20,
    previewAsset: 'assets/cards/minimalist_preview.png',
    cardFaceStyle: CardFaceStyle.minimalist,
    cardBackColor: Color(0xFF2C2C2C),
  ),
  gold(
    id: 'gold',
    name: 'Gold Edition',
    unlockLevel: 60,
    previewAsset: 'assets/cards/gold_preview.png',
    cardFaceStyle: CardFaceStyle.gold,
    cardBackColor: Color(0xFF8B6914),
    isExclusive: true,
  );

  final String id;
  final String name;
  final int unlockLevel;
  final String previewAsset;
  final CardFaceStyle cardFaceStyle;
  final Color cardBackColor;
  final bool isExclusive;

  const CardSkin({
    required this.id,
    required this.name,
    required this.unlockLevel,
    required this.previewAsset,
    required this.cardFaceStyle,
    required this.cardBackColor,
    this.isExclusive = false,
  });

  /// Check if skin is unlocked for a given user level
  bool isUnlocked(int userLevel) => userLevel >= unlockLevel;

  /// Find skin by ID
  static CardSkin fromId(String id) {
    return CardSkin.values.firstWhere(
      (skin) => skin.id == id,
      orElse: () => CardSkin.classic,
    );
  }
}

/// Card face rendering styles
enum CardFaceStyle {
  standard,   // Traditional card design
  poker,      // Casino-style with larger symbols
  nepali,     // Nepali cultural motifs
  minimalist, // Clean, modern design
  gold,       // Premium gold-trimmed design
}

/// User customization preferences
class UserCustomization {
  final GameTheme selectedTheme;
  final CardSkin selectedCardSkin;
  final List<String> unlockedThemeIds;
  final List<String> unlockedCardSkinIds;
  final int userLevel;

  const UserCustomization({
    this.selectedTheme = GameTheme.forestGreen,
    this.selectedCardSkin = CardSkin.classic,
    this.unlockedThemeIds = const ['forest_green', 'midnight'],
    this.unlockedCardSkinIds = const ['classic'],
    this.userLevel = 1,
  });

  /// Create from Firestore document data
  factory UserCustomization.fromMap(Map<String, dynamic> data) {
    return UserCustomization(
      selectedTheme: GameTheme.fromId(data['selectedTheme'] ?? 'forest_green'),
      selectedCardSkin: CardSkin.fromId(data['selectedCardSkin'] ?? 'classic'),
      unlockedThemeIds: List<String>.from(data['unlockedThemes'] ?? ['forest_green', 'midnight']),
      unlockedCardSkinIds: List<String>.from(data['unlockedCardSkins'] ?? ['classic']),
      userLevel: data['level'] ?? 1,
    );
  }

  /// Convert to Firestore document data
  Map<String, dynamic> toMap() {
    return {
      'selectedTheme': selectedTheme.id,
      'selectedCardSkin': selectedCardSkin.id,
      'unlockedThemes': unlockedThemeIds,
      'unlockedCardSkins': unlockedCardSkinIds,
      'level': userLevel,
    };
  }

  /// Check if a specific theme is unlocked
  bool isThemeUnlocked(GameTheme theme) {
    return unlockedThemeIds.contains(theme.id) || theme.isUnlocked(userLevel);
  }

  /// Check if a specific card skin is unlocked
  bool isCardSkinUnlocked(CardSkin skin) {
    return unlockedCardSkinIds.contains(skin.id) || skin.isUnlocked(userLevel);
  }

  /// Create a copy with updated values
  UserCustomization copyWith({
    GameTheme? selectedTheme,
    CardSkin? selectedCardSkin,
    List<String>? unlockedThemeIds,
    List<String>? unlockedCardSkinIds,
    int? userLevel,
  }) {
    return UserCustomization(
      selectedTheme: selectedTheme ?? this.selectedTheme,
      selectedCardSkin: selectedCardSkin ?? this.selectedCardSkin,
      unlockedThemeIds: unlockedThemeIds ?? this.unlockedThemeIds,
      unlockedCardSkinIds: unlockedCardSkinIds ?? this.unlockedCardSkinIds,
      userLevel: userLevel ?? this.userLevel,
    );
  }
}
