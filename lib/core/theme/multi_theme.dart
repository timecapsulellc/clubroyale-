import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Available theme presets for ClubRoyale
enum ThemePreset {
  royalPurple, // Current default - Purple & Gold
  royalGreen, // Royal Green & Gold (new!)
  midnight, // Dark Blue & Silver
  crimson, // Red & Gold
  emerald, // Emerald & Champagne
}

/// Theme mode (light/dark)
enum AppThemeMode { light, dark, system }

/// Theme state model
class ThemeState {
  final ThemePreset preset;
  final AppThemeMode mode;

  const ThemeState({
    this.preset = ThemePreset.royalGreen, // Default to Royal Green + Gold
    this.mode = AppThemeMode.dark,
  });

  ThemeState copyWith({ThemePreset? preset, AppThemeMode? mode}) {
    return ThemeState(preset: preset ?? this.preset, mode: mode ?? this.mode);
  }
}

/// Theme provider for managing app theme state
class ThemeNotifier extends Notifier<ThemeState> {
  @override
  ThemeState build() {
    _loadFromPrefs();
    return const ThemeState();
  }

  Future<void> _loadFromPrefs() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final presetIndex =
          prefs.getInt('theme_preset') ?? 1; // Default to royalGreen
      final modeIndex = prefs.getInt('theme_mode') ?? 1; // Default to dark

      state = ThemeState(
        preset: ThemePreset
            .values[presetIndex.clamp(0, ThemePreset.values.length - 1)],
        mode: AppThemeMode
            .values[modeIndex.clamp(0, AppThemeMode.values.length - 1)],
      );
    } catch (e) {
      // Use defaults
    }
  }

  Future<void> setPreset(ThemePreset preset) async {
    state = state.copyWith(preset: preset);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('theme_preset', preset.index);
  }

  Future<void> setMode(AppThemeMode mode) async {
    state = state.copyWith(mode: mode);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('theme_mode', mode.index);
  }

  void toggleDarkMode() {
    setMode(
      state.mode == AppThemeMode.dark ? AppThemeMode.light : AppThemeMode.dark,
    );
  }
}

/// Provider for theme state
final themeProvider = NotifierProvider<ThemeNotifier, ThemeState>(() {
  return ThemeNotifier();
});

/// Theme colors for each preset
class ThemeColors {
  final Color primary;
  final Color secondary;
  final Color accent;
  final Color background;
  final Color surface;
  final Color surfaceLight;
  final Color gold;
  final Color textPrimary;
  final Color textSecondary;
  final LinearGradient primaryGradient;
  final LinearGradient accentGradient;

  const ThemeColors({
    required this.primary,
    required this.secondary,
    required this.accent,
    required this.background,
    required this.surface,
    required this.surfaceLight,
    required this.gold,
    required this.textPrimary,
    required this.textSecondary,
    required this.primaryGradient,
    required this.accentGradient,
  });

  // ========== ROYAL GREEN + GOLD (NEW DEFAULT) ==========
  static const royalGreen = ThemeColors(
    primary: Color(0xFFD4AF37), // Gold is primary for actions
    secondary: Color(0xFF1B7A4E), // Rich green secondary
    accent: Color(0xFFD4AF37), // Classic gold
    background: Color(0xFF0D3B2E), // Deep radial green (Edge) - from CasinoColors
    surface: Color(0xFF165B47), // Table green mid
    surfaceLight: Color(0xFF1F7A5E), // Table green light
    gold: Color(0xFFD4AF37), // Gold accents
    textPrimary: Color(0xFFFFFFFF),
    textSecondary: Color(0xFFB8D4C8),
    primaryGradient: LinearGradient(
      colors: [Color(0xFF165B47), Color(0xFF0D3B2E)],
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
    ),
    accentGradient: LinearGradient(
      colors: [Color(0xFFD4AF37), Color(0xFFF7E7CE), Color(0xFFD4AF37)],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    ),
  );

  // ========== ROYAL PURPLE + GOLD (CURRENT) ==========
  static const royalPurple = ThemeColors(
    primary: Color(0xFF4A1C6F), // Royal purple
    secondary: Color(0xFF6B21A8), // Vibrant purple
    accent: Color(0xFFD4AF37), // Classic gold
    background: Color(0xFF0D051A), // Very dark purple
    surface: Color(0xFF1A0A2E), // Dark purple card bg
    surfaceLight: Color(0xFF2D1B4E), // Lighter purple
    gold: Color(0xFFD4AF37),
    textPrimary: Color(0xFFFFFFFF),
    textSecondary: Color(0xFFB8A8D4),
    primaryGradient: LinearGradient(
      colors: [Color(0xFF6B21A8), Color(0xFF4A1C6F), Color(0xFF1A0A2E)],
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
    ),
    accentGradient: LinearGradient(
      colors: [Color(0xFFD4AF37), Color(0xFFF7E7CE), Color(0xFFD4AF37)],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    ),
  );

