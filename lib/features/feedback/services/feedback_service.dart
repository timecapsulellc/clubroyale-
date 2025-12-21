import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final feedbackServiceProvider = Provider((ref) => FeedbackService());

enum FeedbackType {
  bug,
  featureHelper,
  general,
}

class FeedbackService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> submitFeedback({
    required String userId,
    required String message,
    required FeedbackType type,
    String? contactEmail,
  }) async {
    await _firestore.collection('feedback').add({
      'userId': userId,
      'message': message,
      'type': type.name, // 'bug', 'featureHelper', 'general'
      'contactEmail': contactEmail,
      'timestamp': FieldValue.serverTimestamp(),
      'status': 'new', // new, reviewed, resolved
      'version': '1.2.1', // Hardcoded or dynamic via package_info
      'platform': 'web', // Detect properly in real app
    });
  }
}
