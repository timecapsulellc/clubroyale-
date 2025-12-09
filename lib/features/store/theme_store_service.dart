/// Theme Store Service
/// 
/// Manages user customization preferences in Firestore
/// for table themes and card skins.

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:taasclub/core/theme/game_themes.dart';
import 'package:taasclub/features/auth/auth_service.dart';

/// Provider for the theme store service
final themeStoreServiceProvider = Provider<ThemeStoreService>((ref) {
  return ThemeStoreService(
    firestore: FirebaseFirestore.instance,
    authService: ref.watch(authServiceProvider),
  );
});

/// Service for managing user theme/skin preferences
class ThemeStoreService {
  final FirebaseFirestore firestore;
  final AuthService authService;

  ThemeStoreService({
    required this.firestore,
    required this.authService,
  });

  /// Get the current user's customization preferences
  Future<UserCustomization> getUserCustomization() async {
    final userId = authService.currentUser?.uid;
    if (userId == null) {
      return const UserCustomization(); // Default for anonymous users
    }

    try {
      final doc = await firestore.collection('users').doc(userId).get();
      if (!doc.exists) {
        return const UserCustomization();
      }
      return UserCustomization.fromMap(doc.data() ?? {});
    } catch (e) {
      return const UserCustomization();
    }
  }

  /// Stream of user customization changes
  Stream<UserCustomization> watchUserCustomization() {
    final userId = authService.currentUser?.uid;
    if (userId == null) {
      return Stream.value(const UserCustomization());
    }

    return firestore
        .collection('users')
        .doc(userId)
        .snapshots()
        .map((doc) {
          if (!doc.exists) return const UserCustomization();
          return UserCustomization.fromMap(doc.data() ?? {});
        });
  }

  /// Update the selected theme
  Future<void> selectTheme(GameTheme theme) async {
    final userId = authService.currentUser?.uid;
    if (userId == null) return;

    await firestore.collection('users').doc(userId).set({
      'selectedTheme': theme.id,
    }, SetOptions(merge: true));
  }

  /// Update the selected card skin
  Future<void> selectCardSkin(CardSkin skin) async {
    final userId = authService.currentUser?.uid;
    if (userId == null) return;

    await firestore.collection('users').doc(userId).set({
      'selectedCardSkin': skin.id,
    }, SetOptions(merge: true));
  }

  /// Unlock a theme for the user
  Future<void> unlockTheme(GameTheme theme) async {
    final userId = authService.currentUser?.uid;
    if (userId == null) return;

    await firestore.collection('users').doc(userId).set({
      'unlockedThemes': FieldValue.arrayUnion([theme.id]),
    }, SetOptions(merge: true));
  }

  /// Unlock a card skin for the user
  Future<void> unlockCardSkin(CardSkin skin) async {
    final userId = authService.currentUser?.uid;
    if (userId == null) return;

    await firestore.collection('users').doc(userId).set({
      'unlockedCardSkins': FieldValue.arrayUnion([skin.id]),
    }, SetOptions(merge: true));
  }

  /// Get the user's current level
  Future<int> getUserLevel() async {
    final userId = authService.currentUser?.uid;
    if (userId == null) return 1;

    try {
      final doc = await firestore.collection('users').doc(userId).get();
      return doc.data()?['level'] ?? 1;
    } catch (e) {
      return 1;
    }
  }
}