  // ========== MIDNIGHT BLUE + SILVER ==========
  static const midnight = ThemeColors(
    primary: Color(0xFF1A237E), // Deep blue
    secondary: Color(0xFF3949AB), // Indigo
    accent: Color(0xFFB0BEC5), // Silver
    background: Color(0xFF0A0E1A), // Very dark blue
    surface: Color(0xFF121830), // Dark blue card bg
    surfaceLight: Color(0xFF1E2746), // Lighter blue
    gold: Color(0xFFC0C0C0), // Silver instead of gold
    textPrimary: Color(0xFFFFFFFF),
    textSecondary: Color(0xFFB0BEC5),
    primaryGradient: LinearGradient(
      colors: [Color(0xFF3949AB), Color(0xFF1A237E), Color(0xFF0A0E1A)],
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
    ),
    accentGradient: LinearGradient(
      colors: [Color(0xFFCFD8DC), Color(0xFFB0BEC5), Color(0xFF90A4AE)],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    ),
  );

  // ========== CRIMSON + GOLD ==========
  static const crimson = ThemeColors(
    primary: Color(0xFF8B0000), // Dark red
    secondary: Color(0xFFB71C1C), // Crimson
    accent: Color(0xFFD4AF37), // Classic gold
    background: Color(0xFF1A0505), // Very dark red
    surface: Color(0xFF2D0A0A), // Dark red card bg
    surfaceLight: Color(0xFF4A1515), // Lighter red
    gold: Color(0xFFD4AF37),
    textPrimary: Color(0xFFFFFFFF),
    textSecondary: Color(0xFFD4B8B8),
    primaryGradient: LinearGradient(
      colors: [Color(0xFFB71C1C), Color(0xFF8B0000), Color(0xFF1A0505)],
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
    ),
    accentGradient: LinearGradient(
      colors: [Color(0xFFD4AF37), Color(0xFFF7E7CE), Color(0xFFD4AF37)],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    ),
  );

  // ========== EMERALD + CHAMPAGNE ==========
  static const emerald = ThemeColors(
    primary: Color(0xFF004D40), // Teal
    secondary: Color(0xFF00695C), // Emerald
    accent: Color(0xFFF7E7CE), // Champagne
    background: Color(0xFF001A14), // Very dark teal
    surface: Color(0xFF002E26), // Dark teal card bg
    surfaceLight: Color(0xFF00473C), // Lighter teal
    gold: Color(0xFFF7E7CE), // Champagne accents
    textPrimary: Color(0xFFFFFFFF),
    textSecondary: Color(0xFFB2DFDB),
    primaryGradient: LinearGradient(
      colors: [Color(0xFF00695C), Color(0xFF004D40), Color(0xFF001A14)],
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
    ),
    accentGradient: LinearGradient(
      colors: [Color(0xFFF7E7CE), Color(0xFFFFECB3), Color(0xFFF7E7CE)],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    ),
  );

  /// Get colors for a preset
  static ThemeColors forPreset(ThemePreset preset) {
    switch (preset) {
      case ThemePreset.royalPurple:
        return royalPurple;
      case ThemePreset.royalGreen:
        return royalGreen;
      case ThemePreset.midnight:
        return midnight;
      case ThemePreset.crimson:
        return crimson;
      case ThemePreset.emerald:
        return emerald;
    }
  }
}

