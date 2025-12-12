import 'package:flutter/material.dart';

/// Casino-themed color palette for premium gaming experience
/// Aligned with ClubRoyale brand: Royal Purple + Gold
class CasinoColors {
  // Primary Colors - ClubRoyale Brand
  static const Color deepPurple = Color(0xFF2D1B4E); // ClubRoyale deep purple
  static const Color darkPurple = Color(0xFF1a0a2e); // Very dark purple
  static const Color richPurple = Color(0xFF4A1C6F); // ClubRoyale royal purple
  
  // Purple Table Colors
  static const Color feltGreenDark = Color(0xFF1f1035);   // Purple dark
  static const Color feltGreenMid = Color(0xFF3b2066);    // Purple mid
  static const Color feltGreenLight = Color(0xFF5a3a87);  // Purple light
  static const Color tableEdge = Color(0xFF3d2814);       // Wood brown
  
  // Accent Colors - ClubRoyale Gold
  static const Color gold = Color(0xFFD4AF37);         // ClubRoyale rich gold
  static const Color lightGold = Color(0xFFF7E7CE);    // ClubRoyale champagne
  static const Color bronzeGold = Color(0xFFB8860B);   // Dark gold bronze
  
  // Supporting Colors
  static const Color velvetRed = Color(0xFF8b0000);
  static const Color feltGreen = Color(0xFF4a2875);    // Purple accent
  static const Color neonPink = Color(0xFFff1493);
  static const Color silverGray = Color(0xFF9e9e9e);
  
  // Surface Colors
  static const Color cardBackground = Color(0xFF251540); // Purple card bg
  static const Color cardBackgroundLight = Color(0xFF3a2560); // Lighter purple
  static const Color surfaceDark = Color(0xFF0a0514);

  
  // Gradients - Purple Theme
  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [feltGreenMid, feltGreenDark],
  );
  
  static const LinearGradient feltTableGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [feltGreenLight, feltGreenMid, feltGreenDark],
    stops: [0.0, 0.5, 1.0],
  );
  
  static const LinearGradient goldGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [lightGold, gold, bronzeGold],
  );
  
  static const LinearGradient cardGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [cardBackgroundLight, cardBackground],
  );
  
  static LinearGradient glassGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Colors.white.withValues(alpha: 0.15),
      Colors.white.withValues(alpha: 0.05),
    ],
  );
  
  // Box Shadows
  static List<BoxShadow> goldGlow = [
    BoxShadow(
      color: gold.withValues(alpha: 0.3),
      blurRadius: 12,
      spreadRadius: 2,
    ),
  ];
  
  static List<BoxShadow> cardShadow = [
    BoxShadow(
      color: Colors.black.withValues(alpha: 0.4),
      blurRadius: 16,
      offset: const Offset(0, 8),
    ),
  ];
  
  // ThemeData for Casino
  static ThemeData get darkTheme => ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    scaffoldBackgroundColor: darkPurple,
    colorScheme: ColorScheme.dark(
      primary: gold,
      secondary: richPurple,
      surface: cardBackground,
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.transparent,
      elevation: 0,
      foregroundColor: Colors.white,
    ),
    cardTheme: CardThemeData(
      color: cardBackground,
      elevation: 8,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        backgroundColor: gold,
        foregroundColor: darkPurple,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    ),
  );
}

/// Glassmorphism decoration for casino cards
class CasinoDecorations {
  static BoxDecoration glassCard({
    Color? borderColor,
    double borderWidth = 1,
    double borderRadius = 20,
  }) {
    return BoxDecoration(
      gradient: CasinoColors.glassGradient,
      borderRadius: BorderRadius.circular(borderRadius),
      border: Border.all(
        color: borderColor ?? CasinoColors.gold.withValues(alpha: 0.3),
        width: borderWidth,
      ),
      boxShadow: CasinoColors.cardShadow,
    );
  }
  
  static BoxDecoration goldAccentCard({double borderRadius = 20}) {
    return BoxDecoration(
      gradient: CasinoColors.cardGradient,
      borderRadius: BorderRadius.circular(borderRadius),
      border: Border.all(
        color: CasinoColors.gold.withValues(alpha: 0.5),
        width: 1.5,
      ),
      boxShadow: CasinoColors.goldGlow,
    );
  }
  
  static BoxDecoration neonBorderCard({
    required Color neonColor,
    double borderRadius = 20,
  }) {
    return BoxDecoration(
      color: CasinoColors.cardBackground,
      borderRadius: BorderRadius.circular(borderRadius),
      border: Border.all(color: neonColor.withValues(alpha: 0.8), width: 2),
      boxShadow: [
        BoxShadow(
          color: neonColor.withValues(alpha: 0.4),
          blurRadius: 12,
          spreadRadius: 1,
        ),
      ],
    );
  }
}
