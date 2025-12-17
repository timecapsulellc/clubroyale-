import 'dart:typed_data';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:clubroyale/features/stories/models/story.dart';
import 'package:clubroyale/features/auth/auth_service.dart';
import 'package:clubroyale/core/demo/demo_data.dart';

/// Stories service provider
final storyServiceProvider = Provider<StoryService>((ref) {
  return StoryService(
    firestore: FirebaseFirestore.instance,
    storage: FirebaseStorage.instance,
    ref: ref,
  );
});

/// Stream of current user's stories
final myStoriesProvider = StreamProvider<List<Story>>((ref) {
  final userId = ref.watch(currentUserIdProvider);
  if (userId == null) return Stream.value([]);
  return ref.watch(storyServiceProvider).getUserStories(userId);
});

/// Stream of friends' stories for story bar
final friendsStoriesProvider = StreamProvider<List<UserStories>>((ref) {
  return ref.watch(storyServiceProvider).getFriendsStories();
});

/// Story expiration duration (24 hours)
const storyDuration = Duration(hours: 24);

/// Service for managing stories
class StoryService {
  final FirebaseFirestore firestore;
  final FirebaseStorage storage;
  final Ref ref;

  StoryService({
    required this.firestore,
    required this.storage,
    required this.ref,
  });

  CollectionReference<Map<String, dynamic>> get _storiesRef =>
      firestore.collection('stories');

  /// Create a new story using bytes (web compatible)
  Future<Story> createStory({
    required Uint8List mediaBytes,
    required StoryMediaType mediaType,
    String? caption,
    String? textOverlay,
    String? textColor,
  }) async {
    final userId = ref.read(currentUserIdProvider);
    final userProfile = ref.read(authStateProvider).value;
    
    if (userId == null) {
      throw Exception('User not authenticated');
    }

    // Upload media to Firebase Storage using putData (web compatible)
    final fileName = '${userId}_${DateTime.now().millisecondsSinceEpoch}';
    final extension = mediaType == StoryMediaType.video ? 'mp4' : 'jpg';
    final storageRef = storage.ref().child('stories/$userId/$fileName.$extension');
    
    // Use putData instead of putFile for web compatibility
    final metadata = SettableMetadata(
      contentType: mediaType == StoryMediaType.video ? 'video/mp4' : 'image/jpeg',
    );
    await storageRef.putData(mediaBytes, metadata);
    final mediaUrl = await storageRef.getDownloadURL();

    final now = DateTime.now();
    final expiresAt = now.add(storyDuration);
    
    final storyDoc = _storiesRef.doc();
    final story = Story(
      id: storyDoc.id,
      userId: userId,
      userName: userProfile?.displayName ?? 'Player',
      userPhotoUrl: userProfile?.photoURL,
      mediaUrl: mediaUrl,
      mediaType: mediaType,
      createdAt: now,
      expiresAt: expiresAt,
      caption: caption,
      textOverlay: textOverlay,
      textColor: textColor,
    );

    await storyDoc.set({
      ...story.toJson(),
      'createdAt': FieldValue.serverTimestamp(),
      'expiresAt': Timestamp.fromDate(expiresAt),
    });

    return story;
  }

  /// Create a game result story (auto-generated after game completion)
  Future<Story> createGameResultStory({
    required String gameType,
    required String winnerId,
    required String winnerName,
    required Map<String, int> scores,
    String? caption,
  }) async {
    final userId = ref.read(currentUserIdProvider);
    final userProfile = ref.read(authStateProvider).value;
    
    if (userId == null) {
      throw Exception('User not authenticated');
    }

    final now = DateTime.now();
    final expiresAt = now.add(storyDuration);
    
    final storyDoc = _storiesRef.doc();
    final story = Story(
      id: storyDoc.id,
      userId: userId,
      userName: userProfile?.displayName ?? 'Player',
      userPhotoUrl: userProfile?.photoURL,
      mediaType: StoryMediaType.gameResult,
      createdAt: now,
      expiresAt: expiresAt,
      caption: caption ?? 'Game completed!',
      gameType: gameType,
      winnerId: winnerId,
      winnerName: winnerName,
      scores: scores,
    );

    await storyDoc.set({
      ...story.toJson(),
      'createdAt': FieldValue.serverTimestamp(),
      'expiresAt': Timestamp.fromDate(expiresAt),
    });

    return story;
  }

