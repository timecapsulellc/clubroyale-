import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:taasclub/features/profile/user_profile.dart';
import 'package:taasclub/features/auth/auth_service.dart';

/// Profile service provider
final profileServiceProvider = Provider<ProfileService>((ref) => ProfileService(ref));

/// Current user's profile stream
final myProfileProvider = StreamProvider<UserProfile?>((ref) {
  final userId = ref.watch(currentUserIdProvider);
  if (userId == null) return Stream.value(null);
  return ref.watch(profileServiceProvider).getProfileStream(userId);
});

/// Profile by ID provider
final profileByIdProvider = StreamProvider.family<UserProfile?, String>((ref, userId) {
  return ref.watch(profileServiceProvider).getProfileStream(userId);
});

/// Followers list provider
final followersProvider = StreamProvider.family<List<UserProfile>, String>((ref, userId) {
  return ref.watch(profileServiceProvider).getFollowers(userId);
});

/// Following list provider
final followingProvider = StreamProvider.family<List<UserProfile>, String>((ref, userId) {
  return ref.watch(profileServiceProvider).getFollowing(userId);
});

/// User posts provider
final userPostsProvider = StreamProvider.family<List<UserPost>, String>((ref, userId) {
  return ref.watch(profileServiceProvider).getUserPosts(userId);
});

/// Check if current user follows another user
final isFollowingProvider = FutureProvider.family<bool, String>((ref, userId) {
  return ref.watch(profileServiceProvider).isFollowing(userId);
});

/// Enhanced profile service with social features
class ProfileService {
  final Ref ref;
  final FirebaseFirestore _firestore;

  ProfileService(this.ref) : _firestore = FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _profilesRef =>
      _firestore.collection('profiles');

  CollectionReference<Map<String, dynamic>> get _postsRef =>
      _firestore.collection('posts');

  // ==================== PROFILE CRUD ====================

  /// Get profile stream
  Stream<UserProfile?> getProfileStream(String userId) {
    return _profilesRef.doc(userId).snapshots().map((doc) {
      if (!doc.exists) return null;
      return _profileFromDoc(doc);
    });
  }

  /// Get profile once
  Future<UserProfile?> getProfile(String userId) async {
    final doc = await _profilesRef.doc(userId).get();
    if (!doc.exists) return null;
    return _profileFromDoc(doc);
  }

  /// Create or update profile
  Future<void> saveProfile(UserProfile profile) async {
    await _profilesRef.doc(profile.id).set(
      _profileToFirestore(profile),
      SetOptions(merge: true),
    );
  }

  /// Alias for saveProfile (backward compatibility)
  Future<void> updateProfile(UserProfile profile) => saveProfile(profile);

  /// Update specific profile fields
  Future<void> updateProfileFields(String userId, Map<String, dynamic> fields) async {
    await _profilesRef.doc(userId).update(fields);
  }

  // ==================== FOLLOW SYSTEM ====================

  /// Follow a user
  Future<void> followUser(String targetUserId) async {
    final currentUserId = ref.read(currentUserIdProvider);
    if (currentUserId == null || currentUserId == targetUserId) return;

    final batch = _firestore.batch();

    // Add to current user's following
    batch.set(
      _profilesRef.doc(currentUserId).collection('following').doc(targetUserId),
      {
        'followerId': currentUserId,
        'followingId': targetUserId,
        'followedAt': FieldValue.serverTimestamp(),
        'isCloseFriend': false,
        'isMuted': false,
      },
    );

    // Add to target user's followers
    batch.set(
      _profilesRef.doc(targetUserId).collection('followers').doc(currentUserId),
      {
        'followerId': currentUserId,
        'followingId': targetUserId,
        'followedAt': FieldValue.serverTimestamp(),
      },
    );

    // Update counts
    batch.update(_profilesRef.doc(currentUserId), {
      'followingCount': FieldValue.increment(1),
    });
    batch.update(_profilesRef.doc(targetUserId), {
      'followersCount': FieldValue.increment(1),
    });

    await batch.commit();
  }

