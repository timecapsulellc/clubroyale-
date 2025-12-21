// Onboarding Screen - First-run experience for new users
//
// Premium casino-themed welcome flow introducing:
// - ClubRoyale brand and games
// - Diamond economy
// - Social features

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:clubroyale/config/casino_theme.dart';
import 'package:clubroyale/config/visual_effects.dart';
import 'package:clubroyale/core/services/sound_service.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  
  final List<OnboardingPage> _pages = [
    OnboardingPage(
      icon: Icons.favorite,
      title: 'Welcome to ClubRoyale',
      subtitle: 'Play & Connect',
      description: 'Your social club for classic card games, live chats, voice rooms, and making friends who share your passion.',
      color: CasinoColors.gold,
    ),
    OnboardingPage(
      icon: Icons.people_alt,
      title: 'Connect with Friends',
      subtitle: 'Chat • Stories • Activity Feed',
      description: 'See who\'s online, share game highlights to your story, react to friends\' wins, and stay connected 24/7.',
      color: Colors.pinkAccent,
    ),
    OnboardingPage(
      icon: Icons.mic,
      title: 'Live Voice Rooms & Clubs',
      subtitle: 'Talk • Play Together • Join Communities',
      description: 'Drop into voice rooms, join exclusive clubs, and find your tribe of card game lovers.',
      color: Colors.purpleAccent,
    ),
    OnboardingPage(
      icon: Icons.style,
      title: 'Premium Card Games',
      subtitle: 'Marriage • Call Break • Teen Patti • In-Between',
      description: 'Play world-class games with stunning animations. No real money needed – earn free diamonds daily!',
      color: Colors.cyanAccent,
    ),
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _completeOnboarding() async {
    HapticFeedback.heavyImpact();
    SoundService.playRoundEnd();
    
    // Mark onboarding as complete
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('onboarding_complete', true);
    
    if (mounted) {
      context.go('/');
    }
  }

  void _nextPage() {
    HapticFeedback.lightImpact();
    SoundService.playCardSlide();
    
    if (_currentPage < _pages.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeOutCubic,
      );
    } else {
      _completeOnboarding();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: CasinoColors.deepPurple,
      body: ParticleBackground(
        primaryColor: CasinoColors.gold,
        secondaryColor: CasinoColors.richPurple,
        particleCount: 30,
        child: SafeArea(
          child: Column(
            children: [
              // Skip button
              Align(
                alignment: Alignment.topRight,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: TextButton(
                    onPressed: _completeOnboarding,
                    child: const Text(
                      'Skip',
                      style: TextStyle(color: Colors.white54, fontSize: 16),
                    ),
                  ),
                ),
              ),
              
              // Page content
              Expanded(
                child: PageView.builder(
                  controller: _pageController,
                  itemCount: _pages.length,
                  onPageChanged: (index) {
                    setState(() => _currentPage = index);
                    HapticFeedback.selectionClick();
                  },
                  itemBuilder: (context, index) {
                    return _buildPage(_pages[index]);
                  },
                ),
              ),
              
              // Page indicators
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 24),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(_pages.length, (index) {
                    final isActive = index == _currentPage;
                    return AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      width: isActive ? 24 : 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: isActive ? CasinoColors.gold : Colors.white24,
                        borderRadius: BorderRadius.circular(4),
                        boxShadow: isActive ? [
                          BoxShadow(
                            color: CasinoColors.gold.withValues(alpha: 0.5),
                            blurRadius: 8,
                          ),
                        ] : null,
                      ),
                    );
                  }),
                ),
              ),
              
              // Next/Get Started button
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 0, 24, 32),
                child: GestureDetector(
                  onTap: _nextPage,
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 18),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [CasinoColors.gold, Colors.orange],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: CasinoColors.gold.withValues(alpha: 0.4),
                          blurRadius: 12,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          _currentPage == _pages.length - 1 ? 'Get Started' : 'Next',
                          style: const TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Icon(
                          _currentPage == _pages.length - 1 
                              ? Icons.rocket_launch 
                              : Icons.arrow_forward,
                          color: Colors.black,
                        ),
                      ],
                    ),
                  ),
                ).animate(onPlay: (c) => c.repeat(reverse: true))
                  .shimmer(delay: 3.seconds, duration: 2.seconds),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPage(OnboardingPage page) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Icon with glow
          Container(
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.black.withValues(alpha: 0.3),
              boxShadow: [
                BoxShadow(
                  color: page.color.withValues(alpha: 0.3),
                  blurRadius: 40,
                  spreadRadius: 10,
                ),
              ],
            ),
            child: Icon(
              page.icon,
              size: 80,
              color: page.color,
            ),
          )
          .animate()
          .scale(delay: 200.ms, duration: 400.ms, curve: Curves.easeOutBack)
          .fadeIn()
          .animate(onPlay: (c) => c.repeat(reverse: true))
          .moveY(begin: 0, end: -10, duration: 2.seconds, curve: Curves.easeInOutSine),
          
          const SizedBox(height: 48),
          
          // Title
          Text(
            page.title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 28,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.2,
            ),
            textAlign: TextAlign.center,
          ).animate().fadeIn(delay: 300.ms).slideY(begin: 0.2),
          
          const SizedBox(height: 12),
          
          // Subtitle
          Text(
            page.subtitle,
            style: TextStyle(
              color: page.color,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.center,
          ).animate().fadeIn(delay: 400.ms),
          
          const SizedBox(height: 24),
          
          // Description
          Text(
            page.description,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 16,
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ).animate().fadeIn(delay: 500.ms),
        ],
      ),
    );
  }
}

class OnboardingPage {
  final IconData icon;
  final String title;
  final String subtitle;
  final String description;
  final Color color;

  const OnboardingPage({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.description,
    required this.color,
  });
}
