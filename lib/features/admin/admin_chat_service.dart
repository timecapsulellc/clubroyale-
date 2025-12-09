import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Provider for admin chat service
final adminChatServiceProvider = Provider<AdminChatService>(
  (ref) => AdminChatService(),
);

/// Service for admin-user support chat
class AdminChatService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  /// Start a new support chat
  Future<String> startChat({
    required String userId,
    required String userName,
    required String subject,
  }) async {
    final docRef = await _db.collection('admin_chats').add({
      'userId': userId,
      'userName': userName,
      'subject': subject,
      'status': 'open',
      'assignedAdmin': null,
      'createdAt': FieldValue.serverTimestamp(),
      'lastMessageAt': FieldValue.serverTimestamp(),
      'unreadByAdmin': true,
      'unreadByUser': false,
    });

    // Add initial message
    await _db
        .collection('admin_chats')
        .doc(docRef.id)
        .collection('messages')
        .add({
      'senderId': userId,
      'senderName': userName,
      'content': subject,
      'type': 'text',
      'createdAt': FieldValue.serverTimestamp(),
    });

    return docRef.id;
  }

  /// Send a message in a chat
  Future<void> sendMessage({
    required String chatId,
    required String senderId,
    required String senderName,
    required String content,
    bool isAdmin = false,
  }) async {
    await _db
        .collection('admin_chats')
        .doc(chatId)
        .collection('messages')
        .add({
      'senderId': senderId,
      'senderName': senderName,
      'content': content,
      'type': 'text',
      'isAdmin': isAdmin,
      'createdAt': FieldValue.serverTimestamp(),
    });

    // Update chat metadata
    await _db.collection('admin_chats').doc(chatId).update({
      'lastMessageAt': FieldValue.serverTimestamp(),
      'unreadByAdmin': !isAdmin,
      'unreadByUser': isAdmin,
    });
  }

  /// Get chats for a specific user
  Stream<List<SupportChat>> watchUserChats(String userId) {
    return _db
        .collection('admin_chats')
        .where('userId', isEqualTo: userId)
        .orderBy('lastMessageAt', descending: true)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => SupportChat.fromFirestore(doc)).toList());
  }

  /// Get all open chats (for admins)
  Stream<List<SupportChat>> watchOpenChats() {
    return _db
        .collection('admin_chats')
        .where('status', isEqualTo: 'open')
        .orderBy('lastMessageAt', descending: true)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => SupportChat.fromFirestore(doc)).toList());
  }

  /// Get chats assigned to a specific admin
  Stream<List<SupportChat>> watchAdminChats(String adminEmail) {
    return _db
        .collection('admin_chats')
        .where('assignedAdmin', isEqualTo: adminEmail)
        .where('status', isEqualTo: 'open')
        .orderBy('lastMessageAt', descending: true)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => SupportChat.fromFirestore(doc)).toList());
  }

  /// Get messages for a chat
  Stream<List<ChatMessage>> watchMessages(String chatId) {
    return _db
        .collection('admin_chats')
        .doc(chatId)
        .collection('messages')
        .orderBy('createdAt', descending: false)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => ChatMessage.fromFirestore(doc)).toList());
  }

  /// Assign chat to an admin
  Future<void> assignChat(String chatId, String adminEmail) async {
    await _db.collection('admin_chats').doc(chatId).update({
      'assignedAdmin': adminEmail,
    });
  }

  /// Close a chat
  Future<void> closeChat(String chatId, String closedBy) async {
    await _db.collection('admin_chats').doc(chatId).update({
      'status': 'closed',
      'closedBy': closedBy,
      'closedAt': FieldValue.serverTimestamp(),
    });
  }

  /// Mark chat as read
  Future<void> markAsRead(String chatId, {required bool isAdmin}) async {
    await _db.collection('admin_chats').doc(chatId).update({
      isAdmin ? 'unreadByAdmin' : 'unreadByUser': false,
    });
  }
}

/// Support chat model
class SupportChat {
  final String id;
  final String userId;
  final String userName;
  final String subject;
  final String status;
  final String? assignedAdmin;
  final DateTime? createdAt;
  final DateTime? lastMessageAt;
  final bool unreadByAdmin;
  final bool unreadByUser;

  SupportChat({
    required this.id,
    required this.userId,
    required this.userName,
    required this.subject,
    required this.status,
    this.assignedAdmin,
    this.createdAt,
    this.lastMessageAt,
    required this.unreadByAdmin,
    required this.unreadByUser,
  });

  factory SupportChat.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return SupportChat(
      id: doc.id,
      userId: data['userId'] ?? '',
      userName: data['userName'] ?? '',
      subject: data['subject'] ?? '',
      status: data['status'] ?? 'open',
      assignedAdmin: data['assignedAdmin'],
      createdAt: (data['createdAt'] as Timestamp?)?.toDate(),
      lastMessageAt: (data['lastMessageAt'] as Timestamp?)?.toDate(),
      unreadByAdmin: data['unreadByAdmin'] ?? false,
      unreadByUser: data['unreadByUser'] ?? false,
    );
  }
}

/// Chat message model
class ChatMessage {
  final String id;
  final String senderId;
  final String senderName;
  final String content;
  final String type;
  final bool isAdmin;
  final DateTime? createdAt;

  ChatMessage({
    required this.id,
    required this.senderId,
    required this.senderName,
    required this.content,
    required this.type,
    required this.isAdmin,
    this.createdAt,
  });

  factory ChatMessage.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return ChatMessage(
      id: doc.id,
      senderId: data['senderId'] ?? '',
      senderName: data['senderName'] ?? '',
      content: data['content'] ?? '',
      type: data['type'] ?? 'text',
      isAdmin: data['isAdmin'] ?? false,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate(),
    );
  }
}
