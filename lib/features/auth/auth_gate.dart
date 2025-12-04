
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'auth_screen.dart';
import '../home_screen.dart';
import 'auth_service.dart';

// Test mode flag - simple ValueNotifier for testing
class TestMode {
  static final ValueNotifier<bool> isEnabled = ValueNotifier(false);
}

class AuthGate extends ConsumerWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authService = ref.watch(authServiceProvider);

    return ValueListenableBuilder<bool>(
      valueListenable: TestMode.isEnabled,
      builder: (context, isTestMode, child) {
        // If test mode is enabled, show HomeScreen directly
        if (isTestMode) {
          return const HomeScreen();
        }

        return StreamBuilder<User?>(
          stream: authService.authStateChanges,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (snapshot.hasData) {
              return const HomeScreen();
            }

            return const AuthScreen();
          },
        );
      },
    );
  }
}


