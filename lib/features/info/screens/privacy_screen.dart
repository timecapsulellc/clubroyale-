import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:clubroyale/core/theme/multi_theme.dart';

/// Privacy Policy Screen
class PrivacyScreen extends ConsumerWidget {
  const PrivacyScreen({super.key});

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
          'Privacy Policy',
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
            
            // Privacy Sections
            _buildSection(
              '1. Introduction',
              'TimeCapsule LLC ("we," "us," or "our") operates ClubRoyale. This Privacy Policy '
              'describes how we collect, use, and protect your information when you use our app.',
              themeColors,
            ),
            
            _buildSection(
              '2. Information We Collect',
              '**Account Information:**\n'
              '• Email address (for authentication)\n'
              '• Display name (optional)\n'
              '• Profile picture (optional)\n\n'
              '**Gameplay Data:**\n'
              '• Game statistics and scores\n'
              '• Diamond balance and transactions\n'
              '• Room participation history\n\n'
              '**Technical Data:**\n'
              '• Device information\n'
              '• App version and performance data\n'
              '• Crash reports (via Firebase Crashlytics)',
              themeColors,
            ),
            
            _buildSection(
              '3. How We Use Your Information',
              'We use your data to:\n\n'
              '• Provide and improve our services\n'
              '• Enable multiplayer gameplay\n'
              '• Track your game progress and statistics\n'
              '• Send important service notifications\n'
              '• Analyze app performance and fix bugs\n'
              '• Detect and prevent cheating/fraud',
              themeColors,
            ),
            
            _buildSection(
              '4. Data Sharing',
              'We do NOT sell your personal data. We may share data with:\n\n'
              '• **Firebase (Google):** Authentication, database, analytics\n'
              '• **Crashlytics:** Crash reporting\n'
              '• **Law Enforcement:** Only when legally required\n\n'
              'Other players can only see your display name and game statistics.',
              themeColors,
            ),
            
            _buildSection(
              '5. Data Security',
              'We implement security measures including:\n\n'
              '• Encrypted data transmission (HTTPS)\n'
              '• Secure Firebase authentication\n'
              '• Server-side data validation\n'
              '• Regular security audits\n\n'
              'No system is 100% secure. Use a strong password.',
              themeColors,
            ),
            
            _buildSection(
              '6. Your Rights',
              'You have the right to:\n\n'
              '• Access your personal data\n'
              '• Correct inaccurate information\n'
              '• Delete your account and data\n'
              '• Export your data\n'
              '• Opt-out of analytics\n\n'
              'Contact us at privacy@clubroyale.app to exercise these rights.',
              themeColors,
            ),
            
            _buildSection(
              '7. Cookies & Storage',
              'We use local storage and cookies for:\n\n'
              '• Keeping you logged in\n'
              '• Storing your theme preferences\n'
              '• Remembering game settings\n\n'
              'You can clear this data in your browser/device settings.',
              themeColors,
            ),
            
            _buildSection(
              '8. Children\'s Privacy',
              'ClubRoyale is intended for users 18 years and older. We do not knowingly '
              'collect data from minors. If you believe a child has provided data, contact us.',
              themeColors,
            ),
            
            _buildSection(
              '9. Third-Party Services',
              'Our app uses third-party services with their own privacy policies:\n\n'
              '• Google Firebase\n'
              '• Google AdMob (ads)\n'
              '• RevenueCat (purchases)\n'
              '• LiveKit (video chat)\n\n'
              'Please review their policies for more information.',
              themeColors,
            ),
            
            _buildSection(
              '10. Changes to Policy',
              'We may update this policy periodically. Significant changes will be notified '
              'via in-app notification. Continued use after changes constitutes acceptance.',
              themeColors,
            ),
            
            _buildSection(
              '11. Contact Us',
              'For privacy questions or concerns:\n\n'
              '📧 Email: privacy@clubroyale.app\n'
              '🏢 TimeCapsule LLC\n'
              '📍 Bengaluru, India',
              themeColors,
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
          Icon(Icons.privacy_tip, size: 48, color: themeColors.gold),
          const SizedBox(height: 12),
          Text(
            'Privacy Policy',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: themeColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Your privacy is important to us',
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
  
  Widget _buildSection(String title, String content, ThemeColors themeColors) {
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
