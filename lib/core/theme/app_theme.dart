import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // Brand Colors
  static const Color tableGreen = Color(0xFF1B5E20); // Darker Green for background
  static const Color tableLightGreen = Color(0xFF2E7D32); // Lighter green for gradients
  static const Color gold = Color(0xFFFFD700);
  static const Color goldDark = Color(0xFFFFA000);
  static const Color orange = Color(0xFFFF6F00);
  static const Color teal = Color(0xFF004D40);
  
  static const Color creamWhite = Color(0xFFF5F5F5);

  static ThemeData get theme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark, // Default to dark because of deep green usage
      
      // Color Scheme
      colorScheme: const ColorScheme(
        brightness: Brightness.dark,
        primary: tableGreen,
        onPrimary: Colors.white,
        secondary: gold,
        onSecondary: Colors.black,
        error: Colors.redAccent,
        onError: Colors.white,
        surface: teal,
        onSurface: creamWhite,
        tertiary: orange,
      ),

      scaffoldBackgroundColor: tableGreen,
      
      // Typography
      textTheme: TextTheme(
        // Headings (Game Titles, Modal Headers)
        displayLarge: GoogleFonts.lobster(
          fontSize: 57, 
          fontWeight: FontWeight.normal,
          color: gold,
        ),
        displayMedium: GoogleFonts.lobster(
          fontSize: 45,
          fontWeight: FontWeight.normal,
          color: creamWhite,
        ),
        displaySmall: GoogleFonts.lobster(
          fontSize: 36,
          fontWeight: FontWeight.normal,
          color: gold,
        ),
        
        // UI Headers
        headlineLarge: GoogleFonts.roboto(
          fontSize: 32,
          fontWeight: FontWeight.bold,
          color: creamWhite,
        ),
        headlineMedium: GoogleFonts.roboto(
          fontSize: 28,
          fontWeight: FontWeight.w600,
          color: gold,
        ),
        
        // Body Text
        bodyLarge: GoogleFonts.openSans(
          fontSize: 16,
          color: creamWhite,
        ),
        bodyMedium: GoogleFonts.openSans(
          fontSize: 14,
          color: creamWhite,
        ),
      ),

      // Component Themes
      
      // 1. App Bar
      appBarTheme: AppBarTheme(
        backgroundColor: tableGreen,
        foregroundColor: gold,
        centerTitle: true,
        titleTextStyle: GoogleFonts.lobster(
          fontSize: 28,
          color: gold,
        ),
        iconTheme: const IconThemeData(color: gold),
      ),

      // 2. Buttons
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          foregroundColor: Colors.black, // Text on Gold
          backgroundColor: gold,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30), // Pill shape common in casinos
            side: const BorderSide(color: goldDark, width: 2), // Bevel effect
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          textStyle: GoogleFonts.roboto(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
          elevation: 4,
        ),
      ),
      
      // 3. Dialogs
      dialogTheme: const DialogThemeData(
        backgroundColor: teal,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(16)),
          side: BorderSide(color: gold, width: 2),
        ),
      ),

      // 4. Cards
      cardTheme: CardThemeData(
        color: teal.withValues(alpha: 0.8),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: gold.withValues(alpha: 0.3), width: 1),
        ),
      ),
    );
  }
}
