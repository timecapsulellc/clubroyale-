import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:taasclub/core/config/club_royale_theme.dart';
import 'package:taasclub/features/settings/widgets/terminology_toggle.dart';

/// Settings Screen
/// 
/// App-wide settings including game terminology, notifications, and account
class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: ClubRoyaleTheme.deepPurple,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => context.pop(),
        ),
        title: const Text('Settings', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: Container(
        decoration: const BoxDecoration(gradient: ClubRoyaleTheme.royalGradient),
        child: ListView(
          children: [
            const SizedBox(height: 16),
            
            // Game Section Header
            _buildSectionHeader('Game'),
            
            // Terminology Toggle
            TerminologyToggle(
              onChanged: () {
                // Force rebuild when terminology changes
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Terminology updated! Restart the game for full effect.'),
                    duration: Duration(seconds: 2),
                  ),
                );
              },
            ),
            
            const SizedBox(height: 24),
            
            // Account Section Header
            _buildSectionHeader('Account'),
            
            // Profile Settings
            _buildListTile(
              icon: Icons.person,
              title: 'Edit Profile',
              subtitle: 'Change display name and avatar',
              onTap: () => context.push('/profile'),
            ),
            
            // Wallet
            _buildListTile(
              icon: Icons.account_balance_wallet,
              title: 'Wallet',
              subtitle: 'Manage diamonds and transactions',
              onTap: () => context.push('/wallet'),
            ),
            
            const SizedBox(height: 24),
            
            // App Section Header
            _buildSectionHeader('App'),
            
            // Notifications
            _buildListTile(
              icon: Icons.notifications,
              title: 'Notifications',
              subtitle: 'Game invites, friend requests',
              onTap: () {
                // TODO: Notifications settings
              },
            ),
            
            // About
            _buildListTile(
              icon: Icons.info,
              title: 'About ClubRoyale',
              subtitle: 'Version 1.0.0',
              onTap: () {
                showAboutDialog(
                  context: context,
                  applicationName: 'ClubRoyale',
                  applicationVersion: '1.0.0',
                  applicationLegalese: '© 2025 TaasClub',
                  children: [
                    const SizedBox(height: 16),
                    const Text('Your Private Card Club - The Ultimate Card Experience'),
                  ],
                );
              },
            ),
            
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
  
  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      child: Text(
        title.toUpperCase(),
        style: const TextStyle(
          color: ClubRoyaleTheme.gold,
          fontSize: 12,
          fontWeight: FontWeight.bold,
          letterSpacing: 1.5,
        ),
      ),
    );
  }
  
  Widget _buildListTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        leading: Icon(icon, color: ClubRoyaleTheme.gold),
        title: Text(title, style: const TextStyle(color: Colors.white)),
        subtitle: Text(subtitle, style: TextStyle(color: Colors.white.withValues(alpha: 0.6), fontSize: 12)),
        trailing: const Icon(Icons.chevron_right, color: Colors.white54),
        onTap: onTap,
      ),
    );
  }
}
