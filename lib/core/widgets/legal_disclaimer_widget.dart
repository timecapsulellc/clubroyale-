/// Legal Disclaimer Widgets
/// 
/// Reusable disclaimer components for app store compliance.
/// Diamonds are entertainment tokens with no cash value.
library;

import 'package:flutter/material.dart';
import 'package:clubroyale/core/constants/disclaimers.dart';

/// Disclaimer banner types
enum DisclaimerType {
  wallet,
  store,
  game,
  loading,
  settlement,
}

/// Compact disclaimer banner for screens
class LegalDisclaimerBanner extends StatelessWidget {
  final DisclaimerType type;
  final bool expanded;
  
  const LegalDisclaimerBanner({
    super.key,
    required this.type,
    this.expanded = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        border: Border(
          bottom: BorderSide(color: Colors.blue.shade100),
        ),
      ),
      child: Row(
        children: [
          Icon(Icons.info_outline, size: 16, color: Colors.blue.shade700),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              _getMessage(),
              style: TextStyle(
                fontSize: 11,
                color: Colors.blue.shade700,
                height: 1.3,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _getMessage() {
    switch (type) {
      case DisclaimerType.wallet:
        return Disclaimers.walletDisclaimer;
      case DisclaimerType.store:
        return Disclaimers.storeDisclaimer;
      case DisclaimerType.game:
        return Disclaimers.skillGameDisclaimer;
      case DisclaimerType.loading:
        return Disclaimers.loadingDisclaimer;
      case DisclaimerType.settlement:
        return Disclaimers.shortSettlementDisclaimer;
    }
  }
}

/// Full-screen entertainment disclaimer overlay
class EntertainmentNotice extends StatelessWidget {
  final VoidCallback onAccept;
  
  const EntertainmentNotice({
    super.key,
    required this.onAccept,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black87,
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.diamond, size: 64, color: Colors.amber),
          const SizedBox(height: 24),
          const Text(
            'Entertainment Tokens',
            style: TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            Disclaimers.entertainmentTokenNotice,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.8),
              fontSize: 14,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 32),
          FilledButton(
            onPressed: onAccept,
            style: FilledButton.styleFrom(
              backgroundColor: Colors.amber,
              foregroundColor: Colors.black,
              padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 16),
            ),
            child: const Text('I Understand'),
          ),
        ],
      ),
    );
  }
}

/// Inline disclaimer text for forms/dialogs
class DisclaimerText extends StatelessWidget {
  final String text;
  
  const DisclaimerText({
    super.key,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.info, size: 16, color: Colors.grey.shade600),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 11,
                color: Colors.grey.shade700,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
