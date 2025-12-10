// Settlement Share Service
//
// Shares game settlement to WhatsApp with viral growth link.
// This is the CORE viral feature - settlement includes app link!

import 'package:share_plus/share_plus.dart';
import 'package:taasclub/core/constants/disclaimers.dart';

/// Settlement data for sharing
class SettlementData {
  final String gameType;
  final String roomCode;
  final String hostName;
  final Map<String, int> finalScores;
  final Map<String, int> debts; // "PlayerA → PlayerB": amount
  final int pointValue; // Points per unit (e.g., 1 point = ₹1)
  final DateTime gameEndTime;

  SettlementData({
    required this.gameType,
    required this.roomCode,
    required this.hostName,
    required this.finalScores,
    required this.debts,
    this.pointValue = 1,
    DateTime? gameEndTime,
  }) : gameEndTime = gameEndTime ?? DateTime.now();
}

/// Settlement Share Service with WhatsApp viral loop
class SettlementShareService {
  
  /// Share settlement to WhatsApp (or other apps)
  static Future<void> shareSettlement(SettlementData data) async {
    final message = _buildSettlementMessage(data);
    await Share.share(message, subject: 'ClubRoyale Game Settlement');
  }

  /// Build the viral settlement message
  static String _buildSettlementMessage(SettlementData data) {
    final buffer = StringBuffer();
    
    // Header
    buffer.writeln('🎴 ${_getGameName(data.gameType)} Game Results');
    buffer.writeln('📍 Room: ${data.roomCode}');
    buffer.writeln('👤 Host: ${data.hostName}');
    buffer.writeln('${'─' * 28}');
    buffer.writeln();
    
    // Scores (sorted by rank)
    buffer.writeln('📊 FINAL SCORES:');
    final sortedScores = data.finalScores.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    
    for (var i = 0; i < sortedScores.length; i++) {
      final entry = sortedScores[i];
      final medal = _getMedal(i);
      buffer.writeln('$medal ${entry.key}: ${entry.value} pts');
    }
    buffer.writeln();
    
    // Settlement (who owes whom)
    if (data.debts.isNotEmpty) {
      buffer.writeln('💰 SETTLEMENT:');
      for (final debt in data.debts.entries) {
        final parts = debt.key.split(' → ');
        if (parts.length == 2) {
          final value = debt.value * data.pointValue;
          buffer.writeln('• ${parts[0]} owes ${parts[1]}: $value pts');
        }
      }
      buffer.writeln();
    }
    
    // Disclaimer
    buffer.writeln('${'─' * 28}');
    buffer.writeln('ℹ️ This is a score summary only.');
    buffer.writeln('Players settle privately outside the app.');
    buffer.writeln();
    
    // VIRAL CTA - This is the growth loop!
    buffer.writeln('🎮 Play free at: taasclub.app');
    buffer.writeln('📲 No install needed - works in browser!');
    
    return buffer.toString();
  }

  /// Share invite to join a new game (pre-game viral loop)
  static Future<void> shareGameInvite({
    required String roomCode,
    required String hostName,
    required String gameType,
  }) async {
    final message = '''
🎴 Join my ${_getGameName(gameType)} game on ClubRoyale!

📍 Room Code: $roomCode
👤 Host: $hostName

👉 Join now: https://taasclub.app/join?room=$roomCode

📲 No download needed - play in your browser!

${Disclaimers.shareFooter}
''';
    
    await Share.share(message, subject: 'Join my ClubRoyale game!');
  }

  /// Quick share room code only
  static Future<void> shareRoomCode(String roomCode) async {
    final message = '''
Join my game on ClubRoyale!

🎴 Room Code: $roomCode
🔗 https://taasclub.app/join?room=$roomCode

${Disclaimers.shareFooter}
''';
    
    await Share.share(message);
  }

  /// Share referral link for diamond rewards
  static Future<void> shareReferralLink(String userId) async {
    final refCode = userId.substring(0, 8).toUpperCase();
    final message = '''
🎴 Play card games with me on ClubRoyale!

I'm playing Marriage & Call Break online with friends.
Join me and we both get free diamonds! 💎

🔗 https://taasclub.app/join?ref=$refCode

📲 Free to play, no install needed!

${Disclaimers.shareFooter}
''';
    
    await Share.share(message, subject: 'Join me on ClubRoyale!');
  }

  // Helper methods
  
  static String _getGameName(String gameType) {
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
        return 'Card Game';
    }
  }

  static String _getMedal(int rank) {
    switch (rank) {
      case 0:
        return '🥇';
      case 1:
        return '🥈';
      case 2:
        return '🥉';
      default:
        return '  ${rank + 1}.';
    }
  }

  /// Format settlement for copying
  static String formatForCopy(SettlementData data) {
    return _buildSettlementMessage(data);
  }
}
