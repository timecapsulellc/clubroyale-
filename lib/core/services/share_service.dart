import 'package:share_plus/share_plus.dart';
import 'package:flutter/material.dart';

/// Service for sharing content across social platforms
class ShareService {
  /// Share referral code with custom message
  static Future<void> shareReferralCode(
    String referralCode, {
    required BuildContext context,
  }) async {
    final shareText = '''
🎮 Join me on TaasClub - The Ultimate Card Gaming App! 🎮

Use my referral code: $referralCode

✨ You get 50 FREE diamonds on signup!
✨ Play Marriage, Teen Patti, Call Break & more
✨ Real-time multiplayer with voice chat
✨ Win diamonds and climb the leaderboard

Download now: https://taasclub.app

See you at the tables! 🃏
''';

    try {
      final result = await Share.shareWithResult(
        shareText,
        subject: 'Join me on TaasClub!',
      );

      if (result.status == ShareResultStatus.success && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Invite shared successfully! 🎉'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to share: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  /// Share game room invite
  static Future<void> shareGameRoomCode(
    String roomCode,
    String gameName, {
    required BuildContext context,
  }) async {
    final shareText = '''
🎮 Join my $gameName game on TaasClub! 🎮

Room Code: $roomCode

Quick join:
1. Open TaasClub app
2. Tap "Join Room"
3. Enter code: $roomCode

Don't have the app? Download: https://taasclub.app

Let's play! 🃏
''';

    try {
      final result = await Share.shareWithResult(
        shareText,
        subject: 'Join my $gameName game!',
      );

      if (result.status == ShareResultStatus.success && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Invite sent! 🚀'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to share: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  /// Share app download link
  static Future<void> shareAppDownload({
    required BuildContext context,
    String? customMessage,
  }) async {
    final shareText = customMessage ??
        '''
🎮 Check out TaasClub - Best Card Gaming App! 🎮

✨ Free diamonds on signup
✨ Real-time multiplayer
✨ Popular card games: Marriage, Teen Patti, Call Break
✨ Voice chat while playing
✨ Win tournaments & prizes

Download: https://taasclub.app

Join thousands of players! 🃏
''';

    try {
      await Share.share(shareText, subject: 'TaasClub - Card Gaming App');
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to share: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  /// Share with file attachment (for screenshots, etc.)
  static Future<void> shareWithFile(
    String text,
    XFile file, {
    required BuildContext context,
  }) async {
    try {
      await Share.shareXFiles(
        [file],
        text: text,
        subject: 'TaasClub',
      );
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to share: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}