  /// Unfollow a user
  Future<void> unfollowUser(String targetUserId) async {
    final currentUserId = ref.read(currentUserIdProvider);
    if (currentUserId == null) return;

    final batch = _firestore.batch();

    // Remove from current user's following
    batch.delete(
      _profilesRef.doc(currentUserId).collection('following').doc(targetUserId),
    );

    // Remove from target user's followers
    batch.delete(
      _profilesRef.doc(targetUserId).collection('followers').doc(currentUserId),
    );

    // Update counts
    batch.update(_profilesRef.doc(currentUserId), {
      'followingCount': FieldValue.increment(-1),
    });
    batch.update(_profilesRef.doc(targetUserId), {
      'followersCount': FieldValue.increment(-1),
    });

    await batch.commit();
  }

  /// Check if current user follows a user
  Future<bool> isFollowing(String targetUserId) async {
    final currentUserId = ref.read(currentUserIdProvider);
    if (currentUserId == null) return false;

    final doc = await _profilesRef
        .doc(currentUserId)
        .collection('following')
        .doc(targetUserId)
        .get();

    return doc.exists;
  }

  /// Get followers of a user
  Stream<List<UserProfile>> getFollowers(String userId) {
    return _profilesRef
        .doc(userId)
        .collection('followers')
        .orderBy('followedAt', descending: true)
        .snapshots()
        .asyncMap((snapshot) async {
          final profiles = <UserProfile>[];
          for (final doc in snapshot.docs) {
            final profile = await getProfile(doc.id);
            if (profile != null) profiles.add(profile);
          }
          return profiles;
        });
  }

  /// Get users that a user is following
  Stream<List<UserProfile>> getFollowing(String userId) {
    return _profilesRef
        .doc(userId)
        .collection('following')
        .orderBy('followedAt', descending: true)
        .snapshots()
        .asyncMap((snapshot) async {
          final profiles = <UserProfile>[];
          for (final doc in snapshot.docs) {
            final profile = await getProfile(doc.id);
            if (profile != null) profiles.add(profile);
          }
          return profiles;
        });
  }

  /// Toggle close friend status
  Future<void> toggleCloseFriend(String targetUserId) async {
    final currentUserId = ref.read(currentUserIdProvider);
    if (currentUserId == null) return;

    final doc = await _profilesRef
        .doc(currentUserId)
        .collection('following')
        .doc(targetUserId)
        .get();

    if (doc.exists) {
      final isCloseFriend = doc.data()?['isCloseFriend'] as bool? ?? false;
      await doc.reference.update({'isCloseFriend': !isCloseFriend});
    }
  }

  // ==================== POSTS ====================

  /// Create a new post
  Future<UserPost> createPost({
    required String content,
    String? mediaUrl,
    PostMediaType mediaType = PostMediaType.none,
    String? gameId,
    String? gameType,
  }) async {
    final currentUserId = ref.read(currentUserIdProvider);
    final userProfile = ref.read(authStateProvider).value;

    if (currentUserId == null) {
      throw Exception('User not authenticated');
    }

    final postDoc = _postsRef.doc();
    final now = DateTime.now();

    final post = UserPost(
      id: postDoc.id,
      userId: currentUserId,
      userName: userProfile?.displayName ?? 'User',
      userAvatarUrl: userProfile?.photoURL,
      content: content,
      mediaUrl: mediaUrl,
      mediaType: mediaType,
      createdAt: now,
      gameId: gameId,
      gameType: gameType,
    );

    await postDoc.set(_postToFirestore(post));

    // Update post count
    await _profilesRef.doc(currentUserId).update({
      'postsCount': FieldValue.increment(1),
    });

    return post;
  }

