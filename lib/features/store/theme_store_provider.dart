/// Theme Store Providers
///
/// Riverpod providers for managing selected theme and card skin state.
library;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:clubroyale/core/theme/game_themes.dart';
import 'package:clubroyale/features/store/theme_store_service.dart';

/// Provider for the current user's customization (stream-based)
final userCustomizationProvider = StreamProvider<UserCustomization>((ref) {
  final service = ref.watch(themeStoreServiceProvider);
  return service.watchUserCustomization();
});

/// Provider for the currently selected theme
final selectedThemeProvider = Provider<GameTheme>((ref) {
  final customization = ref.watch(userCustomizationProvider);
  return customization.when(
    data: (data) => data.selectedTheme,
    loading: () => GameTheme.forestGreen,
    error: (e, st) => GameTheme.forestGreen,
  );
});

/// Provider for the currently selected card skin
final selectedCardSkinProvider = Provider<CardSkin>((ref) {
  final customization = ref.watch(userCustomizationProvider);
  return customization.when(
    data: (data) => data.selectedCardSkin,
    loading: () => CardSkin.classic,
    error: (e, st) => CardSkin.classic,
  );
});

/// Provider for the user's level
final userLevelProvider = Provider<int>((ref) {
  final customization = ref.watch(userCustomizationProvider);
  return customization.when(
    data: (data) => data.userLevel,
    loading: () => 1,
    error: (e, st) => 1,
  );
});

/// Notifier for theme selection actions
class ThemeSelectionNotifier extends Notifier<AsyncValue<void>> {
  @override
  AsyncValue<void> build() => const AsyncValue.data(null);

  Future<void> selectTheme(GameTheme theme) async {
    state = const AsyncValue.loading();
    try {
      final service = ref.read(themeStoreServiceProvider);
      await service.selectTheme(theme);
      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> selectCardSkin(CardSkin skin) async {
    state = const AsyncValue.loading();
    try {
      final service = ref.read(themeStoreServiceProvider);
      await service.selectCardSkin(skin);
      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }
}

/// Provider for theme selection actions
final themeSelectionProvider =
    NotifierProvider<ThemeSelectionNotifier, AsyncValue<void>>(
      ThemeSelectionNotifier.new,
    );
