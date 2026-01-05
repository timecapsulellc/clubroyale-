import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Casino-themed color palette for premium gaming experience
/// Aligned with ClubRoyale brand: Royal Purple + Gold
class CasinoColors {
  // Primary Colors - ClubRoyale Brand
  static const Color deepPurple = Color(0xFF2D1B4E); // ClubRoyale deep purple
  static const Color darkPurple = Color(0xFF1a0a2e); // Very dark purple
  static const Color richPurple = Color(0xFF4A1C6F); // ClubRoyale royal purple

  // Purple Table Colors
  // Green Felt Table Colors (Premium Theme - Bhoos Reference)
  static const Color tableGreenDark = Color(
    0xFF094531,
  ); // Deep radial green (Edge) - Bhoos style
  static const Color tableGreenMid = Color(0xFF0B5A3E); // Primary felt green
  static const Color tableGreenLight = Color(
    0xFF0E6D4A,
  ); // Center spotlight green

  // Legacy Purple Table Colors (Keep for other modes if needed, or deprecate)
  static const Color feltGreenDark = Color(0xFF1f1035); // Purple dark
  static const Color feltGreenMid = Color(0xFF3b2066); // Purple mid
  static const Color feltGreenLight = Color(0xFF5a3a87); // Purple light
  static const Color tableEdge = Color(0xFF3d2814); // Wood brown

  // Accent Colors - ClubRoyale Gold
  static const Color gold = Color(0xFFD4AF37); // ClubRoyale rich gold
  static const Color lightGold = Color(0xFFF7E7CE); // ClubRoyale champagne
  static const Color bronzeGold = Color(0xFFB8860B); // Dark gold bronze

  // Supporting Colors
  static const Color velvetRed = Color(0xFF8b0000);
  static const Color feltGreen = Color(0xFF4a2875); // Purple accent
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

  static const RadialGradient greenFeltGradient = RadialGradient(
    center: Alignment.center,
    radius: 1.2,
    colors: [tableGreenLight, tableGreenMid, tableGreenDark],
    stops: [0.0, 0.6, 1.0],
  );

  static const LinearGradient feltTableGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [feltGreenLight, feltGreenMid, feltGreenDark],
    stops: [0.0, 0.5, 1.0],
  );

  // Classic Casino Green Theme (Alternative)
  static const RadialGradient classicGreenFeltGradient = RadialGradient(
    center: Alignment.center,
    radius: 1.2,
    colors: [
      Color(0xFF1B5E20), // Light green center
      Color(0xFF0D4B14), // Mid green
      Color(0xFF042808), // Dark green edge
    ],
    stops: [0.0, 0.6, 1.0],
  );

  static const LinearGradient classicGreenTableGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xFF1B5E20), Color(0xFF0D4B14), Color(0xFF042808)],
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
  // Common Text Theme
  static TextTheme get _textTheme => TextTheme(
    displayLarge: GoogleFonts.oswald(
      fontSize: 57,
      fontWeight: FontWeight.bold,
      color: Colors.white,
    ),
    displayMedium: GoogleFonts.oswald(
      fontSize: 45,
      fontWeight: FontWeight.bold,
      color: Colors.white,
    ),
    displaySmall: GoogleFonts.oswald(
      fontSize: 36,
      fontWeight: FontWeight.bold,
      color: Colors.white,
    ),
    headlineLarge: GoogleFonts.oswald(
      fontSize: 32,
      fontWeight: FontWeight.bold,
      color: Colors.white,
    ),
    headlineMedium: GoogleFonts.oswald(
      fontSize: 28,
      fontWeight: FontWeight.bold,
      color: Colors.white,
    ),
    titleLarge: GoogleFonts.roboto(
      fontSize: 22,
      fontWeight: FontWeight.w500,
      color: Colors.white,
    ),
    titleMedium: GoogleFonts.roboto(
      fontSize: 16,
      fontWeight: FontWeight.w500,
      color: Colors.white,
    ),
    bodyLarge: GoogleFonts.roboto(
      fontSize: 16,
      fontWeight: FontWeight.normal,
      color: Colors.white,
    ),
    bodyMedium: GoogleFonts.roboto(
      fontSize: 14,
      fontWeight: FontWeight.normal,
      color: Colors.white70,
    ),
  );

  // ThemeData for Casino (Purple - Legacy/Default)
  static ThemeData get darkTheme => ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    scaffoldBackgroundColor: darkPurple,
    textTheme: _textTheme,
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
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        backgroundColor: gold,
        foregroundColor: darkPurple,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        textStyle: GoogleFonts.roboto(
          fontSize: 16,
          fontWeight: FontWeight.bold,
        ),
      ),
    ),
  );

  // ThemeData for Casino (Royal Green - Premium)
  static ThemeData get greenTheme => ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    scaffoldBackgroundColor: tableGreenDark,
    textTheme: _textTheme,
    colorScheme: ColorScheme.dark(
      primary: gold,
      secondary: tableGreenMid,
      surface: const Color(0xFF0F2B22), // Darker green surface
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.transparent,
      elevation: 0,
      foregroundColor: Colors.white,
    ),
    cardTheme: CardThemeData(
      color: const Color(0xFF0F2B22),
      elevation: 8,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        backgroundColor: gold,
        foregroundColor: tableGreenDark, // Dark text on gold
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        textStyle: GoogleFonts.roboto(
          fontSize: 16,
          fontWeight: FontWeight.bold,
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