  /// Get posts by a user
  Stream<List<UserPost>> getUserPosts(String userId) {
    return _postsRef
        .where('userId', isEqualTo: userId)
        .where('isDeleted', isEqualTo: false)
        .orderBy('createdAt', descending: true)
        .limit(50)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => _postFromDoc(doc)).toList());
  }

  /// Get feed posts (from following)
  Stream<List<UserPost>> getFeedPosts() {
    final currentUserId = ref.read(currentUserIdProvider);
    if (currentUserId == null) return Stream.value([]);

    // Get following list first, then posts
    return _profilesRef
        .doc(currentUserId)
        .collection('following')
        .snapshots()
        .asyncMap((followingSnapshot) async {
          final followingIds = followingSnapshot.docs.map((d) => d.id).toList();
          followingIds.add(currentUserId); // Include own posts

          if (followingIds.isEmpty) return <UserPost>[];

          // Firestore 'whereIn' limit is 10
          final chunks = _chunkList(followingIds, 10);
          final allPosts = <UserPost>[];

          for (final chunk in chunks) {
            final snapshot = await _postsRef
                .where('userId', whereIn: chunk)
                .where('isDeleted', isEqualTo: false)
                .orderBy('createdAt', descending: true)
                .limit(20)
                .get();

            allPosts.addAll(snapshot.docs.map((d) => _postFromDoc(d)));
          }

          // Sort by date
          allPosts.sort((a, b) => b.createdAt.compareTo(a.createdAt));
          return allPosts.take(50).toList();
        });
  }

  /// Like a post
  Future<void> likePost(String postId) async {
    final currentUserId = ref.read(currentUserIdProvider);
    if (currentUserId == null) return;

    await _postsRef.doc(postId).update({
      'likedBy': FieldValue.arrayUnion([currentUserId]),
      'likesCount': FieldValue.increment(1),
    });
  }

  /// Unlike a post
  Future<void> unlikePost(String postId) async {
    final currentUserId = ref.read(currentUserIdProvider);
    if (currentUserId == null) return;

    await _postsRef.doc(postId).update({
      'likedBy': FieldValue.arrayRemove([currentUserId]),
      'likesCount': FieldValue.increment(-1),
    });
  }

  /// Delete a post
  Future<void> deletePost(String postId) async {
    final currentUserId = ref.read(currentUserIdProvider);
    if (currentUserId == null) return;

    // Soft delete
    await _postsRef.doc(postId).update({'isDeleted': true});

    // Update post count
    await _profilesRef.doc(currentUserId).update({
      'postsCount': FieldValue.increment(-1),
    });
  }

  // ==================== ACHIEVEMENTS ====================

  /// Unlock an achievement
  Future<void> unlockAchievement(String achievementId) async {
    final currentUserId = ref.read(currentUserIdProvider);
    if (currentUserId == null) return;

    await _profilesRef.doc(currentUserId).update({
      'achievements': FieldValue.arrayUnion([achievementId]),
    });
  }

  /// Award a badge
  Future<void> awardBadge(String badgeId) async {
    final currentUserId = ref.read(currentUserIdProvider);
    if (currentUserId == null) return;

    await _profilesRef.doc(currentUserId).update({
      'badges': FieldValue.arrayUnion([badgeId]),
    });
  }

  // ==================== HELPERS ====================

  UserProfile _profileFromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data()!;
    return UserProfile(
      id: doc.id,
      displayName: data['displayName'] as String? ?? 'User',
      avatarUrl: data['avatarUrl'] as String?,
      coverPhotoUrl: data['coverPhotoUrl'] as String?,
      bio: data['bio'] as String?,
      followersCount: data['followersCount'] as int? ?? 0,
      followingCount: data['followingCount'] as int? ?? 0,
      postsCount: data['postsCount'] as int? ?? 0,
      gamesPlayed: data['gamesPlayed'] as int? ?? 0,
      gamesWon: data['gamesWon'] as int? ?? 0,
      winRate: (data['winRate'] as num?)?.toDouble() ?? 0.0,
      eloRating: data['eloRating'] as int? ?? 1000,
      totalDiamondsEarned: data['totalDiamondsEarned'] as int? ?? 0,
      currentStreak: data['currentStreak'] as int? ?? 0,
      longestStreak: data['longestStreak'] as int? ?? 0,
      achievements: List<String>.from(data['achievements'] ?? []),
      badges: List<String>.from(data['badges'] ?? []),
      profileTheme: data['profileTheme'] as String?,
      accentColor: data['accentColor'] as String?,
      isVerified: data['isVerified'] as bool? ?? false,
      isCreator: data['isCreator'] as bool? ?? false,
      isPrivate: data['isPrivate'] as bool? ?? false,
      instagramHandle: data['instagramHandle'] as String?,
      twitterHandle: data['twitterHandle'] as String?,
      discordTag: data['discordTag'] as String?,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate(),
      lastActiveAt: (data['lastActiveAt'] as Timestamp?)?.toDate(),
      featuredPostId: data['featuredPostId'] as String?,
      highlightedStoryIds: List<String>.from(data['highlightedStoryIds'] ?? []),
    );
  }

  Map<String, dynamic> _profileToFirestore(UserProfile profile) {
    return {
      'displayName': profile.displayName,
      'avatarUrl': profile.avatarUrl,
      'coverPhotoUrl': profile.coverPhotoUrl,
      'bio': profile.bio,
      'followersCount': profile.followersCount,
      'followingCount': profile.followingCount,
      'postsCount': profile.postsCount,
      'gamesPlayed': profile.gamesPlayed,
      'gamesWon': profile.gamesWon,
      'winRate': profile.winRate,
      'eloRating': profile.eloRating,
      'totalDiamondsEarned': profile.totalDiamondsEarned,
      'currentStreak': profile.currentStreak,
      'longestStreak': profile.longestStreak,
      'achievements': profile.achievements,
      'badges': profile.badges,
      'profileTheme': profile.profileTheme,
      'accentColor': profile.accentColor,
      'isVerified': profile.isVerified,
      'isCreator': profile.isCreator,
      'isPrivate': profile.isPrivate,
      'instagramHandle': profile.instagramHandle,
      'twitterHandle': profile.twitterHandle,
      'discordTag': profile.discordTag,
      'createdAt': profile.createdAt != null
          ? Timestamp.fromDate(profile.createdAt!)
          : FieldValue.serverTimestamp(),
      'lastActiveAt': FieldValue.serverTimestamp(),
      'featuredPostId': profile.featuredPostId,
      'highlightedStoryIds': profile.highlightedStoryIds,
    };
  }

  UserPost _postFromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data()!;
    return UserPost(
      id: doc.id,
      userId: data['userId'] as String,
      userName: data['userName'] as String? ?? 'User',
      userAvatarUrl: data['userAvatarUrl'] as String?,
      content: data['content'] as String? ?? '',
      mediaUrl: data['mediaUrl'] as String?,
      mediaType: PostMediaType.values.firstWhere(
        (e) => e.name == data['mediaType'],
        orElse: () => PostMediaType.none,
      ),
      likedBy: List<String>.from(data['likedBy'] ?? []),
      likesCount: data['likesCount'] as int? ?? 0,
      commentsCount: data['commentsCount'] as int? ?? 0,
      sharesCount: data['sharesCount'] as int? ?? 0,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      isDeleted: data['isDeleted'] as bool? ?? false,
      gameId: data['gameId'] as String?,
      gameType: data['gameType'] as String?,
    );
  }

  Map<String, dynamic> _postToFirestore(UserPost post) {
    return {
      'userId': post.userId,
      'userName': post.userName,
      'userAvatarUrl': post.userAvatarUrl,
      'content': post.content,
      'mediaUrl': post.mediaUrl,
      'mediaType': post.mediaType.name,
      'likedBy': post.likedBy,
      'likesCount': post.likesCount,
      'commentsCount': post.commentsCount,
      'sharesCount': post.sharesCount,
      'createdAt': Timestamp.fromDate(post.createdAt),
      'isDeleted': post.isDeleted,
      'gameId': post.gameId,
      'gameType': post.gameType,
    };
  }

  List<List<T>> _chunkList<T>(List<T> list, int chunkSize) {
    final chunks = <List<T>>[];
    for (var i = 0; i < list.length; i += chunkSize) {
      chunks.add(list.sublist(i, (i + chunkSize).clamp(0, list.length)));
    }
    return chunks;
  }
}
