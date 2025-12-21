import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:clubroyale/features/landing/widgets/hero_section.dart';
import 'package:clubroyale/features/landing/widgets/game_showcase_section.dart';
import 'package:clubroyale/features/landing/widgets/ai_rivals_section.dart';

/// Landing Page - World-Class First Impression
/// 
/// A premium, cinematic landing experience that showcases:
/// - The ClubRoyale brand and value proposition
/// - All 4 games with live stats
/// - 5 AI bot personalities
/// - Premium CTAs driving to gameplay
class LandingPage extends ConsumerWidget {
  const LandingPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: const Color(0xFF051A12),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          children: const [
            // 1. Hero Section - "The Royal Table"
            HeroSection(),
            
            // 2. Game Showcase - "The Four Pillars"
            GameShowcaseSection(),
            
            // 3. AI Rivals - "Meet Your Rivals"
            AIRivalsSection(),
            
            // 4. Footer
            _FooterSection(),
          ],
        ),
      ),
    );
  }
}

/// Footer Section with social links and legal
class _FooterSection extends StatelessWidget {
  const _FooterSection();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 48),
      decoration: const BoxDecoration(
        color: Color(0xFF030D08),
        border: Border(
          top: BorderSide(color: Color(0xFFD4AF37), width: 0.5),
        ),
      ),
      child: Column(
        children: [
          // Brand Name
          ShaderMask(
            shaderCallback: (bounds) => const LinearGradient(
              colors: [Color(0xFFD4AF37), Color(0xFFF7E7CE), Color(0xFFD4AF37)],
            ).createShader(bounds),
            child: const Text(
              'CLUBROYALE',
              style: TextStyle(
                fontFamily: 'Oswald',
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white,
                letterSpacing: 4,
              ),
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Tagline
          Text(
            'Where Legends Play',
            style: TextStyle(
              fontSize: 14,
              color: Colors.white.withOpacity(0.5),
              fontStyle: FontStyle.italic,
            ),
          ),
          
          const SizedBox(height: 24),
          
          // Social Links
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _SocialIcon(Icons.discord, onTap: () {}),
              _SocialIcon(Icons.telegram, onTap: () {}),
              _SocialIcon(Icons.email_outlined, onTap: () {}),
            ],
          ),
          
          const SizedBox(height: 32),
          
          // Legal Links
          Wrap(
            spacing: 24,
            runSpacing: 8,
            alignment: WrapAlignment.center,
            children: [
              _FooterLink('Privacy', onTap: () {}),
              _FooterLink('Terms', onTap: () {}),
              _FooterLink('Support', onTap: () {}),
              _FooterLink('FAQ', onTap: () {}),
            ],
          ),
          
          const SizedBox(height: 24),
          
          // Copyright
          Text(
            '© 2025 ClubRoyale. All rights reserved.',
            style: TextStyle(
              fontSize: 12,
              color: Colors.white.withOpacity(0.3),
            ),
          ),
        ],
      ),
    );
  }
}

class _SocialIcon extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  
  const _SocialIcon(this.icon, {required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: IconButton(
        onPressed: onTap,
        icon: Icon(icon, color: const Color(0xFFD4AF37), size: 28),
        style: IconButton.styleFrom(
          backgroundColor: const Color(0xFFD4AF37).withOpacity(0.1),
          shape: const CircleBorder(),
          padding: const EdgeInsets.all(12),
        ),
      ),
    );
  }
}

class _FooterLink extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  
  const _FooterLink(this.label, {required this.onTap});

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: onTap,
      child: Text(
        label,
        style: TextStyle(
          color: Colors.white.withOpacity(0.5),
          fontSize: 13,
        ),
      ),
    );
  }
}
