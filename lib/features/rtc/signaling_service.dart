import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Signaling service using Firestore for WebRTC peer connection
class SignalingService {
  final FirebaseFirestore _firestore;
  final String roomId;
  final String localUserId;

  StreamSubscription? _offerSubscription;
  StreamSubscription? _answerSubscription;
  StreamSubscription? _candidateSubscription;

  // Callbacks for signaling events
  Function(Map<String, dynamic> offer, String fromUserId)? onOfferReceived;
  Function(Map<String, dynamic> answer, String fromUserId)? onAnswerReceived;
  Function(Map<String, dynamic> candidate, String fromUserId)?
  onCandidateReceived;
  Function(String peerId)? onPeerJoined;
  Function(String peerId)? onPeerLeft;

  SignalingService({
    required this.roomId,
    required this.localUserId,
    FirebaseFirestore? firestore,
  }) : _firestore = firestore ?? FirebaseFirestore.instance;

  /// Get the signaling document reference for this room
  DocumentReference get _roomSignalingRef => _firestore
      .collection('game_rooms')
      .doc(roomId)
      .collection('webrtc')
      .doc('signaling');

  /// Get collection for ICE candidates
  CollectionReference get _candidatesRef => _firestore
      .collection('game_rooms')
      .doc(roomId)
      .collection('webrtc')
      .doc('signaling')
      .collection('candidates');

  /// Initialize signaling and start listening
  Future<void> initialize() async {
    // Create signaling document if it doesn't exist
    await _roomSignalingRef.set({
      'createdAt': FieldValue.serverTimestamp(),
      'participants': FieldValue.arrayUnion([localUserId]),
    }, SetOptions(merge: true));

    // Listen for offers from other peers
    _listenForOffers();
    _listenForAnswers();
    _listenForCandidates();
  }

  /// Send an offer to a specific peer
  Future<void> sendOffer({
    required String toPeerId,
    required Map<String, dynamic> offer,
  }) async {
    await _roomSignalingRef
        .collection('offers')
        .doc('${localUserId}_to_$toPeerId')
        .set({
          'from': localUserId,
          'to': toPeerId,
          'offer': offer,
          'timestamp': FieldValue.serverTimestamp(),
        });
  }

  /// Send an answer to a specific peer
  Future<void> sendAnswer({
    required String toPeerId,
    required Map<String, dynamic> answer,
  }) async {
    await _roomSignalingRef
        .collection('answers')
        .doc('${localUserId}_to_$toPeerId')
        .set({
          'from': localUserId,
          'to': toPeerId,
          'answer': answer,
          'timestamp': FieldValue.serverTimestamp(),
        });
  }

  /// Send ICE candidate to a specific peer
  Future<void> sendCandidate({
    required String toPeerId,
    required Map<String, dynamic> candidate,
  }) async {
    await _candidatesRef.add({
      'from': localUserId,
      'to': toPeerId,
      'candidate': candidate,
      'timestamp': FieldValue.serverTimestamp(),
    });
  }

  /// Listen for incoming offers
  void _listenForOffers() {
    _offerSubscription = _roomSignalingRef
        .collection('offers')
        .where('to', isEqualTo: localUserId)
        .snapshots()
        .listen((snapshot) {
          for (var change in snapshot.docChanges) {
            if (change.type == DocumentChangeType.added) {
              final data = change.doc.data();
              if (data != null) {
                onOfferReceived?.call(
                  data['offer'] as Map<String, dynamic>,
                  data['from'] as String,
                );
              }
            }
          }
        });
  }

  /// Listen for incoming answers
  void _listenForAnswers() {
    _answerSubscription = _roomSignalingRef
        .collection('answers')
        .where('to', isEqualTo: localUserId)
        .snapshots()
        .listen((snapshot) {
          for (var change in snapshot.docChanges) {
            if (change.type == DocumentChangeType.added) {
              final data = change.doc.data();
              if (data != null) {
                onAnswerReceived?.call(
                  data['answer'] as Map<String, dynamic>,
                  data['from'] as String,
                );
              }
            }
          }
        });
  }

  /// Listen for incoming ICE candidates
  void _listenForCandidates() {
    _candidateSubscription = _candidatesRef
        .where('to', isEqualTo: localUserId)
        .snapshots()
        .listen((snapshot) {
          for (var change in snapshot.docChanges) {
            if (change.type == DocumentChangeType.added) {
              final data = change.doc.data() as Map<String, dynamic>?;
              if (data != null) {
                onCandidateReceived?.call(
                  data['candidate'] as Map<String, dynamic>,
                  data['from'] as String,
                );
              }
            }
          }
        });
  }

  /// Leave the room and clean up
  Future<void> leave() async {
    // Remove from participants
    await _roomSignalingRef.update({
      'participants': FieldValue.arrayRemove([localUserId]),
    });

    // Clean up subscriptions
    await _offerSubscription?.cancel();
    await _answerSubscription?.cancel();
    await _candidateSubscription?.cancel();

    // Delete our offers/answers/candidates
    final batch = _firestore.batch();

    // Delete offers from this user
    final offers = await _roomSignalingRef
        .collection('offers')
        .where('from', isEqualTo: localUserId)
        .get();
    for (var doc in offers.docs) {
      batch.delete(doc.reference);
    }

    // Delete answers from this user
    final answers = await _roomSignalingRef
        .collection('answers')
        .where('from', isEqualTo: localUserId)
        .get();
    for (var doc in answers.docs) {
      batch.delete(doc.reference);
    }

    // Delete candidates from this user
    final candidates = await _candidatesRef
        .where('from', isEqualTo: localUserId)
        .get();
    for (var doc in candidates.docs) {
      batch.delete(doc.reference);
    }

    await batch.commit();
  }

  /// Get list of current participants
  Future<List<String>> getParticipants() async {
    final doc = await _roomSignalingRef.get();
    final data = doc.data() as Map<String, dynamic>?;
    if (data == null) return [];
    return List<String>.from(data['participants'] ?? []);
  }

  /// Dispose resources
  void dispose() {
    _offerSubscription?.cancel();
    _answerSubscription?.cancel();
    _candidateSubscription?.cancel();
  }
}

/// Provider for signaling service
final signalingServiceProvider =
    Provider.family<SignalingService, SignalingParams>(
      (ref, params) => SignalingService(
        roomId: params.roomId,
        localUserId: params.localUserId,
      ),
    );

/// Parameters for signaling service provider
class SignalingParams {
  final String roomId;
  final String localUserId;

  SignalingParams({required this.roomId, required this.localUserId});

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SignalingParams &&
          roomId == other.roomId &&
          localUserId == other.localUserId;

  @override
  int get hashCode => roomId.hashCode ^ localUserId.hashCode;
}
