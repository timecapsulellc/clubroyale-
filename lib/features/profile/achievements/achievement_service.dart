/// Achievement Service
///
/// Handles checking, unlocking, and tracking achievements
library;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:clubroyale/features/profile/user_profile.dart';
import 'package:clubroyale/features/profile/achievements/achievements_data.dart';

/// Provider for achievement service
final achievementServiceProvider = Provider<AchievementService>((ref) {
  return AchievementService();
});

/// User achievements state provider
final userAchievementsProvider =
    StreamProvider.family<List<Achievement>, String>((ref, userId) {
      return ref
          .watch(achievementServiceProvider)
          .watchUserAchievements(userId);
    });

/// Achievement Service
class AchievementService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Collection reference for user achievements
  CollectionReference<Map<String, dynamic>> _userAchievementsRef(
    String userId,
  ) {
    return _firestore
        .collection('users')
        .doc(userId)
        .collection('achievements');
  }

  /// Watch user's achievements in real-time
  Stream<List<Achievement>> watchUserAchievements(String userId) {
    return _userAchievementsRef(userId).snapshots().map((snapshot) {
      return snapshot.docs
          .map((doc) {
            final data = doc.data();
            final baseAchievement = AchievementsData.getById(doc.id);
            if (baseAchievement == null) return null;

            return baseAchievement.copyWith(
              isUnlocked: data['isUnlocked'] ?? false,
              progress: data['progress'] ?? 0,
              unlockedAt: data['unlockedAt'] != null
                  ? (data['unlockedAt'] as Timestamp).toDate()
                  : null,
            );
          })
          .whereType<Achievement>()
          .toList();
    });
  }

  /// Get user's achievement progress
  Future<Map<String, int>> getProgress(String userId) async {
    final snapshot = await _userAchievementsRef(userId).get();
    final progress = <String, int>{};

    for (final doc in snapshot.docs) {
      progress[doc.id] = doc.data()['progress'] ?? 0;
    }

    return progress;
  }

  /// Update achievement progress
  Future<bool> updateProgress({
    required String userId,
    required String achievementId,
    required int progress,
  }) async {
    try {
      final achievement = AchievementsData.getById(achievementId);
      if (achievement == null) return false;

      final isUnlocked = progress >= (achievement.maxProgress ?? 1);

      await _userAchievementsRef(userId).doc(achievementId).set({
        'progress': progress,
        'isUnlocked': isUnlocked,
        if (isUnlocked) 'unlockedAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      if (isUnlocked) {
        debugPrint('🏆 Achievement unlocked: ${achievement.title}');
      }

      return isUnlocked;
    } catch (e) {
      debugPrint('Error updating achievement: $e');
      return false;
    }
  }

  /// Increment achievement progress by 1
  Future<bool> incrementProgress({
    required String userId,
    required String achievementId,
  }) async {
    final currentProgress = await getProgress(userId);
    final current = currentProgress[achievementId] ?? 0;
    return updateProgress(
      userId: userId,
      achievementId: achievementId,
      progress: current + 1,
    );
  }

  /// Check and unlock achievement if conditions are met
  Future<void> checkGameWinAchievements({
    required String userId,
    required String gameType,
    required int totalWins,
    required int currentStreak,
  }) async {
    // Win count achievements
    if (totalWins >= 1)
      await updateProgress(
        userId: userId,
        achievementId: 'first_win',
        progress: 1,
      );
    if (totalWins >= 10)
      await updateProgress(
        userId: userId,
        achievementId: 'win_10',
        progress: totalWins,
      );
    if (totalWins >= 50)
      await updateProgress(
        userId: userId,
        achievementId: 'win_50',
        progress: totalWins,
      );
    if (totalWins >= 100)
      await updateProgress(
        userId: userId,
        achievementId: 'win_100',
        progress: totalWins,
      );
    if (totalWins >= 500)
      await updateProgress(
        userId: userId,
        achievementId: 'win_500',
        progress: totalWins,
      );

    // Game-specific achievements
    switch (gameType) {
      case 'marriage':
        await incrementProgress(
          userId: userId,
          achievementId: 'marriage_master',
        );
        break;
      case 'call_break':
        await incrementProgress(
          userId: userId,
          achievementId: 'call_break_ace',
        );
        break;
      case 'teen_patti':
        await incrementProgress(
          userId: userId,
          achievementId: 'teen_patti_king',
        );
        break;
    }

    // Streak achievements
    if (currentStreak >= 3)
      await updateProgress(
        userId: userId,
        achievementId: 'streak_3',
        progress: currentStreak,
      );
    if (currentStreak >= 7)
      await updateProgress(
        userId: userId,
        achievementId: 'streak_7',
        progress: currentStreak,
      );
  }

  /// Check social achievements
  Future<void> checkSocialAchievements({
    required String userId,
    required int friendCount,
    required int gamesHosted,
  }) async {
    if (friendCount >= 1)
      await updateProgress(
        userId: userId,
        achievementId: 'first_friend',
        progress: 1,
      );
    if (friendCount >= 10)
      await updateProgress(
        userId: userId,
        achievementId: 'friends_10',
        progress: friendCount,
      );
    if (friendCount >= 50)
      await updateProgress(
        userId: userId,
        achievementId: 'friends_50',
        progress: friendCount,
      );

    if (gamesHosted >= 5)
      await updateProgress(
        userId: userId,
        achievementId: 'host_5',
        progress: gamesHosted,
      );
    if (gamesHosted >= 25)
      await updateProgress(
        userId: userId,
        achievementId: 'host_25',
        progress: gamesHosted,
      );
  }

  /// Check daily streak achievements
  Future<void> checkDailyStreak({
    required String userId,
    required int consecutiveDays,
  }) async {
    if (consecutiveDays >= 7) {
      await updateProgress(
        userId: userId,
        achievementId: 'daily_7',
        progress: consecutiveDays,
      );
    }
    if (consecutiveDays >= 30) {
      await updateProgress(
        userId: userId,
        achievementId: 'daily_30',
        progress: consecutiveDays,
      );
    }
  }

  /// Grant special achievement (e.g., beta tester)
  Future<void> grantSpecialAchievement({
    required String userId,
    required String achievementId,
  }) async {
    await updateProgress(
      userId: userId,
      achievementId: achievementId,
      progress: 1,
    );
  }

  /// Get unlocked achievements count
  Future<int> getUnlockedCount(String userId) async {
    final snapshot = await _userAchievementsRef(
      userId,
    ).where('isUnlocked', isEqualTo: true).get();
    return snapshot.docs.length;
  }

  /// Get all achievements with user progress merged
  Future<List<Achievement>> getAllWithProgress(String userId) async {
    final userProgress = await getProgress(userId);
    final unlockedDocs = await _userAchievementsRef(
      userId,
    ).where('isUnlocked', isEqualTo: true).get();

    final unlockedIds = unlockedDocs.docs.map((d) => d.id).toSet();
    final unlockedDates = <String, DateTime>{};

    for (final doc in unlockedDocs.docs) {
      final data = doc.data();
      if (data['unlockedAt'] != null) {
        unlockedDates[doc.id] = (data['unlockedAt'] as Timestamp).toDate();
      }
    }

    return AchievementsData.allAchievements.map((achievement) {
      return achievement.copyWith(
        progress: userProgress[achievement.id] ?? 0,
        isUnlocked: unlockedIds.contains(achievement.id),
        unlockedAt: unlockedDates[achievement.id],
      );
    }).toList();
  }
}
