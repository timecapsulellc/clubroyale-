import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/social_chat_model.dart';
import '../models/social_message_model.dart';
import '../models/social_user_model.dart';

final socialServiceProvider = Provider((ref) => SocialService());

class SocialService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  String? get currentUserId => _auth.currentUser?.uid;

  // ============ CHATS ============

  /// Watch user's active chats (Home Tab)
  Stream<List<SocialChat>> watchMyChats() {
    final uid = currentUserId;
    if (uid == null) return Stream.value([]);

    return _firestore
        .collection('chats')
        .where('participants', arrayContains: uid)
        .orderBy('updatedAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => SocialChat.fromJson({...doc.data(), 'id': doc.id}))
            .toList());
  }

  /// Create or Get Existing Direct Chat
  Future<String> createDirectChat(String otherUserId) async {
    final uid = currentUserId;
    if (uid == null) throw Exception("Not logged in");

    // Check existing
    final existing = await _firestore
        .collection('chats')
        .where('type', isEqualTo: 'direct')
        .where('participants', arrayContains: uid)
        .get();

    for (final doc in existing.docs) {
      final participants = List<String>.from(doc.data()['participants'] ?? []);
      if (participants.contains(otherUserId)) {
        return doc.id;
      }
    }

    // Create new
    final chatRef = await _firestore.collection('chats').add({
      'type': 'direct',
      'participants': [uid, otherUserId],
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
      'unreadCounts': {uid: 0, otherUserId: 0},
    });

    return chatRef.id;
  }

  /// Create a Voice Room (Clubhouse style)
  Future<String> createVoiceRoom(String name) async {
    final uid = currentUserId;
    if (uid == null) throw Exception("Not logged in");
    
    final chatRef = await _firestore.collection('chats').add({
      'type': 'voiceRoom',
      'participants': [uid],
      'admins': [uid],
      'name': name,
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
      'unreadCounts': {},
    });
    
    return chatRef.id;
  }

  // ============ MESSAGES ============

  /// Watch messages in a specific chat
  Stream<List<SocialMessage>> watchMessages(String chatId) {
    return _firestore
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .orderBy('timestamp', descending: true)
        .limit(50)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => SocialMessage.fromJson({...doc.data(), 'id': doc.id}))
            .toList());
  }

  /// Send a text message
  Future<void> sendTextMessage({
    required String chatId,
    required String text,
  }) async {
    await _sendMessage(
      chatId: chatId,
      type: SocialMessageType.text,
      content: SocialMessageContent(text: text),
      previewText: text,
    );
  }
  
  /// Send a game invite
  Future<void> sendGameInvite({
    required String chatId,
    required String roomId,
    required String gameType,
  }) async {
    await _sendMessage(
      chatId: chatId,
      type: SocialMessageType.gameInvite,
      content: SocialMessageContent(
        gameRoomId: roomId,
        gameType: gameType,
      ),
      previewText: '🎮 Invited you to play $gameType',
    );
  }

  /// Send an Image Message
  Future<void> sendImageMessage({
    required String chatId,
    required File imageFile,
  }) async {
    final uid = currentUserId;
    if (uid == null) throw Exception("Not logged in");

    // 1. Upload Image
    final String fileName = '${DateTime.now().millisecondsSinceEpoch}_$uid.jpg';
    final ref = _storage.ref().child('chats/$chatId/images/$fileName');
    
    // Simple upload
    await ref.putFile(imageFile);
    final downloadUrl = await ref.getDownloadURL();

    // 2. Send Message
    await _sendMessage(
      chatId: chatId,
      type: SocialMessageType.image,
      content: SocialMessageContent(
        mediaUrl: downloadUrl,
      ),
      previewText: '📷 Image',
    );
  }

  /// Internal Send Logic
  Future<void> _sendMessage({
    required String chatId,
    required SocialMessageType type,
    required SocialMessageContent content,
    required String previewText,
  }) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception("Not logged in");

    // 1. Add Message
    final messageRef = _firestore.collection('chats').doc(chatId).collection('messages').doc();
    
    final messageData = {
      'chatId': chatId,
      'senderId': user.uid,
      'senderName': user.displayName ?? 'Unknown',
      'senderAvatarUrl': user.photoURL,
      'type': type.name, // Enum to string
      'content': content.toJson(),
      'timestamp': FieldValue.serverTimestamp(),
      'readBy': [user.uid],
      'reactions': {},
    };

    await messageRef.set(messageData);

    // 2. Update Chat Metadata (Last Message & Unread)
    // We ideally use a Transaction or Cloud Function for atomic increments.
    // For MVP, simple update.
    await _firestore.collection('chats').doc(chatId).update({
      'updatedAt': FieldValue.serverTimestamp(),
      'lastMessage': {
        'messageId': messageRef.id,
        'senderId': user.uid,
        'senderName': user.displayName ?? 'Unknown',
        'content': previewText,
        'type': type.name,
        'timestamp': FieldValue.serverTimestamp(), // Will be resolved on read
      },
      // Basic unread logic: increment for everyone except sender
      // This is better handled by Cloud Functions to avoid race conditions
    });
  }

  // ============ PRESENCE ============
  
  // Presence is typically handled via Realtime Database for "Online/Offline", 
  // but we can simulate "Active" via Firestore for this MVP using 'lastSeen'.
  Future<void> updatePresence() async {
    final uid = currentUserId;
    if (uid == null) return;
    
    await _firestore.collection('users').doc(uid).update({
      'lastSeen': FieldValue.serverTimestamp(),
      'isOnline': true,
    });
  }
  
  // ============ USERS ============
  
  /// Get User Profile
  Future<SocialUser?> getUserProfile(String uid) async {
    final doc = await _firestore.collection('users').doc(uid).get();
    if (!doc.exists) return null;
    return SocialUser.fromJson({...doc.data()!, 'id': doc.id});
  }
}
