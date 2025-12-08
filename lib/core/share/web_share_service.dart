// Web Share Service
//
// Uses Web Share API for native sharing with fallbacks.

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';

/// Share result status
enum ShareResult {
  success,
  dismissed,
  unavailable,
  copied,
}

/// Web Share Service
class WebShareService {
  
  /// Share text content
  static Future<ShareResult> shareText({
    required String text,
    String? subject,
  }) async {
    try {
      if (kIsWeb) {
        // Use share_plus which handles Web Share API
        await Share.share(text, subject: subject);
        return ShareResult.success;
      } else {
        await Share.share(text, subject: subject);
        return ShareResult.success;
      }
    } catch (e) {
      debugPrint('Share error: $e');
      // Fallback to clipboard
      await copyToClipboard(text);
      return ShareResult.copied;
    }
  }

  /// Share URL
  static Future<ShareResult> shareUrl({
    required String url,
    String? title,
    String? text,
  }) async {
    try {
      final content = text != null ? '$text\n$url' : url;
      await Share.share(content, subject: title);
      return ShareResult.success;
    } catch (e) {
      debugPrint('Share URL error: $e');
      await copyToClipboard(url);
      return ShareResult.copied;
    }
  }

  /// Share invite link
  static Future<ShareResult> shareInvite({
    required String roomCode,
    required String inviteUrl,
    required String hostName,
    required String gameType,
  }) async {
    final gameDisplayName = _getGameDisplayName(gameType);
    
    final message = '''
🎴 Join my $gameDisplayName game on TaasClub!

📍 Room Code: $roomCode
👤 Host: $hostName

👉 Click to join: $inviteUrl

Or open TaasClub and enter the room code!
''';

    return shareText(text: message, subject: 'Join my TaasClub game!');
  }

  /// Share game settlement
  static Future<ShareResult> shareSettlement({
    required String gameType,
    required String summary,
    required Map<String, int> scores,
  }) async {
    final gameDisplayName = _getGameDisplayName(gameType);
    
    final buffer = StringBuffer();
    buffer.writeln('🎴 $gameDisplayName Game Results');
    buffer.writeln('${'─' * 20}');
    
    // Sort by score
    final sortedScores = scores.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    
    for (var i = 0; i < sortedScores.length; i++) {
      final entry = sortedScores[i];
      final medal = i == 0 ? '🥇' : i == 1 ? '🥈' : i == 2 ? '🥉' : '  ';
      buffer.writeln('$medal ${entry.key}: ${entry.value} pts');
    }
    
    buffer.writeln('${'─' * 20}');
    buffer.writeln(summary);
    buffer.writeln();
    buffer.writeln('Play at: taasclub.app');
    
    return shareText(
      text: buffer.toString(),
      subject: '$gameDisplayName Game Results',
    );
  }

  /// Copy text to clipboard
  static Future<void> copyToClipboard(String text) async {
    await Clipboard.setData(ClipboardData(text: text));
  }

  /// Copy room code with visual feedback
  static Future<void> copyRoomCode(String code) async {
    await copyToClipboard(code);
  }

  static String _getGameDisplayName(String gameType) {
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

  /// Check if Web Share API is available
  static bool get isShareAvailable {
    // share_plus handles this internally
    return true;
  }
}
