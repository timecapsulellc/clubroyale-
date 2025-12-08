import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

/// Types of feedback that users can submit
enum FeedbackType {
  bug,
  feature,
  general,
}

/// Service for collecting and storing user feedback
class FeedbackService {
  static final FeedbackService _instance = FeedbackService._internal();
  factory FeedbackService() => _instance;
  FeedbackService._internal();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  /// Submit user feedback to Firestore
  Future<void> submitFeedback({
    required FeedbackType type,
    required String message,
    String? email,
  }) async {
    final user = _auth.currentUser;
    
    await _firestore.collection('feedback').add({
      'userId': user?.uid,
      'userEmail': email ?? user?.email,
      'type': type.name,
      'message': message,
      'platform': 'web',
      'appVersion': '1.0.0',
      'timestamp': FieldValue.serverTimestamp(),
      'status': 'new',
    });
  }

  /// Get feedback type display name
  static String getTypeName(FeedbackType type) {
    switch (type) {
      case FeedbackType.bug:
        return 'Bug Report';
      case FeedbackType.feature:
        return 'Feature Request';
      case FeedbackType.general:
        return 'General Feedback';
    }
  }
}
