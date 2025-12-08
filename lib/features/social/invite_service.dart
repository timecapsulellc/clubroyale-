// Deep Link Invite Service
//
// Shareable invite links with signed tokens for security.
// Supports WhatsApp, SMS, and other sharing methods.

import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:share_plus/share_plus.dart';

/// Invite link data
class InviteLink {
  final String deepLink;
  final String roomCode;
  final String hostName;
  final String gameType;
  final DateTime expiresAt;
  final String token;
  
  InviteLink({
    required this.deepLink,
    required this.roomCode,
    required this.hostName,
    required this.gameType,
    required this.expiresAt,
    required this.token,
  });

  bool get isExpired => DateTime.now().isAfter(expiresAt);

  String get formattedExpiry {
    final hours = expiresAt.difference(DateTime.now()).inHours;
    if (hours < 1) return 'Less than 1 hour';
    if (hours < 24) return '$hours hours';
    return '${(hours / 24).floor()} days';
  }
}

/// Invite validation status
enum InviteStatus {
  valid,
  invalid,
  expired,
  roomNotFound,
  roomFull,
  gameStarted,
}

/// Invite validation result
class InviteValidation {
  final InviteStatus status;
  final String? roomId;
  final String? roomCode;
  final String? error;
  
  InviteValidation._({
    required this.status, 
    this.roomId, 
    this.roomCode, 
    this.error,
  });
  
  factory InviteValidation.valid({required String roomId, required String roomCode}) =>
      InviteValidation._(status: InviteStatus.valid, roomId: roomId, roomCode: roomCode);
  
  factory InviteValidation.invalid(String error) =>
      InviteValidation._(status: InviteStatus.invalid, error: error);
  
  factory InviteValidation.expired() =>
      InviteValidation._(status: InviteStatus.expired, error: 'Invite has expired');
  
  factory InviteValidation.roomNotFound() =>
      InviteValidation._(status: InviteStatus.roomNotFound, error: 'Room no longer exists');
  
  factory InviteValidation.roomFull() =>
      InviteValidation._(status: InviteStatus.roomFull, error: 'Room is full');
  
  factory InviteValidation.gameStarted() =>
      InviteValidation._(status: InviteStatus.gameStarted, error: 'Game has already started');
  
  bool get isValid => status == InviteStatus.valid;
}

