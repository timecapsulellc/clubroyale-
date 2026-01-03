/// Contact Admin Screen
///
/// Informational screen for diamond acquisition via admin channel.
/// No in-app transactions - redirects to external channels only.
library;

import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:clubroyale/core/constants/disclaimers.dart';
import 'package:clubroyale/core/widgets/legal_disclaimer_widget.dart';
import 'package:clubroyale/config/casino_theme.dart';

/// Contact admin for diamond acquisition
class ContactAdminScreen extends StatelessWidget {
  const ContactAdminScreen({super.key});

  // External contact channels (no in-app transactions)
  static const String _whatsappNumber =
      '+918000000000'; // Replace with real number
  static const String _telegramUsername = 'ClubRoyaleSupport';
  static const String _supportEmail = 'support@clubroyale.app';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: CasinoColors.darkPurple,
      appBar: AppBar(
        title: const Text('Get Diamonds'),
        backgroundColor: CasinoColors.deepPurple,
      ),
      body: Column(
        children: [
          // Compliance disclaimer
          const LegalDisclaimerBanner(type: DisclaimerType.store),

          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  // Diamond icon
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          CasinoColors.gold.withValues(alpha: 0.3),
                          Colors.amber.withValues(alpha: 0.1),
                        ],
                      ),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.diamond,
                      size: 64,
                      color: CasinoColors.gold,
                    ),
                  ),

                  const SizedBox(height: 24),

                  const Text(
                    'Diamond Acquisition',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 12),

                  Text(
                    'Contact our team through the channels below '
                    'to learn about acquiring entertainment tokens.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.7),
                      fontSize: 14,
                    ),
                  ),

                  const SizedBox(height: 32),

                  // Available packs (no prices!)
                  const Text(
                    'Available Packs',
                    style: TextStyle(
                      color: CasinoColors.gold,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),

                  _buildPackCard(
                    'Starter Pack',
                    '50 Diamonds',
                    Icons.diamond_outlined,
                  ),
                  _buildPackCard(
                    'Player Pack',
                    '100 Diamonds + 10 Bonus',
                    Icons.diamond,
                  ),
                  _buildPackCard(
                    'Pro Pack',
                    '500 Diamonds + 75 Bonus',
                    Icons.star,
                    isBest: true,
                  ),
                  _buildPackCard(
                    'Champion Pack',
                    '1000 Diamonds + 200 Bonus',
                    Icons.emoji_events,
                  ),

                  const SizedBox(height: 32),

                  // Contact channels
                  const Text(
                    'Contact Admin',
                    style: TextStyle(
                      color: CasinoColors.gold,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),

                  _buildContactButton(
                    context,
                    icon: Icons.message,
                    label: 'WhatsApp',
                    color: Colors.green,
                    onTap: () => _launchWhatsApp(),
                  ),

                  const SizedBox(height: 12),

                  _buildContactButton(
                    context,
                    icon: Icons.send,
                    label: 'Telegram',
                    color: Colors.blue,
                    onTap: () => _launchTelegram(),
                  ),

                  const SizedBox(height: 12),

                  _buildContactButton(
                    context,
                    icon: Icons.email,
                    label: 'Email Support',
                    color: Colors.orange,
                    onTap: () => _launchEmail(),
                  ),

                  const SizedBox(height: 32),

                  // Disclaimer
                  DisclaimerText(text: Disclaimers.diamondsDisclaimer),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPackCard(
    String name,
    String diamonds,
    IconData icon, {
    bool isBest = false,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: isBest
            ? Border.all(color: CasinoColors.gold, width: 2)
            : Border.all(color: Colors.white24),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isBest
                  ? CasinoColors.gold.withValues(alpha: 0.2)
                  : Colors.white12,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              icon,
              color: isBest ? CasinoColors.gold : Colors.white70,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      name,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    if (isBest) ...[
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: CasinoColors.gold,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Text(
                          'POPULAR',
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  diamonds,
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.7),
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContactButton(
    BuildContext context, {
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: onTap,
        icon: Icon(icon),
        label: Text(label),
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }

  Future<void> _launchWhatsApp() async {
    final uri = Uri.parse(
      'https://wa.me/$_whatsappNumber?text=Hi, I want to learn about ClubRoyale diamonds',
    );
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  Future<void> _launchTelegram() async {
    final uri = Uri.parse('https://t.me/$_telegramUsername');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  Future<void> _launchEmail() async {
    final uri = Uri.parse('mailto:$_supportEmail?subject=Diamond Inquiry');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }
}
