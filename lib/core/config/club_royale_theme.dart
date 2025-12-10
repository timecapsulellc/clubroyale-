import 'package:flutter/material.dart';

/// ClubRoyale Premium Theme
/// 
/// Elegant, sophisticated color palette for premium casino feel

class ClubRoyaleTheme {
  // ============ PRIMARY COLORS ============
  
  static const Color royalPurple = Color(0xFF4A1C6F);
  static const Color deepPurple = Color(0xFF2D1B4E);
  static const Color gold = Color(0xFFD4AF37);
  static const Color champagne = Color(0xFFF7E7CE);
  
  // ============ BACKGROUND COLORS ============
  
  static const Color feltGreen = Color(0xFF1B4D3E);
  static const Color feltGreenDark = Color(0xFF0F2E24);
  static const Color tableWood = Color(0xFF3E2723);
  
  // ============ CARD COLORS ============
  
  static const Color cardWhite = Color(0xFFFFFFF8);
  static const Color cardRed = Color(0xFFD32F2F);
  static const Color cardBlack = Color(0xFF212121);
  
  // ============ ACCENT COLORS ============
  
  static const Color success = Color(0xFF4CAF50);
  static const Color warning = Color(0xFFFF9800);
  static const Color error = Color(0xFFE53935);
  static const Color info = Color(0xFF2196F3);
  
  // ============ TEXT COLORS ============
  
  static const Color textLight = Color(0xFFFFFFFF);
  static const Color textGold = Color(0xFFD4AF37);
  static const Color textMuted = Color(0xFFB0B0B0);
  
  // ============ GRADIENTS ============
  
  static const LinearGradient royalGradient = LinearGradient(
    colors: [royalPurple, deepPurple],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  static const LinearGradient goldGradient = LinearGradient(
    colors: [Color(0xFFD4AF37), Color(0xFFF7E7CE), Color(0xFFD4AF37)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  static const LinearGradient feltGradient = LinearGradient(
    colors: [feltGreen, feltGreenDark],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );
  
  // ============ SHADOWS ============
  
  static List<BoxShadow> get goldGlow => [
    BoxShadow(
      color: gold.withValues(alpha: 0.4),
      blurRadius: 12,
      spreadRadius: 2,
    ),
  ];
  
  static List<BoxShadow> get cardShadow => [
    BoxShadow(
      color: Colors.black.withValues(alpha: 0.3),
      blurRadius: 8,
      offset: const Offset(2, 4),
    ),
  ];
  
  // ============ BORDER DECORATIONS ============
  
  static BoxDecoration get goldBorder => BoxDecoration(
    border: Border.all(color: gold, width: 2),
    borderRadius: BorderRadius.circular(12),
  );
  
  static BoxDecoration get premiumCard => BoxDecoration(
    color: deepPurple,
    borderRadius: BorderRadius.circular(16),
    border: Border.all(color: gold.withValues(alpha: 0.5)),
    boxShadow: cardShadow,
  );
  
  // ============ BUTTON STYLES ============
  
  static ButtonStyle get goldButton => ElevatedButton.styleFrom(
    backgroundColor: gold,
    foregroundColor: deepPurple,
    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
  );
  
  static ButtonStyle get royalButton => ElevatedButton.styleFrom(
    backgroundColor: royalPurple,
    foregroundColor: Colors.white,
    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
  );
  
  // ============ TEXT STYLES ============
  
  static const TextStyle headingLarge = TextStyle(
    fontSize: 28,
    fontWeight: FontWeight.bold,
    color: textLight,
    letterSpacing: 1.2,
  );
  
  static const TextStyle headingMedium = TextStyle(
    fontSize: 22,
    fontWeight: FontWeight.bold,
    color: textLight,
  );
  
  static const TextStyle headingGold = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.bold,
    color: gold,
    letterSpacing: 1.5,
  );
  
  static const TextStyle bodyText = TextStyle(
    fontSize: 16,
    color: textLight,
  );
  
  static const TextStyle caption = TextStyle(
    fontSize: 12,
    color: textMuted,
  );
  
  // ============ APP THEME ============
  
  static ThemeData get theme => ThemeData(
    primaryColor: royalPurple,
    scaffoldBackgroundColor: deepPurple,
    colorScheme: const ColorScheme.dark(
      primary: royalPurple,
      secondary: gold,
      surface: deepPurple,
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.transparent,
      elevation: 0,
      centerTitle: true,
      titleTextStyle: headingMedium,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(style: goldButton),
    cardTheme: const CardThemeData(
      color: deepPurple,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(16))),
    ),

    textTheme: const TextTheme(
      headlineLarge: headingLarge,
      headlineMedium: headingMedium,
      bodyLarge: bodyText,
      bodySmall: caption,
    ),
  );
}