/// Deep Link Invite Service
class InviteService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  // Base URL for deep links
  static const String _baseUrl = 'https://taasclub.app/join';
  
  // Signing secret (in production, use environment variable or secure storage)
  static const String _signingSecret = 'TAASCLUB_INVITE_SECRET_2024';
  
  /// Generate a signed invite link
  Future<InviteLink> generateInviteLink({
    required String roomId,
    required String roomCode,
    required String hostId,
    required String hostName,
    required String gameType,
    Duration expiry = const Duration(hours: 24),
  }) async {
    final expiresAt = DateTime.now().add(expiry);
    
    final payload = {
      'roomId': roomId,
      'roomCode': roomCode,
      'hostId': hostId,
      'gameType': gameType,
      'exp': expiresAt.millisecondsSinceEpoch,
    };
    
    final payloadJson = jsonEncode(payload);
    final payloadBase64 = base64Url.encode(utf8.encode(payloadJson));
    
    // Sign the payload
    final signature = _sign(payloadBase64);
    final token = '$payloadBase64.$signature';
    
    final deepLink = '$_baseUrl?token=$token';
    
    // Store invite for tracking
    await _firestore.collection('invites').add({
      'roomId': roomId,
      'roomCode': roomCode,
      'hostId': hostId,
      'hostName': hostName,
      'gameType': gameType,
      'token': token,
      'expiresAt': Timestamp.fromDate(expiresAt),
      'createdAt': FieldValue.serverTimestamp(),
      'usedBy': <String>[],
    });
    
    return InviteLink(
      deepLink: deepLink,
      roomCode: roomCode,
      hostName: hostName,
      gameType: gameType,
      expiresAt: expiresAt,
      token: token,
    );
  }
  
  /// Validate and parse an invite token
  Future<InviteValidation> validateInviteToken(String token) async {
    try {
      final parts = token.split('.');
      if (parts.length != 2) {
        return InviteValidation.invalid('Malformed token');
      }
      
      final payloadBase64 = parts[0];
      final signature = parts[1];
      
      // Verify signature
      if (_sign(payloadBase64) != signature) {
        return InviteValidation.invalid('Invalid signature');
      }
      
      // Decode payload
      final payloadJson = utf8.decode(base64Url.decode(payloadBase64));
      final payload = jsonDecode(payloadJson) as Map<String, dynamic>;
      
      // Check expiry
      final exp = payload['exp'] as int;
      if (DateTime.now().millisecondsSinceEpoch > exp) {
        return InviteValidation.expired();
      }
      
      // Check room still exists and has space
      final roomId = payload['roomId'] as String;
      final roomDoc = await _firestore.collection('matches').doc(roomId).get();
      
      if (!roomDoc.exists) {
        return InviteValidation.roomNotFound();
      }
      
      final roomData = roomDoc.data()!;
      final players = Map.from(roomData['players'] ?? {});
      final maxPlayers = roomData['maxPlayers'] ?? 4;
      final status = roomData['status'] as String?;
      
      if (players.length >= maxPlayers) {
        return InviteValidation.roomFull();
      }
      
      if (status != null && status != 'waiting') {
        return InviteValidation.gameStarted();
      }
      
      return InviteValidation.valid(
        roomId: roomId,
        roomCode: payload['roomCode'] as String,
      );
    } catch (e) {
      return InviteValidation.invalid('Error parsing token: $e');
    }
  }
  
  /// Share invite link via system share sheet
  Future<void> shareInviteLink(InviteLink invite) async {
    final gameDisplayName = _getGameDisplayName(invite.gameType);
    
    final message = '''
🎴 Join my $gameDisplayName game on TaasClub!

📍 Room Code: ${invite.roomCode}
👤 Host: ${invite.hostName}
⏰ Expires: ${invite.formattedExpiry}

👉 Tap to join: ${invite.deepLink}

Or open TaasClub and enter the room code!
''';
    
    await Share.share(message, subject: 'Join my TaasClub game!');
  }
  
  /// Share via WhatsApp specifically
  Future<void> shareToWhatsApp(InviteLink invite) async {
    // Uses share_plus which will show WhatsApp in the share sheet
    await shareInviteLink(invite);
  }
  
  /// Mark invite as used
  Future<void> markInviteUsed(String token, String usedByUserId) async {
    final query = await _firestore
        .collection('invites')
        .where('token', isEqualTo: token)
        .limit(1)
        .get();
    
    if (query.docs.isNotEmpty) {
      await query.docs.first.reference.update({
        'usedBy': FieldValue.arrayUnion([usedByUserId]),
        'lastUsedAt': FieldValue.serverTimestamp(),
      });
    }
  }
  
  /// Get invite stats for analytics
  Future<Map<String, dynamic>> getInviteStats(String roomId) async {
    final query = await _firestore
        .collection('invites')
        .where('roomId', isEqualTo: roomId)
        .get();
    
    int totalInvites = query.docs.length;
    int totalUses = 0;
    
    for (final doc in query.docs) {
      final usedBy = doc.data()['usedBy'] as List?;
      totalUses += usedBy?.length ?? 0;
    }
    
    return {
      'totalInvites': totalInvites,
      'totalUses': totalUses,
      'conversionRate': totalInvites > 0 ? totalUses / totalInvites : 0,
    };
  }
  
  String _sign(String data) {
    final hmac = Hmac(sha256, utf8.encode(_signingSecret));
    final digest = hmac.convert(utf8.encode(data));
    return base64Url.encode(digest.bytes);
  }
  
  String _getGameDisplayName(String gameType) {
    switch (gameType) {
      case 'marriage':
        return 'Marriage';
      case 'call_break':
        return 'Call Break';
      case 'teen_patti':
        return 'Teen Patti';
      case 'rummy':
        return 'Rummy';
      default:
        return gameType;
    }
  }
}
