import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:clubroyale/config/casino_theme.dart';

class ClubRoyaleSplashScreen extends StatefulWidget {
  const ClubRoyaleSplashScreen({super.key});

  @override
  State<ClubRoyaleSplashScreen> createState() => _ClubRoyaleSplashScreenState();
}

class _ClubRoyaleSplashScreenState extends State<ClubRoyaleSplashScreen> {
  @override
  void initState() {
    super.initState();
    _checkOnboardingAndNavigate();
  }

  Future<void> _checkOnboardingAndNavigate() async {
    // Wait for splash animation
    await Future.delayed(const Duration(seconds: 3));
    
    if (!mounted) return;
    
    // Check if onboarding is complete with timeout handling
    try {
      final prefs = await SharedPreferences.getInstance()
          .timeout(const Duration(seconds: 2), onTimeout: () {
        debugPrint('⚠️ SharedPreferences timeout - proceeding to home');
        throw TimeoutException('SharedPreferences timeout');
      });
      final onboardingComplete = prefs.getBool('onboarding_complete') ?? false;
      
      if (!mounted) return;
      
      if (onboardingComplete) {
        debugPrint('✅ Onboarding complete - navigating to home');
        context.go('/');
      } else {
        debugPrint('📱 First launch - showing onboarding');
        context.go('/onboarding');
      }
    } catch (e) {
      // On any error, go to home (AuthGate will handle auth state)
      debugPrint('⚠️ Splash navigation error: $e - defaulting to home');
      if (mounted) {
        context.go('/');
      }
    }
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: CasinoColors.deepPurple,
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              CasinoColors.darkPurple,
              CasinoColors.deepPurple,
            ],
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Logo icon - using Icon-192 (clean logo)
              Image.asset(
                'assets/images/logo.png',
                width: 100,
                height: 100,
                fit: BoxFit.contain,
              ).animate()
                .fadeIn(duration: 600.ms)
                .scale(begin: const Offset(0.8, 0.8), curve: Curves.easeOutBack),
              
              const SizedBox(height: 24),
              
              // Brand name - Gold text
              Text(
                'ClubRoyale',
                style: TextStyle(
                  color: CasinoColors.gold,
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.5,
                ),
              ).animate(delay: 300.ms).fadeIn().slideY(begin: 0.2),
              
              const SizedBox(height: 48),
              
              // Loading Indicator - Gold themed
              SizedBox(
                width: 36,
                height: 36,
                child: CircularProgressIndicator(
                  color: CasinoColors.gold.withValues(alpha: 0.7),
                  strokeWidth: 3,
                ),
              ).animate(delay: 500.ms).fadeIn(),
            ],
          ),
        ),
      ),
    );
  }
}
