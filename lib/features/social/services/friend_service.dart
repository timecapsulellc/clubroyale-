import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/social_user_model.dart'; // Reuse SocialUser

final friendServiceProvider = Provider((ref) => FriendService());

class FriendService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String? get currentUserId => _auth.currentUser?.uid;

  /// Send Friend Request
  Future<void> sendFriendRequest(String targetUserId) async {
    final uid = currentUserId;
    if (uid == null) throw Exception("Not logged in");
    if (uid == targetUserId) throw Exception("Cannot add self");

    // Check if already friends
    final userDoc = await _firestore.collection('users').doc(uid).get();
    final friends = List<String>.from(userDoc.data()?['friendIds'] ?? []);
    if (friends.contains(targetUserId)) throw Exception("Already friends");

    // Check if request already exists
    final existing = await _firestore.collection('friend_requests')
        .where('from', isEqualTo: uid)
        .where('to', isEqualTo: targetUserId)
        .where('status', isEqualTo: 'pending')
        .get();
        
    if (existing.docs.isNotEmpty) throw Exception("Request already sent");

    // Create Request
    await _firestore.collection('friend_requests').add({
      'from': uid,
      'to': targetUserId,
      'status': 'pending',
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  /// Accept Friend Request
  Future<void> acceptFriendRequest(String requestId) async {
    final uid = currentUserId;
    if (uid == null) throw Exception("Not logged in");

    final requestDoc = await _firestore.collection('friend_requests').doc(requestId).get();
    if (!requestDoc.exists) throw Exception("Request not found");
    
    final data = requestDoc.data()!;
    if (data['to'] != uid) throw Exception("Not authorized");
    if (data['status'] != 'pending') throw Exception("Invalid status");

    final fromUserId = data['from'] as String;

    // Transaction to add friends to both users and update request
    await _firestore.runTransaction((transaction) async {
      final myRef = _firestore.collection('users').doc(uid);
      final otherRef = _firestore.collection('users').doc(fromUserId);
      final reqRef = _firestore.collection('friend_requests').doc(requestId);

      transaction.update(reqRef, {'status': 'accepted'});
      
      transaction.update(myRef, {
        'friendIds': FieldValue.arrayUnion([fromUserId])
      });
      
      transaction.update(otherRef, {
        'friendIds': FieldValue.arrayUnion([uid])
      });
    });
  }

  /// Reject Friend Request
  Future<void> rejectFriendRequest(String requestId) async {
    await _firestore.collection('friend_requests').doc(requestId).update({
      'status': 'rejected'
    });
  }

  /// Watch Incoming Friend Requests
  Stream<List<FriendRequest>> watchIncomingRequests() {
    final uid = currentUserId;
    if (uid == null) return Stream.value([]);

    return _firestore.collection('friend_requests')
        .where('to', isEqualTo: uid)
        .where('status', isEqualTo: 'pending')
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) {
           final data = doc.data();
           return FriendRequest(
             id: doc.id,
             from: data['from'],
             to: data['to'],
             status: data['status'],
             createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
           );
        }).toList());
  }

  /// Watch My Friends
  Stream<List<String>> watchMyFriendIds() {
    final uid = currentUserId;
    if (uid == null) return Stream.value([]);

    return _firestore.collection('users').doc(uid).snapshots().map((doc) {
      return List<String>.from(doc.data()?['friendIds'] ?? []);
    });
  }

  /// Search Users by Name (Simple)
  Future<List<SocialUser>> searchUsers(String query) async {
    if (query.isEmpty) return [];
    
    // Note: Firestore doesn't do full text search natively.
    // Use a simple prefix search on 'displayName' or similar.
    // Assuming 'searchName' field exists (lowercase)
    
    final snapshot = await _firestore.collection('users')
        .where('displayName', isGreaterThanOrEqualTo: query)
        .where('displayName', isLessThan: '${query}z')
        .limit(20)
        .get();
        
    return snapshot.docs.map((doc) => SocialUser.fromJson({...doc.data(), 'id': doc.id})).toList();
  }
}

class FriendRequest {
  final String id;
  final String from;
  final String to;
  final String status;
  final DateTime createdAt;

  FriendRequest({
    required this.id,
    required this.from,
    required this.to,
    required this.status,
    required this.createdAt,
  });
}
