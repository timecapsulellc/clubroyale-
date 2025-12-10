import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:clubroyale/core/theme/multi_theme.dart';

/// Terms and Conditions Screen
class TermsScreen extends ConsumerWidget {
  const TermsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeColors = ref.watch(themeColorsProvider);
    
    return Scaffold(
      backgroundColor: themeColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => context.pop(),
        ),
        title: Text(
          'Terms & Conditions',
          style: TextStyle(color: themeColors.gold, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: Container(
        decoration: BoxDecoration(gradient: themeColors.primaryGradient),
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Header
            _buildHeader(themeColors),
            const SizedBox(height: 24),
            
            // Last updated
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: themeColors.gold.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(Icons.update, color: themeColors.gold, size: 18),
                  const SizedBox(width: 8),
                  Text(
                    'Last Updated: December 11, 2025',
                    style: TextStyle(color: themeColors.gold),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            
            // Terms Sections
            _buildTermsSection(
              '1. Acceptance of Terms',
              'By accessing and using ClubRoyale ("the App"), you acknowledge that you have read, '
              'understood, and agree to be bound by these Terms of Service. If you do not agree '
              'to these terms, please do not use the App.',
              themeColors,
            ),
            
            _buildTermsSection(
              '2. Age Requirement',
              'You must be 18 years of age or older to use ClubRoyale. By using the App, you '
              'confirm that you are at least 18 years old. The card games offered are for '
              'entertainment purposes only and do not involve real money gambling.',
              themeColors,
            ),
            
            _buildTermsSection(
              '3. Nature of the Service',
              'ClubRoyale is a **social card game platform** for entertainment. Key points:\n\n'
              '• The App functions as a **calculator/scorekeeper** for card games\n'
              '• **No real money** is wagered, won, or lost within the App\n'
              '• Virtual currency ("Diamonds") has **no real-world monetary value**\n'
              '• Settlement features are for **informational purposes only**\n'
              '• Any actual monetary transactions between users occur **outside the App**',
              themeColors,
            ),
            
            _buildTermsSection(
              '4. Virtual Currency (Diamonds)',
              'Diamonds are virtual items used within the App:\n\n'
              '• Diamonds can be earned through gameplay, daily bonuses, and referrals\n'
              '• Diamonds may optionally be purchased via in-app purchases\n'
              '• Diamonds have **no cash value** and cannot be exchanged for real money\n'
              '• Diamonds are non-refundable and non-transferable outside the App\n'
              '• We reserve the right to modify Diamond pricing and availability',
              themeColors,
            ),
            
            _buildTermsSection(
              '5. User Conduct',
              'Users agree NOT to:\n\n'
              '• Use the App for any illegal gambling activities\n'
              '• Engage in harassment, abuse, or hate speech\n'
              '• Attempt to cheat, exploit, or manipulate game outcomes\n'
              '• Share inappropriate content in chat features\n'
              '• Impersonate other users or entities\n'
              '• Use automated tools or bots (unauthorized)\n'
              '• Violate any applicable local, state, or national laws',
              themeColors,
            ),
            
            _buildTermsSection(
              '6. Account Termination',
              'We reserve the right to suspend or terminate accounts that:\n\n'
              '• Violate these Terms of Service\n'
              '• Engage in fraudulent or abusive behavior\n'
              '• Attempt to exploit or hack the platform\n'
              '• Are involved in real-money gambling using our settlement features',
              themeColors,
            ),
            
            _buildTermsSection(
              '7. Intellectual Property',
              'All content, graphics, code, and trademarks within ClubRoyale are the '
              'property of TimeCapsule LLC. Users may not:\n\n'
              '• Copy, modify, or distribute App content without permission\n'
              '• Use our branding for commercial purposes\n'
              '• Reverse engineer the application',
              themeColors,
            ),
            
            _buildTermsSection(
              '8. Privacy',
              'Your privacy is important to us. Please review our Privacy Policy to '
              'understand how we collect, use, and protect your information. By using '
              'the App, you consent to our data practices as described in the Privacy Policy.',
              themeColors,
            ),
            
            _buildTermsSection(
              '9. Disclaimer of Warranties',
              'THE APP IS PROVIDED "AS IS" WITHOUT WARRANTIES OF ANY KIND. We do not guarantee:\n\n'
              '• Uninterrupted or error-free service\n'
              '• Accuracy of game outcomes or calculations\n'
              '• Compatibility with all devices\n'
              '• Preservation of user data in case of system failure',
              themeColors,
            ),
            
            _buildTermsSection(
              '10. Limitation of Liability',
              'TimeCapsule LLC shall not be liable for:\n\n'
              '• Any indirect, incidental, or consequential damages\n'
              '• Loss of data, profits, or goodwill\n'
              '• Any monetary losses from external transactions\n'
              '• Third-party actions or content',
              themeColors,
            ),
            
            _buildTermsSection(
              '11. Modifications',
              'We may update these Terms at any time. Continued use of the App after '
              'changes constitutes acceptance of the new Terms. We will notify users of '
              'significant changes via in-app notifications.',
              themeColors,
            ),
            
            _buildTermsSection(
              '12. Governing Law',
              'These Terms are governed by the laws of India. Any disputes shall be '
              'resolved in the courts of Bengaluru, Karnataka.',
              themeColors,
            ),
            
            _buildTermsSection(
              '13. Contact',
              'For questions or concerns about these Terms:\n\n'
              '📧 Email: legal@clubroyale.app\n'
              '🏢 TimeCapsule LLC\n'
              '📍 Bengaluru, India',
              themeColors,
            ),
            
            const SizedBox(height: 32),
            
            // Agreement note
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: themeColors.surface.withOpacity(0.5),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: themeColors.gold.withOpacity(0.3)),
              ),
              child: Row(
                children: [
                  Icon(Icons.check_circle, color: themeColors.gold),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'By using ClubRoyale, you agree to these Terms & Conditions.',
                      style: TextStyle(color: themeColors.textPrimary),
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
  
  Widget _buildHeader(ThemeColors themeColors) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: themeColors.surface.withOpacity(0.5),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: themeColors.gold.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Icon(Icons.description, size: 48, color: themeColors.gold),
          const SizedBox(height: 12),
          Text(
            'Terms & Conditions',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: themeColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Please read these terms carefully before using ClubRoyale',
            style: TextStyle(
              color: themeColors.textSecondary,
              fontSize: 14,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
  
  Widget _buildTermsSection(String title, String content, ThemeColors themeColors) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: themeColors.surface.withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: themeColors.gold,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            content,
            style: TextStyle(
              color: themeColors.textPrimary,
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }
}