/// Build Material ThemeData from ThemeColors
class ThemeBuilder {
  static ThemeData buildDarkTheme(ThemeColors colors) {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      primaryColor: colors.primary,
      scaffoldBackgroundColor: colors.background,
      
      // Premium Typography
      textTheme: TextTheme(
        displayLarge: GoogleFonts.oswald(fontSize: 57, fontWeight: FontWeight.bold, color: colors.textPrimary),
        displayMedium: GoogleFonts.oswald(fontSize: 45, fontWeight: FontWeight.bold, color: colors.textPrimary), // Headlines
        displaySmall: GoogleFonts.oswald(fontSize: 36, fontWeight: FontWeight.bold, color: colors.textPrimary),
        headlineLarge: GoogleFonts.oswald(fontSize: 32, fontWeight: FontWeight.bold, color: colors.textPrimary),
        headlineMedium: GoogleFonts.oswald(fontSize: 28, fontWeight: FontWeight.bold, color: colors.textPrimary),
        titleLarge: GoogleFonts.roboto(fontSize: 22, fontWeight: FontWeight.w500, color: colors.textPrimary), // AppBars/Dialog Titles
        titleMedium: GoogleFonts.roboto(fontSize: 16, fontWeight: FontWeight.w500, color: colors.textPrimary),
        bodyLarge: GoogleFonts.roboto(fontSize: 16, fontWeight: FontWeight.normal, color: colors.textPrimary),
        bodyMedium: GoogleFonts.roboto(fontSize: 14, fontWeight: FontWeight.normal, color: colors.textSecondary),
      ),

      colorScheme: ColorScheme.dark(
        primary: colors.accent,
        secondary: colors.secondary,
        surface: colors.surface,
        onPrimary: colors.background,
        onSecondary: Colors.white,
        onSurface: colors.textPrimary,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
      ),
      cardTheme: CardThemeData(
        color: colors.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        elevation: 8,
        shadowColor: Colors.black.withValues(alpha: 0.4),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: colors.gold,
          foregroundColor: colors.background,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          textStyle: GoogleFonts.roboto(fontSize: 16, fontWeight: FontWeight.bold),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: colors.gold,
          textStyle: GoogleFonts.roboto(fontSize: 14, fontWeight: FontWeight.bold),
        ),
      ),
      iconTheme: IconThemeData(color: colors.textPrimary),
      dividerColor: colors.surfaceLight,
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: colors.surface,
        selectedItemColor: colors.gold,
        unselectedItemColor: colors.textSecondary,
        selectedLabelStyle: GoogleFonts.roboto(fontSize: 12, fontWeight: FontWeight.bold),
        unselectedLabelStyle: GoogleFonts.roboto(fontSize: 12),
      ),
    );
  }

  static ThemeData buildLightTheme(ThemeColors colors) {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      primaryColor: colors.primary,
      scaffoldBackgroundColor: Colors.white,
      colorScheme: ColorScheme.light(
        primary: colors.primary,
        secondary: colors.secondary,
        surface: Colors.grey[100]!,
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onSurface: Colors.black87,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: colors.primary,
        elevation: 0,
        centerTitle: true,
        foregroundColor: Colors.white,
      ),
      cardTheme: CardThemeData(
        color: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        elevation: 2,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: colors.primary,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }

  static ThemeData getTheme(ThemeState state) {
    final colors = ThemeColors.forPreset(state.preset);

    switch (state.mode) {
      case AppThemeMode.light:
        return buildLightTheme(colors);
      case AppThemeMode.dark:
        return buildDarkTheme(colors);
      case AppThemeMode.system:
        return buildDarkTheme(colors); // Default to dark for casino feel
    }
  }
}

/// Extension to get current theme colors from context
///
/// Usage: `context.themeColors.primary` or use `ref.watch(themeColorsProvider)`
extension ThemeColorsExtension on BuildContext {
  /// Get theme colors - requires ProviderScope in widget tree
  /// Falls back to royalGreen if provider not found
  ThemeColors get themeColors {
    try {
      final container = ProviderScope.containerOf(this);
      return container.read(themeColorsProvider);
    } catch (_) {
      // Fallback for widgets outside ProviderScope
      return ThemeColors.royalGreen;
    }
  }

  /// Quick accessor for primary gradient
  LinearGradient get primaryGradient => themeColors.primaryGradient;

  /// Quick accessor for gold/accent color
  Color get accentGold => themeColors.gold;
}

/// Provider to get current theme colors
final themeColorsProvider = Provider<ThemeColors>((ref) {
  final state = ref.watch(themeProvider);
  return ThemeColors.forPreset(state.preset);
});

/// Provider to get current ThemeData
final themeDataProvider = Provider<ThemeData>((ref) {
  final state = ref.watch(themeProvider);
  return ThemeBuilder.getTheme(state);
});

/// Names and icons for theme presets
class ThemePresetInfo {
  static String getName(ThemePreset preset) {
    switch (preset) {
      case ThemePreset.royalPurple:
        return 'Royal Purple';
      case ThemePreset.royalGreen:
        return 'Royal Green';
      case ThemePreset.midnight:
        return 'Midnight Blue';
      case ThemePreset.crimson:
        return 'Crimson';
      case ThemePreset.emerald:
        return 'Emerald';
    }
  }

  static Color getPreviewColor(ThemePreset preset) {
    switch (preset) {
      case ThemePreset.royalPurple:
        return const Color(0xFF6B21A8);
      case ThemePreset.royalGreen:
        return const Color(0xFF1B7A4E);
      case ThemePreset.midnight:
        return const Color(0xFF3949AB);
      case ThemePreset.crimson:
        return const Color(0xFFB71C1C);
      case ThemePreset.emerald:
        return const Color(0xFF00695C);
    }
  }

  static Color getAccentColor(ThemePreset preset) {
    switch (preset) {
      case ThemePreset.royalPurple:
      case ThemePreset.royalGreen:
      case ThemePreset.crimson:
        return const Color(0xFFD4AF37); // Gold
      case ThemePreset.midnight:
        return const Color(0xFFB0BEC5); // Silver
      case ThemePreset.emerald:
        return const Color(0xFFF7E7CE); // Champagne
    }
  }
}
