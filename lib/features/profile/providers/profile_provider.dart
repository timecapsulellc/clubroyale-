import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:clubroyale/features/auth/auth_service.dart';

class UserProfile {
  final String id;
  final String displayName;
  final String avatarUrl;
  final int level;
  final int rank;
  final int totalGames;
  final double winRate;

  const UserProfile({
    required this.id,
    required this.displayName,
    required this.avatarUrl,
    this.level = 1,
    this.rank = 0,
    this.totalGames = 0,
    this.winRate = 0.0,
  });
}

final userProfileProvider = FutureProvider<UserProfile?>((ref) async {
  final userId = ref.watch(currentUserIdProvider);
  if (userId == null) return null;

  // Return dummy data for now to fix build
  return UserProfile(
    id: userId,
    displayName: 'Player',
    avatarUrl: 'assets/avatars/default.png',
    level: 12,
    rank: 450,
    totalGames: 102,
    winRate: 0.54,
  );
});
