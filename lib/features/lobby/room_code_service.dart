import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final roomCodeServiceProvider = Provider<RoomCodeService>(
  (ref) => RoomCodeService(),
);

/// Service for generating and managing 6-digit room codes
class RoomCodeService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final Random _random = Random();

  /// Generates a unique 6-digit room code
  /// Format: Numbers only (000000-999999)
  Future<String> generateUniqueCode() async {
    String code;
    bool isUnique = false;
    int attempts = 0;
    const maxAttempts = 10;

    do {
      // Generate 6-digit code
      code = _generateCode();

      // Check if code is already in use
      isUnique = await isCodeAvailable(code);
      attempts++;

      if (attempts >= maxAttempts) {
        // Fallback: append timestamp suffix
        code =
            '${_generateCode().substring(0, 3)}${DateTime.now().millisecondsSinceEpoch % 1000}';
        break;
      }
    } while (!isUnique);

    return code;
  }

  /// Generates a random 6-digit code
  String _generateCode() {
    // Generate number between 100000 and 999999 to ensure 6 digits
    final number = 100000 + _random.nextInt(900000);
    return number.toString();
  }

  /// Checks if a room code is available (not in use)
  Future<bool> isCodeAvailable(String code) async {
    try {
      final snapshot = await _db
          .collection('games')
          .where('roomCode', isEqualTo: code)
          .where('status', whereIn: ['waiting', 'playing'])
          .limit(1)
          .get();

      return snapshot.docs.isEmpty;
    } catch (e) {
      // If query fails, assume code is taken (safer)
      return false;
    }
  }

  /// Finds a game room by its room code
  Future<DocumentSnapshot?> findRoomByCode(String code) async {
    try {
      final snapshot = await _db
          .collection('games')
          .where('roomCode', isEqualTo: code)
          .where('status', whereIn: ['waiting', 'playing'])
          .limit(1)
          .get();

      if (snapshot.docs.isNotEmpty) {
        return snapshot.docs.first;
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  /// Validates room code format (6 digits)
  bool isValidCodeFormat(String code) {
    if (code.length != 6) return false;
    return RegExp(r'^\d{6}$').hasMatch(code);
  }
}