  /// Get stories by a specific user
  Stream<List<Story>> getUserStories(String userId) {
    final now = DateTime.now();
    return _storiesRef
        .where('userId', isEqualTo: userId)
        .where('expiresAt', isGreaterThan: Timestamp.fromDate(now))
        .orderBy('expiresAt')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => _storyFromDoc(doc))
            .toList());
  }

  /// Get friends' stories aggregated by user
  Stream<List<UserStories>> getFriendsStories() {
    final userId = ref.read(currentUserIdProvider);
    if (userId == null) return Stream.value([]);

    final now = DateTime.now();
    
    // Get all non-expired stories from friends
    return firestore
        .collection('users')
        .doc(userId)
        .collection('friends')
        .snapshots()
        .asyncMap((friendsSnapshot) async {
          final friendIds = friendsSnapshot.docs.map((d) => d.id).toList();
          
          // Inject Demo Data if no friends
          if (friendIds.isEmpty) return DemoData.stories;

          // Firestore whereIn has a limit of 10
          final chunks = _chunkList(friendIds, 10);
          final allStories = <Story>[];

          for (final chunk in chunks) {
            final snapshot = await _storiesRef
                .where('userId', whereIn: chunk)
                .where('expiresAt', isGreaterThan: Timestamp.fromDate(now))
                .get();
            
            allStories.addAll(
              snapshot.docs.map((doc) => _storyFromDoc(doc)),
            );
          }

          // Group by user
          final grouped = <String, List<Story>>{};
          for (final story in allStories) {
            grouped.putIfAbsent(story.userId, () => []).add(story);
          }

          // Convert to UserStories
          return grouped.entries.map((entry) {
            final stories = entry.value
              ..sort((a, b) => a.createdAt.compareTo(b.createdAt));
            final hasUnviewed = stories.any((s) => !s.viewedBy.contains(userId));
            
            return UserStories(
              userId: entry.key,
              userName: stories.first.userName,
              userPhotoUrl: stories.first.userPhotoUrl,
              stories: stories,
              hasUnviewed: hasUnviewed,
              latestStoryAt: stories.last.createdAt,
            );
          }).toList()
            ..sort((a, b) {
              // Unviewed first, then by latest
              if (a.hasUnviewed != b.hasUnviewed) {
                return a.hasUnviewed ? -1 : 1;
              }
              return (b.latestStoryAt ?? DateTime(0))
                  .compareTo(a.latestStoryAt ?? DateTime(0));
            });
        });
  }

  /// Mark a story as viewed
  Future<void> markAsViewed(String storyId) async {
    final userId = ref.read(currentUserIdProvider);
    if (userId == null) return;

    await _storiesRef.doc(storyId).update({
      'viewedBy': FieldValue.arrayUnion([userId]),
      'viewCount': FieldValue.increment(1),
    });
  }

  /// Get viewers of a story
  Future<List<StoryViewer>> getStoryViewers(String storyId) async {
    final doc = await _storiesRef.doc(storyId).get();
    if (!doc.exists) return [];

    final viewedBy = List<String>.from(doc.data()?['viewedBy'] ?? []);
    final viewers = <StoryViewer>[];

    for (final viewerId in viewedBy) {
      final userDoc = await firestore.collection('users').doc(viewerId).get();
      if (userDoc.exists) {
        viewers.add(StoryViewer(
          id: viewerId,
          name: userDoc.data()?['displayName'] ?? 'User',
          photoUrl: userDoc.data()?['photoURL'],
          viewedAt: DateTime.now(), // Approximate
        ));
      }
    }

    return viewers;
  }

  /// Delete a story
  Future<void> deleteStory(String storyId) async {
    final doc = await _storiesRef.doc(storyId).get();
    if (!doc.exists) return;

    final story = _storyFromDoc(doc);
    
    // Delete media from storage
    try {
      if (story.mediaUrl != null) {
        final ref = storage.refFromURL(story.mediaUrl!);
        await ref.delete();
      }
    } catch (_) {
      // Media might already be deleted
    }

    // Delete Firestore document
    await _storiesRef.doc(storyId).delete();
  }

  /// Helper to convert Firestore doc to Story
  Story _storyFromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data()!;
    return Story(
      id: doc.id,
      userId: data['userId'] as String,
      userName: data['userName'] as String,
      userPhotoUrl: data['userPhotoUrl'] as String?,
      mediaUrl: data['mediaUrl'] as String?,
      mediaType: StoryMediaType.values.firstWhere(
        (e) => e.name == data['mediaType'],
        orElse: () => StoryMediaType.photo,
      ),
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      expiresAt: (data['expiresAt'] as Timestamp?)?.toDate() ?? 
          DateTime.now().add(storyDuration),
      viewedBy: List<String>.from(data['viewedBy'] ?? []),
      viewCount: data['viewCount'] as int? ?? 0,
      caption: data['caption'] as String?,
      textOverlay: data['textOverlay'] as String?,
      textColor: data['textColor'] as String?,
      // Game result fields
      gameType: data['gameType'] as String?,
      winnerId: data['winnerId'] as String?,
      winnerName: data['winnerName'] as String?,
      scores: data['scores'] != null 
          ? Map<String, int>.from(data['scores']) 
          : null,
    );
  }

  /// Split list into chunks
  List<List<T>> _chunkList<T>(List<T> list, int chunkSize) {
    final chunks = <List<T>>[];
    for (var i = 0; i < list.length; i += chunkSize) {
      chunks.add(list.sublist(i, (i + chunkSize).clamp(0, list.length)));
    }
    return chunks;
  }
}
